#!/usr/bin/env bash
# openspec new — Crear nueva propuesta de cambio
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/common.sh"

usage() {
    cat <<EOF
openspec new — Crear nueva propuesta de cambio

USAGE:
    openspec new [CHANGE-ID] <título> [options]
    openspec new --auto <título>

OPTIONS:
    --auto              Generar ID automáticamente
    --from <file>       Crear desde user story refinada
    --ticket <id>       Asociar con un ID de ticket (ej: app-tienda-23)
    --priority <level>  Prioridad (critical/high/medium/low)
    --author <name>     Autor (default: git user)
    -h, --help          Mostrar ayuda

DESCRIPTION:
    Crea una nueva propuesta de cambio con estructura completa:
    - proposal.md (QUÉ y POR QUÉ)
    - design.md (CÓMO técnico)
    - tasks.md (Tareas y Testing Report)
    - specs/ (Delta specs si aplica)

EXAMPLES:
    openspec new CHANGE-001 "Implementar autenticación JWT"
    openspec new --auto "Sistema de notificaciones" --ticket app-tienda-23
    openspec new CHANGE-002 --from stories/auth-refined.md

OUTPUT:
    openspec/changes/CHANGE-XXX-nombre/
    ├── proposal.md
    ├── design.md
    ├── tasks.md
    └── specs/  (si aplica)

EOF
}

# Parse arguments
CHANGE_ID=""
TITLE=""
AUTO_ID=false
FROM_FILE=""
TICKET_ID=""
PRIORITY="medium"
AUTHOR=$(git config user.name 2>/dev/null || echo "Unknown")

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --auto)
            AUTO_ID=true
            shift
            ;;
        --from)
            FROM_FILE="$2"
            shift 2
            ;;
        --ticket)
            TICKET_ID="$2"
            shift 2
            ;;
        --priority)
            PRIORITY="$2"
            shift 2
            ;;
        --author)
            AUTHOR="$2"
            shift 2
            ;;
        CHANGE-*)
            CHANGE_ID="$1"
            shift
            ;;
        *)
            if [[ -z "$TITLE" ]]; then
                TITLE="$1"
            else
                error "Argumento inesperado: $1"
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate inputs
validate_project

if [[ -z "$TITLE" ]]; then
    error "Debe proporcionar un título para la propuesta"
    usage
    exit 1
fi

# Generate or validate ID
if [[ "$AUTO_ID" == true ]]; then
    CHANGE_NUM=$(get_next_id "change")
    CHANGE_ID="CHANGE-$CHANGE_NUM"
    info "ID generado automáticamente: $CHANGE_ID"
elif [[ -z "$CHANGE_ID" ]]; then
    error "Debe proporcionar CHANGE-ID o usar --auto"
    usage
    exit 1
elif [[ ! $CHANGE_ID =~ ^CHANGE-[0-9]{4}$ ]]; then
    error "Formato de ID inválido. Use: CHANGE-XXXX (ej: CHANGE-0001)"
    exit 1
fi

# Create slug from title
SLUG=$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//' | sed 's/-$//')
CHANGE_DIR="$PROJECT_ROOT/openspec/changes/${CHANGE_ID}-${SLUG}"

# Check if already exists
if [[ -d "$CHANGE_DIR" ]]; then
    error "La propuesta ya existe: $CHANGE_DIR"
    exit 1
fi

info "Creando propuesta: $CHANGE_ID — $TITLE"

# Create directory structure
ensure_dir "$CHANGE_DIR"
ensure_dir "$CHANGE_DIR/specs"

# Get current date
DATE=$(current_date)

# Create proposal.md from template
step "Creando proposal.md..."
TEMPLATE_PROPOSAL="$PROJECT_ROOT/openspec/templates/proposal.md"
cp "$TEMPLATE_PROPOSAL" "$CHANGE_DIR/proposal.md"

# Replace placeholders
sed -i.bak \
    -e "s/CHANGE-XXX/$CHANGE_ID/g" \
    -e "s/Título del Cambio/$TITLE/g" \
    -e "s/YYYY-MM-DD/$DATE/g" \
    -e "s/nombre/$AUTHOR/g" \
    -e "s/TICKET-XXX/${TICKET_ID:-TICKET-XXX}/g" \
    -e "s/medium/$PRIORITY/g" \
    "$CHANGE_DIR/proposal.md"
rm "$CHANGE_DIR/proposal.md.bak"

# Create design.md from template
step "Creando design.md..."
TEMPLATE_DESIGN="$PROJECT_ROOT/openspec/templates/design.md"
cp "$TEMPLATE_DESIGN" "$CHANGE_DIR/design.md"

sed -i.bak \
    -e "s/CHANGE-XXX/$CHANGE_ID/g" \
    -e "s/Título del Cambio/$TITLE/g" \
    -e "s/YYYY-MM-DD/$DATE/g" \
    -e "s/nombre/$AUTHOR/g" \
    "$CHANGE_DIR/design.md"
rm "$CHANGE_DIR/design.md.bak"

# Create tasks.md from template
step "Creando tasks.md..."
TEMPLATE_TASKS="$PROJECT_ROOT/openspec/templates/tasks.md"
cp "$TEMPLATE_TASKS" "$CHANGE_DIR/tasks.md"

sed -i.bak \
    -e "s/CHANGE-XXX/$CHANGE_ID/g" \
    -e "s/Título del Cambio/$TITLE/g" \
    -e "s/YYYY-MM-DD/$DATE/g" \
    -e "s/TICKET-XXX/${TICKET_ID:-TICKET-XXX}/g" \
    "$CHANGE_DIR/tasks.md"
rm "$CHANGE_DIR/tasks.md.bak"

# If created from refined user story, populate proposal
if [[ -n "$FROM_FILE" ]]; then
    if [[ -f "$FROM_FILE" ]]; then
        step "Importando user story refinada desde $FROM_FILE..."
        # Append refined content to proposal
        echo -e "\n## User Story Refinada (Importada)\n" >> "$CHANGE_DIR/proposal.md"
        cat "$FROM_FILE" >> "$CHANGE_DIR/proposal.md"
    else
        warning "Archivo no encontrado: $FROM_FILE"
    fi
fi

# Create README in change folder
cat > "$CHANGE_DIR/README.md" <<EOF
# $CHANGE_ID — $TITLE

| Campo | Valor |
|-------|-------|
| ID | $CHANGE_ID |
| Título | $TITLE |
| Estado | draft |
| Autor | $AUTHOR |
| Fecha | $DATE |
| Prioridad | $PRIORITY |
| Ticket | ${TICKET_ID:-N/A} |

## Archivos

- [proposal.md](./proposal.md) — QUÉ y POR QUÉ
- [design.md](./design.md) — CÓMO (diseño técnico)
- [tasks.md](./tasks.md) — Tareas y Testing Report
- specs/ — Delta specs (si aplica)

## Próximos Pasos

1. Completar \`proposal.md\` (contexto, problema, solución, alcance)
2. Completar \`design.md\` (arquitectura, API, datos, seguridad)
3. Desglosar tareas en \`tasks.md\`
4. Crear delta specs si modifica specs existentes
5. Solicitar aprobación: \`openspec verify $CHANGE_ID\`
6. Implementar: \`openspec apply $CHANGE_ID\`

## Comandos

\`\`\`bash
# Fast-forward: generar propuesta completa con AI
openspec ff $CHANGE_ID

# Aplicar propuesta (crear branch, implementar)
openspec apply $CHANGE_ID

# Verificar tests y specs
openspec verify $CHANGE_ID

# Code review
openspec code-review $CHANGE_ID

# Archivar al completar
openspec archive $CHANGE_ID
\`\`\`
EOF

success "Propuesta creada exitosamente: $CHANGE_DIR"
info ""
info "Archivos creados:"
info "  - proposal.md"
info "  - design.md"
info "  - tasks.md"
info "  - README.md"
info ""
info "Próximos pasos:"
info "  1. Editar proposal.md (QUÉ y POR QUÉ)"
info "  2. Editar design.md (CÓMO)"
info "  3. Desglosar tareas en tasks.md"
info "  4. (Opcional) openspec ff $CHANGE_ID para generar rápido con AI"
info ""
info "Cuando esté listo:"
info "  openspec apply $CHANGE_ID"
