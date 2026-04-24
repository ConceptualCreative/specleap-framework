#!/bin/bash
# generate-contract.sh
# Genera CONTRATO.md desde archivo de respuestas YAML

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SPECLEAP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
RESPONSES_FILE="${1:-}"
OUTPUT_DIR="${2:-}"

if [[ -z "$RESPONSES_FILE" || ! -f "$RESPONSES_FILE" ]]; then
    echo "❌ Error: Archivo de respuestas no encontrado"
    echo "Uso: $0 <responses.yaml> [output_dir]"
    exit 1
fi

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}📝 Generando CONTRATO.md desde respuestas...${NC}"
echo ""

# Extraer PROJECT_NAME
PROJECT_NAME=$(grep "^project_name:" "$RESPONSES_FILE" | cut -d: -f2 | xargs)

if [[ -z "$PROJECT_NAME" ]]; then
    echo "❌ Error: project_name no encontrado en respuestas"
    exit 1
fi

# Determinar OUTPUT_DIR si no se especificó
if [[ -z "$OUTPUT_DIR" ]]; then
    OUTPUT_DIR="$SPECLEAP_ROOT/proyectos/$PROJECT_NAME"
fi

# Crear directorio del proyecto
mkdir -p "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/context"
mkdir -p "$OUTPUT_DIR/memory-bank"

# Copiar template
TEMPLATE="$SPECLEAP_ROOT/proyectos/_template/CONTRATO.md"
OUTPUT_CONTRACT="$OUTPUT_DIR/CONTRATO.md"

if [[ ! -f "$TEMPLATE" ]]; then
    echo "❌ Error: Template CONTRATO.md no encontrado en $TEMPLATE"
    exit 1
fi

echo -e "${GREEN}✓${NC} Copiando template..."
cp "$TEMPLATE" "$OUTPUT_CONTRACT"

# ===== FUNCIÓN: Reemplazar placeholders =====
replace_placeholder() {
    local key="$1"
    local value="$2"
    local file="$3"
    
    # Escapar caracteres especiales en value
    value=$(echo "$value" | sed 's/[&/\]/\\&/g')
    
    # Reemplazar en el archivo
    sed -i '' "s/{{ $key }}/$value/g" "$file"
}

# ===== EXTRAER VALORES DEL YAML =====
echo -e "${GREEN}✓${NC} Extrayendo valores..."

# Función para extraer valores del YAML
get_yaml_value() {
    local key="$1"
    grep "^$key:" "$RESPONSES_FILE" | cut -d: -f2- | xargs
}

# Valores básicos
PROJECT_DISPLAY_NAME=$(get_yaml_value "project_display_name")
PROJECT_OBJECTIVE=$(get_yaml_value "project_objective")
PROBLEM_SOLVED=$(get_yaml_value "problem_solved")
TARGET_AUDIENCE=$(get_yaml_value "target_audience")
COMPETITORS=$(get_yaml_value "competitors")
BACKEND_FRAMEWORK=$(get_yaml_value "backend_framework")
FRONTEND_FRAMEWORK=$(get_yaml_value "frontend_framework")
DATABASE=$(get_yaml_value "database")
HOSTING=$(get_yaml_value "hosting")
VISUAL_STYLE=$(get_yaml_value "visual_style")
TIME_LIMIT=$(get_yaml_value "time_limit")

# Fecha actual
CREATED_AT=$(date +%Y-%m-%d)

# ===== GENERAR FRONTMATTER YAML =====
echo -e "${GREEN}✓${NC} Generando frontmatter..."

# Crear archivo temporal con el frontmatter
TEMP_FRONTMATTER=$(mktemp)

cat > "$TEMP_FRONTMATTER" << EOF
---
# ===== METADATA (Parseable por scripts) =====
project:
  name: "$PROJECT_NAME"
  display_name: "$PROJECT_DISPLAY_NAME"
  created_at: "$CREATED_AT"
  status: draft
  version: "1.0"
  responsible: ""
  
identity:
  objective: "$PROJECT_OBJECTIVE"
  problem_solved: "$PROBLEM_SOLVED"
  target_audience: "$TARGET_AUDIENCE"
  competitors: "$COMPETITORS"
  
stack:
  backend:
    framework: "$BACKEND_FRAMEWORK"
    language: ""
    version: ""
  frontend:
    framework: "$FRONTEND_FRAMEWORK"
    language: ""
    build_tool: ""
    ui_library: ""
  database:
    engine: "$DATABASE"
    version: ""
  devops:
    hosting: "$HOSTING"
    ci_cd: ""
    containers: ""
    
features:
  core: []
  secondary: []
  auth:
    enabled: false
    methods: []
    two_factor: false
  admin_panel:
    enabled: false
    level: ""
  file_uploads:
    enabled: false
    storage: ""
  payments:
    enabled: false
    providers: []
  notifications:
    email: false
    push: false
    in_app: false
    
users:
  registration: false
  roles: []
  
design:
  color_palette: ""
  primary_color: ""
  secondary_color: ""
  accent_color: ""
  visual_style: "$VISUAL_STYLE"
  dark_mode: false
  responsive: true
  
architecture:
  pattern: "mvc"
  separation: "monolith"
  
deployment:
  ssl: true
  custom_domain: ""
  environments: []
  
security:
  level: "basic"
  gdpr_compliant: false
  sensitive_data: false
  
performance:
  load_time_target: ""
  api_response_target: ""
  concurrent_users: 0
  
testing:
  unit: false
  integration: false
  e2e: false
  coverage_target: 0
  
constraints:
  time_limit: "$TIME_LIMIT"
  budget_limit: ""
  out_of_scope: []
  
asana:
  workspace_id: ""
  section_count: 0
  task_count: 0
  synced_at: ""
---
EOF

# Reemplazar el frontmatter en el CONTRATO
# (Eliminar frontmatter del template y agregar el nuevo)
sed -i '' '1,/^---$/d' "$OUTPUT_CONTRACT"  # Eliminar primera sección ---
sed -i '' '1,/^---$/d' "$OUTPUT_CONTRACT"  # Eliminar segunda sección ---

# Agregar nuevo frontmatter al inicio
cat "$TEMP_FRONTMATTER" "$OUTPUT_CONTRACT" > "${OUTPUT_CONTRACT}.tmp"
mv "${OUTPUT_CONTRACT}.tmp" "$OUTPUT_CONTRACT"

rm "$TEMP_FRONTMATTER"

# ===== REEMPLAZAR PLACEHOLDERS EN MARKDOWN =====
echo -e "${GREEN}✓${NC} Reemplazando placeholders..."

# Reemplazos básicos (los que no están en frontmatter)
sed -i '' "s/{{ project.name }}/$PROJECT_NAME/g" "$OUTPUT_CONTRACT"
sed -i '' "s/{{ project.display_name }}/$PROJECT_DISPLAY_NAME/g" "$OUTPUT_CONTRACT"
sed -i '' "s/{{ project.created_at }}/$CREATED_AT/g" "$OUTPUT_CONTRACT"
sed -i '' "s/{{ identity.objective }}/$PROJECT_OBJECTIVE/g" "$OUTPUT_CONTRACT"

# ===== GENERAR ARCHIVOS CONTEXT =====
echo -e "${GREEN}✓${NC} Generando archivos context..."

# brief.md
cat > "$OUTPUT_DIR/context/brief.md" << EOF
# Brief — $PROJECT_DISPLAY_NAME

**Fecha:** $CREATED_AT

## Resumen Ejecutivo

$PROJECT_OBJECTIVE

## Problema

$PROBLEM_SOLVED

## Público Objetivo

$TARGET_AUDIENCE

## Competencia / Referencias

$COMPETITORS

## Stack Tecnológico

- **Backend:** $BACKEND_FRAMEWORK
- **Frontend:** $FRONTEND_FRAMEWORK
- **Base de Datos:** $DATABASE
- **Hosting:** $HOSTING
EOF

# architecture.md (placeholder)
cat > "$OUTPUT_DIR/context/architecture.md" << EOF
# Arquitectura — $PROJECT_DISPLAY_NAME

## Patrón de Arquitectura

MVC (Model-View-Controller)

## Capas

- **Presentation:** Controllers, Views, Components
- **Application:** Services, Use Cases
- **Domain:** Models, Business Logic
- **Infrastructure:** Database, External APIs

## Decisiones Arquitectónicas

[Se irán documentando durante el desarrollo]
EOF

# tech-stack.md
cat > "$OUTPUT_DIR/context/tech-stack.md" << EOF
# Stack Tecnológico — $PROJECT_DISPLAY_NAME

## Backend

**Framework:** $BACKEND_FRAMEWORK

**Justificación:** [A definir]

## Frontend

**Framework:** $FRONTEND_FRAMEWORK

**Justificación:** [A definir]

## Base de Datos

**Motor:** $DATABASE

**Justificación:** [A definir]

## Hosting

**Proveedor:** $HOSTING

**Justificación:** [A definir]
EOF

# conventions.md (placeholder)
cat > "$OUTPUT_DIR/context/conventions.md" << EOF
# Convenciones — $PROJECT_DISPLAY_NAME

## Nomenclatura

[A definir según el stack]

## Estructura de Archivos

[A definir]

## Patrones de Código

[A definir]
EOF

# decisions.md (vacío, se llena durante desarrollo)
cat > "$OUTPUT_DIR/context/decisions.md" << EOF
# Log de Decisiones — $PROJECT_DISPLAY_NAME

## Formato

Cada decisión sigue el formato ADR (Architecture Decision Record):

### [YYYY-MM-DD] Título de la Decisión

**Estado:** Propuesta | Aceptada | Rechazada | Obsoleta

**Contexto:** ¿Por qué necesitamos tomar esta decisión?

**Decisión:** ¿Qué decidimos?

**Consecuencias:** ¿Qué implica esta decisión?

---

EOF

echo ""
echo -e "${GREEN}✅ CONTRATO.md generado exitosamente${NC}"
echo ""
echo -e "${BLUE}📁 Archivos creados:${NC}"
echo "  - $OUTPUT_CONTRACT"
echo "  - $OUTPUT_DIR/context/brief.md"
echo "  - $OUTPUT_DIR/context/architecture.md"
echo "  - $OUTPUT_DIR/context/tech-stack.md"
echo "  - $OUTPUT_DIR/context/conventions.md"
echo "  - $OUTPUT_DIR/context/decisions.md"
echo ""
echo -e "${YELLOW}Siguiente paso:${NC} Revisar y refinar el CONTRATO con /refinar"
