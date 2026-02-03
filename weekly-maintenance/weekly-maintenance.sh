#!/bin/bash
# Weekly maintenance script for macOS
# Runs brew update/upgrade and topsoil compost
#
# Usage: weekly-maintenance.sh [role]
#   role: Your topsoil role (e.g., frontend, backend, ios, android)
#         If not provided, uses previously saved default

set -euo pipefail

ROLE="${1:-}"

echo "========================================"
echo "Started: $(date)"
echo "========================================"

echo ""
echo ">>> brew update"
/opt/homebrew/bin/brew update || echo "⚠️  brew update had issues, continuing..."

echo ""
echo ">>> brew upgrade"
/opt/homebrew/bin/brew upgrade || echo "⚠️  brew upgrade had issues, continuing..."

echo ""
echo ">>> topsoil compost"
cd ~/Development/topsoil
git pull

if [[ -n "$ROLE" ]]; then
  ./compost "$ROLE"
else
  ./compost
fi

echo ""
echo "========================================"
echo "Finished: $(date)"
echo "========================================"
