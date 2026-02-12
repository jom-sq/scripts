#!/bin/bash
# Cleanup git worktrees that haven't been modified in X days
# Usage: cleanup-worktrees.sh [days] [--dry-run]
#
# Examples:
#   cleanup-worktrees.sh              # Remove worktrees older than 4 days
#   cleanup-worktrees.sh 7            # Remove worktrees older than 7 days
#   cleanup-worktrees.sh 4 --dry-run  # Preview what would be removed

set -euo pipefail

DAYS="${1:-4}"
DRY_RUN=false
[[ "${2:-}" == "--dry-run" ]] && DRY_RUN=true

DEV_BASE="$HOME/Development"
LOG_FILE="$HOME/.local/logs/worktree-cleanup.log"

mkdir -p "$(dirname "$LOG_FILE")"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "Starting worktree cleanup (threshold: $DAYS days, dry-run: $DRY_RUN)"

# Find all *-worktrees directories (e.g., square-web-worktrees, dashboard-worktrees)
for worktrees_dir in "$DEV_BASE"/*-worktrees/; do
  [[ ! -d "$worktrees_dir" ]] && continue

  # Derive main repo name: square-web-worktrees -> square-web
  dir_name=$(basename "$worktrees_dir")
  repo_name="${dir_name%-worktrees}"
  main_repo="$DEV_BASE/$repo_name"

  # Skip if main repo doesn't exist
  [[ ! -d "$main_repo/.git" ]] && continue

  for worktree in "$worktrees_dir"/*/; do
    [[ ! -d "$worktree" ]] && continue

    worktree_name=$(basename "$worktree")

    # Check last modification time (most recent file change in the worktree)
    last_modified=$(find "$worktree" -type f -not -path '*/.git/*' -mtime -"$DAYS" 2>/dev/null | head -1)

    if [[ -z "$last_modified" ]]; then
      log "OLD: $repo_name/$worktree_name (no changes in $DAYS days)"

      if [[ "$DRY_RUN" == "false" ]]; then
        rm -rf "$worktree"
        log "  -> Removed"
      else
        log "  -> Would remove (dry-run)"
      fi
    else
      log "KEEP: $repo_name/$worktree_name (recently modified)"
    fi
  done

  # Prune the main repo
  if [[ "$DRY_RUN" == "false" ]]; then
    (cd "$main_repo" && git worktree prune 2>/dev/null) || true
  fi
done

log "Cleanup complete"
