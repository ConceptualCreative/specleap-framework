#!/usr/bin/env bash
# openspec apply — Implementar propuesta aprobada
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/common.sh"

usage() {
    if [ "$(cli_lang)" = "en" ]; then
        cat <<EOF
openspec apply — Implement an approved proposal

USAGE:
    openspec apply <CHANGE-ID> [options]

OPTIONS:
    --no-branch         Do not create a Git branch
    --base <branch>     Base branch (default: develop)
    --dry-run           Simulate without making changes
    -h, --help          Show help

DESCRIPTION:
    Implements an approved proposal:
    1. Creates a Git branch (feat/CHANGE-ID-name)
    2. Applies delta specs (if any)
    3. Generates scaffolding from design.md
    4. Updates status to "in_progress"

    NOTE: Does not generate code automatically.
          Use an AI assistant (Continue, Copilot) to implement against specs.

EXAMPLES:
    openspec apply CHANGE-001
    openspec apply CHANGE-002 --base main
    openspec apply CHANGE-003 --dry-run

PREREQUISITES:
    - Proposal completed and reviewed
    - Git repository initialised
    - Base branch already exists

EOF
    else
        cat <<EOF
openspec apply — Implementar propuesta aprobada

USAGE:
    openspec apply <CHANGE-ID> [options]

OPTIONS:
    --no-branch         No crear branch de Git
    --base <branch>     Branch base (default: develop)
    --dry-run           Simular sin hacer cambios
    -h, --help          Mostrar ayuda

DESCRIPTION:
    Implementa una propuesta aprobada:
    1. Crea branch de Git (feat/CHANGE-ID-nombre)
    2. Aplica delta specs (si existen)
    3. Genera scaffolding según design.md
    4. Actualiza estado a "in_progress"

    NOTA: No genera código automáticamente.
          Use AI assistant (Continue, Copilot) para implementar según specs.

EXAMPLES:
    openspec apply CHANGE-001
    openspec apply CHANGE-002 --base main
    openspec apply CHANGE-003 --dry-run

PREREQUISITES:
    - Propuesta completada y revisada
    - Git repositorio inicializado
    - Base branch existente

EOF
    fi
}

# Parse arguments
CHANGE_ID=""
NO_BRANCH=false
BASE_BRANCH="develop"
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --no-branch)
            NO_BRANCH=true
            shift
            ;;
        --base)
            BASE_BRANCH="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
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

info "Aplicando propuesta: $CHANGE_ID — $CHANGE_NAME"

# Verify required files exist
for file in proposal.md design.md tasks.md; do
    if [[ ! -f "$CHANGE_DIR/$file" ]]; then
        error "Archivo requerido no encontrado: $file"
        exit 1
    fi
done

# Check Git status
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    error "No estás en un repositorio Git"
    exit 1
fi

if git_has_changes && [[ "$DRY_RUN" == false ]]; then
    warning "Hay cambios sin commitear en el working directory"
    read -p "¿Continuar de todos modos? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        info "Operación cancelada"
        exit 0
    fi
fi

# Create feature branch
if [[ "$NO_BRANCH" == false ]]; then
    BRANCH_NAME="feat/${CHANGE_ID}-${CHANGE_NAME}"
    
    step "Creando branch: $BRANCH_NAME desde $BASE_BRANCH"
    
    if [[ "$DRY_RUN" == false ]]; then
        # Check if base branch exists
        if ! git show-ref --verify --quiet "refs/heads/$BASE_BRANCH"; then
            error "Branch base no existe: $BASE_BRANCH"
            exit 1
        fi
        
        # Create and checkout new branch
        git checkout -b "$BRANCH_NAME" "$BASE_BRANCH" || {
            error "No se pudo crear branch. Puede que ya exista."
            exit 1
        }
        success "Branch creado: $BRANCH_NAME"
    else
        info "[DRY RUN] Crearía branch: $BRANCH_NAME"
    fi
fi

# Apply delta specs if they exist
if [[ -d "$CHANGE_DIR/specs" ]] && [[ -n "$(ls -A "$CHANGE_DIR/specs" 2>/dev/null)" ]]; then
    step "Aplicando delta specs..."
    
    for delta_spec in "$CHANGE_DIR/specs"/**/*.spec.md; do
        if [[ -f "$delta_spec" ]]; then
            # Extract relative path
            rel_path="${delta_spec#$CHANGE_DIR/specs/}"
            target_spec="$PROJECT_ROOT/openspec/specs/$rel_path"
            
            info "  Delta: $rel_path"
            
            if [[ "$DRY_RUN" == false ]]; then
                # Create target directory if needed
                target_dir=$(dirname "$target_spec")
                ensure_dir "$target_dir"
                
                # Apply delta (simple: copy for now, later implement merge)
                if [[ -f "$target_spec" ]]; then
                    warning "    Spec existente será actualizada: $target_spec"
                    # TODO: Implement proper delta merge
                    cp "$delta_spec" "$target_spec"
                else
                    cp "$delta_spec" "$target_spec"
                fi
                success "    Aplicada: $target_spec"
            else
                info "[DRY RUN] Aplicaría delta a: $target_spec"
            fi
        fi
    done
else
    info "No hay delta specs para aplicar"
fi

# Update proposal state
step "Actualizando estado de propuesta a: in_progress"

if [[ "$DRY_RUN" == false ]]; then
    # Update state in proposal.md
    sed -i.bak 's/Estado | draft/Estado | in_progress/' "$CHANGE_DIR/proposal.md"
    sed -i.bak 's/Estado | review/Estado | in_progress/' "$CHANGE_DIR/proposal.md"
    sed -i.bak 's/Estado | approved/Estado | in_progress/' "$CHANGE_DIR/proposal.md"
    rm -f "$CHANGE_DIR/proposal.md.bak"
    
    # Commit the state change
    git add "$CHANGE_DIR/proposal.md"
    git commit -m "chore(openspec): iniciar implementación de $CHANGE_ID

## Qué se hizo
- Cambiar estado de propuesta a in_progress
- Aplicar delta specs

## Refs
- Propuesta: openspec/changes/$CHANGE_ID-$CHANGE_NAME/
" || true
    
    success "Estado actualizado"
else
    info "[DRY RUN] Actualizaría estado a: in_progress"
fi

# Show next steps
success "Propuesta aplicada exitosamente"
info ""
info "Branch activo: $(git_current_branch)"
info "Propuesta: $CHANGE_DIR"
info ""
info "Próximos pasos:"
info "  1. Implementar según design.md y tasks.md"
info "  2. Usar AI assistant (Continue, Copilot) con las specs"
info "  3. Escribir tests según Testing Strategy"
info "  4. openspec verify $CHANGE_ID (verificar tests)"
info "  5. openspec code-review $CHANGE_ID (solicitar review)"
info ""
info "Archivos clave:"
info "  - $(basename "$CHANGE_DIR")/design.md — Diseño técnico"
info "  - $(basename "$CHANGE_DIR")/tasks.md — Tareas y criterios"
info "  - openspec/specs/ — Especificaciones source of truth"
