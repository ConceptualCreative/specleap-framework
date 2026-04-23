#!/bin/bash
# SpecLeap — Compliance audit
# Checks 6 dimensions and produces a 0-100 score per dimension + total average.
# Writes a JSON with full detail to .quality/evidence/compliance/audit-TIMESTAMP.json

set +e   # don't abort on individual check failures

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

source "$ROOT/.specleap/i18n.sh"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# ---------- Utility: append an observation (tab-separated: dimension\ttext)
OBS_FILE=$(mktemp)
trap 'rm -f "$OBS_FILE"' EXIT

observe() {
    echo -e "$1\t$2" >> "$OBS_FILE"
}

# ---------- 1. Version
check_version() {
    local score=100
    local version
    version=$(grep -E '"version"' "$ROOT/package.json" | head -1 | sed 's/.*"version": *"\([^"]*\)".*/\1/')

    local last_tag
    last_tag=$(git -C "$ROOT" describe --tags --abbrev=0 2>/dev/null || echo "")

    if [ -z "$last_tag" ]; then
        # No tags yet: not penalised, common before first release
        :
    elif [ "v$version" != "$last_tag" ] && [ "$version" != "$last_tag" ]; then
        score=50
        observe "version" "$(t 'quality.compliance.version_mismatch') package.json=$version vs tag=$last_tag"
    fi

    VERSION_SCORE=$score
}

# ---------- 2. Skills count consistency
check_skills() {
    local score=100
    local skills_installed=0
    if [ -d "$HOME/.skills" ]; then
        skills_installed=$(find "$HOME/.skills" -maxdepth 1 -type d -not -path "$HOME/.skills" 2>/dev/null | wc -l | tr -d ' ')
    fi

    # Expected from baseline.json
    local baseline_count=0
    if [ -f "$ROOT/.quality/baselines/baseline.json" ] && command -v jq &>/dev/null; then
        baseline_count=$(jq -r '.repo_snapshot.skills_count // 0' "$ROOT/.quality/baselines/baseline.json")
    fi

    if [ "$skills_installed" -ne "$baseline_count" ] && [ "$baseline_count" -gt 0 ]; then
        score=$((score - 25))
        observe "skills" "$(t 'quality.compliance.skills_mismatch') installed=$skills_installed, baseline=$baseline_count"
    fi

    # Check README mentions N skills consistently
    local readme_counts
    readme_counts=$(grep -oE '[0-9]+ Agent Skills' "$ROOT/README.md" 2>/dev/null | grep -oE '^[0-9]+' | sort -u)
    if [ -n "$readme_counts" ]; then
        for c in $readme_counts; do
            if [ "$c" != "$skills_installed" ] && [ "$c" != "20" ] && [ "$c" != "14" ]; then
                # 20 (tier 1) and 14 (tier 2) are valid partial counts
                score=$((score - 25))
                observe "skills" "$(t 'quality.compliance.skills_mismatch') README menciona $c Agent Skills"
            fi
        done
    fi

    [ $score -lt 0 ] && score=0
    SKILLS_SCORE=$score
    SKILLS_COUNT=$skills_installed
}

# ---------- 3. i18n parity
check_i18n() {
    local score=100
    local es_file="$ROOT/.specleap/i18n/es.json"
    local en_file="$ROOT/.specleap/i18n/en.json"

    if [ ! -f "$es_file" ] || [ ! -f "$en_file" ]; then
        score=0
        observe "i18n" "$(t 'quality.compliance.i18n_missing_file')"
        I18N_SCORE=$score
        return
    fi

    if ! command -v jq &>/dev/null; then
        I18N_SCORE=$score   # can't verify → generous default
        return
    fi

    # Flatten keys: extract all leaf paths
    local es_keys en_keys
    es_keys=$(jq -r 'paths(scalars) | map(tostring) | join(".")' "$es_file" 2>/dev/null | sort -u)
    en_keys=$(jq -r 'paths(scalars) | map(tostring) | join(".")' "$en_file" 2>/dev/null | sort -u)

    local missing_in_en missing_in_es
    missing_in_en=$(comm -23 <(echo "$es_keys") <(echo "$en_keys"))
    missing_in_es=$(comm -13 <(echo "$es_keys") <(echo "$en_keys"))

    local missing_count=0
    if [ -n "$missing_in_en" ]; then
        while IFS= read -r k; do
            [ -z "$k" ] && continue
            missing_count=$((missing_count + 1))
            observe "i18n" "$(t 'quality.compliance.i18n_missing_key') en.json: $k"
        done <<< "$missing_in_en"
    fi
    if [ -n "$missing_in_es" ]; then
        while IFS= read -r k; do
            [ -z "$k" ] && continue
            missing_count=$((missing_count + 1))
            observe "i18n" "$(t 'quality.compliance.i18n_missing_key') es.json: $k"
        done <<< "$missing_in_es"
    fi

    score=$((100 - missing_count * 5))
    [ $score -lt 0 ] && score=0
    I18N_SCORE=$score
}

# ---------- 4. Hooks
check_hooks() {
    local score=0
    local hook="$ROOT/.claude/hooks/spec-guard.sh"
    local template="$ROOT/.claude/settings.json.template"

    if [ -f "$hook" ]; then
        score=$((score + 25))
        if head -1 "$hook" | grep -q '^#!/bin/bash\|^#!/usr/bin/env bash'; then
            score=$((score + 25))
        else
            observe "hooks" "$(t 'quality.compliance.hook_not_shebang') spec-guard.sh"
        fi
        if [ -x "$hook" ]; then
            score=$((score + 25))
        else
            observe "hooks" "$(t 'quality.compliance.hook_not_exec') spec-guard.sh"
        fi
    else
        observe "hooks" "$(t 'quality.compliance.hook_missing') .claude/hooks/spec-guard.sh"
    fi

    if [ -f "$template" ] && grep -q "spec-guard.sh" "$template"; then
        score=$((score + 25))
    else
        observe "hooks" "$(t 'quality.compliance.hook_not_in_template')"
    fi

    HOOKS_SCORE=$score
}

# ---------- 5. Baseline freshness
check_baseline() {
    local score=100
    local baseline="$ROOT/.quality/baselines/baseline.json"

    if [ ! -f "$baseline" ] || ! command -v jq &>/dev/null; then
        BASELINE_SCORE=$score
        return
    fi

    local saved_loc saved_files saved_agents saved_commands
    saved_loc=$(jq -r '.repo_snapshot.loc_total // 0' "$baseline")
    saved_files=$(jq -r '.repo_snapshot.files_count // 0' "$baseline")
    saved_agents=$(jq -r '.repo_snapshot.agents_count // 0' "$baseline")
    saved_commands=$(jq -r '.repo_snapshot.commands_count // 0' "$baseline")

    # Recompute
    local real_files real_loc real_agents real_commands
    real_files=$(find "$ROOT" -type f \
        \( -name "*.md" -o -name "*.sh" -o -name "*.json" -o -name "*.mdc" \) \
        -not -path "*/node_modules/*" -not -path "*/vendor/*" \
        -not -path "*/dist/*" -not -path "*/.git/*" -not -path "*/.astro/*" \
        -not -path "*/proyectos/*" 2>/dev/null | wc -l | tr -d ' ')

    real_loc=0
    if [ "$real_files" -gt 0 ]; then
        real_loc=$(find "$ROOT" -type f \
            \( -name "*.md" -o -name "*.sh" -o -name "*.json" -o -name "*.mdc" \) \
            -not -path "*/node_modules/*" -not -path "*/vendor/*" \
            -not -path "*/dist/*" -not -path "*/.git/*" -not -path "*/.astro/*" \
            -not -path "*/proyectos/*" -exec cat {} + 2>/dev/null | wc -l | tr -d ' ')
    fi

    real_agents=$(find "$ROOT/.agents" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    real_commands=$(find "$ROOT/.commands" -maxdepth 1 -type f -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

    # Compute max diff pct
    local max_diff=0
    local fields=("loc:$saved_loc:$real_loc" "files:$saved_files:$real_files" "agents:$saved_agents:$real_agents" "commands:$saved_commands:$real_commands")
    for fld in "${fields[@]}"; do
        IFS=':' read -r name saved real <<< "$fld"
        if [ "$real" -gt 0 ]; then
            local diff
            diff=$(awk "BEGIN { s=$saved; r=$real; d = (s>r?s-r:r-s); pct = (r>0 ? d/r*100 : 0); printf \"%.0f\", pct }")
            [ "$diff" -gt "$max_diff" ] && max_diff=$diff
        fi
    done

    if [ "$max_diff" -gt 20 ]; then
        score=60
        observe "baseline" "$(t 'quality.compliance.baseline_stale')"
    elif [ "$max_diff" -gt 5 ]; then
        score=85
        observe "baseline" "$(t 'quality.compliance.baseline_stale')"
    fi

    BASELINE_SCORE=$score
}

# ---------- 6. Docs residuals
check_docs() {
    local score=100
    local found=0
    local patterns="iapanderson archspec openclaw pamela"

    for md in "$ROOT"/*.md; do
        [ -f "$md" ] || continue
        local filename
        filename=$(basename "$md")
        # CHANGELOG is history
        [ "$filename" = "CHANGELOG.md" ] && continue

        for p in $patterns; do
            if grep -qi "$p" "$md"; then
                found=$((found + 1))
                observe "docs" "$(t 'quality.compliance.docs_residual') $filename: $p"
            fi
        done
    done

    score=$((100 - found * 10))
    [ $score -lt 0 ] && score=0
    DOCS_SCORE=$score
}

# ---------- Run all checks
check_version
check_skills
check_i18n
check_hooks
check_baseline
check_docs

TOTAL=$(( (VERSION_SCORE + SKILLS_SCORE + I18N_SCORE + HOOKS_SCORE + BASELINE_SCORE + DOCS_SCORE) / 6 ))

# ---------- Print human-readable summary
echo -e "${BOLD}$(t 'quality.compliance.header')${NC}"
echo "──────────────────────────────────────────"
printf "  %-12s %3d/100\n" "$(t 'quality.compliance.version')" "$VERSION_SCORE"
printf "  %-12s %3d/100\n" "$(t 'quality.compliance.skills')" "$SKILLS_SCORE"
printf "  %-12s %3d/100\n" "$(t 'quality.compliance.i18n')" "$I18N_SCORE"
printf "  %-12s %3d/100\n" "$(t 'quality.compliance.hooks')" "$HOOKS_SCORE"
printf "  %-12s %3d/100\n" "$(t 'quality.compliance.baseline')" "$BASELINE_SCORE"
printf "  %-12s %3d/100\n" "$(t 'quality.compliance.docs')" "$DOCS_SCORE"
echo "──────────────────────────────────────────"
echo -e "  ${BOLD}$(t 'quality.compliance.total'): $TOTAL/100${NC}"

# Observations
if [ -s "$OBS_FILE" ]; then
    echo ""
    echo -e "${YELLOW}$(t 'quality.compliance.observations'):${NC}"
    while IFS=$'\t' read -r dim msg; do
        printf "  [%s] %s\n" "$dim" "$msg"
    done < "$OBS_FILE"
fi

# ---------- Write JSON detail
TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)
OUT_DIR="$ROOT/.quality/evidence/compliance"
mkdir -p "$OUT_DIR"
OUT_FILE="$OUT_DIR/audit-$TS.json"

if command -v jq &>/dev/null; then
    # Build observations array
    OBS_JSON="[]"
    if [ -s "$OBS_FILE" ]; then
        OBS_JSON=$(jq -Rs '
            split("\n")
            | map(select(length > 0))
            | map(split("\t"))
            | map({dimension: .[0], message: .[1]})
        ' "$OBS_FILE")
    fi

    jq -n \
        --arg ts "$TS" \
        --argjson version "$VERSION_SCORE" \
        --argjson skills "$SKILLS_SCORE" \
        --argjson i18n "$I18N_SCORE" \
        --argjson hooks "$HOOKS_SCORE" \
        --argjson baseline "$BASELINE_SCORE" \
        --argjson docs "$DOCS_SCORE" \
        --argjson total "$TOTAL" \
        --argjson observations "$OBS_JSON" \
        '{
            timestamp: $ts,
            scores: {
                version: $version,
                skills: $skills,
                i18n: $i18n,
                hooks: $hooks,
                baseline: $baseline,
                docs: $docs
            },
            total: $total,
            observations: $observations
        }' > "$OUT_FILE"

    echo ""
    echo -e "$(t 'quality.compliance.details_saved') $OUT_FILE"
fi

exit 0
