#!/usr/bin/env bash
# openspec archive — Archivar propuesta completada
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/common.sh"

usage() {
    if [ "$(cli_lang)" = "en" ]; then
        cat <<EOF
openspec archive — Archive a completed proposal

USAGE:
    openspec archive <CHANGE-ID> [options]

OPTIONS:
    --keep-branch       Do not delete the feature branch
    --no-merge          Skip merge check (useful if already merged manually)
    -h, --help          Show help

DESCRIPTION:
    Archives a completed and merged proposal:
    1. Verifies the PR is merged
    2. Updates status to "completed"
    3. Deletes the feature branch (optional)
    4. Generates a final report

EXAMPLES:
    openspec archive CHANGE-001
    openspec archive CHANGE-002 --keep-branch
    openspec archive CHANGE-003 --no-merge

PREREQUISITES:
    - PR merged into the base branch
    - Code review approved

EOF
    else
        cat <<EOF
openspec archive — Archivar propuesta completada

USAGE:
    openspec archive <CHANGE-ID> [options]

OPTIONS:
    --keep-branch       No eliminar branch feature
    --no-merge          No verificar merge (útil si ya mergeado manualmente)
    -h, --help          Mostrar ayuda

DESCRIPTION:
    Archiva una propuesta completada y mergeada:
    1. Verifica que PR esté mergeado
    2. Actualiza estado a "completed"
    3. Elimina branch feature (opcional)
    4. Genera reporte final

EXAMPLES:
    openspec archive CHANGE-001
    openspec archive CHANGE-002 --keep-branch
    openspec archive CHANGE-003 --no-merge

PREREQUISITES:
    - PR mergeado a base branch
    - Code review aprobado

EOF
    fi
}

# Parse arguments
CHANGE_ID=""
KEEP_BRANCH=false
NO_MERGE_CHECK=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --keep-branch)
            KEEP_BRANCH=true
            shift
            ;;
        --no-merge)
            NO_MERGE_CHECK=true
            shift
            ;;
        CHANGE-*)
            CHANGE_ID="$1"
            shift
            ;;
        *)
            error "Argumento desconocido: $1"
            usage
            exit 1
            ;;
    esac
done

# Validate
validate_project

if [[ -z "$CHANGE_ID" ]]; then
    error "Debe proporcionar CHANGE-ID"
    usage
    exit 1
fi

# Find change directory
CHANGE_DIR=$(find "$PROJECT_ROOT/openspec/changes" -maxdepth 1 -type d -name "${CHANGE_ID}-*" | head -n1)

if [[ -z "$CHANGE_DIR" ]] || [[ ! -d "$CHANGE_DIR" ]]; then
    error "Propuesta no encontrada: $CHANGE_ID"
    exit 1
fi

CHANGE_NAME=$(basename "$CHANGE_DIR" | sed "s/^${CHANGE_ID}-//")

info "Archivando propuesta: $CHANGE_ID — $CHANGE_NAME"

# Check if PR is merged (if gh is available)
if [[ "$NO_MERGE_CHECK" == false ]] && command -v gh &> /dev/null; then
    step "Verificando estado de PR..."
    
    # Find PR for this change
    FEATURE_BRANCH="feat/${CHANGE_ID}-${CHANGE_NAME}"
    PR_STATE=$(gh pr list --head "$FEATURE_BRANCH" --state all --json state --jq '.[0].state' 2>/dev/null || echo "")
    
    if [[ "$PR_STATE" != "MERGED" ]]; then
        warning "PR no parece estar mergeado (estado: ${PR_STATE:-desconocido})"
        read -p "¿Continuar de todos modos? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Operación cancelada"
            exit 0
        fi
    else
        success "PR verificado como mergeado"
    fi
fi

# Update proposal state
step "Actualizando estado a: completed"

sed -i.bak 's/Estado | .*/Estado | completed/' "$CHANGE_DIR/proposal.md"
rm -f "$CHANGE_DIR/proposal.md.bak"

# Add completion date
COMPLETION_DATE=$(current_date)
echo -e "\n## Completada\n- Fecha: $COMPLETION_DATE" >> "$CHANGE_DIR/proposal.md"

# Update spec states if delta specs were applied
if [[ -d "$CHANGE_DIR/specs" ]]; then
    for delta_spec in "$CHANGE_DIR/specs"/**/*.spec.md; do
        if [[ -f "$delta_spec" ]]; then
            rel_path="${delta_spec#$CHANGE_DIR/specs/}"
            target_spec="$PROJECT_ROOT/openspec/specs/$rel_path"
            
            if [[ -f "$target_spec" ]]; then
                # Update state to implemented
                sed -i.bak 's/Estado: draft/Estado: implemented/' "$target_spec"
                sed -i.bak 's/Estado: review/Estado: implemented/' "$target_spec"
                sed -i.bak 's/Estado: approved/Estado: implemented/' "$target_spec"
                rm -f "$target_spec.bak"
                
                success "Spec marcada como implemented: $rel_path"
            fi
        fi
    done
fi

# Commit archive changes
git add "$CHANGE_DIR/proposal.md"
if [[ -d "$PROJECT_ROOT/openspec/specs" ]]; then
    git add "$PROJECT_ROOT/openspec/specs"
fi

git commit -m "chore(openspec): archivar $CHANGE_ID como completed

## Qué se hizo
- Marcar propuesta como completed
- Actualizar specs a implemented

## Refs
- Propuesta: openspec/changes/$CHANGE_ID-$CHANGE_NAME/
" || true

success "Propuesta archivada"

# Delete feature branch if requested
if [[ "$KEEP_BRANCH" == false ]]; then
    FEATURE_BRANCH="feat/${CHANGE_ID}-${CHANGE_NAME}"
    
    step "Eliminando branch feature: $FEATURE_BRANCH"
    
    # Switch to base branch first
    BASE_BRANCH="develop"
    if git show-ref --verify --quiet "refs/heads/$BASE_BRANCH"; then
        git checkout "$BASE_BRANCH" || true
    elif git show-ref --verify --quiet "refs/heads/main"; then
        git checkout main || true
    fi
    
    # Delete local branch
    git branch -d "$FEATURE_BRANCH" 2>/dev/null || warning "Branch local no encontrado"
    
    # Delete remote branch
    git push origin --delete "$FEATURE_BRANCH" 2>/dev/null || warning "Branch remoto no encontrado o ya eliminado"
    
    success "Branch eliminado"
else
    info "Branch feature conservado (--keep-branch)"
fi

# Generate final report
step "Generando reporte final..."

REPORT_FILE="$CHANGE_DIR/COMPLETION_REPORT.md"

cat > "$REPORT_FILE" <<EOF
# Reporte de Completación: $CHANGE_ID

| Campo | Valor |
|-------|-------|
| ID | $CHANGE_ID |
| Título | $CHANGE_NAME |
| Completada | $COMPLETION_DATE |

## Archivos Generados

- proposal.md
- design.md
- tasks.md
- $(find "$CHANGE_DIR/specs" -name "*.spec.md" 2>/dev/null | wc -l) delta specs

## Specs Actualizadas

$(if [[ -d "$CHANGE_DIR/specs" ]]; then
    find "$CHANGE_DIR/specs" -name "*.spec.md" -exec basename {} \; 2>/dev/null | sed 's/^/- /'
else
    echo "Ninguna"
fi)

## Commits

\`\`\`bash
$(git log --oneline --grep="$CHANGE_ID" 2>/dev/null || echo "No commits found")
\`\`\`

## Estado Final

✅ Propuesta completada y archivada
✅ Specs actualizadas a "implemented"
$(if [[ "$KEEP_BRANCH" == false ]]; then echo "✅ Branch feature eliminado"; else echo "⚠️ Branch feature conservado"; fi)

---
Generado: $(current_datetime)
EOF

success "Reporte generado: $REPORT_FILE"

# Final message
success "✅ $CHANGE_ID archivado exitosamente"
info ""
info "Reporte final: $REPORT_FILE"
info ""
info "La propuesta está completada y puede consultarse en:"
info "  openspec/changes/$CHANGE_ID-$CHANGE_NAME/"
