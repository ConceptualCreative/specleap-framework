#!/usr/bin/env bash

# SpecLeap — Generador de CONTRATO.md interactivo
# Fase 2.1: Cuestionario básico con guardado parcial

set -euo pipefail

# ============================================================================
# CONFIGURACIÓN
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSIONS_DIR="$SCRIPT_DIR/.sessions"
TEMPLATE_FILE="$SCRIPT_DIR/../proyectos/_template/CONTRATO.md"
TEMPLATE_LEGACY_FILE="$SCRIPT_DIR/../proyectos/_template/CONTRATO-LEGACY.md"
VALIDATE_LIB="$SCRIPT_DIR/lib/validate.sh"
ANALYZE_SCRIPT="$SCRIPT_DIR/analyze-project.sh"

# Cargar sistema i18n (define SPECLEAP_LANG y la función t())
source "$SCRIPT_DIR/../.specleap/i18n.sh"

# Cuestionario localizado: questions.<lang>.json (es por defecto, fallback si EN no existe)
QUESTIONS_FILE="$SCRIPT_DIR/lib/questions.${SPECLEAP_LANG}.json"
if [ ! -f "$QUESTIONS_FILE" ]; then
    QUESTIONS_FILE="$SCRIPT_DIR/lib/questions.es.json"
fi

# Cargar funciones de validación
source "$VALIDATE_LIB"

# Colores (si terminal lo soporta)
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    MAGENTA='\033[0;35m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    MAGENTA=''
    CYAN=''
    BOLD=''
    RESET=''
fi

# Variables globales
SESSION_ID=""
SESSION_FILE=""
ANSWERS_FILE=""
PROJECT_NAME=""
PROJECT_TYPE=""
PROJECT_PATH=""
ANALYSIS_FILE=""
CURRENT_QUESTION=1
TOTAL_QUESTIONS=58
CHECKPOINT_INTERVAL=10

# Crear directorio de sesiones si no existe
mkdir -p "$SESSIONS_DIR"

# ============================================================================
# UTILIDADES
# ============================================================================

print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "════════════════════════════════════════════════════════════════"
    echo "  $(t 'questionnaire.title')"
    echo "════════════════════════════════════════════════════════════════"
    echo -e "${RESET}"
}

print_section() {
    echo -e "\n${MAGENTA}${BOLD}━━━ $1 ━━━${RESET}\n"
}

print_progress() {
    local current=$1
    local total=$2
    local percentage=$((current * 100 / total))
    local filled=$((percentage / 2))
    local empty=$((50 - filled))
    
    printf "\r${BLUE}$(t 'questionnaire.progress'): ["
    printf "%${filled}s" | tr ' ' '█'
    printf "%${empty}s" | tr ' ' '░'
    printf "] %d/%d (%d%%)${RESET}" "$current" "$total" "$percentage"
}

print_success() {
    echo -e "${GREEN}✅ $1${RESET}"
}

print_error() {
    echo -e "${RED}❌ Error: $1${RESET}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${RESET}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${RESET}"
}

# ============================================================================
# GESTIÓN DE SESIONES
# ============================================================================

generate_session_id() {
    echo "contrato-$(date +%s)"
}

save_session() {
    local session_data=$(cat <<EOF
{
  "session_id": "$SESSION_ID",
  "project_name": "$PROJECT_NAME",
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "last_checkpoint": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "progress": {
    "current_question": $CURRENT_QUESTION,
    "total_questions": $TOTAL_QUESTIONS,
    "percentage": $((CURRENT_QUESTION * 100 / TOTAL_QUESTIONS))
  },
  "answers": $(cat "$ANSWERS_FILE")
}
EOF
)
    echo "$session_data" > "$SESSION_FILE"
}

save_checkpoint() {
    save_session
    print_success "$(t "questionnaire.checkpoint_saved") $CURRENT_QUESTION/$TOTAL_QUESTIONS)"
}

detect_incomplete_session() {
    local sessions=($(ls -t "$SESSIONS_DIR"/*.json 2>/dev/null || true))
    
    if [[ ${#sessions[@]} -eq 0 ]]; then
        return 1
    fi
    
    local latest="${sessions[0]}"
    local progress=$(jq -r '.progress.current_question' "$latest")
    local total=$(jq -r '.progress.total_questions' "$latest")
    local project=$(jq -r '.project_name' "$latest")
    local session_id=$(jq -r '.session_id' "$latest")
    
    if [[ $progress -lt $total ]]; then
        echo -e "\n${YELLOW}$(t "questionnaire.session_incomplete")${RESET}"
        echo -e "   $(t "questionnaire.project_label") ${BOLD}$project${RESET}"
        echo -e "   $(t "questionnaire.progress_label") ${BOLD}$progress/$total${RESET} $(t "questionnaire.questions_label") ($(( progress * 100 / total ))%)"
        echo -e "   $(t "questionnaire.last_update"): $(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$latest")"
        echo ""
        
        read -p "$(t "questionnaire.continue_prompt") $((progress + 1))? $(t "questionnaire.continue_yes_no") " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Ss]$ ]]; then
            SESSION_ID="$session_id"
            SESSION_FILE="$latest"
            ANSWERS_FILE="$SESSIONS_DIR/$SESSION_ID-answers.json"
            PROJECT_NAME="$project"
            CURRENT_QUESTION=$((progress + 1))
            
            # Cargar respuestas
            jq -r '.answers' "$SESSION_FILE" > "$ANSWERS_FILE"
            
            print_success "$(t "questionnaire.session_restored") $CURRENT_QUESTION..."
            return 0
        else
            print_info "$(t "questionnaire.new_session")"
            return 1
        fi
    fi
    
    return 1
}

cleanup_old_sessions() {
    # Limpiar sesiones de hace más de 7 días
    find "$SESSIONS_DIR" -name "*.json" -mtime +7 -delete 2>/dev/null || true
}

# ============================================================================
# ANÁLISIS DE PROYECTO LEGACY
# ============================================================================

analyze_legacy_project() {
    local project_path="$1"
    
    print_section "$(t "session.analyzing_legacy")"
    
    if [[ ! -d "$project_path" ]]; then
        print_error "$(t "session.dir_not_found") $project_path"
        return 1
    fi
    
    print_info "Analizando código en: $project_path"
    print_info "Esto puede tardar unos minutos..."
    echo ""
    
    # Ejecutar analyze-project.sh
    local analysis_output
    if analysis_output=$(bash "$ANALYZE_SCRIPT" "$project_path" 2>&1); then
        # Guardar análisis en archivo temporal
        ANALYSIS_FILE="$SESSIONS_DIR/$SESSION_ID-analysis.json"
        echo "$analysis_output" > "$ANALYSIS_FILE"
        
        print_success "Análisis completado"
        
        # Mostrar resumen
        echo ""
        print_info "Resumen del análisis:"
        echo "$analysis_output" | head -20
        echo ""
        
        return 0
    else
        print_error "Fallo al analizar proyecto"
        print_warning "Continuando sin análisis automático..."
        return 1
    fi
}

# ============================================================================
# CUESTIONARIO
# ============================================================================

ask_question() {
    local q_json=$1
    local q_number=$(echo "$q_json" | jq -r '.number')
    local q_id=$(echo "$q_json" | jq -r '.id')
    local q_text=$(echo "$q_json" | jq -r '.text')
    local q_type=$(echo "$q_json" | jq -r '.type')
    local q_required=$(echo "$q_json" | jq -r '.required')
    local q_default=$(echo "$q_json" | jq -r '.default // ""')
    local q_help=$(echo "$q_json" | jq -r '.help // ""')
    local q_example=$(echo "$q_json" | jq -r '.example // ""')
    local q_options=$(echo "$q_json" | jq -r '.options // [] | join(", ")')
    local q_skip_if=$(echo "$q_json" | jq -c '.skip_if // null')
    local q_auto_suggest=$(echo "$q_json" | jq -c '.auto_suggest // null')
    
    # Verificar si debemos skipear esta pregunta
    if should_skip_question "$q_skip_if" "$ANSWERS_FILE"; then
        print_info "Pregunta $q_number skipeada (condición cumplida)"
        return 0
    fi
    
    local answer=""
    local valid=false
    local auto_suggested=""
    
    # Obtener auto-sugerencia si existe
    if [[ "$q_auto_suggest" != "null" ]]; then
        # Determinar de qué campo depende
        local depends_on=""
        case "$q_id" in
            "stack.backend.language") depends_on="stack.backend.framework" ;;
            "stack.backend.version") depends_on="stack.backend.framework" ;;
            "stack.database.version") depends_on="stack.database.engine" ;;
        esac
        
        if [[ -n "$depends_on" ]]; then
            auto_suggested=$(get_auto_suggest "$q_auto_suggest" "$depends_on" "$ANSWERS_FILE")
        fi
    fi
    
    while [[ "$valid" == false ]]; do
        echo -e "\n${BOLD}Pregunta $q_number/$TOTAL_QUESTIONS:${RESET} $q_text"
        
        if [[ -n "$q_help" ]] && [[ "$q_help" != "null" ]]; then
            echo -e "${CYAN}💡 $q_help${RESET}"
        fi
        
        if [[ -n "$q_options" ]]; then
            echo -e "${CYAN}$(t 'questionnaire.options_label') $q_options${RESET}"
        fi
        
        if [[ -n "$q_example" ]] && [[ "$q_example" != "null" ]]; then
            echo -e "${CYAN}$(t 'questionnaire.example_label') $q_example${RESET}"
        fi
        
        if [[ -n "$auto_suggested" ]]; then
            echo -e "${GREEN}✨ Sugerencia: $auto_suggested${RESET}"
        fi
        
        if [[ "$q_required" == "false" ]] && [[ -n "$q_default" ]] && [[ "$q_default" != "null" ]] && [[ "$q_default" != "[]" ]]; then
            echo -e "${CYAN}[Opcional, default: $q_default]${RESET}"
        fi
        
        read -p "> " answer
        
        # Si está vacío y hay auto-sugerencia, usarla
        if [[ -z "$answer" ]] && [[ -n "$auto_suggested" ]]; then
            answer="$auto_suggested"
            print_info "Usando sugerencia: $auto_suggested"
        fi
        
        # Si es opcional y está vacío, usar default
        if [[ -z "$answer" ]] && [[ "$q_required" == "false" ]]; then
            if [[ -n "$q_default" ]] && [[ "$q_default" != "null" ]] && [[ "$q_default" != "[]" ]]; then
                answer="$q_default"
            fi
            valid=true
            continue
        fi
        
        # Validar con validate.sh (fase 2.2)
        local validation_result
        validation_result=$(validate_answer "$answer" "$q_json" "$ANSWERS_FILE")
        local validation_status=$?
        
        if [[ $validation_status -eq 0 ]]; then
            # Extraer valor normalizado si existe
            if [[ "$validation_result" =~ ^OK:(.+)$ ]]; then
                answer="${BASH_REMATCH[1]}"
            fi
            valid=true
        else
            # Extraer mensaje de error
            if [[ "$validation_result" =~ ^ERROR:(.+)$ ]]; then
                print_error "${BASH_REMATCH[1]}"
            else
                print_error "$validation_result"
            fi
            continue
        fi
    done
    
    # Guardar respuesta
    # Si el tipo es array/multiselect, convertir a JSON array
    if [[ "$q_type" == "array" ]] || [[ "$q_type" == "multiselect" ]]; then
        if [[ -z "$answer" ]]; then
            answer="[]"
        else
            # Separar por comas y crear array JSON
            IFS=',' read -ra items <<< "$answer"
            answer="["
            for i in "${!items[@]}"; do
                item="${items[$i]}"
                # Trim espacios
                item="$(echo "$item" | xargs)"
                answer+="\"$item\""
                if [[ $i -lt $((${#items[@]} - 1)) ]]; then
                    answer+=","
                fi
            done
            answer+="]"
        fi
    fi
    
    # Guardar respuesta en archivo
    if [[ "$answer" =~ ^\[.*\]$ ]]; then
        jq --arg key "$q_id" --argjson val "$answer" '.[$key] = $val' "$ANSWERS_FILE" > "$ANSWERS_FILE.tmp" && mv "$ANSWERS_FILE.tmp" "$ANSWERS_FILE"
    else
        jq --arg key "$q_id" --arg val "$answer" '.[$key] = $val' "$ANSWERS_FILE" > "$ANSWERS_FILE.tmp" && mv "$ANSWERS_FILE.tmp" "$ANSWERS_FILE"
    fi
    
    print_progress "$CURRENT_QUESTION" "$TOTAL_QUESTIONS"
}

run_questionnaire() {
    local questions=$(jq -c '.questions[]' "$QUESTIONS_FILE")
    local section_current=""
    
    while IFS= read -r question; do
        local number=$(echo "$question" | jq -r '.number')
        
        # Skip si ya pasamos esta pregunta (sesión restaurada)
        if [[ $number -lt $CURRENT_QUESTION ]]; then
            continue
        fi
        
        local section=$(echo "$question" | jq -r '.section')
        local id=$(echo "$question" | jq -r '.id')
        
        # Imprimir sección si cambió
        if [[ "$section" != "$section_current" ]]; then
            print_section "$section"
            section_current="$section"
        fi
        
        # Hacer pregunta (pasar JSON completo)
        ask_question "$question"
        
        CURRENT_QUESTION=$((number + 1))
        
        # Checkpoint cada 10 preguntas
        if [[ $((number % CHECKPOINT_INTERVAL)) -eq 0 ]]; then
            save_checkpoint
        fi
        
        # Acciones especiales según pregunta
        case "$id" in
            "project.type")
                PROJECT_TYPE=$(jq -r '.["project.type"]' "$ANSWERS_FILE")
                ;;
            "project.path")
                # Si es proyecto existente y se proporcionó ruta, analizar
                if [[ "$PROJECT_TYPE" == "existente" ]]; then
                    PROJECT_PATH=$(jq -r '.["project.path"]' "$ANSWERS_FILE")
                    if [[ -n "$PROJECT_PATH" ]] && [[ "$PROJECT_PATH" != "null" ]]; then
                        analyze_legacy_project "$PROJECT_PATH"
                    fi
                fi
                ;;
            "project.name")
                PROJECT_NAME=$(jq -r '.["project.name"]' "$ANSWERS_FILE")
                ;;
        esac
        
    done <<< "$questions"
    
    # Guardar sesión final
    save_session
}

# ============================================================================
# GENERACIÓN CONTRATO.md
# ============================================================================

generate_contrato() {
    local project_type=$(jq -r '.["project.type"]' "$ANSWERS_FILE")
    
    if [[ "$project_type" == "existente" ]]; then
        print_section "Generando CONTRATO-LEGACY.md"
    else
        print_section "Generando CONTRATO.md"
    fi
    
    local project_name=$(jq -r '.["project.name"]' "$ANSWERS_FILE")
    local project_dir="$SCRIPT_DIR/../proyectos/$project_name"
    
    mkdir -p "$project_dir"
    mkdir -p "$project_dir/context"
    
    # Elegir template según tipo de proyecto
    local template_to_use="$TEMPLATE_FILE"
    local output_filename="CONTRATO.md"
    
    if [[ "$project_type" == "existente" ]]; then
        template_to_use="$TEMPLATE_LEGACY_FILE"
        output_filename="CONTRATO-LEGACY.md"
        
        # Copiar análisis si existe
        if [[ -f "$ANALYSIS_FILE" ]]; then
            cp "$ANALYSIS_FILE" "$project_dir/analisis-codigo.json"
            print_info "Análisis guardado en: $project_dir/analisis-codigo.json"
        fi
    fi
    
    local output_file="$project_dir/$output_filename"
    local render_script="$SCRIPT_DIR/lib/render-contrato.py"
    
    # Usar renderizador Python con Jinja2
    if python3 "$render_script" "$ANSWERS_FILE" "$QUESTIONS_FILE" "$template_to_use" "$output_file" 2>&1; then
        print_success "$output_filename generado exitosamente"
        echo ""
        echo -e "${CYAN}$(t 'questionnaire.location_label') ${BOLD}$output_file${RESET}"
        
        if [[ "$project_type" == "existente" ]]; then
            echo -e "${CYAN}$(t 'questionnaire.analysis_label') ${BOLD}$project_dir/analisis-codigo.json${RESET}"
        fi
        
        echo ""
        echo -e "${CYAN}Para ver el archivo:${RESET}"
        echo -e "  ${BOLD}cat $output_file${RESET}"
        echo ""
        echo -e "${CYAN}Para editarlo:${RESET}"
        echo -e "  ${BOLD}code $output_file${RESET}"
        echo ""
    else
        print_error "Fallo al generar $output_filename"
        print_info "Verifica que Python3 y Jinja2 estén instalados"
        return 1
    fi
}

# ============================================================================
# MANEJO DE SEÑALES
# ============================================================================

trap_exit() {
    echo ""
    print_warning "Interrupción detectada"
    
    if [[ $CURRENT_QUESTION -gt 1 ]] && [[ $CURRENT_QUESTION -le $TOTAL_QUESTIONS ]]; then
        print_info "Guardando progreso..."
        save_session
        print_success "Sesión guardada. Puedes continuar más tarde ejecutando este script de nuevo."
    fi
    
    exit 0
}

trap trap_exit INT TERM

# ============================================================================
# MAIN
# ============================================================================

main() {
    print_header
    
    cleanup_old_sessions
    
    # Detectar sesión incompleta
    if ! detect_incomplete_session; then
        # Nueva sesión
        SESSION_ID=$(generate_session_id)
        SESSION_FILE="$SESSIONS_DIR/$SESSION_ID.json"
        ANSWERS_FILE="$SESSIONS_DIR/$SESSION_ID-answers.json"
        
        echo -e "$(t "questionnaire.intro_line1") ${BOLD}$TOTAL_QUESTIONS $(t "questionnaire.questions_label")${RESET}"
        echo -e "$(t "questionnaire.intro_line2")"
        echo ""
        echo -e "$(t 'questionnaire.estimated_time')"
        echo -e "$(t 'questionnaire.auto_save')"
        echo -e "$(t 'questionnaire.interrupt_msg')"
        echo ""
        
        read -p "¿Listo para comenzar? [s/N]: " -n 1 -r
        echo
        
        if ! [[ $REPLY =~ ^[Ss]$ ]]; then
            echo "Cancelado."
            exit 0
        fi
        
        # Inicializar archivo de respuestas
        echo "{}" > "$ANSWERS_FILE"
    fi
    
    # Ejecutar cuestionario
    run_questionnaire
    
    echo ""
    print_success "¡Cuestionario completado! 🎉"
    echo ""
    
    # Generar CONTRATO.md
    generate_contrato
    
    # Limpiar sesión
    rm -f "$SESSION_FILE" "$ANSWERS_FILE"
    
    print_success "¡Listo! 🚀"
}

# Ejecutar
main "$@"
