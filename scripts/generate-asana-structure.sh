#!/usr/bin/env bash

# Cargar sistema i18n
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../.specleap/i18n.sh"

# Auto-cargar .env desde el root del proyecto SpecLeap.
# setup.sh guarda ASANA_ACCESS_TOKEN/ASANA_WORKSPACE_GID en .env, pero las
# shells nuevas (ej: las que arranca Claude Code) no lo cargan automáticamente.
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
if [[ -f "$PROJECT_ROOT/.env" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$PROJECT_ROOT/.env"
    set +a
fi

# SpecLeap — Generador de estructura Asana
# Convierte CONTRATO.md → proyecto Asana con secciones y tareas

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARSE_SCRIPT="$SCRIPT_DIR/parse-contrato.sh"
ASANA_UTILS="$SCRIPT_DIR/lib/asana-utils.sh"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

source "$PARSE_SCRIPT"
source "$ASANA_UTILS"

print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "════════════════════════════════════════════════════════════════"
    echo "  $(t 'asana.header')"
    echo "════════════════════════════════════════════════════════════════"
    echo -e "${RESET}"
}

print_section() {
    echo -e "\n${MAGENTA}${BOLD}━━━ $1 ━━━${RESET}\n" >&2
}

print_success() {
    echo -e "${GREEN}✅ $1${RESET}" >&2
}

print_error() {
    echo -e "${RED}❌ Error: $1${RESET}" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${RESET}" >&2
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${RESET}" >&2
}

usage() {
    cat << EOF
Uso: $(basename "$0") [OPCIONES]

Genera estructura completa en Asana desde CONTRATO.md

OPCIONES:
    -p, --proyecto RUTA     Ruta al proyecto (default: directorio actual)
    -n, --nombre NOMBRE     Nombre del proyecto en Asana (sobreescribe CONTRATO)
    -d, --dry-run          Modo simulación (no crea nada en Asana)
    -h, --help             Muestra esta ayuda

EJEMPLOS:
    # Desde directorio del proyecto:
    $(basename "$0")

    # Especificar proyecto:
    $(basename "$0") -p ~/proyectos/mi-app

    # Modo simulación:
    $(basename "$0") --dry-run

CONFIGURACIÓN:
    Variables de entorno requeridas:
    - ASANA_ACCESS_TOKEN: Token de API personal
    - ASANA_WORKSPACE_GID: ID del workspace (opcional, se detecta automáticamente)

EOF
}

# Parsear argumentos
PROYECTO_DIR="$(pwd)"
NOMBRE_PROYECTO=""
DRY_RUN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--proyecto)
            PROYECTO_DIR="$2"
            shift 2
            ;;
        -n|--nombre)
            NOMBRE_PROYECTO="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            print_error "Opción desconocida: $1"
            usage
            exit 1
            ;;
    esac
done

# Verificar token
if [[ -z "${ASANA_ACCESS_TOKEN:-}" ]]; then
    print_error "ASANA_ACCESS_TOKEN no está configurado"
    echo ""
    echo "Configúralo en ~/.zshrc o ~/.bashrc:"
    echo "  export ASANA_ACCESS_TOKEN=\"tu-token-aqui\""
    exit 1
fi

# Verificar CONTRATO.md
CONTRATO_PATH="$PROYECTO_DIR/CONTRATO.md"
if [[ ! -f "$CONTRATO_PATH" ]]; then
    print_error "No se encontró CONTRATO.md en: $PROYECTO_DIR"
    exit 1
fi

print_header

# Parsear CONTRATO.md
print_section "Analizando CONTRATO.md"
CONTRATO_JSON=$(parse_contrato "$CONTRATO_PATH")

# Extraer datos básicos
PROJECT_NAME=$(echo "$CONTRATO_JSON" | jq -r '.project_name // "Proyecto Sin Nombre"')
if [[ -n "$NOMBRE_PROYECTO" ]]; then
    PROJECT_NAME="$NOMBRE_PROYECTO"
fi

print_info "Proyecto: $PROJECT_NAME"

# Obtener workspace si no está configurado
if [[ -z "${ASANA_WORKSPACE_GID:-}" ]]; then
    print_info "Detectando workspace..."
    ASANA_WORKSPACE_GID=$(asana_get_default_workspace)
    export ASANA_WORKSPACE_GID
fi

print_info "Workspace: $ASANA_WORKSPACE_GID"

if [[ "$DRY_RUN" == true ]]; then
    print_warning "Modo DRY-RUN: no se creará nada en Asana"
fi

# Crear proyecto en Asana
print_section "Creando proyecto en Asana"

if [[ "$DRY_RUN" == false ]]; then
    PROJECT_GID=$(asana_create_project "$PROJECT_NAME")
    print_success "Proyecto creado: $PROJECT_GID"
else
    PROJECT_GID="DRY-RUN-PROJECT-123"
    print_info "Proyecto (simulado): $PROJECT_GID"
fi

# Generar épicas como secciones
print_section "Generando estructura de secciones y tareas"

EPIC_COUNT=0
STORY_COUNT=0

# Épica 1: Infraestructura
EPIC_COUNT=$((EPIC_COUNT + 1))
if [[ "$DRY_RUN" == false ]]; then
    INFRA_SECTION=$(asana_create_section "$PROJECT_GID" "🛠️ Infraestructura")
    print_success "Sección: Infraestructura"
    
    # Tareas de infraestructura
    asana_create_task "$PROJECT_GID" "Setup inicial del proyecto" "$INFRA_SECTION" 3
    asana_create_task "$PROJECT_GID" "Configurar CI/CD" "$INFRA_SECTION" 5
    asana_create_task "$PROJECT_GID" "Configurar entornos (dev/staging/prod)" "$INFRA_SECTION" 3
    STORY_COUNT=$((STORY_COUNT + 3))
else
    print_info "  📋 Sección: Infraestructura (3 tareas)"
    STORY_COUNT=$((STORY_COUNT + 3))
fi

# Épica 2: Backend
EPIC_COUNT=$((EPIC_COUNT + 1))
if [[ "$DRY_RUN" == false ]]; then
    BACKEND_SECTION=$(asana_create_section "$PROJECT_GID" "⚙️ Backend")
    print_success "Sección: Backend"
    
    # Tareas de backend desde CONTRATO
    FEATURES=$(echo "$CONTRATO_JSON" | jq -r '.features[]? // empty')
    if [[ -n "$FEATURES" ]]; then
        while IFS= read -r feature; do
            asana_create_task "$PROJECT_GID" "Implementar: $feature" "$BACKEND_SECTION" 5
            STORY_COUNT=$((STORY_COUNT + 1))
        done <<< "$FEATURES"
    else
        asana_create_task "$PROJECT_GID" "Implementar API REST básica" "$BACKEND_SECTION" 8
        asana_create_task "$PROJECT_GID" "Implementar autenticación" "$BACKEND_SECTION" 5
        asana_create_task "$PROJECT_GID" "Implementar autorización (roles)" "$BACKEND_SECTION" 5
        STORY_COUNT=$((STORY_COUNT + 3))
    fi
else
    print_info "  📋 Sección: Backend (~5-8 tareas)"
    STORY_COUNT=$((STORY_COUNT + 5))
fi

# Épica 3: Frontend
EPIC_COUNT=$((EPIC_COUNT + 1))
if [[ "$DRY_RUN" == false ]]; then
    FRONTEND_SECTION=$(asana_create_section "$PROJECT_GID" "🎨 Frontend")
    print_success "Sección: Frontend"
    
    asana_create_task "$PROJECT_GID" "Implementar sistema de diseño base" "$FRONTEND_SECTION" 8
    asana_create_task "$PROJECT_GID" "Implementar autenticación UI" "$FRONTEND_SECTION" 5
    asana_create_task "$PROJECT_GID" "Implementar navegación principal" "$FRONTEND_SECTION" 3
    STORY_COUNT=$((STORY_COUNT + 3))
else
    print_info "  📋 Sección: Frontend (3 tareas)"
    STORY_COUNT=$((STORY_COUNT + 3))
fi

# Épica 4: Testing
EPIC_COUNT=$((EPIC_COUNT + 1))
if [[ "$DRY_RUN" == false ]]; then
    TESTING_SECTION=$(asana_create_section "$PROJECT_GID" "🧪 Testing")
    print_success "Sección: Testing"
    
    asana_create_task "$PROJECT_GID" "Tests unitarios backend (>=90% coverage)" "$TESTING_SECTION" 5
    asana_create_task "$PROJECT_GID" "Tests E2E críticos" "$TESTING_SECTION" 5
    asana_create_task "$PROJECT_GID" "Tests de integración" "$TESTING_SECTION" 3
    STORY_COUNT=$((STORY_COUNT + 3))
else
    print_info "  📋 Sección: Testing (3 tareas)"
    STORY_COUNT=$((STORY_COUNT + 3))
fi

# Resumen final
print_section "Resumen"
echo -e "${BOLD}Proyecto:${RESET} $PROJECT_NAME"
echo -e "${BOLD}Secciones creadas:${RESET} $EPIC_COUNT"
echo -e "${BOLD}Tareas creadas:${RESET} $STORY_COUNT"

if [[ "$DRY_RUN" == false ]]; then
    echo -e "\n${GREEN}${BOLD}✅ Estructura generada exitosamente en Asana${RESET}"
    echo -e "\n📊 Ver proyecto: https://app.asana.com/0/$PROJECT_GID"
else
    echo -e "\n${YELLOW}${BOLD}ℹ️  Modo DRY-RUN: ningún cambio realizado${RESET}"
    echo -e "Ejecuta sin --dry-run para crear la estructura real"
fi

echo ""
