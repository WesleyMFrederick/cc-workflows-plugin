---
name: fetch-reference-docs
description: Use when fetching external documentation to markdown files for use as context — fetches pages via HTTP, extracts main content, converts to markdown. Use when user says "grab the docs for X", "fetch the reference pages", "download the API docs", or needs to batch-convert a documentation site to local markdown files.
---

# fetch-reference-docs

## Overview

`fetch-reference-docs` fetches HTTP pages, extracts main content, and saves as markdown files. It discovers URLs via one of four modes, then batch-fetches and saves them.

**Critical constraint:** HTTP-only — no JavaScript rendering. SPAs that require JS to populate content will return empty or near-empty markdown.

## How to Run

The tool is a workspace package, not a global binary. Run via:

```bash
node packages/fetch-reference-docs/dist/src/cli.js [flags]
```

Do NOT use `npx fetch-reference-docs` — it's not on npm. Build first if `dist/src/` is missing:

```bash
npm run build -w packages/fetch-reference-docs
```

## Choosing a Discovery Mode

| If the site has... | Use mode |
|---|---|
| `/llms.txt` with markdown links | `llms-txt` |
| `/sitemap.xml` | `sitemap-xml` |
| Server-rendered HTML navigation | `navigation` |
| Specific known URLs | `manual` |

**Always dry-run first** to see what will be fetched:

```bash
node packages/fetch-reference-docs/dist/src/cli.js -m <mode> -u <url> -o /tmp/out --dry-run
```

If 0 URLs discovered, the site's discovery endpoint is empty, blocked, or SPA-rendered — try a different mode or use `manual`.

## Quick Reference

| Flag | Short | Description | Default |
|---|---|---|---|
| `--mode` | `-m` | `navigation\|llms-txt\|sitemap-xml\|manual` | required |
| `--url` | `-u` | Base URL for discovery | required (except `manual`) |
| `--output` | `-o` | Output directory | required |
| `--urls` | | Comma-separated URLs (manual mode) | — |
| `--url-file` | | File of URLs, one per line (manual mode) | — |
| `--include` | | Include only URLs matching this glob pattern (`*` = wildcard) | — |
| `--exclude` | | Exclude URLs matching this glob pattern (`*` = wildcard) | — |
| `--delay` | `-d` | Milliseconds between requests | `100` |
| `--selector` | `-s` | CSS selector for content extraction | — |
| `--full-page` | | Skip content extraction, use entire page HTML | `false` |
| `--dry-run` | | List discovered URLs, don't download | `false` |
| `--verbose` | `-v` | Print each URL as it's fetched | `false` |

## Usage Examples

### llms-txt (best for supported sites)

```bash
# Dry run to verify llms.txt exists and has URLs
node packages/fetch-reference-docs/dist/src/cli.js \
  -m llms-txt -u https://docs.example.com -o ./references --dry-run

# Full fetch
node packages/fetch-reference-docs/dist/src/cli.js \
  -m llms-txt -u https://docs.example.com -o ./references --verbose
```

### sitemap-xml

```bash
node packages/fetch-reference-docs/dist/src/cli.js \
  -m sitemap-xml -u https://example.com -o ./references \
  --include "/docs/" --dry-run
```

### navigation (extracts links from base URL page only)

```bash
# Only fetches links found on the homepage — NOT a full site crawler
node packages/fetch-reference-docs/dist/src/cli.js \
  -m navigation -u https://effect.website -o ./references --dry-run
```

### manual

```bash
# Comma-separated URLs
node packages/fetch-reference-docs/dist/src/cli.js \
  -m manual \
  --urls "https://example.com/api/one,https://example.com/api/two" \
  -o ./references

# From a file (one URL per line)
node packages/fetch-reference-docs/dist/src/cli.js \
  -m manual --url-file /tmp/urls.txt -o ./references \
  --include "/api/"
```

## Filtering with --include / --exclude

`--include` and `--exclude` use **glob-style patterns** matched against the full URL string:
- Plain strings like `/api/` match any URL containing `/api/`
- `*` is a wildcard matching any characters: `*/api/*` works
- Regex metacharacters (`.`, `+`, `^`, `$`, etc.) are treated **literally** — NOT as regex
- Multiple patterns are OR'd: URL is included if it matches ANY of the include patterns

```bash
# Include URLs containing "/api/" (plain glob)
--include "/api/"

# Include using wildcard (same result)
--include "*/api/*"

# Exclude blog posts
--exclude "/blog/"

# Multiple OR'd include patterns — matches either /docs/ OR /api/
--include "/docs/" --include "/api/"
```

Do NOT use regex syntax — `.` is literal, not "any character". Use plain strings or `*` wildcards only.

## Troubleshooting

### 0 URLs discovered

The site's `/llms.txt` or `/sitemap.xml` is missing, blocked, or returns HTML (SPA).

Try:
1. `curl -L https://site.com/llms.txt` — check if it returns plain text or HTML
2. Switch modes: `llms-txt` → `sitemap-xml` → `navigation`
3. Find URLs manually and use `--mode manual`

### Empty or very short markdown files

**Cause:** Site is a JavaScript SPA — the server sends an HTML shell with no content. `fetch-reference-docs` does not execute JavaScript.

**Symptoms:** Files contain only nav/footer boilerplate, or near-empty body text.

**Fix:** `--full-page` does NOT solve this — it still gets the shell HTML. Use the `--selector` flag only if the site sends static HTML but with complex layout:

```bash
--selector "article.content"   # target a specific content region
```

If the content is only populated by JS, this tool cannot fetch it. Consider alternative sources (GitHub source, PDF downloads, cached static mirrors).

### Content includes nav/sidebar noise

Use `--selector` to target just the main content area:

```bash
--selector "main"
--selector ".docs-content"
--selector "article"
```

### Rate limiting / 429 errors

Increase delay between requests:

```bash
--delay 1000   # 1 second between requests
```

## Common Pitfalls

| Mistake | Reality |
|---|---|
| `npx fetch-reference-docs` | Not on npm. Use `node packages/fetch-reference-docs/dist/src/cli.js` |
| `navigation` mode crawls whole site | It only extracts links from the ONE page you provide |
| `--include ".*pattern.*"` (regex syntax) | Use glob patterns: `--include "*/pattern/*"` or `--include "/pattern/"` |
| `--full-page` fixes SPA empty content | No — SPA content requires JS. Tool is HTTP-only. |
| Skipping `--dry-run` | Always dry-run first to verify discovered URLs before downloading |
| Forgetting `-o` flag | It's required — tool will error without it |
