---
name: extract-package-to-repo
description: Use when extracting a package or tool from cc-workflows into its own standalone GitHub repo — handles git history extraction, package rename, issue transfer, and .claude submodule wiring.
---

# Extract Package to Repo

## Overview

Extracts a package from cc-workflows into a standalone GitHub repo with full commit history, proper package identity rename, GitHub issue transfer, and the cc-workflows-plugin wired as a `.claude` submodule.

**Announce at start:** "I'm using the extract-package-to-repo skill."

---

## Pre-Flight Checklist

Answer all questions BEFORE touching anything:

- [ ] **Package path**: What is the package path in cc-workflows? (e.g., `tools/citation-manager/`)
- [ ] **New repo name**: What is the new GitHub repo name? (e.g., `jact`)
- [ ] **Package identity**: What should the npm package name and CLI bin be? (may differ from repo name)
- [ ] **`git filter-repo` installed?**
  ```bash
  which git-filter-repo
  ```
  If missing: `brew install git-filter-repo`
- [ ] **GitHub issues identified**: Run issue search BEFORE starting so nothing is forgotten
  ```bash
  gh issue list -R WesleyMFrederick/cc-workflows --search "<package-name>" --state open --json number,title,state
  ```
  Review with user — confirm which open issues to transfer.

---

## Phase 1: Create GitHub Repo

```bash
gh repo create WesleyMFrederick/<repo-name> --public
```

Verify: URL returned confirms repo exists.

---

## Phase 2: Extract with git filter-repo

> Extract the package path with its commit history into a new local repo.

**Step 1** — Clone cc-workflows fresh to a temp location:
```bash
git clone /Users/wesleyfrederick/Documents/ObsidianVault/0_SoftwareDevelopment/cc-workflows /tmp/<repo-name>-extract
```

**Step 2** — Run filter-repo to extract path and move contents to root:
```bash
cd /tmp/<repo-name>-extract
git filter-repo --path <package-path>/ --path-rename <package-path>/:
```

**Step 3** — Set remote and push:
```bash
git remote add origin git@github.com:WesleyMFrederick/<repo-name>.git
git push -u origin main
```

Verify: `git log --oneline -5` shows only commits that touched the package.

---

## Phase 3: Rename Package Identity

In the new repo's `package.json`:
- `name` → `<package-name>`
- `bin` → `{ "<cli-command>": "./dist/..." }`

Keep source filenames as-is unless user specifies otherwise.

Verify the rename compiled:
```bash
npm install
npm run build
npx <cli-command> --help
```

---

## Phase 4: Transfer GitHub Issues

Transfer each identified open issue one at a time (never batch):
```bash
gh issue transfer <number> WesleyMFrederick/<repo-name> -R WesleyMFrederick/cc-workflows
```

Confirm each transfer returns a valid `https://github.com/WesleyMFrederick/<repo-name>/issues/<N>` URL.

Note the mapping (cc-workflows → new repo) for reference.

---

## Phase 5: Add .claude Submodule

Wire the cc-workflows-plugin so Claude Code skills and hooks work in the new repo:
```bash
cd /path/to/<repo-name>
git submodule add git@github.com:WesleyMFrederick/cc-workflows-plugin.git .claude
```

Add postinstall to `package.json` scripts:
```json
"postinstall": "git submodule update --init --recursive"
```

Commit both changes:
```bash
git add .gitmodules .claude package.json
git commit -m "feat: add cc-workflows-plugin as .claude submodule"
```

---

## Phase 6: Verify Standalone

Full standalone check from the new repo root:
```bash
npm install
npm run build
npm test
npx <cli-command> --help
ls .claude/skills/
```

All must pass before declaring done.

---

## Phase 7: Commit and Push Final State

```bash
git add -A
git commit -m "feat: rename package to <package-name>, wire standalone"
git push
```

---

## Common Mistakes to Avoid

| Mistake | Prevention |
|---------|-----------|
| Forgetting issue transfer | Run issue search in Pre-Flight, before any repo creation |
| `git filter-repo` not installed | Check in Pre-Flight — fail fast, not mid-extraction |
| Undefined repo/package name | Resolve all names in Pre-Flight before touching code |
| Transferring to wrong repo | Double-check `-R` source and destination for every `gh issue transfer` call |
| Skipping standalone verify | Phase 6 is mandatory — extraction can succeed while npm scripts break |
