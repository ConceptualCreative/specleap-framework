#!/usr/bin/env bash
# openspec ff — Fast-forward: generar propuesta completa con AI
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/common.sh"

usage() {
    if [ "$(cli_lang)" = "en" ]; then
        cat <<EOF
openspec ff — Fast-forward: generate the complete proposal with AI

USAGE:
    openspec ff <CHANGE-ID> [options]

OPTIONS:
    --model <model>     AI model to use (default: auto)
    --skip-proposal     Skip proposal.md generation
    --skip-design       Skip design.md generation
    --skip-tasks        Skip tasks.md generation
    -h, --help          Show help

DESCRIPTION:
    Automatically generates with AI:
    - Full proposal.md (if a base user story is available)
    - Technical design.md (architecture, API, data)
    - Broken-down tasks.md (tasks + estimates)

    IMPORTANT: Review and adjust the AI output before applying.

EXAMPLES:
    openspec ff CHANGE-001
    openspec ff CHANGE-002 --model anthropic/claude-sonnet-4
    openspec ff CHANGE-003 --skip-tasks

PREREQUISITES:
    - Proposal created via: openspec new
    - At least a proposal.md with basic context

EOF
    else
        cat <<EOF
openspec ff — Fast-forward: generar propuesta completa con AI

USAGE:
    openspec ff <CHANGE-ID> [options]

OPTIONS:
    --model <model>     Modelo AI a usar (default: auto)
    --skip-proposal     Omitir generación de proposal.md
    --skip-design       Omitir generación de design.md
    --skip-tasks        Omitir generación de tasks.md
    -h, --help          Mostrar ayuda

DESCRIPTION:
    Genera automáticamente con AI:
    - proposal.md completo (si tiene user story base)
    - design.md técnico (arquitectura, API, datos)
    - tasks.md desglosado (tareas + estimaciones)

    IMPORTANTE: Revisa y ajusta la salida del AI antes de aplicar.

EXAMPLES:
    openspec ff CHANGE-001
    openspec ff CHANGE-002 --model anthropic/claude-sonnet-4
    openspec ff CHANGE-003 --skip-tasks

PREREQUISITES:
    - Propuesta creada con: openspec new
    - Al menos proposal.md con contexto básico

EOF
    fi
}

# Parse arguments
CHANGE_ID=""
MODEL="auto"
SKIP_PROPOSAL=false
SKIP_DESIGN=false
SKIP_TASKS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --model)
            MODEL="$2"
            shift 2
            ;;
        --skip-proposal)
            SKIP_PROPOSAL=true
            shift
            ;;
        --skip-design)
            SKIP_DESIGN=true
            shift
            ;;
        --skip-tasks)
            SKIP_TASKS=true
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
    info "Use: openspec new $CHANGE_ID <título>"
    exit 1
fi

info "Generando propuesta completa para: $CHANGE_ID"
info "Directorio: $CHANGE_DIR"

# Read current proposal for context
PROPOSAL_FILE="$CHANGE_DIR/proposal.md"
if [[ ! -f "$PROPOSAL_FILE" ]]; then
    error "proposal.md no encontrado en $CHANGE_DIR"
    exit 1
fi

PROPOSAL_CONTENT=$(cat "$PROPOSAL_FILE")

# Detect AI CLI
AI_CMD=""
if command -v oracle &> /dev/null; then
    AI_CMD="oracle"
elif command -v ai-cli &> /dev/null; then
    AI_CMD="ai-cli"
else
    error "No se encontró CLI de AI (oracle, ai-cli)"
    exit 1
fi

# Generate design.md
if [[ "$SKIP_DESIGN" == false ]]; then
    step "Generando design.md con AI..."
    
    DESIGN_PROMPT=$(cat <<EOF
Eres un arquitecto de software experto.

Basándote en esta PROPUESTA:

---
$PROPOSAL_CONTENT
---

Genera un DISEÑO TÉCNICO completo siguiendo este formato:

# [$CHANGE_ID] Diseño Técnico: [Título]

## Resumen del Diseño
Descripción técnica de alto nivel.

## Arquitectura

### Diagrama de Componentes
\`\`\`
[Diagrama ASCII de componentes y flujo]
\`\`\`

### Componentes Afectados
| Componente | Tipo de Cambio | Descripción |
|------------|----------------|-------------|
| ... | ... | ... |

## Modelo de Datos

### Nuevas Entidades
\`\`\`typescript
interface NuevaEntidad {
  // ...
}
\`\`\`

### Migraciones de Base de Datos
\`\`\`sql
-- Migration: ...
\`\`\`

## API / Interfaces

### Nuevos Endpoints
\`\`\`
POST /api/v1/...
GET  /api/v1/...
\`\`\`

### Contratos de API
\`\`\`typescript
interface Request { ... }
interface Response { ... }
\`\`\`

## Seguridad
- Autenticación/autorización
- Validación de inputs
- Consideraciones de seguridad

## Performance
- Estimaciones de carga
- Optimizaciones necesarias

## Testing Strategy
- Unit tests
- Integration tests
- E2E tests (si aplica)

Usa español técnico. Sé específico y pragmático.
EOF
)

    DESIGN_CONTENT=""
    case $AI_CMD in
        oracle)
            DESIGN_CONTENT=$(echo "$DESIGN_PROMPT" | oracle --model "$MODEL" --no-stream)
            ;;
        ai-cli)
            DESIGN_CONTENT=$(echo "$DESIGN_PROMPT" | ai-cli prompt --model "$MODEL")
            ;;
    esac
    
    if [[ -n "$DESIGN_CONTENT" ]]; then
        echo "$DESIGN_CONTENT" > "$CHANGE_DIR/design.md"
        success "design.md generado"
    else
        warning "No se pudo generar design.md"
    fi
fi

# Generate tasks.md
if [[ "$SKIP_TASKS" == false ]]; then
    step "Generando tasks.md con AI..."
    
    # Read design for context
    DESIGN_CONTENT=""
    if [[ -f "$CHANGE_DIR/design.md" ]]; then
        DESIGN_CONTENT=$(cat "$CHANGE_DIR/design.md")
    fi
    
    TASKS_PROMPT=$(cat <<EOF
Eres un Tech Lead experto en planificación de desarrollo.

Basándote en:

PROPUESTA:
---
$PROPOSAL_CONTENT
---

DISEÑO:
---
$DESIGN_CONTENT
---

Genera un DESGLOSE DE TAREAS completo siguiendo este formato:

# [$CHANGE_ID] Tareas: [Título]

## Resumen
Total de tareas: X
Estimación total: X story points

## Tareas

### 🏗️ Setup & Scaffolding

#### TASK-001: [Título de tarea]
- **Estimación:** X SP
- **Estado:** ⬜ Pendiente
- **Branch:** \`feat/$CHANGE_ID-...\`

**Subtareas:**
- [ ] Subtarea 1
- [ ] Subtarea 2

**Criterios de aceptación:**
- [ ] Criterio 1
- [ ] Criterio 2

---

### 📊 Backend / API
[Tareas de backend]

### 🎨 Frontend / UI
[Tareas de frontend]

### 🧪 Testing
[Tareas de testing]

### 📚 Documentación
[Tareas de documentación]

## Dependencias entre Tareas
\`\`\`
TASK-001 → TASK-002 → TASK-003
\`\`\`

## Testing Report (Template)
| Suite | Tests | Passed | Failed | Coverage |
|-------|-------|--------|--------|----------|
| Unit | 0 | 0 | 0 | 0% |

Usa español. Estima realísticamente (1-5 SP por tarea).
EOF
)

    TASKS_CONTENT=""
    case $AI_CMD in
        oracle)
            TASKS_CONTENT=$(echo "$TASKS_PROMPT" | oracle --model "$MODEL" --no-stream)
            ;;
        ai-cli)
            TASKS_CONTENT=$(echo "$TASKS_PROMPT" | ai-cli prompt --model "$MODEL")
            ;;
    esac
    
    if [[ -n "$TASKS_CONTENT" ]]; then
        echo "$TASKS_CONTENT" > "$CHANGE_DIR/tasks.md"
        success "tasks.md generado"
    else
        warning "No se pudo generar tasks.md"
    fi
fi

success "Fast-forward completado para $CHANGE_ID"
info ""
info "IMPORTANTE: Revisa y ajusta los archivos generados antes de continuar"
info ""
info "Archivos actualizados:"
[[ "$SKIP_DESIGN" == false ]] && info "  - design.md"
[[ "$SKIP_TASKS" == false ]] && info "  - tasks.md"
info ""
info "Próximos pasos:"
info "  1. Revisar y ajustar diseño/tareas"
info "  2. openspec verify $CHANGE_ID"
info "  3. openspec apply $CHANGE_ID"
