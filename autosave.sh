#!/bin/bash
#
# autosave.sh - Automatically commit all changes as a new revision
#
# Usage:
#   ./autosave.sh                  # Auto-generates a timestamped commit message
#   ./autosave.sh "my message"     # Uses your custom commit message
#   ./autosave.sh --watch          # Watches for changes and auto-commits every 60s
#   ./autosave.sh --watch 30       # Watches with a custom interval (seconds)
#
# This script stages all changes (new, modified, deleted files) and commits them.
# It skips the commit if there are no changes to save.

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# ─── Single snapshot commit ───────────────────────────────────────────────────

snapshot() {
    local message="$1"

    # Stage everything
    git add -A

    # Check if there's anything to commit
    if git diff --cached --quiet; then
        echo -e "${YELLOW}No changes to save.${NC}"
        return 0
    fi

    # Build commit message
    if [ -z "$message" ]; then
        local timestamp
        timestamp=$(date "+%Y-%m-%d %H:%M:%S")

        # Summarise what changed
        local added modified deleted
        added=$(git diff --cached --numstat | awk '{a+=$1} END{print a+0}')
        deleted=$(git diff --cached --numstat | awk '{d+=$2} END{print d+0}')
        modified=$(git diff --cached --name-only | wc -l | tr -d ' ')

        message="Autosave: ${timestamp} | ${modified} file(s) changed (+${added} -${deleted})"
    fi

    git commit -m "$message"

    echo ""
    echo -e "${GREEN}Revision saved!${NC}"
    echo -e "${BLUE}$(git log -1 --oneline)${NC}"
    echo ""
}

# ─── Watch mode ───────────────────────────────────────────────────────────────

watch_mode() {
    local interval="${1:-60}"

    echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  Autosave watcher started                          ║${NC}"
    echo -e "${BLUE}║  Checking for changes every ${interval}s                     ║${NC}"
    echo -e "${BLUE}║  Press Ctrl+C to stop                              ║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${NC}"
    echo ""

    while true; do
        snapshot ""
        sleep "$interval"
    done
}

# ─── Main ─────────────────────────────────────────────────────────────────────

case "${1:-}" in
    --watch)
        watch_mode "${2:-60}"
        ;;
    --help|-h)
        echo "Usage:"
        echo "  ./autosave.sh                  Auto-save with timestamped message"
        echo "  ./autosave.sh \"my message\"      Save with a custom commit message"
        echo "  ./autosave.sh --watch           Watch and auto-save every 60s"
        echo "  ./autosave.sh --watch 30        Watch with custom interval (seconds)"
        echo "  ./autosave.sh --help            Show this help message"
        ;;
    *)
        snapshot "$1"
        ;;
esac
