---
name: typescript-setup
description: Setup TypeScript projects with Biome linter, Vitest testing, and Node types. Use when initializing new TypeScript repositories, adding TypeScript to existing projects, or setting up modern TypeScript tooling with package.json, tsconfig.json, biome.json, and vitest.config.js. Includes latest stable versions and example files.
---

# TypeScript Project Setup

Setup a modern TypeScript project with Biome (linter/formatter), Vitest (testing), TypeScript compiler, and Node types.

## What Gets Installed

**Development Tools:**
- TypeScript 5.9.3 - Type-safe JavaScript
- Biome 2.3.14 - Fast linter and formatter
- Vitest 4.0.18 - Fast unit test framework
- @types/node 25.2.3 - Node.js type definitions

**Configuration:**
- `package.json` - Dependencies and npm scripts
- `tsconfig.base.json` - Base TypeScript settings
- `tsconfig.json` - Project TypeScript config
- `biome.json` - Linting and formatting rules
- `vitest.config.js` - Test runner configuration

**Project Structure:**
- `src/` - Source TypeScript files
- `test/` - Test files
- `dist/` - Compiled output (gitignored)

## Quick Start

**1. Copy template files to project root:**

All templates are in `assets/templates/` directory:
- `package.json.template` → `package.json` (replace {{PROJECT_NAME}} and {{PROJECT_DESCRIPTION}})
- `tsconfig.base.json` → `tsconfig.base.json`
- `tsconfig.json` → `tsconfig.json`
- `biome.json` → `biome.json`
- `vitest.config.js` → `vitest.config.js`
- `test/setup.js` → `test/setup.js`
- `src/example.ts` → `src/example.ts` (optional, for verification)
- `test/example.test.ts` → `test/example.test.ts` (optional, for verification)

**2. Update package.json placeholders:**

Replace these in package.json:
- `{{PROJECT_NAME}}` - Your project name (lowercase, hyphen-separated)
- `{{PROJECT_DESCRIPTION}}` - Brief project description

**3. Install dependencies:**

```bash
npm install
```

**4. Handle Biome migration (if needed):**

If you see a schema version error from Biome:
```bash
npx biome migrate --write
```

**5. Verify setup:**

```bash
npm test              # Run tests (should pass with example files)
npm run type-check    # TypeScript type checking
npm run check         # Biome linting and formatting
```

## Step-by-Step Setup Process

### Step 1: Create Configuration Files

Copy each template file to your project root:

**package.json:**
- Use `assets/templates/package.json.template`
- Replace `{{PROJECT_NAME}}` with your project name
- Replace `{{PROJECT_DESCRIPTION}}` with description
- Includes all necessary devDependencies

**TypeScript configs:**
- Copy `assets/templates/tsconfig.base.json` → project root
- Copy `assets/templates/tsconfig.json` → project root
- No modifications needed

**Biome config:**
- Copy `assets/templates/biome.json` → project root
- Uses schema 2.3.14 (latest format)
- Configured with tabs, double quotes, organize imports

**Vitest config:**
- Copy `assets/templates/vitest.config.js` → project root
- Uses modern Vitest 4 configuration (no deprecated poolOptions)

### Step 2: Create Directory Structure

Create directories:
```bash
mkdir -p src test
```

**Copy setup file:**
- Copy `assets/templates/test/setup.js` → `test/setup.js`

**Optional: Add example files:**
- Copy `assets/templates/src/example.ts` → `src/example.ts`
- Copy `assets/templates/test/example.test.ts` → `test/example.test.ts`

These demonstrate the setup works and can be deleted after verification.

### Step 3: Install Dependencies

Run npm install to download all packages:

```bash
npm install
```

Expected output: All packages installed successfully (~189 packages)

### Step 4: Handle Biome Schema Migration

If Biome reports schema version mismatch (older Biome configs):

```bash
npx biome migrate --write
```

This updates the config to the latest schema format.

### Step 5: Create Your Code

Delete example files (if used):
```bash
rm src/example.ts test/example.test.ts
```

Create your first TypeScript file:
```typescript
// src/index.ts
export function hello(name: string): string {
  return `Hello, ${name}!`;
}
```

Create your first test:
```typescript
// test/index.test.ts
import { describe, expect, it } from "vitest";
import { hello } from "../src/index.js";

describe("hello function", () => {
  it("should greet a person", () => {
    expect(hello("World")).toBe("Hello, World!");
  });
});
```

### Step 6: Verify Everything Works

Run verification commands:

```bash
npm test              # Tests should pass
npm run type-check    # No type errors
npm run check         # Code formatted and linted
```

## Available npm Scripts

After setup, these scripts are available:

**Testing:**
- `npm test` - Run all tests once
- `npm run test:watch` - Run tests in watch mode
- `npm run test:ui` - Run tests with UI
- `npm run test:coverage` - Generate coverage report

**Type Checking & Building:**
- `npm run type-check` - Check types without emitting files
- `npm run build` - Compile TypeScript to JavaScript
- `npm run build:clean` - Clean and rebuild

**Linting & Formatting:**
- `npm run format` - Format all files with Biome
- `npm run lint` - Lint all files
- `npm run check` - Lint and format (auto-fix)

## Template Files Reference

All template files are located in `assets/templates/`:

**Configuration:**
- `package.json.template` - Package definition with latest versions
- `tsconfig.base.json` - Base TypeScript compiler options
- `tsconfig.json` - Project TypeScript config (extends base)
- `biome.json` - Linter and formatter settings
- `vitest.config.js` - Test runner configuration

**Project Structure:**
- `test/setup.js` - Test setup file
- `src/example.ts` - Example TypeScript module
- `test/example.test.ts` - Example Vitest test

## Latest Stable Versions

As of creation (February 2026):
- @biomejs/biome: ^2.3.14
- @types/node: ^25.2.3
- @vitest/ui: ^4.0.18
- c8: ^10.1.3
- typescript: ^5.9.3
- vitest: ^4.0.18

To check for newer versions:
```bash
npm view <package-name> version
```

## Troubleshooting

### Biome Schema Version Mismatch

**Problem:** Biome reports "configuration schema version does not match"

**Solution:**
```bash
npx biome migrate --write
```

This migrates your config to the latest schema format (2.3.14).

### Vitest poolOptions Deprecation

**Problem:** Warning about `poolOptions` being deprecated

**Solution:** The template already uses the modern format with top-level `maxForks` and `minForks`. No action needed.

### TypeScript "files list is empty"

**Problem:** TypeScript can't find files to compile

**Solution:** Ensure `tsconfig.json` has proper `include` array:
```json
{
  "extends": "./tsconfig.base.json",
  "include": ["src/**/*", "test/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### Tests Can't Find Source Files

**Problem:** Import errors in tests

**Solution:**
- Ensure imports use `.js` extension: `import { fn } from "../src/file.js"`
- TypeScript compiles `.ts` to `.js`, so imports reference the output extension
- Check `package.json` has `"type": "module"`

## Customization

**Change indentation style:**

Edit `biome.json`:
```json
"formatter": {
  "indentStyle": "space"  // or "tab"
}
```

**Change quote style:**

Edit `biome.json`:
```json
"javascript": {
  "formatter": {
    "quoteStyle": "single"  // or "double"
  }
}
```

**Add additional dependencies:**

Update `package.json` dependencies or devDependencies, then run `npm install`.

**Adjust test patterns:**

Edit `vitest.config.js` `include` array to match your test file locations.
