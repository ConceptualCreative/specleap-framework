#!/bin/bash
# SpecLeap — Spec-guard pre-tool-use hook
# Blocks Write/Edit/NotebookEdit on protected branches (main/stage/develop).
# Fail-open philosophy: any internal error results in exit 0 (allow).
#
# Input: stdin JSON from Claude Code PreToolUse hook
#   { "tool_name": "Write", "tool_input": { "file_path": "src/X.ts" }, ... }
#
# Exit codes:
#   0   allow
#   2   block (stderr is shown to the user)

set +e   # never abort on unexpected errors; we fail-open explicitly

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# The hook lives at <project>/.claude/hooks/, so root is two levels up
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Try to load i18n helper if available (we live in a consumer project,
# so .specleap may or may not exist there)
if [ -f "$PROJECT_ROOT/.specleap/i18n.sh" ]; then
    # shellcheck source=/dev/null
    source "$PROJECT_ROOT/.specleap/i18n.sh" 2>/dev/null || true
fi

# Translation helper with hard-coded English fallback
# so the hook works even without SpecLeap i18n present.
translate() {
    local key="$1"
    local fallback="$2"
    if command -v t &>/dev/null; then
        local result
        result=$(t "$key" 2>/dev/null)
        if [ -n "$result" ] && [ "$result" != "$key" ]; then
            echo "$result"
            return
        fi
    fi
    echo "$fallback"
}

# Read stdin (hook input from Claude Code)
INPUT=""
if [ -t 0 ]; then
    # No stdin available (ran manually for testing) — allow
    exit 0
fi
INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0

# Parse tool_name and file_path
TOOL=""
FILE=""
if command -v jq &>/dev/null; then
    TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
    FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
else
    # Fallback without jq — crude regex extraction
    TOOL=$(echo "$INPUT" | grep -o '"tool_name":[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
    FILE=$(echo "$INPUT" | grep -o '"file_path":[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
fi

# Only care about file-writing tools
case "$TOOL" in
    Write|Edit|NotebookEdit) ;;
    *) exit 0 ;;
esac

[ -z "$FILE" ] && exit 0

# Only enforce on typical app-code paths.
# Accept both absolute and relative forms.
case "$FILE" in
    *"/src/"*|"src/"*|\
    *"/app/"*|"app/"*|\
    *"/tests/"*|"tests/"*|\
    *"/test/"*|"test/"*|\
    *"/lib/"*|"lib/"*)
        ;;
    *)
        exit 0
        ;;
esac

# Determine current git branch. If not a git repo → fail-open.
BRANCH=""
if command -v git &>/dev/null; then
    BRANCH=$(git -C "$PROJECT_ROOT" rev-parse --abbrev-ref HEAD 2>/dev/null)
fi
[ -z "$BRANCH" ] && exit 0

# Protected branches list
PROTECTED="main stage develop"

BLOCKED=0
for p in $PROTECTED; do
    if [ "$BRANCH" = "$p" ]; then
        BLOCKED=1
        break
    fi
done

[ "$BLOCKED" -eq 0 ] && exit 0

# --- Blocked: print pedagogical message to stderr and exit 2 ---

HEADER=$(translate 'quality.spec_guard.blocked_header' 'SpecLeap: write blocked on protected branch')
ON_BRANCH=$(translate 'quality.spec_guard.blocked_branch' 'You are on protected branch:')
HINT_CREATE=$(translate 'quality.spec_guard.hint_create_branch' 'Create a feature branch:')
HINT_CMD=$(translate 'quality.spec_guard.hint_command' 'git checkout -b feature/[project]-[ticket]-[description]')
HINT_EXAMPLE=$(translate 'quality.spec_guard.hint_example' 'Example: git checkout -b feature/app-tienda-23-cart')
HINT_FLOW=$(translate 'quality.spec_guard.hint_flow' 'Flow: feature → stage → main (via PR)')

{
    echo ""
    echo "╔═════════════════════════════════════════════════════════╗"
    echo "║ $HEADER"
    echo "╚═════════════════════════════════════════════════════════╝"
    echo ""
    echo "  $ON_BRANCH $BRANCH"
    echo "  → $FILE"
    echo ""
    echo "  $HINT_CREATE"
    echo "    $HINT_CMD"
    echo ""
    echo "  $HINT_EXAMPLE"
    echo ""
    echo "  $HINT_FLOW"
    echo ""
} >&2

exit 2
