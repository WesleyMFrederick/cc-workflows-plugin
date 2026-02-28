#!/usr/bin/env bash
# Deterministic submodule sync: discovers hub remote, classifies divergence,
# safety-checks content loss, moves pointer — or STOPS on conflict.
#
# Usage: sync-submodule.sh [submodule-path] [branch]
# Defaults: submodule-path=.claude, branch=main
#
# Exit codes:
#   0 = synced (already synced or successfully moved pointer)
#   1 = error (no hub remote, fetch failed, verify failed)
#   2 = conflict (overlapping files with real diffs — needs user)
#   3 = submodule-ahead (needs push, not sync)
#
# Stdout: KEY=VALUE pairs, parseable by caller

set -euo pipefail

SUBMODULE="${1:-.claude}"
BRANCH="${2:-main}"

# --- Output helpers ---
output() { echo "$1"; }
die() {
  output "STATUS=error"
  output "ERROR=$1"
  exit 1
}

# --- Phase 1: Discover hub remote ---
>&2 echo "Phase 1: Discover hub remote"

HUB_REMOTE=""
while IFS= read -r line; do
  # Match path-based URLs (start with / or ~) in fetch lines
  if [[ "$line" =~ ^([a-zA-Z0-9_-]+)[[:space:]]+(/.+|~.+)[[:space:]]+\(fetch\)$ ]]; then
    HUB_REMOTE="${BASH_REMATCH[1]}"
    break
  fi
done < <(git -C "$SUBMODULE" remote -v 2>/dev/null)

if [[ -z "$HUB_REMOTE" ]]; then
  die "No path-based (local hub) remote found in '$SUBMODULE' remotes"
fi

>&2 echo "  Found hub remote: $HUB_REMOTE"
output "HUB_REMOTE=$HUB_REMOTE"

# --- Phase 2: Fetch from hub ---
>&2 echo "Phase 2: Fetch from hub"

if ! git -C "$SUBMODULE" fetch "$HUB_REMOTE" 2>&2; then
  die "Fetch from '$HUB_REMOTE' failed"
fi

>&2 echo "  Fetch complete"

# --- Phase 3: Compare HEADs ---
>&2 echo "Phase 3: Compare HEADs"

LOCAL_HEAD=$(git -C "$SUBMODULE" rev-parse HEAD)
REMOTE_HEAD=$(git -C "$SUBMODULE" rev-parse "$HUB_REMOTE/$BRANCH")

output "OLD_HEAD=${LOCAL_HEAD:0:7}"

if [[ "$LOCAL_HEAD" == "$REMOTE_HEAD" ]]; then
  >&2 echo "  Already synced"
  output "STATUS=synced"
  output "NEW_HEAD=${REMOTE_HEAD:0:7}"
  exit 0
fi

>&2 echo "  Local:  ${LOCAL_HEAD:0:7}"
>&2 echo "  Remote: ${REMOTE_HEAD:0:7}"

# --- Phase 4: Classify divergence ---
>&2 echo "Phase 4: Classify divergence"

REMOTE_IS_ANCESTOR=false
LOCAL_IS_ANCESTOR=false

if git -C "$SUBMODULE" merge-base --is-ancestor "$HUB_REMOTE/$BRANCH" HEAD 2>/dev/null; then
  REMOTE_IS_ANCESTOR=true
fi

if git -C "$SUBMODULE" merge-base --is-ancestor HEAD "$HUB_REMOTE/$BRANCH" 2>/dev/null; then
  LOCAL_IS_ANCESTOR=true
fi

if [[ "$REMOTE_IS_ANCESTOR" == "true" && "$LOCAL_IS_ANCESTOR" == "false" ]]; then
  # Submodule is ahead of hub
  >&2 echo "  Classification: submodule-ahead"
  output "STATUS=submodule-ahead"
  output "NEW_HEAD=${REMOTE_HEAD:0:7}"
  exit 3
fi

if [[ "$LOCAL_IS_ANCESTOR" == "true" && "$REMOTE_IS_ANCESTOR" == "false" ]]; then
  # Hub is ahead, submodule behind — simple catch-up
  >&2 echo "  Classification: catch-up (hub ahead, linear)"
  # Skip Phase 5, go directly to Phase 6
  CLASSIFICATION="catch-up"
else
  # Both have unique commits — diverged, need safety check
  >&2 echo "  Classification: diverged (both have unique commits)"
  CLASSIFICATION="diverged"
fi

# --- Phase 5: Safety check (diverged paths only) ---
if [[ "$CLASSIFICATION" == "diverged" ]]; then
  >&2 echo "Phase 5: Safety check (diverged)"

  MERGE_BASE=$(git -C "$SUBMODULE" merge-base HEAD "$HUB_REMOTE/$BRANCH")
  >&2 echo "  Merge base: ${MERGE_BASE:0:7}"

  # Files changed locally since merge base
  LOCAL_FILES=$(git -C "$SUBMODULE" diff --name-only "$MERGE_BASE"..HEAD)
  # Files changed on hub since merge base
  REMOTE_FILES=$(git -C "$SUBMODULE" diff --name-only "$MERGE_BASE".."$HUB_REMOTE/$BRANCH")

  # Find overlapping files
  OVERLAP=""
  while IFS= read -r file; do
    [[ -z "$file" ]] && continue
    if echo "$REMOTE_FILES" | grep -qxF "$file"; then
      if [[ -n "$OVERLAP" ]]; then
        OVERLAP="$OVERLAP,$file"
      else
        OVERLAP="$file"
      fi
    fi
  done <<< "$LOCAL_FILES"

  if [[ -z "$OVERLAP" ]]; then
    >&2 echo "  No overlapping files — safe to proceed"
    CLASSIFICATION="diverged-safe"
  else
    >&2 echo "  Overlapping files: $OVERLAP"

    # Check if overlapping files have real diffs
    HAS_REAL_DIFF=false
    DIFF_SUMMARY=""
    IFS=',' read -ra OVERLAP_ARR <<< "$OVERLAP"
    for file in "${OVERLAP_ARR[@]}"; do
      FILE_DIFF=$(git -C "$SUBMODULE" diff HEAD "$HUB_REMOTE/$BRANCH" -- "$file" 2>/dev/null || true)
      if [[ -n "$FILE_DIFF" ]]; then
        HAS_REAL_DIFF=true
        if [[ -n "$DIFF_SUMMARY" ]]; then
          DIFF_SUMMARY="$DIFF_SUMMARY; $file has real changes"
        else
          DIFF_SUMMARY="$file has real changes"
        fi
      fi
    done

    if [[ "$HAS_REAL_DIFF" == "true" ]]; then
      >&2 echo "  CONFLICT: Real diffs found in overlapping files"
      output "STATUS=conflict"
      output "NEW_HEAD=${REMOTE_HEAD:0:7}"
      output "OVERLAP_FILES=$OVERLAP"
      output "DIFF_SUMMARY=$DIFF_SUMMARY"
      exit 2
    else
      >&2 echo "  Overlapping files have identical content — safe to proceed"
      CLASSIFICATION="diverged-safe"
    fi
  fi
else
  >&2 echo "Phase 5: Skipped (not diverged)"
fi

# --- Phase 6: Move pointer ---
>&2 echo "Phase 6: Move pointer"

git -C "$SUBMODULE" checkout "$HUB_REMOTE/$BRANCH" 2>&2

>&2 echo "  Pointer moved to $HUB_REMOTE/$BRANCH"

# --- Phase 7: Verify alignment ---
>&2 echo "Phase 7: Verify alignment"

REMAINING=$(git -C "$SUBMODULE" log "$HUB_REMOTE/$BRANCH"..HEAD --oneline 2>/dev/null || true)

if [[ -n "$REMAINING" ]]; then
  die "Verification failed: commits remain after pointer move: $REMAINING"
fi

>&2 echo "  Verified: no commits ahead of hub"

# --- Output final status ---
output "STATUS=$CLASSIFICATION"
output "NEW_HEAD=${REMOTE_HEAD:0:7}"
exit 0
