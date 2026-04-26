#!/usr/bin/env bash
# openspec status — Ver estado de propuestas
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/common.sh"

usage() {
    if [ "$(cli_lang)" = "en" ]; then
        cat <<EOF
openspec status — View proposal status

USAGE:
    openspec status [options]

OPTIONS:
    --all               Show all (including completed)
    --state <state>     Filter by state
    --format <fmt>      Format (table|json|list)
    -h, --help          Show help

DESCRIPTION:
    Shows the current status of all active proposals.

EXAMPLES:
    openspec status
    openspec status --all
    openspec status --state in_progress
    openspec status --format json

STATES:
    draft, review, approved, in_progress, testing, completed, archived, rejected

EOF
    else
        cat <<EOF
openspec status — Ver estado de propuestas

USAGE:
    openspec status [options]

OPTIONS:
    --all               Mostrar todas (incluidas completadas)
    --state <state>     Filtrar por estado
    --format <fmt>      Formato (table|json|list)
    -h, --help          Mostrar ayuda

DESCRIPTION:
    Muestra el estado actual de todas las propuestas activas.

EXAMPLES:
    openspec status
    openspec status --all
    openspec status --state in_progress
    openspec status --format json

STATES:
    draft, review, approved, in_progress, testing, completed, archived, rejected

EOF
    fi
}

# Parse arguments
SHOW_ALL=false
FILTER_STATE=""
FORMAT="table"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --all)
            SHOW_ALL=true
            shift
            ;;
        --state)
            FILTER_STATE="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        *)
            error "Argumento desconocido: $1"
            usage
            exit 1
            ;;
    esac
done

validate_project

info "Estado de propuestas OpenSpec"
echo ""

CHANGES_DIR="$PROJECT_ROOT/openspec/changes"

if [[ ! -d "$CHANGES_DIR" ]]; then
    warning "No hay directorio de cambios: $CHANGES_DIR"
    exit 0
fi

# Collect proposals
declare -a PROPOSALS=()

for change_dir in "$CHANGES_DIR"/CHANGE-*; do
    if [[ ! -d "$change_dir" ]]; then
        continue
    fi
    
    if [[ ! -f "$change_dir/proposal.md" ]]; then
        continue
    fi
    
    # Parse proposal data
    CHANGE_ID=$(basename "$change_dir" | grep -oP '^CHANGE-\d+')
    CHANGE_NAME=$(basename "$change_dir" | sed "s/^${CHANGE_ID}-//")
    STATE=$(grep -oP 'Estado.*\|\s*\K\w+' "$change_dir/proposal.md" | head -n1 || echo "unknown")
    PRIORITY=$(grep -oP 'Prioridad.*\|\s*\K\w+' "$change_dir/proposal.md" | head -n1 || echo "unknown")
    AUTHOR=$(grep -oP 'Autor.*\|\s*\K[^\|]+' "$change_dir/proposal.md" | head -n1 | xargs || echo "unknown")
    DATE=$(grep -oP 'Fecha.*\|\s*\K[\d-]+' "$change_dir/proposal.md" | head -n1 || echo "unknown")
    
    # Filter
    if [[ "$SHOW_ALL" == false ]] && [[ "$STATE" == "completed" || "$STATE" == "archived" || "$STATE" == "rejected" ]]; then
        continue
    fi
    
    if [[ -n "$FILTER_STATE" ]] && [[ "$STATE" != "$FILTER_STATE" ]]; then
        continue
    fi
    
    PROPOSALS+=("$CHANGE_ID|$CHANGE_NAME|$STATE|$PRIORITY|$AUTHOR|$DATE")
done

if [[ ${#PROPOSALS[@]} -eq 0 ]]; then
    info "No hay propuestas que mostrar"
    exit 0
fi

# Output
case $FORMAT in
    table)
        echo "ID          | Título                          | Estado       | Prioridad | Autor        | Fecha"
        echo "------------|--------------------------------|--------------|-----------|--------------|----------"
        for proposal in "${PROPOSALS[@]}"; do
            IFS='|' read -r id name state priority author date <<< "$proposal"
            printf "%-11s | %-30s | %-12s | %-9s | %-12s | %s\n" \
                "$id" "${name:0:30}" "$state" "$priority" "${author:0:12}" "$date"
        done
        ;;
    
    json)
        echo "{"
        echo '  "proposals": ['
        for i in "${!PROPOSALS[@]}"; do
            IFS='|' read -r id name state priority author date <<< "${PROPOSALS[$i]}"
            echo "    {"
            echo "      \"id\": \"$id\","
            echo "      \"name\": \"$name\","
            echo "      \"state\": \"$state\","
            echo "      \"priority\": \"$priority\","
            echo "      \"author\": \"$author\","
            echo "      \"date\": \"$date\""
            if [[ $i -lt $((${#PROPOSALS[@]} - 1)) ]]; then
                echo "    },"
            else
                echo "    }"
            fi
        done
        echo "  ]"
        echo "}"
        ;;
    
    list)
        for proposal in "${PROPOSALS[@]}"; do
            IFS='|' read -r id name state priority author date <<< "$proposal"
            echo "• $id — $name"
            echo "  Estado: $state | Prioridad: $priority | Autor: $author | Fecha: $date"
            echo ""
        done
        ;;
esac

# Summary
if [[ "$FORMAT" == "table" ]] || [[ "$FORMAT" == "list" ]]; then
    echo ""
    info "Total: ${#PROPOSALS[@]} propuesta(s)"
    
    # Count by state
    declare -A STATE_COUNTS
    for proposal in "${PROPOSALS[@]}"; do
        IFS='|' read -r id name state priority author date <<< "$proposal"
        STATE_COUNTS[$state]=$((${STATE_COUNTS[$state]:-0} + 1))
    done
    
    echo ""
    for state in "${!STATE_COUNTS[@]}"; do
        echo "  $state: ${STATE_COUNTS[$state]}"
    done
fi
