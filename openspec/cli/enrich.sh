#!/usr/bin/env bash
# openspec enrich — Refinar user story con AI
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/common.sh"

usage() {
    if [ "$(cli_lang)" = "en" ]; then
        cat <<EOF
openspec enrich — Refine a user story with AI

USAGE:
    openspec enrich <user-story> [options]
    openspec enrich --file <path>

OPTIONS:
    --file <path>       Read user story from file
    --output <path>     Save the result (default: STDOUT)
    --model <model>     AI model to use (default: auto)
    -h, --help          Show help

DESCRIPTION:
    Takes a plain user story and enriches it with:
    - Technical context
    - Detailed acceptance criteria
    - Identified edge cases
    - Complexity estimate

EXAMPLE:
    openspec enrich "As a user I want to log in"
    openspec enrich --file stories/US-123.md --output stories/US-123-refined.md

OUTPUT:
    Refined user story in markdown with:
    - Title and description
    - Business context
    - Acceptance criteria (GIVEN/WHEN/THEN)
    - Additional use cases
    - Initial estimate

EOF
    else
        cat <<EOF
openspec enrich — Refinar user story con AI

USAGE:
    openspec enrich <user-story> [options]
    openspec enrich --file <path>

OPTIONS:
    --file <path>       Leer user story desde archivo
    --output <path>     Guardar resultado (default: STDOUT)
    --model <model>     Modelo AI a usar (default: auto)
    -h, --help          Mostrar ayuda

DESCRIPTION:
    Toma una user story simple y la enriquece con:
    - Contexto técnico
    - Criterios de aceptación detallados
    - Edge cases identificados
    - Estimación de complejidad

EXAMPLE:
    openspec enrich "Como usuario quiero hacer login"
    openspec enrich --file stories/US-123.md --output stories/US-123-refined.md

OUTPUT:
    User story refinada en formato markdown con:
    - Título y descripción
    - Contexto del negocio
    - Criterios de aceptación (GIVEN/WHEN/THEN)
    - Casos de uso adicionales
    - Estimación inicial

EOF
    fi
}

# Parse arguments
USER_STORY=""
INPUT_FILE=""
OUTPUT_FILE=""
MODEL="auto"

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --file)
            INPUT_FILE="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        --model)
            MODEL="$2"
            shift 2
            ;;
        -*)
            error "Opción desconocida: $1"
            usage
            exit 1
            ;;
        *)
            USER_STORY="$1"
            shift
            ;;
    esac
done

# Read input
if [[ -n "$INPUT_FILE" ]]; then
    if [[ ! -f "$INPUT_FILE" ]]; then
        error "Archivo no encontrado: $INPUT_FILE"
        exit 1
    fi
    USER_STORY=$(cat "$INPUT_FILE")
elif [[ -z "$USER_STORY" ]]; then
    error "Debe proporcionar una user story o usar --file"
    usage
    exit 1
fi

info "Refinando user story con AI..."

# Prompt para el AI
PROMPT=$(cat <<EOF
Eres un Product Owner experto en Spec-Driven Development.

Refina la siguiente user story básica en una especificación detallada:

---
$USER_STORY
---

Genera una user story refinada con este formato:

# [ID] Título Descriptivo

## User Story
Como [rol], quiero [acción] para [beneficio]

## Contexto del Negocio
Por qué esta funcionalidad es importante.

## Criterios de Aceptación

### Escenario 1: [Nombre del escenario]
- **GIVEN** [contexto inicial]
- **WHEN** [acción del usuario]
- **THEN** [resultado esperado]
- **AND** [condición adicional]

### Escenario 2: [Edge case]
...

## Casos de Uso Adicionales
- Caso 1: Descripción
- Caso 2: Descripción

## Requisitos No Funcionales
- Performance: ...
- Seguridad: ...
- UX: ...

## Estimación Inicial
- **Complejidad:** Baja / Media / Alta
- **Esfuerzo:** S / M / L / XL
- **Riesgos:** ...

## Fuera de Alcance
- Qué NO incluye esta user story

Usa español técnico claro y preciso.
EOF
)

# Detect available AI CLI
AI_CMD=""
if command -v oracle &> /dev/null; then
    AI_CMD="oracle"
elif command -v gh &> /dev/null && gh copilot --version &> /dev/null 2>&1; then
    AI_CMD="gh_copilot"
elif command -v ai-cli &> /dev/null; then
    AI_CMD="ai-cli"
else
    error "No se encontró CLI de AI disponible (oracle, gh copilot, ai-cli)"
    exit 1
fi

# Execute AI enrichment
REFINED_STORY=""
case $AI_CMD in
    oracle)
        info "Usando Oracle CLI..."
        REFINED_STORY=$(echo "$PROMPT" | oracle --model "${MODEL}" --no-stream)
        ;;
    gh_copilot)
        info "Usando GitHub Copilot CLI..."
        REFINED_STORY=$(echo "$PROMPT" | gh copilot suggest -t shell)
        ;;
    ai-cli)
        info "Usando AI CLI..."
        # Use sessions_send or direct prompt
        REFINED_STORY=$(echo "$PROMPT" | ai-cli prompt)
        ;;
esac

# Output result
if [[ -n "$OUTPUT_FILE" ]]; then
    echo "$REFINED_STORY" > "$OUTPUT_FILE"
    success "User story refinada guardada en: $OUTPUT_FILE"
else
    echo "$REFINED_STORY"
fi

success "User story refinada exitosamente"
