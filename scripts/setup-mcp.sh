#!/bin/bash

# SpecLeap — Setup Completo Automatizado
# Verificación inteligente: solo instala lo que falta

set -e  # Exit on error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════╗"
echo "║      SpecLeap — Setup Automatizado        ║"
echo "║         Verificación Inteligente          ║"
echo "╔════════════════════════════════════════════╗"
echo -e "${NC}"
echo ""

# ============================================
# VERIFICACIONES PREVIAS
# ============================================

echo -e "${CYAN}🔍 Verificando sistema...${NC}"
echo ""

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js no está instalado${NC}"
    echo "Instala Node.js desde: https://nodejs.org"
    exit 1
fi
echo -e "${GREEN}✅ Node.js:${NC} $(node --version)"

# Verificar npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm no está instalado${NC}"
    exit 1
fi
echo -e "${GREEN}✅ npm:${NC} $(npm --version)"

# Verificar Python 3 (necesario para manipular JSON)
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 no está instalado (necesario para configurar JSON)${NC}"
    echo "Instala Python 3:"
    echo "  macOS: brew install python3"
    echo "  Ubuntu: sudo apt install python3"
    exit 1
fi
echo -e "${GREEN}✅ Python 3:${NC} $(python3 --version)"

# Verificar npx skills
if ! command -v npx &> /dev/null; then
    echo -e "${RED}❌ npx no está disponible${NC}"
    exit 1
fi
echo -e "${GREEN}✅ npx:${NC} disponible"

echo ""

# ============================================
# DETECTAR IDE
# ============================================

IDE=""
CONFIG_PATH=""

echo -e "${CYAN}🔍 Detectando IDE...${NC}"

if command -v code &> /dev/null; then
    IDE="vscode"
    CONFIG_PATH=~/.vscode/extensions
    echo -e "${GREEN}✅ IDE detectado: VSCode${NC}"
elif [ -d ~/.cursor ]; then
    IDE="cursor"
    CONFIG_PATH=~/.cursor/config.json
    echo -e "${GREEN}✅ IDE detectado: Cursor${NC}"
elif [ -d ~/.continue ]; then
    IDE="continue"
    CONFIG_PATH=.continue/config.json
    echo -e "${GREEN}✅ IDE detectado: Continue (VSCode)${NC}"
else
    echo -e "${RED}❌ No se detectó IDE compatible${NC}"
    echo "Compatible con: VSCode, Cursor, Continue"
    exit 1
fi

echo ""

# ============================================
# VERIFICAR QUÉ YA ESTÁ INSTALADO
# ============================================

echo -e "${CYAN}📋 Verificando instalaciones existentes...${NC}"
echo ""

# Verificar Agent Skills
SKILLS_INSTALLED=false
if [ -d ~/.skills ]; then
    SKILLS_COUNT=$(find ~/.skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
    if [ "$SKILLS_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✅ Agent Skills detectadas: $SKILLS_COUNT instaladas${NC}"
        SKILLS_INSTALLED=true
    else
        echo -e "${YELLOW}⚠️  Directorio ~/.skills existe pero está vacío${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Agent Skills: No instaladas${NC}"
fi

# Verificar CodeRabbit config
CODERABBIT_INSTALLED=false
if [ -f .coderabbit.yaml ]; then
    echo -e "${GREEN}✅ CodeRabbit config: .coderabbit.yaml encontrado${NC}"
    CODERABBIT_INSTALLED=true
else
    echo -e "${YELLOW}⚠️  CodeRabbit config: No encontrado${NC}"
fi

# Verificar Asana en config
JIRA_INSTALLED=false
if [ -f "$CONFIG_PATH" ]; then
    if grep -q "jira" "$CONFIG_PATH" 2>/dev/null; then
        echo -e "${GREEN}✅ Asana: Configurado en $IDE${NC}"
        JIRA_INSTALLED=true
    else
        echo -e "${YELLOW}⚠️  Asana: No configurado${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Asana: Archivo de config no existe${NC}"
fi

# Verificar Context7 MCP
CONTEXT7_INSTALLED=false
if [ -f "$CONFIG_PATH" ]; then
    if grep -q "context7" "$CONFIG_PATH" 2>/dev/null; then
        echo -e "${GREEN}✅ Context7 MCP: Configurado${NC}"
        CONTEXT7_INSTALLED=true
    fi
fi

echo ""

# ============================================
# RESUMEN PRE-INSTALACIÓN
# ============================================

NEEDS_INSTALL=false

if [ "$SKILLS_INSTALLED" = false ] || [ "$CODERABBIT_INSTALLED" = false ] || [ "$JIRA_INSTALLED" = false ]; then
    NEEDS_INSTALL=true
fi

if [ "$NEEDS_INSTALL" = false ]; then
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════╗"
    echo "║    ✅ TODO YA ESTÁ INSTALADO               ║"
    echo "╔════════════════════════════════════════════╗"
    echo -e "${NC}"
    echo ""
    echo "No hay nada que instalar. Sistema completo."
    echo ""
    echo "Verifica con: /refinar SCRUM-1"
    echo ""
    exit 0
fi

echo -e "${BLUE}📦 Componentes a instalar:${NC}"
echo ""
if [ "$SKILLS_INSTALLED" = false ]; then
    echo "  🔲 Agent Skills TIER 1 (20 skills)"
fi
if [ "$CODERABBIT_INSTALLED" = false ]; then
    echo "  🔲 CodeRabbit config (.coderabbit.yaml)"
fi
if [ "$JIRA_INSTALLED" = false ]; then
    echo "  🔲 Asana"
fi
if [ "$CONTEXT7_INSTALLED" = false ]; then
    echo "  🔲 Context7 MCP (opcional)"
fi
echo ""

read -p "¿Continuar con la instalación? (s/n): " CONTINUE_INSTALL
if [[ ! "$CONTINUE_INSTALL" =~ ^[Ss]$ ]]; then
    echo "Instalación cancelada."
    exit 0
fi

echo ""

# ============================================
# PASO 1: Agent Skills TIER 1
# ============================================

if [ "$SKILLS_INSTALLED" = false ]; then
    echo -e "${BLUE}📚 Instalando Agent Skills TIER 1 (OBLIGATORIO)${NC}"
    echo ""
    echo "⚠️  Skills TIER 1 son OBLIGATORIAS para mantener calidad del código"
    echo ""
    echo "Tiempo estimado: ~2-3 minutos"
    echo ""

    # Lista de skills a instalar (formato: "repo:path:name")
    declare -a SKILLS=(
        # Consistencia & Calidad (5) - obra/superpowers
        "obra/superpowers:skills/verification-before-completion:verification-before-completion"
        "obra/superpowers:skills/systematic-debugging:systematic-debugging"
        "obra/superpowers:skills/test-driven-development:test-driven-development"
        "obra/superpowers:skills/requesting-code-review:requesting-code-review"
        "obra/superpowers:skills/receiving-code-review:receiving-code-review"
        
        # Backend & Full-Stack (8) - jeffallan/claude-skills
        "jeffallan/claude-skills:skills/laravel-specialist:laravel-specialist"
        "jeffallan/claude-skills:skills/api-designer:api-designer"
        "jeffallan/claude-skills:skills/database-optimizer:database-optimizer"
        "jeffallan/claude-skills:skills/code-reviewer:code-reviewer"
        "jeffallan/claude-skills:skills/debugging-wizard:debugging-wizard"
        "jeffallan/claude-skills:skills/python-pro:python-pro"
        "jeffallan/claude-skills:skills/react-expert:react-expert"
        "jeffallan/claude-skills:skills/typescript-pro:typescript-pro"
        
        # Diseño & Frontend (4) - anthropics/skills
        "anthropics/skills:skills/frontend-design:frontend-design"
        "anthropics/skills:skills/skill-creator:skill-creator"
        "anthropics/skills:skills/canvas-design:canvas-design"
        "anthropics/skills:skills/algorithmic-art:algorithmic-art"
        
        # DevOps & Arquitectura (3) - jeffallan/claude-skills
        "jeffallan/claude-skills:skills/devops-engineer:devops-engineer"
        "jeffallan/claude-skills:skills/cloud-architect:cloud-architect"
        "jeffallan/claude-skills:skills/architecture-designer:architecture-designer"
    )

    TOTAL_SKILLS=${#SKILLS[@]}
    INSTALLED_COUNT=0
    FAILED_COUNT=0
    SKIPPED_COUNT=0
    
    SKILLS_DIR="${HOME}/.skills"
    TMP_DIR="/tmp/specleap-skills-$$"
    
    mkdir -p "${SKILLS_DIR}"
    mkdir -p "${TMP_DIR}"

    echo -e "${CYAN}📦 Instalando skills desde GitHub...${NC}"
    echo ""

    for i in "${!SKILLS[@]}"; do
        IFS=':' read -r repo path name <<< "${SKILLS[$i]}"
        skill_num=$((i + 1))
        
        echo -ne "  [$skill_num/$TOTAL_SKILLS] $name... "
        
        # Verificar si ya está instalada
        if [ -d "${SKILLS_DIR}/${name}" ]; then
            echo -e "${YELLOW}⚠️  (ya instalada)${NC}"
            ((SKIPPED_COUNT++))
            continue
        fi
        
        # Clonar repo si no existe
        repo_dir="${TMP_DIR}/$(echo $repo | tr '/' '_')"
        if [ ! -d "${repo_dir}" ]; then
            git clone "https://github.com/${repo}.git" "${repo_dir}" &>/dev/null
            if [ $? -ne 0 ]; then
                echo -e "${RED}❌ (repo no accesible)${NC}"
                ((FAILED_COUNT++))
                continue
            fi
        fi
        
        # Copiar skill
        if [ -f "${repo_dir}/${path}/SKILL.md" ]; then
            cp -r "${repo_dir}/${path}" "${SKILLS_DIR}/${name}"
            echo -e "${GREEN}✅${NC}"
            ((INSTALLED_COUNT++))
        else
            echo -e "${RED}❌ (SKILL.md no encontrado)${NC}"
            ((FAILED_COUNT++))
        fi
    done
    
    # Cleanup
    rm -rf "${TMP_DIR}"

    echo ""
    echo -e "${GREEN}✅ Skills instaladas exitosamente: $INSTALLED_COUNT${NC}"
    if [ $SKIPPED_COUNT -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Skills ya instaladas: $SKIPPED_COUNT${NC}"
    fi
    if [ $FAILED_COUNT -gt 0 ]; then
        echo -e "${RED}❌ Skills fallidas o no encontradas: $FAILED_COUNT${NC}"
    fi
    echo ""
else
    echo -e "${GREEN}✅ Agent Skills ya instaladas — Omitiendo${NC}"
    echo ""
fi

# ============================================
# PASO 2: Context7 MCP (Opcional)
# ============================================

if [ "$CONTEXT7_INSTALLED" = false ]; then
    echo -e "${BLUE}📚 Context7 MCP (Opcional)${NC}"
    echo "Context7 permite consultar documentación actualizada de librerías."
    echo ""
    read -p "¿Instalar Context7? (s/n): " INSTALL_CONTEXT7

    if [[ "$INSTALL_CONTEXT7" =~ ^[Ss]$ ]]; then
        echo ""
        echo -e "${BLUE}📦 Instalando Context7 MCP...${NC}"
        
        if npm install -g @context7/mcp-server; then
            echo -e "${GREEN}✅ Context7 MCP instalado${NC}"
            echo ""
            
            echo "🔑 Obtén tu API key en: https://context7.com/dashboard"
            read -sp "    API Key: " CONTEXT7_KEY
            echo ""
            echo ""
            
            if [ -n "$CONTEXT7_KEY" ]; then
                CONTEXT7_INSTALLED=true
                echo -e "${GREEN}✅ Context7 API Key guardada${NC}"
            fi
        else
            echo -e "${RED}❌ Error instalando Context7${NC}"
        fi
        echo ""
    else
        echo -e "${YELLOW}⏭️  Context7 omitido${NC}"
        echo ""
    fi
else
    echo -e "${GREEN}✅ Context7 ya configurado — Omitiendo${NC}"
    echo ""
fi

# ============================================
# PASO 3: CodeRabbit Config
# ============================================

if [ "$CODERABBIT_INSTALLED" = false ]; then
    echo -e "${BLUE}🤖 CodeRabbit Config (OBLIGATORIO)${NC}"
    echo ""
    echo "⚠️  CodeRabbit es OBLIGATORIO para mantener calidad del código."
    echo "    Hace code review automático en todos los PRs."
    echo ""

    TEMPLATE_PATH="proyectos/_template/.coderabbit.yaml"

    if [ -f "$TEMPLATE_PATH" ]; then
        cp "$TEMPLATE_PATH" .coderabbit.yaml
        echo -e "${GREEN}✅ .coderabbit.yaml copiado${NC}"
        echo ""
        echo -e "${YELLOW}📋 Próximo paso (después del setup):${NC}"
        echo "    Instala CodeRabbit en GitHub: https://github.com/apps/coderabbitai"
        echo ""
    else
        echo -e "${RED}❌ Template no encontrado: $TEMPLATE_PATH${NC}"
        echo -e "${YELLOW}⚠️  Deberás crear .coderabbit.yaml manualmente${NC}"
        echo ""
    fi
else
    echo -e "${GREEN}✅ CodeRabbit config ya existe — Omitiendo${NC}"
    echo ""
fi

# ============================================
# PASO 4: Asana (OBLIGATORIO — ÚLTIMO)
# ============================================

if [ "$JIRA_INSTALLED" = false ]; then
    echo -e "${BLUE}🔌 Asana (OBLIGATORIO)${NC}"
    echo ""
    echo "⚠️  Asana es OBLIGATORIO para usar SpecLeap."
    echo "    El workflow completo depende de Jira para:"
    echo "    - Generar tickets desde CONTRATO"
    echo "    - Refinar user stories"
    echo "    - Vincular PRs a tickets"
    echo ""

    SKIP_JSON_CONFIG=false

    if [ "$IDE" = "vscode" ]; then
        # VSCode: Instalar extensión oficial de Atlassian
        echo -e "${BLUE}📦 Instalando extensión Atlassian para VSCode...${NC}"
        
        if code --install-extension Atlassian.atlascode; then
            echo -e "${GREEN}✅ Extensión Atlassian instalada${NC}"
            echo ""
            echo -e "${YELLOW}ℹ️  Configuración de Jira en VSCode:${NC}"
            echo ""
            echo "  Después de reiniciar VSCode:"
            echo "  1. Busca el icono de Atlassian en la barra lateral"
            echo "  2. Click en 'Connect' y sigue el flujo OAuth"
            echo ""
            SKIP_JSON_CONFIG=true
        else
            echo -e "${RED}❌ Error instalando extensión de Atlassian${NC}"
            echo -e "${YELLOW}⚠️  Instálala manualmente desde el marketplace de VSCode${NC}"
            exit 1
        fi
    else
        # Cursor, Continue: Solicitar credenciales
        echo -e "${BLUE}🔐 Configuración de Asana${NC}"
        echo ""
        
        read -p "🔗 Jira URL (ej: https://tu-workspace.atlassian.net): " JIRA_URL
        echo ""
        
        read -p "📧 Email de Atlassian: " JIRA_EMAIL
        echo ""
        
        echo "🔑 API Token (obtener en: https://id.atlassian.com/manage-profile/security/api-tokens)"
        read -sp "    Token: " JIRA_TOKEN
        echo ""
        echo ""
        
        # Validar inputs
        if [ -z "$JIRA_URL" ] || [ -z "$JIRA_EMAIL" ] || [ -z "$JIRA_TOKEN" ]; then
            echo -e "${RED}❌ Todos los campos son obligatorios${NC}"
            exit 1
        fi
        
        # Normalizar URL (quitar trailing slash si existe)
        JIRA_URL="${JIRA_URL%/}"
        
        echo ""
        echo -e "${BLUE}⚙️  Configurando Asana en $IDE...${NC}"
    fi

    # Configurar JSON solo para IDEs que no sean VSCode
    if [ "$SKIP_JSON_CONFIG" = false ]; then
        # Backup del config existente
        if [ -f "$CONFIG_PATH" ]; then
            BACKUP_PATH="${CONFIG_PATH}.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$CONFIG_PATH" "$BACKUP_PATH"
            echo -e "${GREEN}✅ Backup creado: $BACKUP_PATH${NC}"
        fi

        # Configurar según IDE
        case "$IDE" in
        vscode)
            # Verificar si existe el archivo
            if [ ! -f "$CONFIG_PATH" ]; then
                echo -e "${YELLOW}⚠️  $CONFIG_PATH no existe. Creando...${NC}"
                mkdir -p "$(dirname "$CONFIG_PATH")"
                echo '{"agents":{"main":{}}}' > "$CONFIG_PATH"
            fi
            
            # Usar Python para manipular JSON
            python3 - <<EOF
import json

config_path = "$CONFIG_PATH"

with open(config_path, 'r') as f:
    config = json.load(f)

# Asegurar estructura
if 'agents' not in config:
    config['agents'] = {}
if 'main' not in config['agents']:
    config['agents']['main'] = {}
if 'mcpServers' not in config['agents']['main']:
    config['agents']['main']['mcpServers'] = {}

# Agregar Asana
config['agents']['main']['mcpServers']['jira'] = {
    "command": "asana",
    "args": [],
    "env": {
        "JIRA_URL": "$JIRA_URL",
        "JIRA_EMAIL": "$JIRA_EMAIL",
        "JIRA_API_TOKEN": "$JIRA_TOKEN"
    }
}

# Agregar Context7 si fue instalado
if $CONTEXT7_INSTALLED:
    config['agents']['main']['mcpServers']['context7'] = {
        "command": "context7-mcp",
        "env": {
            "CONTEXT7_API_KEY": "$CONTEXT7_KEY"
        }
    }

# Guardar
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print("✅ Configuración actualizada")
EOF
            ;;
            
        cursor)
            # Cursor usa ~/.cursor/config.json
            if [ ! -f "$CONFIG_PATH" ]; then
                mkdir -p ~/.cursor
                echo '{}' > "$CONFIG_PATH"
            fi
            
            python3 - <<EOF
import json

config_path = "$CONFIG_PATH"

with open(config_path, 'r') as f:
    config = json.load(f)

# Asegurar estructura
if 'mcp' not in config:
    config['mcp'] = {}
if 'servers' not in config['mcp']:
    config['mcp']['servers'] = {}

# Agregar Asana
config['mcp']['servers']['jira'] = {
    "command": "asana",
    "env": {
        "JIRA_URL": "$JIRA_URL",
        "JIRA_EMAIL": "$JIRA_EMAIL",
        "JIRA_API_TOKEN": "$JIRA_TOKEN"
    }
}

# Agregar Context7 si fue instalado
if $CONTEXT7_INSTALLED:
    config['mcp']['servers']['context7'] = {
        "command": "context7-mcp",
        "env": {
            "CONTEXT7_API_KEY": "$CONTEXT7_KEY"
        }
    }

# Guardar
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print("✅ Configuración actualizada")
EOF
            ;;
            
        continue)
            # Continue usa .continue/config.json en el proyecto
            PROJECT_ROOT=$(pwd)
            CONFIG_DIR="$PROJECT_ROOT/.continue"
            CONFIG_PATH="$CONFIG_DIR/config.json"
            
            if [ ! -d "$CONFIG_DIR" ]; then
                mkdir -p "$CONFIG_DIR"
            fi
            
            if [ ! -f "$CONFIG_PATH" ]; then
                echo '{}' > "$CONFIG_PATH"
            fi
            
            python3 - <<EOF
import json

config_path = "$CONFIG_PATH"

with open(config_path, 'r') as f:
    config = json.load(f)

# Asegurar estructura
if 'mcpServers' not in config:
    config['mcpServers'] = {}

# Agregar Asana
config['mcpServers']['jira'] = {
    "command": "asana",
    "env": {
        "JIRA_URL": "$JIRA_URL",
        "JIRA_EMAIL": "$JIRA_EMAIL",
        "JIRA_API_TOKEN": "$JIRA_TOKEN"
    }
}

# Agregar Context7 si fue instalado
if $CONTEXT7_INSTALLED:
    config['mcpServers']['context7'] = {
        "command": "context7-mcp",
        "env": {
            "CONTEXT7_API_KEY": "$CONTEXT7_KEY"
        }
    }

# Guardar
with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print("✅ Configuración actualizada")
EOF
            ;;
        esac

        echo -e "${GREEN}✅ Asana configurado en $IDE${NC}"
        echo ""
    fi
else
    echo -e "${GREEN}✅ Asana ya configurado — Omitiendo${NC}"
    echo ""
fi

# ============================================
# RESUMEN FINAL
# ============================================

echo ""
echo -e "${GREEN}"
echo "╔════════════════════════════════════════════╗"
echo "║       ✅ Setup Completo — Reiniciar        ║"
echo "╔════════════════════════════════════════════╗"
echo -e "${NC}"
echo ""

echo -e "${BLUE}📋 Estado final:${NC}"
echo ""
echo "  ✅ Agent Skills TIER 1 — $INSTALLED_COUNT instaladas, $FAILED_COUNT fallidas"
if [ "$CONTEXT7_INSTALLED" = true ]; then
    echo "  ✅ Context7 MCP — Configurado"
fi
echo "  ✅ CodeRabbit config (.coderabbit.yaml)"
echo "  ✅ Asana — Configurado en $CONFIG_PATH"
echo ""

echo -e "${YELLOW}🔄 Próximos pasos:${NC}"
echo ""
echo "  1. ${GREEN}Reinicia $IDE${NC} (cerrar completamente y reabrir)"
echo "  2. Abre un proyecto de SpecLeap"
echo "  3. En el chat con la IA, prueba:"
echo ""
echo -e "     ${GREEN}/refinar SCRUM-1${NC}"
echo ""
echo "  Si funciona, la IA leerá el ticket de Jira automáticamente."
echo ""

echo -e "${BLUE}📖 Documentación:${NC}"
echo "  • SETUP.md — Troubleshooting completo"
echo "  • README.md — Uso de SpecLeap"
echo "  • .commands/*.md — Referencia de comandos"
echo "  • docs/SKILLS-REFERENCE.md — Guía rápida skills"
echo ""

echo -e "${GREEN}✨ ¡Setup completo! Reinicia $IDE para activar todo.${NC}"
echo ""
