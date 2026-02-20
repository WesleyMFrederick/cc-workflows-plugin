# DeepWiki Q&A with Code Context for Repository: thedotmack/claude-mem
## Q1
how could I modify this to use my own LLM by using gemini cli? an example module is below

---

import { exec } from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import { promisify } from "node:util";
import { fileURLToPath } from "node:url";
import { createLogger } from "./logger.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const execAsync = promisify(exec);
const logger = createLogger("gemini-cli");

class GeminiCLI {
	constructor(configPath = null) {
		this.configPath = configPath || path.resolve(__dirname, "../../config.json");
		this.config = this.loadConfig();
		this.tempFiles = new Set(); // Track temp files for cleanup
	}

	loadConfig() {
		try {
			logger.debug("Loading configuration", { path: this.configPath });
			const configContent = fs.readFileSync(this.configPath, "utf-8");
			const config = JSON.parse(configContent);

			// Apply environment variable overrides
			const overrides = {};
			if (process.env.GEMINI_MODEL) {
				config.gemini.model = process.env.GEMINI_MODEL;
				overrides.model = process.env.GEMINI_MODEL;
			}
			if (process.env.BATCH_SIZE) {
				config.processing.batchSize = parseInt(process.env.BATCH_SIZE, 10);
				overrides.batchSize = process.env.BATCH_SIZE;
			}
			if (process.env.VERBOSE) {
				config.output.verbose = process.env.VERBOSE === "true";
				overrides.verbose = process.env.VERBOSE;
			}

			if (Object.keys(overrides).length > 0) {
				logger.info("Applied environment variable overrides", overrides);
			}

			logger.debug("Configuration loaded successfully");
			return config;
		} catch (error) {
			logger.warn(
				`Failed to load config from ${this.configPath}, using defaults`,
				{ error: error.message },
			);
			console.warn(
				`Failed to load config from ${this.configPath}, using defaults:`,
				error.message,
			);
			return this.getDefaultConfig();
		}
	}

	getDefaultConfig() {
		return {
			gemini: {
				model: "gemini-2.5-flash",
				options: {
					timeout: 120000,
				},
			},
			processing: {
				batchSize: 5,
				maxRetries: 3,
				retryDelay: 5000,
				parallelProcessing: true,
			},
			output: {
				verbose: true,
				showProgress: true,
				logLevel: "info",
			},
		};
	}

	// Get current model with fallback
	getModel() {
		return this.config.gemini.model || "gemini-2.5-flash";
	}

	// Get processing configuration
	getProcessingConfig() {
		return this.config.processing;
	}

	// Build Gemini CLI command (conservative - only verified parameters)
	buildCommand(_options = {}) {
		let cmd = "gemini";

		// Add model flag to override default (which is gemini-2.5-pro)
		const model = this.getModel();
		cmd += ` -m ${model}`;

		// Available flags from --help: -m/--model, -p/--prompt, -s/--sandbox, -d/--debug, etc.
		// NOTE: --response-mime-type is NOT supported by this CLI tool

		if (this.config.output.verbose) {
			console.log("⚠️  Note: Gemini CLI has limited parameter support");
			console.log(`🔧 Using model: ${model}`);
		}

		return cmd;
	}

	// Create a unique temporary file
	createTempFile(content, prefix = "gemini-prompt") {
		const tempFileName = `${prefix}-${Date.now()}-${Math.random().toString(36).substr(2, 9)}.txt`;
		const tempFilePath = path.resolve(__dirname, `../${tempFileName}`);

		logger.fileOperation("create", tempFilePath);
		fs.writeFileSync(tempFilePath, content);
		this.tempFiles.add(tempFilePath);

		return tempFilePath;
	}

	// Clean up a specific temp file
	cleanupTempFile(filePath) {
		try {
			if (fs.existsSync(filePath)) {
				fs.unlinkSync(filePath);
				this.tempFiles.delete(filePath);
				logger.fileOperation("delete", filePath);
			}
		} catch (error) {
			logger.error(`Failed to cleanup temp file ${filePath}`, {
				error: error.message,
			});
			console.warn(`Failed to cleanup temp file ${filePath}:`, error.message);
		}
	}

	// Clean up all temp files
	cleanupAllTempFiles() {
		for (const filePath of this.tempFiles) {
			this.cleanupTempFile(filePath);
		}
	}

	// Execute a prompt with Gemini CLI
	async executePrompt(prompt, options = {}) {
		const startTime = Date.now();
		const tempFile = this.createTempFile(prompt, options.prefix);
		const maxRetries = options.maxRetries || this.config.processing.maxRetries;
		const retryDelay = options.retryDelay || this.config.processing.retryDelay;

		logger.debug("Starting Gemini CLI execution", {
			promptLength: prompt.length,
			prefix: options.prefix,
			maxRetries,
			tempFile,
		});

		let lastError;

		for (let attempt = 1; attempt <= maxRetries; attempt++) {
			try {
				const command = this.buildCommand(options);
				// Redirect stderr to /dev/null to avoid MCP server log pollution
				const fullCommand = `cat "${tempFile}" | ${command} 2>/dev/null`;

				logger.debug(`Gemini CLI attempt ${attempt}/${maxRetries}`, {
					command: fullCommand,
				});

				if (this.config.output.verbose) {
					console.log(
						`🔄 Executing: ${fullCommand} (attempt ${attempt}/${maxRetries})`,
					);
				}

				const timeout = options.timeout || this.config.gemini.options.timeout;
				const { stdout, stderr } = await execAsync(fullCommand, { timeout });

				const duration = ((Date.now() - startTime) / 1000).toFixed(1);

				// Clean up temp file on success
				this.cleanupTempFile(tempFile);

				if (stderr && this.config.output.verbose) {
					console.warn(`Gemini CLI warning:`, stderr);
					logger.warn("Gemini CLI stderr output", { stderr });
				}

				logger.geminiRequest(fullCommand, stdout.length, duration);
				logger.geminiResponse(true, stdout);

				return {
					success: true,
					output: stdout,
					attempt,
					command: fullCommand,
				};
			} catch (error) {
				lastError = error;

				logger.warn(`Gemini CLI attempt ${attempt}/${maxRetries} failed`, {
					error: error.message,
					timeout: options.timeout || this.config.gemini.options.timeout,
				});

				if (this.config.output.verbose) {
					console.warn(
						`❌ Attempt ${attempt}/${maxRetries} failed:`,
						error.message,
					);
				}

				// Wait before retry (except on last attempt)
				if (attempt < maxRetries) {
					await new Promise((resolve) => setTimeout(resolve, retryDelay));
				}
			}
		}

		// Clean up temp file on failure
		this.cleanupTempFile(tempFile);

		const totalDuration = ((Date.now() - startTime) / 1000).toFixed(1);
		logger.geminiResponse(false, null, lastError);
		logger.error("Gemini CLI execution failed after all retries", {
			attempts: maxRetries,
			totalDuration: `${totalDuration}s`,
			error: lastError?.message,
		});

		return {
			success: false,
			error: lastError,
			attempts: maxRetries,
		};
	}

	// Get available models
	getAvailableModels() {
		return (
			this.config.gemini.models || {
				fastest: "gemini-2.5-flash",
				capable: "gemini-2.5-pro",
			}
		);
	}

	// Set model by name or alias
	setModel(modelNameOrAlias) {
		const models = this.getAvailableModels();

		// Check if it's an alias
		if (models[modelNameOrAlias]) {
			this.config.gemini.model = models[modelNameOrAlias];
		} else {
			// Assume it's a direct model name
			this.config.gemini.model = modelNameOrAlias;
		}

		if (this.config.output.verbose) {
			console.log(`🔧 Model set to: ${this.config.gemini.model}`);
		}
	}

	// Save current configuration
	saveConfig() {
		try {
			fs.writeFileSync(this.configPath, JSON.stringify(this.config, null, 2));
			if (this.config.output.verbose) {
				console.log(`💾 Configuration saved to ${this.configPath}`);
			}
		} catch (error) {
			console.error(`Failed to save config:`, error.message);
		}
	}

	// Display current configuration
	showConfig() {
		console.log(`
╔══════════════════════════════════════════════════════════════╗
║                    Gemini CLI Configuration                  ║
╚══════════════════════════════════════════════════════════════╝

🤖 Model Settings:
   • Current model: ${this.getModel()}
   • Temperature: ${this.config.gemini.options.temperature}
   • Max tokens: ${this.config.gemini.options.maxTokens}
   • Timeout: ${this.config.gemini.options.timeout}ms

⚡ Processing:
   • Batch size: ${this.config.processing.batchSize}
   • Max retries: ${this.config.processing.maxRetries}
   • Retry delay: ${this.config.processing.retryDelay}ms
   • Parallel processing: ${this.config.processing.parallelProcessing}

📊 Output:
   • Verbose: ${this.config.output.verbose}
   • Show progress: ${this.config.output.showProgress}
   • Log level: ${this.config.output.logLevel}

📋 Available Models:
${Object.entries(this.getAvailableModels())
	.map(([alias, model]) => `   • ${alias}: ${model}`)
	.join("\n")}
`);
	}
}

// Export singleton instance and class
const geminiCLI = new GeminiCLI();

// Convenience functions
const executePrompt = (prompt, options) =>
	geminiCLI.executePrompt(prompt, options);
const setModel = (model) => geminiCLI.setModel(model);
const getModel = () => geminiCLI.getModel();
const getConfig = () => geminiCLI.config;
const showConfig = () => geminiCLI.showConfig();
const saveConfig = () => geminiCLI.saveConfig();
const cleanup = () => geminiCLI.cleanupAllTempFiles();

export {
	GeminiCLI,
	geminiCLI,
	executePrompt,
	setModel,
	getModel,
	getConfig,
	showConfig,
	saveConfig,
	cleanup,
};
## Claude-Mem Provider Architecture & Gemini CLI Integration
This codemap traces the provider architecture in claude-mem, showing how AI providers are selected [1a], how agents process sessions [2a], and where to integrate a new Gemini CLI module [3a]. The system uses a pluggable architecture where providers are configured via settings [4a] and agents are registered during worker startup [5a]. Key integration points include the queryGeminiMultiTurn method [3a] which would be replaced with CLI execution, and the provider selection logic [1a] that determines which agent to use.
### 1. Provider Selection & Agent Initialization
How the system chooses which AI provider to use and initializes the corresponding agent
### 1a. Provider Selection Logic (`SessionRoutes.ts:53`)
Core method that determines which agent to use based on settings
```text
private getActiveAgent(): SDKAgent | GeminiAgent | OpenRouterAgent {
```
### 1b. OpenRouter Check (`SessionRoutes.ts:54`)
First checks if OpenRouter is selected and available
```text
if (isOpenRouterSelected()) {
```
### 1c. Gemini Check (`SessionRoutes.ts:62`)
Then checks if Gemini is selected and available
```text
if (isGeminiSelected()) {
```
### 1d. Default to Claude (`SessionRoutes.ts:70`)
Falls back to Claude SDK by default
```text
return this.sdkAgent;
```
### 1e. Provider Setting (`SettingsDefaultsManager.ts:82`)
Default provider configuration in settings
```text
CLAUDE_MEM_PROVIDER: 'claude',  // Default to Claude
```
### 2. Agent Session Lifecycle
How an agent processes a session from start to finish
### 2a. Start Generator (`SessionRoutes.ts:355`)
Triggers agent to start processing session
```text
this.ensureGeneratorRunning(sessionDbId, 'init');
```
### 2b. Execute Agent (`SessionRoutes.ts:160`)
Calls the selected agent's startSession method
```text
session.generatorPromise = agent.startSession(session, this.workerService)
```
### 2c. Agent Implementation (`GeminiAgent.ts:131`)
Example agent session processing (Gemini)
```text
async startSession(session: ActiveSession, worker?: WorkerRef): Promise<void> {
```
### 2d. Query LLM (`GeminiAgent.ts:158`)
Makes actual API call to language model
```text
const initResponse = await this.queryGeminiMultiTurn(session.conversationHistory, apiKey, model, rateLimitingEnabled);
```
### 2e. Process Response (`GeminiAgent.ts:170`)
Handles LLM response through shared processor
```text
await processAgentResponse(initResponse.content, session, this.dbManager, this.sessionManager, worker, tokensUsed, null, 'Gemini');
```
### 3. Gemini CLI Integration Points
Where to modify the code to integrate the Gemini CLI module
### 3a. Current API Method (`GeminiAgent.ts:360`)
Current REST API implementation to replace with CLI
```text
private async queryGeminiMultiTurn(history: ConversationMessage[], apiKey: string, model: GeminiModel, rateLimitingEnabled: boolean): Promise<{ content: string; tokensUsed?: number }> {
```
### 3b. API Endpoint (`GeminiAgent.ts:374`)
Direct API call that would be replaced
```text
const url = `${GEMINI_API_URL}/${model}:generateContent?key=${apiKey}`;
```
### 3c. HTTP Request (`GeminiAgent.ts:379`)
fetch call to be replaced with CLI execution
```text
const response = await fetch(url, {
```
### 3d. CLI Module Method (`claude-code.ts:1`)
Example CLI executePrompt method to integrate
```text
async executePrompt(prompt, options = {}) {
```
### 3e. CLI Execution (`claude-code.ts:1`)
Command execution pattern from CLI module
```text
const fullCommand = `cat "${tempFile}" | ${command} 2>/dev/null`;
```
### 4. Configuration & Settings Integration
How to configure the system to use the new Gemini CLI provider
### 4a. Provider Type Definition (`SettingsDefaultsManager.ts:22`)
Type definition for provider setting
```text
CLAUDE_MEM_PROVIDER: string;  // 'claude' | 'gemini' | 'openrouter'
```
### 4b. Provider Check Function (`GeminiAgent.ts:467`)
Function that checks if Gemini is selected
```text
export function isGeminiSelected(): boolean {
```
### 4c. Provider Comparison (`GeminiAgent.ts:470`)
Actual check against settings
```text
return settings.CLAUDE_MEM_PROVIDER === 'gemini';
```
### 4d. Config Retrieval (`GeminiAgent.ts:415`)
Method to get Gemini-specific configuration
```text
private getGeminiConfig(): { apiKey: string; model: GeminiModel; rateLimitingEnabled: boolean } {
```
### 4e. API Key Resolution (`GeminiAgent.ts:421`)
How API key is resolved from settings
```text
const apiKey = settings.CLAUDE_MEM_GEMINI_API_KEY || getCredential('GEMINI_API_KEY') || '';
```
### 5. Agent Registration & Initialization
How agents are registered in the worker service during startup
### 5a. Agent Instantiation (`worker-service.ts:197`)
Gemini agent created in worker service
```text
this.geminiAgent = new GeminiAgent(this.dbManager, this.sessionManager);
```
### 5b. OpenRouter Agent (`worker-service.ts:198`)
OpenRouter agent also instantiated
```text
this.openRouterAgent = new OpenRouterAgent(this.dbManager, this.sessionManager);
```
### 5c. SDK Agent (`worker-service.ts:196`)
Claude SDK agent instantiated
```text
this.sdkAgent = new SDKAgent(this.dbManager, this.sessionManager);
```
### 5d. Worker Agent Selection (`worker-service.ts:480`)
Worker service also has agent selection logic
```text
private getActiveAgent(): SDKAgent | GeminiAgent | OpenRouterAgent {
```
### 5e. Route Registration (`worker-service.ts:327`)
Agents passed to session routes for HTTP handling
```text
this.server.registerRoutes(new SessionRoutes(this.sessionManager, this.dbManager, this.sdkAgent, this.geminiAgent, this.openRouterAgent, this.sessionEventBroadcaster, this));
```