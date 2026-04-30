#!/bin/bash
# SpecLeap — Instalador Profesional Completo
# Versión 2.0 — Instalación guiada con todos los tokens

set -e

# Colores deshabilitados por defecto para máxima compatibilidad
# Si quieres colores, descomenta el bloque de abajo

RED=''
GREEN=''
YELLOW=''
BLUE=''
CYAN=''
BOLD=''
NC=''

# OPCIÓN AVANZADA: Descomentar para habilitar colores (puede causar códigos ANSI visibles en algunos terminales)
# if [[ -t 1 ]] && command -v tput &>/dev/null && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
#   RED='\033[0;31m'
#   GREEN='\033[0;32m'
#   YELLOW='\033[1;33m'
#   BLUE='\033[0;34m'
#   CYAN='\033[0;36m'
#   BOLD='\033[1m'
#   NC='\033[0m'
# fi

# Ancho terminal
COLS=$(tput cols 2>/dev/null || echo 80)
LINE=$(printf '%*s\n' "$COLS" '' | tr ' ' '═')

clear

echo -e "${CYAN}${LINE}${NC}"
echo -e "${CYAN}${BOLD}"
cat << "EOF"
   _____ ____  ___________    __    _________    ____ 
  / ___// __ \/ ____/ ____/   / /   / ____/   |  / __ \
  \__ \/ /_/ / __/ / /       / /   / __/ / /| | / /_/ /
 ___/ / ____/ /___/ /___    / /___/ /___/ ___ |/ ____/ 
/____/_/   /_____/\____/   /_____/_____/_/  |_/_/      
                                                        
EOF
echo -e "${NC}${CYAN}${LINE}${NC}"
echo -e "${GREEN}${BOLD}  Spec-Driven Development Framework${NC}"
echo -e "${YELLOW}  v2.0.0 — Instalador Profesional${NC}"
echo -e "${CYAN}${LINE}${NC}"
echo ""

# ============================================
# PASO 1: Selección de Idioma
# ============================================

echo -e "${BLUE}${BOLD}Paso 1/6: Idioma / Language${NC}"
echo ""
echo "  1) Español"
echo "  2) English"
echo ""
read -p "$(echo -e ${YELLOW}Selecciona / Select [1-2]:${NC} )" lang_choice

case $lang_choice in
    1) LANG="es" ;;
    2) LANG="en" ;;
    *) LANG="es" ;;
esac

# Textos según idioma
if [ "$LANG" = "es" ]; then
    MSG_WELCOME="¡Bienvenido a SpecLeap!"
    MSG_INSTALL_TIME="⏱️  Tiempo estimado: 10-15 minutos"
    MSG_REQUIREMENTS="Verificando requisitos del sistema..."
    MSG_GITHUB="Paso 2/6: Configuración GitHub"
    MSG_ASANA="Paso 3/6: Configuración Asana (Obligatorio)"
    MSG_SKILLS="Paso 4/6: Agent Skills (34 skills)"
    MSG_CODERABBIT="Paso 5/6: CodeRabbit"
    MSG_FINAL="Paso 6/6: Finalizando"
    MSG_SUCCESS="✅ ¡Instalación completa!"
    MSG_NEXT_STEPS="Próximos pasos:"
    MSG_ERROR="❌ Error:"
else
    MSG_WELCOME="Welcome to SpecLeap!"
    MSG_INSTALL_TIME="⏱️  Estimated time: 10-15 minutes"
    MSG_REQUIREMENTS="Checking system requirements..."
    MSG_GITHUB="Step 2/6: GitHub Setup"
    MSG_ASANA="Step 3/6: Asana Setup (Required)"
    MSG_SKILLS="Step 4/6: Agent Skills (34 skills)"
    MSG_CODERABBIT="Step 5/6: CodeRabbit"
    MSG_FINAL="Step 6/6: Finishing"
    MSG_SUCCESS="✅ Installation complete!"
    MSG_NEXT_STEPS="Next steps:"
    MSG_ERROR="❌ Error:"
fi

echo ""
echo -e "${GREEN}${BOLD}$MSG_WELCOME${NC}"
echo -e "${YELLOW}$MSG_INSTALL_TIME${NC}"
echo ""
sleep 2

# ============================================
# VERIFICACIONES PREVIAS
# ============================================

echo -e "${CYAN}${BOLD}$MSG_REQUIREMENTS${NC}"
echo ""

# Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}$MSG_ERROR Node.js not installed${NC}"
    echo "Install from: https://nodejs.org"
    exit 1
fi
echo -e "${GREEN}✅ Node.js:${NC} $(node --version)"

# npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}$MSG_ERROR npm not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ npm:${NC} $(npm --version)"

# Git
if ! command -v git &> /dev/null; then
    echo -e "${RED}$MSG_ERROR Git not installed${NC}"
    echo "Install Git: https://git-scm.com"
    exit 1
fi
echo -e "${GREEN}✅ Git:${NC} $(git --version | cut -d' ' -f3)"

# curl
if ! command -v curl &> /dev/null; then
    echo -e "${RED}$MSG_ERROR curl not installed${NC}"
    exit 1
fi
echo -e "${GREEN}✅ curl:${NC} available"

echo ""
sleep 1

# ============================================
# PASO 2: GitHub
# ============================================

echo -e "${CYAN}${LINE}${NC}"
echo -e "${BLUE}${BOLD}$MSG_GITHUB${NC}"
echo -e "${CYAN}${LINE}${NC}"
echo ""

if [ "$LANG" = "es" ]; then
    echo "SpecLeap necesita GitHub para:"
    echo "  • Control de versiones del CONTRATO.md"
    echo "  • Integración con CodeRabbit (code review automático)"
    echo "  • Historial de cambios y decisiones"
    echo ""
    echo "🔗 Obtén tu token en: ${CYAN}https://github.com/settings/tokens${NC}"
    echo "   Permisos necesarios: repo, workflow"
    echo ""
else
    echo "SpecLeap needs GitHub for:"
    echo "  • CONTRACT.md version control"
    echo "  • CodeRabbit integration (automatic code review)"
    echo "  • Change and decision history"
    echo ""
    echo "🔗 Get your token at: ${CYAN}https://github.com/settings/tokens${NC}"
    echo "   Required scopes: repo, workflow"
    echo ""
fi

# Validación con reintentos: hasta 3 intentos antes de pedir abort/reintentar
GITHUB_USER=""
GITHUB_ATTEMPT=0
GITHUB_MAX_ATTEMPTS=3

while [ -z "$GITHUB_USER" ]; do
    GITHUB_ATTEMPT=$((GITHUB_ATTEMPT + 1))

    read -p "$(echo -e ${YELLOW}GitHub Token:${NC} )" GITHUB_TOKEN
    echo ""

    if [ -z "$GITHUB_TOKEN" ]; then
        if [ "$LANG" = "es" ]; then
            echo -e "${RED}❌ Token vacío. Pega tu token de GitHub.${NC}"
        else
            echo -e "${RED}❌ Empty token. Paste your GitHub token.${NC}"
        fi
        echo ""
        # No cuenta como intento si está vacío (probable typo / pegado mal)
        GITHUB_ATTEMPT=$((GITHUB_ATTEMPT - 1))
        continue
    fi

    # Verificar token contra la API de GitHub
    echo -ne "Verificando token... "
    GITHUB_USER=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -o '"login": "[^"]*' | cut -d'"' -f4)

    if [ -z "$GITHUB_USER" ]; then
        echo -e "${RED}❌ Token inválido${NC}"
        echo ""

        if [ "$GITHUB_ATTEMPT" -ge "$GITHUB_MAX_ATTEMPTS" ]; then
            if [ "$LANG" = "es" ]; then
                echo -e "${YELLOW}⚠️  Has fallado $GITHUB_MAX_ATTEMPTS veces.${NC}"
                read -p "$(echo -e ${YELLOW}¿[R]eintentar o [C]ancelar instalación? [R/c]:${NC} )" RETRY_CHOICE
            else
                echo -e "${YELLOW}⚠️  You've failed $GITHUB_MAX_ATTEMPTS times.${NC}"
                read -p "$(echo -e ${YELLOW}[R]etry or [C]ancel installation? [R/c]:${NC} )" RETRY_CHOICE
            fi

            if [[ "$RETRY_CHOICE" =~ ^[Cc]$ ]]; then
                if [ "$LANG" = "es" ]; then
                    echo -e "${RED}Instalación cancelada por el usuario.${NC}"
                else
                    echo -e "${RED}Installation cancelled by user.${NC}"
                fi
                exit 1
            fi
            # Reset contador para nueva ronda de 3 intentos
            GITHUB_ATTEMPT=0
            echo ""
            continue
        fi

        if [ "$LANG" = "es" ]; then
            echo "Intenta de nuevo (intento $((GITHUB_ATTEMPT + 1))/$GITHUB_MAX_ATTEMPTS)."
            echo "Verifica que el token tenga los permisos: repo, workflow."
        else
            echo "Try again (attempt $((GITHUB_ATTEMPT + 1))/$GITHUB_MAX_ATTEMPTS)."
            echo "Make sure the token has the scopes: repo, workflow."
        fi
        echo ""
    fi
done

echo -e "${GREEN}✅ Token válido (Usuario: $GITHUB_USER)${NC}"
echo ""
sleep 1

# ============================================
# PASO 3: Asana (OBLIGATORIO)
# ============================================

echo -e "${CYAN}${LINE}${NC}"
echo -e "${BLUE}${BOLD}$MSG_ASANA${NC}"
echo -e "${CYAN}${LINE}${NC}"
echo ""

if [ "$LANG" = "es" ]; then
    echo "⚠️  ${YELLOW}Asana es OBLIGATORIO para usar SpecLeap${NC}"
    echo ""
    echo "Asana te permite:"
    echo "  • Generar backlog automático desde CONTRATO.md"
    echo "  • Comando 'planificar' crea épicas + user stories"
    echo "  • Tracking de progreso"
    echo ""
    echo "📋 Cómo obtener tu token:"
    echo "  1. Ve a: ${CYAN}https://app.asana.com/0/my-apps${NC}"
    echo "  2. Click 'Create new token'"
    echo "  3. Nombre: 'SpecLeap Integration'"
    echo "  4. Copia el token (empieza con '0/')"
    echo ""
else
    echo "⚠️  ${YELLOW}Asana is REQUIRED to use SpecLeap${NC}"
    echo ""
    echo "Asana allows you to:"
    echo "  • Auto-generate backlog from CONTRACT.md"
    echo "  • 'planificar' command creates epics + user stories"
    echo "  • Progress tracking"
    echo ""
    echo "📋 How to get your token:"
    echo "  1. Go to: ${CYAN}https://app.asana.com/0/my-apps${NC}"
    echo "  2. Click 'Create new token'"
    echo "  3. Name: 'SpecLeap Integration'"
    echo "  4. Copy token (starts with '0/')"
    echo ""
fi

# Validación con reintentos: hasta 3 intentos antes de pedir abort/reintentar
ASANA_VALID=""
ASANA_ATTEMPT=0
ASANA_MAX_ATTEMPTS=3

while [ -z "$ASANA_VALID" ]; do
    ASANA_ATTEMPT=$((ASANA_ATTEMPT + 1))

    read -p "$(echo -e ${YELLOW}Asana Token:${NC} )" ASANA_TOKEN
    echo ""

    if [ -z "$ASANA_TOKEN" ]; then
        if [ "$LANG" = "es" ]; then
            echo -e "${RED}❌ Token vacío. Pega tu token de Asana (empieza con '0/' o '1/' o '2/').${NC}"
        else
            echo -e "${RED}❌ Empty token. Paste your Asana token (starts with '0/' or '1/' or '2/').${NC}"
        fi
        echo ""
        ASANA_ATTEMPT=$((ASANA_ATTEMPT - 1))
        continue
    fi

    # Verificar token y obtener workspace
    echo -ne "Verificando token Asana... "
    ASANA_RESPONSE=$(curl -s -H "Authorization: Bearer $ASANA_TOKEN" https://app.asana.com/api/1.0/workspaces)

    if echo "$ASANA_RESPONSE" | grep -q '"gid"'; then
        echo -e "${GREEN}✅ Token válido${NC}"
        ASANA_VALID="yes"
    else
        echo -e "${RED}❌ Token inválido${NC}"
        echo ""

        if [ "$ASANA_ATTEMPT" -ge "$ASANA_MAX_ATTEMPTS" ]; then
            if [ "$LANG" = "es" ]; then
                echo -e "${YELLOW}⚠️  Has fallado $ASANA_MAX_ATTEMPTS veces.${NC}"
                read -p "$(echo -e ${YELLOW}¿[R]eintentar o [C]ancelar instalación? [R/c]:${NC} )" RETRY_CHOICE
            else
                echo -e "${YELLOW}⚠️  You've failed $ASANA_MAX_ATTEMPTS times.${NC}"
                read -p "$(echo -e ${YELLOW}[R]etry or [C]ancel installation? [R/c]:${NC} )" RETRY_CHOICE
            fi

            if [[ "$RETRY_CHOICE" =~ ^[Cc]$ ]]; then
                if [ "$LANG" = "es" ]; then
                    echo -e "${RED}Instalación cancelada por el usuario.${NC}"
                else
                    echo -e "${RED}Installation cancelled by user.${NC}"
                fi
                exit 1
            fi
            ASANA_ATTEMPT=0
            echo ""
            continue
        fi

        if [ "$LANG" = "es" ]; then
            echo "Intenta de nuevo (intento $((ASANA_ATTEMPT + 1))/$ASANA_MAX_ATTEMPTS)."
            echo "Verifica que el token sea Personal Access Token de Asana."
        else
            echo "Try again (attempt $((ASANA_ATTEMPT + 1))/$ASANA_MAX_ATTEMPTS)."
            echo "Make sure the token is an Asana Personal Access Token."
        fi
        echo ""
    fi
done

echo ""

# Listar workspaces disponibles
if [ "$LANG" = "es" ]; then
    echo "Workspaces disponibles:"
else
    echo "Available workspaces:"
fi
echo ""

# Extraer workspaces (simple parsing)
WORKSPACE_COUNT=0
while IFS= read -r line; do
    if echo "$line" | grep -q '"gid"'; then
        WORKSPACE_COUNT=$((WORKSPACE_COUNT + 1))
        WS_GID=$(echo "$line" | grep -o '"gid":"[^"]*' | cut -d'"' -f4)
        WS_NAME=$(echo "$ASANA_RESPONSE" | grep -A1 "\"gid\":\"$WS_GID\"" | grep '"name"' | grep -o '"name":"[^"]*' | cut -d'"' -f4)
        echo "  $WORKSPACE_COUNT) $WS_NAME (ID: $WS_GID)"

        # Guardar primer workspace como default
        if [ $WORKSPACE_COUNT -eq 1 ]; then
            DEFAULT_WORKSPACE_ID="$WS_GID"
        fi
    fi
done < <(echo "$ASANA_RESPONSE" | grep '"gid"')

echo ""
if [ "$LANG" = "es" ]; then
    read -p "$(echo -e ${YELLOW}Workspace ID [Enter para usar el primero]:${NC} )" ASANA_WORKSPACE_INPUT
else
    read -p "$(echo -e ${YELLOW}Workspace ID [Enter to use first]:${NC} )" ASANA_WORKSPACE_INPUT
fi

if [ -z "$ASANA_WORKSPACE_INPUT" ]; then
    ASANA_WORKSPACE_ID="$DEFAULT_WORKSPACE_ID"
else
    ASANA_WORKSPACE_ID="$ASANA_WORKSPACE_INPUT"
fi

echo -e "${GREEN}✅ Workspace seleccionado: $ASANA_WORKSPACE_ID${NC}"

echo ""
sleep 1

# ============================================
# PASO 4: Agent Skills (34 skills: 20 TIER 1 + 14 TIER 2)
# ============================================

echo -e "${CYAN}${LINE}${NC}"
echo -e "${BLUE}${BOLD}$MSG_SKILLS${NC}"
echo -e "${CYAN}${LINE}${NC}"
echo ""

if [ "$LANG" = "es" ]; then
    echo "SpecLeap incluye 20 Agent Skills profesionales:"
    echo "  • 5 Seguridad (OWASP, STRIDE)"
    echo "  • 3 Consistencia (verification-before-completion)"
    echo "  • 6 Diseño (Vercel-style, UI/UX)"
    echo "  • 6 Backend/Dev (Laravel, React, TDD)"
    echo ""
    echo "⏱️  Tiempo: 2-3 minutos"
    echo ""
else
    echo "SpecLeap includes 20 professional Agent Skills:"
    echo "  • 5 Security (OWASP, STRIDE)"
    echo "  • 3 Consistency (verification-before-completion)"
    echo "  • 6 Design (Vercel-style, UI/UX)"
    echo "  • 6 Backend/Dev (Laravel, React, TDD)"
    echo ""
    echo "⏱️  Time: 2-3 minutes"
    echo ""
fi

read -p "$(echo -e ${YELLOW}Instalar Agent Skills? [S/n]:${NC} )" INSTALL_SKILLS

if [[ ! "$INSTALL_SKILLS" =~ ^[Nn]$ ]]; then
    bash scripts/install-skills.sh || {
        echo -e "${RED}$MSG_ERROR Skills installation failed${NC}"
        exit 1
    }
else
    echo -e "${YELLOW}⏭️  Skills omitidas${NC}"
fi

echo ""
sleep 1

# ============================================
# PASO 5: CodeRabbit
# ============================================

echo -e "${CYAN}${LINE}${NC}"
echo -e "${BLUE}${BOLD}$MSG_CODERABBIT${NC}"
echo -e "${CYAN}${LINE}${NC}"
echo ""

if [ "$LANG" = "es" ]; then
    echo "CodeRabbit hace code review automático en todos tus PRs."
    echo ""
    echo "Se copiará .coderabbit.yaml al proyecto."
    echo "Después deberás instalar la app en GitHub:"
    echo "  ${CYAN}https://github.com/apps/coderabbitai${NC}"
    echo ""
else
    echo "CodeRabbit automatically reviews all your PRs."
    echo ""
    echo ".coderabbit.yaml will be copied to your project."
    echo "Then install the GitHub app:"
    echo "  ${CYAN}https://github.com/apps/coderabbitai${NC}"
    echo ""
fi

# .coderabbit.yaml ya está en la raíz del proyecto
echo -e "${GREEN}✅ .coderabbit.yaml listo${NC}"

echo ""
sleep 1

# ============================================
# PASO 6: Guardar Configuración
# ============================================

echo -e "${CYAN}${LINE}${NC}"
echo -e "${BLUE}${BOLD}$MSG_FINAL${NC}"
echo -e "${CYAN}${LINE}${NC}"
echo ""

# Crear directorios
mkdir -p .specleap
mkdir -p proyectos

# Config JSON
cat > .specleap/config.json <<EOF
{
  "version": "2.0.0",
  "language": "$LANG",
  "installed_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "github_user": "$GITHUB_USER",
  "asana_workspace": "$ASANA_WORKSPACE_ID"
}
EOF

# .env
cat > .env <<EOF
# SpecLeap Configuration
SPECLEAP_LANG=$LANG

# GitHub
GITHUB_TOKEN=$GITHUB_TOKEN
GITHUB_USER=$GITHUB_USER

# Asana (REQUIRED)
ASANA_ACCESS_TOKEN=$ASANA_TOKEN
ASANA_WORKSPACE_ID=$ASANA_WORKSPACE_ID

# CodeRabbit (installed via GitHub App)
# https://github.com/apps/coderabbitai
EOF

# Hacer ejecutables los scripts
chmod +x scripts/*.sh 2>/dev/null || true

echo -e "${GREEN}✅ Configuración guardada${NC}"
echo ""

# ============================================
# RESUMEN FINAL
# ============================================

echo -e "${GREEN}${LINE}${NC}"
echo -e "${GREEN}${BOLD}"
echo "   ✅ $MSG_SUCCESS"
echo -e "${NC}${GREEN}${LINE}${NC}"
echo ""

echo -e "${YELLOW}${BOLD}$MSG_NEXT_STEPS${NC}"
echo ""

if [ "$LANG" = "es" ]; then
    echo "  ${BOLD}1. Instalar CodeRabbit en GitHub:${NC}"
    echo "     ${CYAN}https://github.com/apps/coderabbitai${NC}"
    echo ""
    echo "  ${BOLD}2. Ejecutar cuestionario (20 min):${NC}"
    echo "     ${GREEN}./scripts/generate-contrato.sh${NC}"
    echo ""
    echo "  ${BOLD}3. Push a GitHub:${NC}"
    echo "     ${GREEN}git init && git add . && git commit -m 'init: SpecLeap setup'${NC}"
    echo "     ${GREEN}git push origin main${NC}"
    echo ""
    echo "  ${BOLD}4. Abrir en tu IDE:${NC}"
    echo "     ${GREEN}code .${NC}  (VSCode)"
    echo "     ${GREEN}cursor .${NC}  (Cursor)"
    echo ""
    echo "  ${BOLD}5. En el chat con la IA, escribe:${NC}"
    echo "     ${GREEN}ayuda${NC}"
    echo ""
else
    echo "  ${BOLD}1. Install CodeRabbit on GitHub:${NC}"
    echo "     ${CYAN}https://github.com/apps/coderabbitai${NC}"
    echo ""
    echo "  ${BOLD}2. Run questionnaire (20 min):${NC}"
    echo "     ${GREEN}./scripts/generate-contrato.sh${NC}"
    echo ""
    echo "  ${BOLD}3. Push to GitHub:${NC}"
    echo "     ${GREEN}git init && git add . && git commit -m 'init: SpecLeap setup'${NC}"
    echo "     ${GREEN}git push origin main${NC}"
    echo ""
    echo "  ${BOLD}4. Open in your IDE:${NC}"
    echo "     ${GREEN}code .${NC}  (VSCode)"
    echo "     ${GREEN}cursor .${NC}  (Cursor)"
    echo ""
    echo "  ${BOLD}5. In AI chat, type:${NC}"
    echo "     ${GREEN}ayuda${NC}"
    echo ""
fi

echo -e "${CYAN}${LINE}${NC}"
echo ""
echo -e "${GREEN}${BOLD}¡Disfruta SpecLeap! 🚀${NC}"
echo ""
