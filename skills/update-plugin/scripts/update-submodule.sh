#!/usr/bin/env bash
# update-submodule.sh — Pull latest cc-workflows-plugin into .claude submodule
set -e

echo "Updating .claude submodule from local hub..."
git -C .claude pull origin-local main
git add .claude
git commit -m "chore(deps): update .claude submodule to latest"
echo "Done."
