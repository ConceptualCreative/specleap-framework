#!/usr/bin/env bash

# SpecLeap — Crear tareas individuales en Asana
# Permite crear tareas rápidamente desde línea de comandos

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASANA_UTILS="$SCRIPT_DIR/lib/asana-utils.sh"

# Auto-cargar .env desde el root del proyecto SpecLeap.
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
if [[ -f "$PROJECT_ROOT/.env" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$PROJECT_ROOT/.env"
    set +a
fi

source "$ASANA_UTILS"

# Colores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

usage() {
    cat << EOF
Uso: $(basename "$0") [OPCIONES]

Crea tareas individuales en Asana

OPCIONES:
    -p, --proyecto GID      ID del proyecto (obligatorio)
    -t, --titulo "TEXTO"    Título de la tarea (obligatorio)
    -s, --seccion GID       ID de la sección (opcional)
    -P, --puntos NUM        Story points (default: 3)
    -l, --listar           Listar proyectos disponibles
    -h, --help             Muestra esta ayuda

EJEMPLOS:
    # Listar proyectos:
    $(basename "$0") --listar

    # Crear tarea simple:
    $(basename "$0") -p 1234567890 -t "Implementar login"

    # Crear tarea con sección y puntos:
    $(basename "$0") -p 1234567890 -t "Setup CI/CD" -s 9876543210 -P 5

EOF
}

# Parsear argumentos
PROJECT_GID=""
TASK_NAME=""
SECTION_GID=""
POINTS=3
LIST_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--proyecto)
            PROJECT_GID="$2"
            shift 2
            ;;
        -t|--titulo)
            TASK_NAME="$2"
            shift 2
            ;;
        -s|--seccion)
            SECTION_GID="$2"
            shift 2
            ;;
        -P|--puntos)
            POINTS="$2"
            shift 2
            ;;
        -l|--listar)
            LIST_MODE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Opción desconocida: $1${RESET}"
            usage
            exit 1
            ;;
    esac
done

# Verificar token
if [[ -z "${ASANA_ACCESS_TOKEN:-}" ]]; then
    echo -e "${RED}❌ Error: ASANA_ACCESS_TOKEN no configurado${RESET}"
    echo ""
    echo "Configúralo en ~/.zshrc o ~/.bashrc:"
    echo "  export ASANA_ACCESS_TOKEN=\"tu-token-aqui\""
    exit 1
fi

# Modo listar
if [[ "$LIST_MODE" == true ]]; then
    echo -e "${CYAN}${BOLD}📋 Proyectos disponibles:${RESET}\n"
    asana_list_projects | while IFS=$'\t' read -r gid name; do
        echo -e "  ${BOLD}$gid${RESET}  $name"
    done
    exit 0
fi

# Validar argumentos obligatorios
if [[ -z "$PROJECT_GID" ]]; then
    echo -e "${RED}❌ Error: --proyecto es obligatorio${RESET}"
    usage
    exit 1
fi

if [[ -z "$TASK_NAME" ]]; then
    echo -e "${RED}❌ Error: --titulo es obligatorio${RESET}"
    usage
    exit 1
fi

# Crear tarea
echo -e "${CYAN}Creando tarea en Asana...${RESET}"
TASK_GID=$(asana_create_task "$PROJECT_GID" "$TASK_NAME" "$SECTION_GID" "$POINTS")

if [[ -n "$TASK_GID" ]]; then
    echo -e "${GREEN}${BOLD}✅ Tarea creada exitosamente${RESET}"
    echo -e "  ${BOLD}ID:${RESET} $TASK_GID"
    echo -e "  ${BOLD}Título:${RESET} $TASK_NAME"
    echo -e "  ${BOLD}Points:${RESET} $POINTS"
    echo -e "\n📊 Ver tarea: https://app.asana.com/0/$PROJECT_GID/$TASK_GID"
else
    echo -e "${RED}❌ Error al crear tarea${RESET}"
    exit 1
fi
