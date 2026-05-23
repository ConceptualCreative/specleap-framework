#!/bin/bash
# SpecLeap — Instalador de Agent Skills (20 skills curados para el flujo SDD)
#
# Path: instala en $HOME/.claude/skills/ (path canónico que Claude Code
# auto-descubre). Si existe $HOME/.skills/ (path legacy de versiones previas
# de SpecLeap), se crea un symlink desde el path canónico para mantener
# compatibilidad sin mover archivos.
#
# La lista está curada para el stack de SpecLeap (Laravel + React + TypeScript
# + PostgreSQL) y el flujo CONTRATO → tickets → implementar → verify.

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━ Installing 20 curated Agent Skills ━━━${NC}"
echo ""

# Lista de skills (repo:path:name)
# El "name" debe coincidir con el frontmatter `name` del SKILL.md del repo,
# porque ese es el identificador que Claude Code usa para activar la skill.
SKILLS=(
    # Core / Quality (5)
    "obra/superpowers:skills/verification-before-completion:verification-before-completion"
    "obra/superpowers:skills/systematic-debugging:systematic-debugging"
    "obra/superpowers:skills/requesting-code-review:requesting-code-review"
    "obra/superpowers:skills/receiving-code-review:receiving-code-review"
    "obra/superpowers:skills/test-driven-development:test-driven-development"

    # Backend Stack (4) — Laravel + PostgreSQL
    "jeffallan/claude-skills:skills/laravel-specialist:laravel-specialist"
    "jeffallan/claude-skills:skills/api-designer:api-designer"
    "jeffallan/claude-skills:skills/database-optimizer:database-optimizer"
    "supabase/agent-skills:skills/supabase-postgres-best-practices:supabase-postgres-best-practices"

    # Frontend Stack (4) — React + TypeScript + Tailwind/shadcn
    "jeffallan/claude-skills:skills/react-expert:react-expert"
    "jeffallan/claude-skills:skills/typescript-pro:typescript-pro"
    "vercel-labs/agent-skills:skills/react-best-practices:vercel-react-best-practices"
    "shadcn-ui/ui:skills/shadcn:shadcn"

    # Design (3)
    "anthropics/skills:skills/frontend-design:frontend-design"
    "vercel-labs/agent-skills:skills/web-design-guidelines:web-design-guidelines"
    "arvindrk/extract-design-system:skills/extract-design-system:extract-design-system"

    # Security (2)
    "jeffallan/claude-skills:skills/security-reviewer:security-reviewer"
    "alirezarezvani/claude-skills:ra-qm-team/skills/gdpr-dsgvo-expert:gdpr-dsgvo-expert"

    # Process (2)
    "jeffallan/claude-skills:skills/code-reviewer:code-reviewer"
    "obra/superpowers:skills/brainstorming:brainstorming"
)

TOTAL=${#SKILLS[@]}
INSTALLED=0
FAILED=0
SKIPPED=0

SKILLS_DIR="$HOME/.claude/skills"
LEGACY_SKILLS_DIR="$HOME/.skills"
TMP_DIR="/tmp/specleap-skills-$$"

# Compatibilidad con instalaciones legacy:
# Si el path antiguo ($HOME/.skills/) tiene skills y el path canónico
# no existe todavía, crear symlink. Así Claude Code los ve sin tener
# que mover archivos ni reinstalar nada.
if [ -d "$LEGACY_SKILLS_DIR" ] && [ ! -e "$SKILLS_DIR" ]; then
    mkdir -p "$HOME/.claude"
    ln -s "$LEGACY_SKILLS_DIR" "$SKILLS_DIR"
    echo -e "${YELLOW}⚠️  Detected legacy skills path $LEGACY_SKILLS_DIR${NC}"
    echo -e "${YELLOW}   Created symlink at $SKILLS_DIR for Claude Code auto-discovery.${NC}"
    echo ""
fi

mkdir -p "$SKILLS_DIR"
mkdir -p "$TMP_DIR"

# Función para limpiar temporal
cleanup() {
    rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo -e "Installing to: ${GREEN}$SKILLS_DIR${NC}"
echo ""

for i in "${!SKILLS[@]}"; do
    IFS=':' read -r repo path name <<< "${SKILLS[$i]}"
    num=$((i + 1))

    printf "  [%2d/%2d] %-40s " "$num" "$TOTAL" "$name"

    # Skip si ya existe
    if [ -d "$SKILLS_DIR/$name" ]; then
        echo -e "${YELLOW}SKIP${NC} (already installed)"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi

    # Clonar repo si no existe
    repo_dir="$TMP_DIR/$(echo $repo | tr '/' '_')"
    if [ ! -d "$repo_dir" ]; then
        if ! git clone -q "https://github.com/$repo.git" "$repo_dir" 2>/dev/null; then
            echo -e "${RED}FAIL${NC} (repo not accessible)"
            FAILED=$((FAILED + 1))
            continue
        fi
    fi

    # Verificar SKILL.md
    if [ ! -f "$repo_dir/$path/SKILL.md" ]; then
        echo -e "${RED}FAIL${NC} (SKILL.md not found at $path)"
        FAILED=$((FAILED + 1))
        continue
    fi

    # Copiar skill
    cp -r "$repo_dir/$path" "$SKILLS_DIR/$name"
    echo -e "${GREEN}OK${NC}"
    INSTALLED=$((INSTALLED + 1))
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}✅ Installed:${NC} $INSTALLED"
if [ $SKIPPED -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Skipped:${NC} $SKIPPED (already existed)"
fi
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}❌ Failed:${NC} $FAILED"
fi
echo ""

if [ $INSTALLED -eq 0 ] && [ $SKIPPED -eq $TOTAL ]; then
    echo -e "${GREEN}All 20 skills already installed!${NC}"
    exit 0
fi

if [ $FAILED -gt 0 ]; then
    echo -e "${YELLOW}Warning: Some skills failed to install${NC}"
    echo "This may affect code quality. Check network connection and try again."
    exit 1
fi

echo -e "${GREEN}Agent Skills installation complete (20 skills)!${NC}"
