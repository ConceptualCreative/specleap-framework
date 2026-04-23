#!/bin/bash
# SpecLeap — Quality Baseline helper
# Usage: bash scripts/quality-baseline.sh [init|snapshot|new-evidence FEATURE]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load i18n helper (exposes t "key.path" and SPECLEAP_LANG)
source "$ROOT/.specleap/i18n.sh"

QUALITY_DIR="$ROOT/.quality"
BASELINE_FILE="$QUALITY_DIR/baselines/baseline.json"
EVIDENCE_DIR="$QUALITY_DIR/evidence"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

cmd_init() {
    echo -e "$(t 'quality.baseline.init_start')"

    mkdir -p "$QUALITY_DIR/baselines"
    mkdir -p "$EVIDENCE_DIR"

    if [ ! -f "$EVIDENCE_DIR/.gitkeep" ]; then
        touch "$EVIDENCE_DIR/.gitkeep"
    fi

    if [ -f "$BASELINE_FILE" ]; then
        echo -e "${YELLOW}$(t 'quality.baseline.already_exists')${NC} $BASELINE_FILE"
        return 0
    fi

    cat > "$BASELINE_FILE" <<EOF
{
  "version": "1.0",
  "updated_at": "$(date -u +%Y-%m-%d)",
  "thresholds": {
    "coverage_min": 80,
    "coverage_target": 90,
    "complexity_max_per_function": 10,
    "duplicates_max_pct": 3
  },
  "repo_snapshot": {
    "loc_total": 0,
    "files_count": 0,
    "agents_count": 0,
    "commands_count": 0,
    "skills_count": 0
  }
}
EOF

    echo -e "${GREEN}$(t 'quality.baseline.init_done')${NC}"
}

cmd_snapshot() {
    echo -e "$(t 'quality.baseline.snapshot_start')"

    if [ ! -f "$BASELINE_FILE" ]; then
        echo -e "${RED}$(t 'quality.baseline.missing_baseline')${NC}"
        echo "$(t 'quality.baseline.run_init_first')"
        exit 1
    fi

    if ! command -v jq &> /dev/null; then
        echo -e "${RED}$(t 'quality.baseline.jq_required')${NC}"
        exit 1
    fi

    # Count source files (exclude node_modules, vendor, dist, .git, .astro)
    local files_count
    files_count=$(find "$ROOT" \
        -type f \
        \( -name "*.md" -o -name "*.sh" -o -name "*.json" -o -name "*.mdc" \) \
        -not -path "*/node_modules/*" \
        -not -path "*/vendor/*" \
        -not -path "*/dist/*" \
        -not -path "*/.git/*" \
        -not -path "*/.astro/*" \
        -not -path "*/proyectos/*" \
        2>/dev/null | wc -l | tr -d ' ')

    # Count total lines of code in those files
    local loc_total=0
    if [ "$files_count" -gt 0 ]; then
        loc_total=$(find "$ROOT" \
            -type f \
            \( -name "*.md" -o -name "*.sh" -o -name "*.json" -o -name "*.mdc" \) \
            -not -path "*/node_modules/*" \
            -not -path "*/vendor/*" \
            -not -path "*/dist/*" \
            -not -path "*/.git/*" \
            -not -path "*/.astro/*" \
            -not -path "*/proyectos/*" \
            -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')
    fi

    local agents_count
    agents_count=$(find "$ROOT/.agents" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

    local commands_count
    commands_count=$(find "$ROOT/.commands" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

    local skills_count=0
    if [ -d "$HOME/.skills" ]; then
        skills_count=$(find "$HOME/.skills" -maxdepth 1 -type d -not -path "$HOME/.skills" 2>/dev/null | wc -l | tr -d ' ')
    fi

    local tmp_file
    tmp_file=$(mktemp)
    jq \
        --arg date "$(date -u +%Y-%m-%d)" \
        --argjson loc "$loc_total" \
        --argjson files "$files_count" \
        --argjson agents "$agents_count" \
        --argjson commands "$commands_count" \
        --argjson skills "$skills_count" \
        '.updated_at = $date
         | .repo_snapshot.loc_total = $loc
         | .repo_snapshot.files_count = $files
         | .repo_snapshot.agents_count = $agents
         | .repo_snapshot.commands_count = $commands
         | .repo_snapshot.skills_count = $skills' \
        "$BASELINE_FILE" > "$tmp_file"
    mv "$tmp_file" "$BASELINE_FILE"

    echo -e "${GREEN}$(t 'quality.baseline.snapshot_done')${NC}"
    echo "  LOC: $loc_total | files: $files_count | agents: $agents_count | commands: $commands_count | skills: $skills_count"
}

cmd_new_evidence() {
    local slug="$1"

    if [ -z "$slug" ]; then
        echo -e "${RED}$(t 'quality.baseline.missing_slug')${NC}"
        echo "$(t 'quality.baseline.usage')"
        exit 1
    fi

    # Slug validation: lowercase, numbers, hyphens only
    if ! [[ "$slug" =~ ^[a-z0-9-]+$ ]]; then
        echo -e "${RED}$(t 'quality.baseline.invalid_slug')${NC} $slug"
        exit 1
    fi

    local target="$EVIDENCE_DIR/$slug"
    echo -e "$(t 'quality.baseline.evidence_start') $slug"

    mkdir -p "$target/tests"
    mkdir -p "$target/security"

    cat > "$target/metadata.json" <<EOF
{
  "feature_slug": "$slug",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "ticket": "",
  "author": "",
  "status": "planning",
  "baseline_version": "1.0"
}
EOF

    cat > "$target/decisions.md" <<EOF
# Decisiones técnicas — $slug

## Contexto

(Resumen del ticket y problema que resuelve)

## Decisiones

### [Título de la decisión]

**Fecha:** $(date -u +%Y-%m-%d)
**Contexto:** …
**Opciones consideradas:**
- …

**Decisión:** …
**Consecuencias:** …
EOF

    touch "$target/tests/unit.txt"
    touch "$target/tests/integration.txt"
    touch "$target/tests/coverage.json"
    touch "$target/security/audit.txt"

    echo -e "${GREEN}$(t 'quality.baseline.evidence_done')${NC} $target"
}

# Dispatch
case "${1:-}" in
    init)
        cmd_init
        ;;
    snapshot)
        cmd_snapshot
        ;;
    new-evidence)
        cmd_new_evidence "$2"
        ;;
    *)
        echo "$(t 'quality.baseline.usage')"
        exit 1
        ;;
esac
