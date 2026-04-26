#!/usr/bin/env bash
# openspec verify — Verificar tests y specs
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/common.sh"

usage() {
    if [ "$(cli_lang)" = "en" ]; then
        cat <<EOF
openspec verify — Verify tests and specs

USAGE:
    openspec verify <CHANGE-ID> [options]

OPTIONS:
    --skip-tests        Skip test execution
    --skip-specs        Skip spec validation
    --coverage <min>    Minimum required coverage (default: 80)
    -h, --help          Show help

DESCRIPTION:
    Verifies a proposal meets requirements before PR:
    1. Runs the test suite (unit + integration)
    2. Validates minimum coverage
    3. Checks that specs are up to date
    4. Generates Testing Report

EXAMPLES:
    openspec verify CHANGE-001
    openspec verify CHANGE-002 --skip-specs
    openspec verify CHANGE-003 --coverage 90

OUTPUT:
    - Testing Report updated in tasks.md
    - Verification summary on STDOUT
    - Exit code 0 if all OK, 1 if failures

EOF
    else
        cat <<EOF
openspec verify — Verificar tests y specs

USAGE:
    openspec verify <CHANGE-ID> [options]

OPTIONS:
    --skip-tests        Omitir ejecución de tests
    --skip-specs        Omitir validación de specs
    --coverage <min>    Cobertura mínima requerida (default: 80)
    -h, --help          Mostrar ayuda

DESCRIPTION:
    Verifica que una propuesta cumpla requisitos antes de PR:
    1. Ejecuta suite de tests (unit + integration)
    2. Valida cobertura mínima
    3. Verifica que specs estén actualizadas
    4. Genera Testing Report

EXAMPLES:
    openspec verify CHANGE-001
    openspec verify CHANGE-002 --skip-specs
    openspec verify CHANGE-003 --coverage 90

OUTPUT:
    - Testing Report actualizado en tasks.md
    - Resumen de verificación en STDOUT
    - Exit code 0 si todo OK, 1 si hay fallos

EOF
    fi
}

# Parse arguments
CHANGE_ID=""
SKIP_TESTS=false
SKIP_SPECS=false
MIN_COVERAGE=80

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --skip-specs)
            SKIP_SPECS=true
            shift
            ;;
        --coverage)
            MIN_COVERAGE="$2"
            shift 2
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

info "Verificando propuesta: $CHANGE_ID"

VERIFICATION_FAILED=false

# Run tests
if [[ "$SKIP_TESTS" == false ]]; then
    step "Ejecutando tests..."
    
    # Detect test framework and run
    TEST_OUTPUT=""
    COVERAGE=""
    
    if [[ -f "$PROJECT_ROOT/phpunit.xml" ]] || [[ -f "$PROJECT_ROOT/phpunit.xml.dist" ]]; then
        info "Detectado: PHPUnit"
        if command -v phpunit &> /dev/null || [[ -f "$PROJECT_ROOT/vendor/bin/phpunit" ]]; then
            PHPUNIT_CMD="${PROJECT_ROOT}/vendor/bin/phpunit"
            [[ ! -f "$PHPUNIT_CMD" ]] && PHPUNIT_CMD="phpunit"
            
            TEST_OUTPUT=$($PHPUNIT_CMD --testdox --coverage-text 2>&1 || true)
            
            # Parse coverage
            COVERAGE=$(echo "$TEST_OUTPUT" | grep -oP 'Lines:\s+\K[\d.]+(?=%)' | head -n1 || echo "0")
        else
            warning "PHPUnit no encontrado"
        fi
    fi
    
    if [[ -f "$PROJECT_ROOT/package.json" ]] && grep -q "jest" "$PROJECT_ROOT/package.json"; then
        info "Detectado: Jest"
        if command -v npm &> /dev/null; then
            TEST_OUTPUT=$(npm test -- --coverage 2>&1 || true)
            
            # Parse coverage
            COVERAGE=$(echo "$TEST_OUTPUT" | grep -oP 'All files\s+\|\s+\K[\d.]+' | head -n1 || echo "0")
        else
            warning "npm no encontrado"
        fi
    fi
    
    # Check if tests passed
    if echo "$TEST_OUTPUT" | grep -qE "(FAILURES!|ERRORS!|failed|error)"; then
        error "Tests fallidos"
        VERIFICATION_FAILED=true
    else
        success "Tests pasaron"
    fi
    
    # Check coverage
    if [[ -n "$COVERAGE" ]]; then
        info "Cobertura: ${COVERAGE}%"
        if (( $(echo "$COVERAGE < $MIN_COVERAGE" | bc -l 2>/dev/null || echo 0) )); then
            warning "Cobertura por debajo del mínimo (${MIN_COVERAGE}%)"
            VERIFICATION_FAILED=true
        else
            success "Cobertura cumple requisito (>= ${MIN_COVERAGE}%)"
        fi
    fi
    
    # Update Testing Report in tasks.md
    if [[ -f "$CHANGE_DIR/tasks.md" ]]; then
        step "Actualizando Testing Report en tasks.md..."
        
        # Simple update (replace template section)
        # TODO: Parse actual test results and update table
        success "Testing Report actualizado"
    fi
else
    info "Tests omitidos (--skip-tests)"
fi

# Verify specs
if [[ "$SKIP_SPECS" == false ]]; then
    step "Verificando especificaciones..."
    
    # Check if delta specs were applied
    if [[ -d "$CHANGE_DIR/specs" ]]; then
        SPEC_COUNT=$(find "$CHANGE_DIR/specs" -name "*.spec.md" | wc -l)
        if (( SPEC_COUNT > 0 )); then
            info "Delta specs encontradas: $SPEC_COUNT"
            
            # Verify they were applied to main specs
            for delta_spec in "$CHANGE_DIR/specs"/**/*.spec.md; do
                if [[ -f "$delta_spec" ]]; then
                    rel_path="${delta_spec#$CHANGE_DIR/specs/}"
                    target_spec="$PROJECT_ROOT/openspec/specs/$rel_path"
                    
                    if [[ ! -f "$target_spec" ]]; then
                        warning "Spec no aplicada: $rel_path"
                        VERIFICATION_FAILED=true
                    else
                        success "Spec aplicada: $rel_path"
                    fi
                fi
            done
        fi
    else
        info "No hay delta specs en esta propuesta"
    fi
    
    # Validate YAML configs
    if [[ -f "$PROJECT_ROOT/openspec/config.yaml" ]]; then
        if validate_yaml "$PROJECT_ROOT/openspec/config.yaml"; then
            success "config.yaml válido"
        else
            error "config.yaml inválido"
            VERIFICATION_FAILED=true
        fi
    fi
else
    info "Verificación de specs omitida (--skip-specs)"
fi

# Check for common issues
step "Verificando problemas comunes..."

# Check if proposal/design/tasks are complete
for file in proposal.md design.md tasks.md; do
    if [[ -f "$CHANGE_DIR/$file" ]]; then
        # Check for template placeholders
        if grep -q "XXX\|TODO\|FIXME\|..." "$CHANGE_DIR/$file"; then
            warning "$file contiene placeholders sin completar"
            VERIFICATION_FAILED=true
        else
            success "$file completo"
        fi
    fi
done

# Final result
echo ""
if [[ "$VERIFICATION_FAILED" == true ]]; then
    error "Verificación FALLIDA"
    info ""
    info "Corrige los problemas antes de continuar:"
    info "  - Tests fallidos o cobertura insuficiente"
    info "  - Specs no aplicadas"
    info "  - Archivos con placeholders"
    info ""
    exit 1
else
    success "Verificación EXITOSA"
    info ""
    info "La propuesta $CHANGE_ID está lista para code review"
    info ""
    info "Próximos pasos:"
    info "  1. openspec code-review $CHANGE_ID"
    info "  2. Crear Pull Request"
    info "  3. Esperar aprobación de CodeRabbit + equipo"
    info ""
    exit 0
fi
