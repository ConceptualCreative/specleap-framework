#!/usr/bin/env bash
# openspec code-review — Solicitar review de CodeRabbit
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/common.sh"

usage() {
    cat <<EOF
openspec code-review — Solicitar review de CodeRabbit

USAGE:
    openspec code-review <CHANGE-ID> [options]

OPTIONS:
    --create-pr         Crear Pull Request automáticamente
    --base <branch>     Branch base para PR (default: develop)
    --draft             Crear PR como draft
    -h, --help          Mostrar ayuda

DESCRIPTION:
    Solicita code review para una propuesta:
    1. Verifica que tests pasen (openspec verify)
    2. Crea PR en GitHub (si --create-pr)
    3. CodeRabbit hace review automático
    4. Genera reporte de review

EXAMPLES:
    openspec code-review CHANGE-001
    openspec code-review CHANGE-002 --create-pr
    openspec code-review CHANGE-003 --create-pr --draft

PREREQUISITES:
    - Branch feature creado
    - Tests pasando
    - GitHub CLI configurado (gh)
    - CodeRabbit activo en el repo

EOF
}

# Parse arguments
CHANGE_ID=""
CREATE_PR=false
BASE_BRANCH="develop"
DRAFT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --create-pr)
            CREATE_PR=true
            shift
            ;;
        --base)
            BASE_BRANCH="$2"
            shift 2
            ;;
        --draft)
            DRAFT=true
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

info "Solicitando code review para: $CHANGE_ID — $CHANGE_NAME"

# Run verification first
step "Verificando tests y specs..."
if ! "$SCRIPT_DIR/verify.sh" "$CHANGE_ID"; then
    error "La verificación falló. Corrige los problemas antes de solicitar review."
    exit 1
fi

# Check Git status
CURRENT_BRANCH=$(git_current_branch)
if [[ "$CURRENT_BRANCH" == "main" ]] || [[ "$CURRENT_BRANCH" == "master" ]] || [[ "$CURRENT_BRANCH" == "develop" ]]; then
    error "No puedes crear PR desde branch principal: $CURRENT_BRANCH"
    info "Usa: openspec apply $CHANGE_ID para crear feature branch"
    exit 1
fi

# Push current branch
step "Pusheando branch a remoto..."
if ! git push -u origin "$CURRENT_BRANCH" 2>&1; then
    # Branch may already exist
    if ! git push origin "$CURRENT_BRANCH" 2>&1; then
        error "No se pudo pushear branch"
        exit 1
    fi
fi
success "Branch pusheado: $CURRENT_BRANCH"

# Create PR if requested
if [[ "$CREATE_PR" == true ]]; then
    require_command "gh" "Instalar GitHub CLI: https://cli.github.com"
    
    step "Creando Pull Request..."
    
    # Extract ticket id from proposal
    TICKET_ID=$(grep -oP 'Ticket.*\|\s*\K[a-zA-Z0-9-]+-\d+' "$CHANGE_DIR/proposal.md" || echo "")

    # PR title
    PR_TITLE="$CHANGE_ID: $CHANGE_NAME"
    if [[ -n "$TICKET_ID" ]]; then
        PR_TITLE="$TICKET_ID — $CHANGE_NAME"
    fi
    
    # PR body from proposal
    PR_BODY=$(cat <<EOF
## Propuesta
$CHANGE_ID — $CHANGE_NAME

## Descripción
$(grep -A 10 "## Resumen Ejecutivo" "$CHANGE_DIR/proposal.md" | tail -n +2 || echo "Ver propuesta completa en openspec/changes/$CHANGE_ID-$CHANGE_NAME/")

## Archivos Clave
- \`openspec/changes/$CHANGE_ID-$CHANGE_NAME/proposal.md\` — QUÉ y POR QUÉ
- \`openspec/changes/$CHANGE_ID-$CHANGE_NAME/design.md\` — CÓMO (diseño técnico)
- \`openspec/changes/$CHANGE_ID-$CHANGE_NAME/tasks.md\` — Tareas y Testing Report

## Testing Report
Ver \`tasks.md\` para resultados completos.

## Referencias
- Propuesta: openspec/changes/$CHANGE_ID-$CHANGE_NAME/
$(if [[ -n "$TICKET_ID" ]]; then echo "- Ticket: $TICKET_ID"; fi)

---
**Code Review:** CodeRabbit está activo. Revisa comentarios automáticos.
EOF
)
    
    # Create PR
    PR_ARGS=(
        --base "$BASE_BRANCH"
        --head "$CURRENT_BRANCH"
        --title "$PR_TITLE"
        --body "$PR_BODY"
    )
    
    if [[ "$DRAFT" == true ]]; then
        PR_ARGS+=(--draft)
    fi
    
    PR_URL=$(gh pr create "${PR_ARGS[@]}" 2>&1)
    
    if [[ $? -eq 0 ]]; then
        success "Pull Request creado: $PR_URL"
        
        # Update proposal state
        sed -i.bak 's/Estado | in_progress/Estado | testing/' "$CHANGE_DIR/proposal.md"
        rm -f "$CHANGE_DIR/proposal.md.bak"
        
        git add "$CHANGE_DIR/proposal.md"
        git commit -m "chore(openspec): PR creado para $CHANGE_ID" || true
        git push origin "$CURRENT_BRANCH" || true
    else
        error "No se pudo crear PR"
        echo "$PR_URL"
        exit 1
    fi
else
    info "Para crear PR manualmente:"
    info "  gh pr create --base $BASE_BRANCH --head $CURRENT_BRANCH"
fi

success "Code review solicitado para $CHANGE_ID"
info ""
info "CodeRabbit revisará automáticamente el PR"
info "Revisa los comentarios y aplica cambios sugeridos"
info ""
info "Cuando el review esté aprobado:"
info "  openspec archive $CHANGE_ID"
