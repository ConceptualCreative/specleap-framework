#!/usr/bin/env bash
# openspec report — Generar testing report
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

source "$SCRIPT_DIR/common.sh"

usage() {
    if [ "$(cli_lang)" = "en" ]; then
        cat <<EOF
openspec report — Generate testing report

USAGE:
    openspec report [CHANGE-ID] [options]

OPTIONS:
    --format <fmt>      Output format (markdown|json|text)
    --output <file>     Output file (default: STDOUT)
    -h, --help          Show help

DESCRIPTION:
    Generates a Testing Report automatically from test results:
    - Runs the test suite
    - Parses results (PHPUnit, Jest, etc.)
    - Generates the report in the specified format
    - Updates tasks.md if a CHANGE-ID is provided

EXAMPLES:
    openspec report
    openspec report CHANGE-001
    openspec report --format json --output report.json
    openspec report CHANGE-002 --format markdown

OUTPUT (markdown):
    ## Testing Report
    | Suite | Tests | Passed | Failed | Coverage |
    |-------|-------|--------|--------|----------|
    | Unit | X | X | 0 | XX% |

EOF
    else
        cat <<EOF
openspec report — Generar testing report

USAGE:
    openspec report [CHANGE-ID] [options]

OPTIONS:
    --format <fmt>      Formato de salida (markdown|json|text)
    --output <file>     Archivo de salida (default: STDOUT)
    -h, --help          Mostrar ayuda

DESCRIPTION:
    Genera un Testing Report automáticamente desde resultados de tests:
    - Ejecuta suite de tests
    - Parsea resultados (PHPUnit, Jest, etc.)
    - Genera reporte en formato especificado
    - Actualiza tasks.md si se proporciona CHANGE-ID

EXAMPLES:
    openspec report
    openspec report CHANGE-001
    openspec report --format json --output report.json
    openspec report CHANGE-002 --format markdown

OUTPUT (markdown):
    ## Testing Report
    | Suite | Tests | Passed | Failed | Coverage |
    |-------|-------|--------|--------|----------|
    | Unit | X | X | 0 | XX% |

EOF
    fi
}

# Parse arguments
CHANGE_ID=""
FORMAT="markdown"
OUTPUT_FILE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --output)
            OUTPUT_FILE="$2"
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

validate_project

info "Generando Testing Report..."

# Detect and run tests
UNIT_TESTS=0
UNIT_PASSED=0
UNIT_FAILED=0
UNIT_COVERAGE="N/A"

INTEGRATION_TESTS=0
INTEGRATION_PASSED=0
INTEGRATION_FAILED=0

E2E_TESTS=0
E2E_PASSED=0
E2E_FAILED=0

# PHPUnit
if [[ -f "$PROJECT_ROOT/phpunit.xml" ]] || [[ -f "$PROJECT_ROOT/phpunit.xml.dist" ]]; then
    step "Ejecutando PHPUnit..."
    
    PHPUNIT_CMD="${PROJECT_ROOT}/vendor/bin/phpunit"
    [[ ! -f "$PHPUNIT_CMD" ]] && PHPUNIT_CMD="phpunit"
    
    if command -v "$PHPUNIT_CMD" &> /dev/null || [[ -f "$PHPUNIT_CMD" ]]; then
        TEST_OUTPUT=$($PHPUNIT_CMD --testdox --coverage-text 2>&1 || true)
        
        # Parse results
        UNIT_TESTS=$(echo "$TEST_OUTPUT" | grep -oP '\d+(?= tests?)' | head -n1 || echo "0")
        UNIT_PASSED=$(echo "$TEST_OUTPUT" | grep -oP 'OK \(\K\d+(?= test)' || echo "$UNIT_TESTS")
        UNIT_FAILED=$(echo "$TEST_OUTPUT" | grep -oP 'FAILURES!\s+Tests:\s+\d+,\s+Assertions:\s+\d+,\s+Failures:\s+\K\d+' || echo "0")
        UNIT_COVERAGE=$(echo "$TEST_OUTPUT" | grep -oP 'Lines:\s+\K[\d.]+(?=%)' | head -n1 || echo "N/A")
        
        success "PHPUnit completado"
    fi
fi

# Jest
if [[ -f "$PROJECT_ROOT/package.json" ]] && grep -q "jest" "$PROJECT_ROOT/package.json"; then
    step "Ejecutando Jest..."
    
    if command -v npm &> /dev/null; then
        TEST_OUTPUT=$(npm test -- --coverage --json 2>&1 || true)
        
        # Parse Jest JSON output
        if echo "$TEST_OUTPUT" | grep -q "numTotalTests"; then
            UNIT_TESTS=$(echo "$TEST_OUTPUT" | grep -oP '"numTotalTests":\s*\K\d+' || echo "0")
            UNIT_PASSED=$(echo "$TEST_OUTPUT" | grep -oP '"numPassedTests":\s*\K\d+' || echo "0")
            UNIT_FAILED=$(echo "$TEST_OUTPUT" | grep -oP '"numFailedTests":\s*\K\d+' || echo "0")
            UNIT_COVERAGE=$(echo "$TEST_OUTPUT" | grep -oP '"pct":\s*\K[\d.]+' | head -n1 || echo "N/A")
        fi
        
        success "Jest completado"
    fi
fi

# Generate report
REPORT=""

case $FORMAT in
    markdown)
        REPORT=$(cat <<EOF
## Testing Report

| Suite | Tests | Passed | Failed | Coverage |
|-------|-------|--------|--------|----------|
| Unit | $UNIT_TESTS | $UNIT_PASSED | $UNIT_FAILED | ${UNIT_COVERAGE}% |
| Integration | $INTEGRATION_TESTS | $INTEGRATION_PASSED | $INTEGRATION_FAILED | N/A |
| E2E | $E2E_TESTS | $E2E_PASSED | $E2E_FAILED | N/A |

**Fecha:** $(current_datetime)

### Resumen
- Total tests: $((UNIT_TESTS + INTEGRATION_TESTS + E2E_TESTS))
- Pasados: $((UNIT_PASSED + INTEGRATION_PASSED + E2E_PASSED))
- Fallidos: $((UNIT_FAILED + INTEGRATION_FAILED + E2E_FAILED))
- Cobertura: ${UNIT_COVERAGE}%

### CodeRabbit Status
- [ ] Review pendiente
- [ ] Cambios requeridos
- [ ] Aprobado
EOF
)
        ;;
    
    json)
        REPORT=$(cat <<EOF
{
  "date": "$(current_datetime)",
  "suites": {
    "unit": {
      "total": $UNIT_TESTS,
      "passed": $UNIT_PASSED,
      "failed": $UNIT_FAILED,
      "coverage": "${UNIT_COVERAGE}"
    },
    "integration": {
      "total": $INTEGRATION_TESTS,
      "passed": $INTEGRATION_PASSED,
      "failed": $INTEGRATION_FAILED,
      "coverage": "N/A"
    },
    "e2e": {
      "total": $E2E_TESTS,
      "passed": $E2E_PASSED,
      "failed": $E2E_FAILED,
      "coverage": "N/A"
    }
  },
  "summary": {
    "total": $((UNIT_TESTS + INTEGRATION_TESTS + E2E_TESTS)),
    "passed": $((UNIT_PASSED + INTEGRATION_PASSED + E2E_PASSED)),
    "failed": $((UNIT_FAILED + INTEGRATION_FAILED + E2E_FAILED))
  }
}
EOF
)
        ;;
    
    text)
        REPORT=$(cat <<EOF
TESTING REPORT
$(current_datetime)

Unit Tests:       $UNIT_PASSED/$UNIT_TESTS passed ($UNIT_FAILED failed) — Coverage: ${UNIT_COVERAGE}%
Integration:      $INTEGRATION_PASSED/$INTEGRATION_TESTS passed ($INTEGRATION_FAILED failed)
E2E:              $E2E_PASSED/$E2E_TESTS passed ($E2E_FAILED failed)

Total:            $((UNIT_PASSED + INTEGRATION_PASSED + E2E_PASSED))/$((UNIT_TESTS + INTEGRATION_TESTS + E2E_TESTS)) passed
EOF
)
        ;;
esac

# Output report
if [[ -n "$OUTPUT_FILE" ]]; then
    echo "$REPORT" > "$OUTPUT_FILE"
    success "Reporte guardado en: $OUTPUT_FILE"
else
    echo "$REPORT"
fi

# Update tasks.md if CHANGE-ID provided
if [[ -n "$CHANGE_ID" ]]; then
    CHANGE_DIR=$(find "$PROJECT_ROOT/openspec/changes" -maxdepth 1 -type d -name "${CHANGE_ID}-*" | head -n1)
    
    if [[ -n "$CHANGE_DIR" ]] && [[ -f "$CHANGE_DIR/tasks.md" ]]; then
        step "Actualizando tasks.md..."
        
        # Replace Testing Report section
        # Simple approach: append if not exists, or replace if marker found
        if grep -q "## Testing Report" "$CHANGE_DIR/tasks.md"; then
            # Replace from "## Testing Report" to next "##" or EOF
            sed -i.bak '/^## Testing Report/,/^## /c\
## Testing Report\
\
'"$(echo "$REPORT" | sed 's/## Testing Report//')"'\
' "$CHANGE_DIR/tasks.md"
            rm -f "$CHANGE_DIR/tasks.md.bak"
        else
            echo -e "\n$REPORT" >> "$CHANGE_DIR/tasks.md"
        fi
        
        success "tasks.md actualizado"
    fi
fi

success "Testing Report generado"
