#!/bin/bash
# SpecLeap — Healing telemetry log per feature
# Writes JSONL entries to .quality/evidence/[feature]/healing.jsonl
#
# Verbs:
#   log    append a new entry
#   show   print last N entries (default 20)
#   stats  count entries by severity, phase and action

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT/.specleap/i18n.sh"

EVIDENCE_DIR="$ROOT/.quality/evidence"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# -----------------------------------------------------------------------------
# Argument parser (long options only)
# Sets: ARG_FEATURE, ARG_PHASE, ARG_SEVERITY, ARG_ACTION, ARG_DETAIL, ARG_FILE, ARG_LAST
# -----------------------------------------------------------------------------
parse_args() {
    ARG_FEATURE=""
    ARG_PHASE=""
    ARG_SEVERITY=""
    ARG_ACTION=""
    ARG_DETAIL=""
    ARG_FILE=""
    ARG_LAST="20"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --feature)  ARG_FEATURE="$2"; shift 2 ;;
            --phase)    ARG_PHASE="$2"; shift 2 ;;
            --severity) ARG_SEVERITY="$2"; shift 2 ;;
            --action)   ARG_ACTION="$2"; shift 2 ;;
            --detail)   ARG_DETAIL="$2"; shift 2 ;;
            --file)     ARG_FILE="$2"; shift 2 ;;
            --last)     ARG_LAST="$2"; shift 2 ;;
            *)          shift ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# Resolve path to the healing.jsonl of a given feature
# Outputs path via stdout; returns non-zero if evidence folder missing
# -----------------------------------------------------------------------------
log_path_for() {
    local feature="$1"
    local dir="$EVIDENCE_DIR/$feature"
    if [ ! -d "$dir" ]; then
        return 1
    fi
    echo "$dir/healing.jsonl"
}

# -----------------------------------------------------------------------------
# JSON-escape a string (wraps jq)
# -----------------------------------------------------------------------------
json_escape() {
    if command -v jq &> /dev/null; then
        jq -Rn --arg s "$1" '$s'
    else
        # Fallback: crude escaping for common cases
        local s="$1"
        s="${s//\\/\\\\}"
        s="${s//\"/\\\"}"
        s="${s//$'\n'/\\n}"
        s="${s//$'\t'/\\t}"
        echo "\"$s\""
    fi
}

cmd_log() {
    parse_args "$@"

    if [ -z "$ARG_FEATURE" ]; then
        echo -e "${RED}$(t 'quality.healing.missing_feature')${NC}"
        echo "$(t 'quality.healing.usage_log')"
        exit 1
    fi
    if [ -z "$ARG_PHASE" ]; then
        echo -e "${RED}$(t 'quality.healing.missing_phase')${NC}"
        exit 1
    fi
    if [ -z "$ARG_ACTION" ]; then
        echo -e "${RED}$(t 'quality.healing.missing_action')${NC}"
        exit 1
    fi

    # Default severity = info
    [ -z "$ARG_SEVERITY" ] && ARG_SEVERITY="info"

    case "$ARG_SEVERITY" in
        info|warn|error) ;;
        *)
            echo -e "${RED}$(t 'quality.healing.severity_invalid')${NC} $ARG_SEVERITY"
            exit 1
            ;;
    esac

    local log_file
    if ! log_file=$(log_path_for "$ARG_FEATURE"); then
        echo -e "${RED}$(t 'quality.healing.no_evidence')${NC} $ARG_FEATURE"
        echo "$(t 'quality.healing.run_new_evidence_first')"
        exit 1
    fi

    local ts
    ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Build JSON entry one line
    local entry
    if command -v jq &> /dev/null; then
        entry=$(jq -cn \
            --arg ts "$ts" \
            --arg phase "$ARG_PHASE" \
            --arg severity "$ARG_SEVERITY" \
            --arg action "$ARG_ACTION" \
            --arg detail "$ARG_DETAIL" \
            --arg file "$ARG_FILE" \
            '{ts: $ts, phase: $phase, severity: $severity, action: $action, detail: $detail, file: $file}
             | if .file == "" then del(.file) else . end
             | if .detail == "" then del(.detail) else . end')
    else
        # Fallback without jq
        local json="{\"ts\":$(json_escape "$ts"),\"phase\":$(json_escape "$ARG_PHASE"),\"severity\":$(json_escape "$ARG_SEVERITY"),\"action\":$(json_escape "$ARG_ACTION")"
        [ -n "$ARG_DETAIL" ] && json="$json,\"detail\":$(json_escape "$ARG_DETAIL")"
        [ -n "$ARG_FILE" ] && json="$json,\"file\":$(json_escape "$ARG_FILE")"
        json="$json}"
        entry="$json"
    fi

    echo "$entry" >> "$log_file"

    echo -e "${GREEN}$(t 'quality.healing.log_done')${NC} $log_file"
}

cmd_show() {
    parse_args "$@"

    if [ -z "$ARG_FEATURE" ]; then
        echo -e "${RED}$(t 'quality.healing.missing_feature')${NC}"
        echo "$(t 'quality.healing.usage_show')"
        exit 1
    fi

    local log_file
    if ! log_file=$(log_path_for "$ARG_FEATURE"); then
        echo -e "${RED}$(t 'quality.healing.no_evidence')${NC} $ARG_FEATURE"
        exit 1
    fi

    if [ ! -f "$log_file" ]; then
        echo -e "${YELLOW}$(t 'quality.healing.no_log')${NC} $ARG_FEATURE"
        exit 0
    fi

    local total
    total=$(wc -l < "$log_file" | tr -d ' ')

    echo "healing.jsonl — $ARG_FEATURE — $total $(t 'quality.healing.entries')"
    echo ""

    if command -v jq &> /dev/null; then
        tail -n "$ARG_LAST" "$log_file" | jq -r '"[\(.ts)] \(.severity | ascii_upcase)  \(.phase) / \(.action)\t\(.detail // "")"'
    else
        tail -n "$ARG_LAST" "$log_file"
    fi
}

cmd_stats() {
    parse_args "$@"

    if [ -z "$ARG_FEATURE" ]; then
        echo -e "${RED}$(t 'quality.healing.missing_feature')${NC}"
        echo "$(t 'quality.healing.usage_stats')"
        exit 1
    fi

    local log_file
    if ! log_file=$(log_path_for "$ARG_FEATURE"); then
        echo -e "${RED}$(t 'quality.healing.no_evidence')${NC} $ARG_FEATURE"
        exit 1
    fi

    if [ ! -f "$log_file" ]; then
        echo -e "${YELLOW}$(t 'quality.healing.no_log')${NC} $ARG_FEATURE"
        exit 0
    fi

    if ! command -v jq &> /dev/null; then
        echo -e "${RED}$(t 'quality.healing.jq_required')${NC}"
        exit 1
    fi

    local total
    total=$(wc -l < "$log_file" | tr -d ' ')

    echo "healing.jsonl — $ARG_FEATURE"
    echo "$(t 'quality.healing.total_entries'): $total"
    echo ""

    echo "$(t 'quality.healing.by_severity'):"
    jq -r '.severity' "$log_file" | sort | uniq -c | sort -rn | awk '{printf "  %-8s %s\n", $2, $1}'
    echo ""

    echo "$(t 'quality.healing.by_phase'):"
    jq -r '.phase' "$log_file" | sort | uniq -c | sort -rn | awk '{printf "  %-20s %s\n", $2, $1}'
    echo ""

    echo "$(t 'quality.healing.by_action'):"
    jq -r '.action' "$log_file" | sort | uniq -c | sort -rn | awk '{printf "  %-25s %s\n", $2, $1}'
}

# Dispatch
case "${1:-}" in
    log)
        shift
        cmd_log "$@"
        ;;
    show)
        shift
        cmd_show "$@"
        ;;
    stats)
        shift
        cmd_stats "$@"
        ;;
    *)
        echo "$(t 'quality.healing.usage')"
        exit 1
        ;;
esac
