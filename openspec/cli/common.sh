#!/usr/bin/env bash
# Common functions for OpenSpec CLI

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Output helpers
info() { echo -e "${BLUE}ℹ${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warning() { echo -e "${YELLOW}⚠${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*" >&2; }
step() { echo -e "${CYAN}→${NC} $*"; }

# Validate project structure
validate_project() {
    if [[ ! -f "$PROJECT_ROOT/openspec/config.yaml" ]]; then
        error "No se encuentra openspec/config.yaml"
        error "Asegúrate de estar en la raíz del proyecto"
        exit 1
    fi
}

# Get next ID for spec/change
get_next_id() {
    local type="$1"  # "spec" or "change"
    local dir=""
    
    case $type in
        spec)
            dir="$PROJECT_ROOT/openspec/specs"
            ;;
        change)
            dir="$PROJECT_ROOT/openspec/changes"
            ;;
        *)
            error "Tipo desconocido: $type"
            return 1
            ;;
    esac
    
    # Find highest existing ID
    local max_id=0
    if [[ -d "$dir" ]]; then
        for item in "$dir"/*; do
            if [[ -d "$item" ]] || [[ -f "$item" ]]; then
                local basename=$(basename "$item")
                if [[ $basename =~ ^(SPEC|CHANGE)-([0-9]+) ]]; then
                    local num="${BASH_REMATCH[2]}"
                    if (( num > max_id )); then
                        max_id=$num
                    fi
                fi
            fi
        done
    fi
    
    # Next ID
    local next_id=$((max_id + 1))
    printf "%04d" "$next_id"
}

# Check if command exists
require_command() {
    local cmd="$1"
    local install_hint="${2:-}"
    
    if ! command -v "$cmd" &> /dev/null; then
        error "Comando requerido no encontrado: $cmd"
        if [[ -n "$install_hint" ]]; then
            info "$install_hint"
        fi
        exit 1
    fi
}

# Validate YAML file
validate_yaml() {
    local file="$1"
    
    if ! command -v yq &> /dev/null; then
        warning "yq no instalado, omitiendo validación YAML"
        return 0
    fi
    
    if ! yq eval "$file" > /dev/null 2>&1; then
        error "YAML inválido: $file"
        return 1
    fi
    
    return 0
}

# Parse config value from config.yaml
get_config() {
    local key="$1"
    local config_file="$PROJECT_ROOT/openspec/config.yaml"
    
    if command -v yq &> /dev/null; then
        yq eval ".$key" "$config_file" 2>/dev/null || echo ""
    else
        # Fallback: simple grep
        grep "^${key}:" "$config_file" | cut -d':' -f2 | xargs
    fi
}

# Create directory if not exists
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

# Copy template with replacements
copy_template() {
    local template="$1"
    local output="$2"
    shift 2
    local replacements=("$@")
    
    if [[ ! -f "$template" ]]; then
        error "Template no encontrado: $template"
        return 1
    fi
    
    local content=$(cat "$template")
    
    # Apply replacements
    for replacement in "${replacements[@]}"; do
        local key="${replacement%%=*}"
        local value="${replacement#*=}"
        content="${content//$key/$value}"
    done
    
    echo "$content" > "$output"
}

# Git helpers
git_current_branch() {
    git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown"
}

git_is_clean() {
    [[ -z $(git status --porcelain) ]]
}

git_has_changes() {
    ! git_is_clean
}

# Ticket integration helpers
parse_ticket_id() {
    local text="$1"
    if [[ $text =~ ([a-zA-Z0-9-]+-[0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    fi
}

# Date helpers
current_date() {
    date +%Y-%m-%d
}

current_datetime() {
    date +%Y-%m-%d\ %H:%M:%S
}
