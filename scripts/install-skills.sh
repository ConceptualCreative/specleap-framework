#!/bin/bash
# SpecLeap — Instalador de Agent Skills TIER 1 + TIER 2
# Versión 2.1.1 — 34 skills profesionales

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━ Installing Agent Skills (34 total) ━━━${NC}"
echo ""

# Lista de skills (repo:path:name)
SKILLS=(
    # Consistencia (3) - obra/superpowers
    "obra/superpowers:skills/verification-before-completion:verification-before-completion"
    "obra/superpowers:skills/systematic-debugging:systematic-debugging"
    "obra/superpowers:skills/requesting-code-review:requesting-code-review"
    
    # Backend (7) - jeffallan/claude-skills
    "jeffallan/claude-skills:skills/laravel-specialist:laravel-specialist"
    "jeffallan/claude-skills:skills/api-designer:api-designer"
    "jeffallan/claude-skills:skills/database-optimizer:database-optimizer"
    "jeffallan/claude-skills:skills/code-reviewer:code-reviewer"
    "jeffallan/claude-skills:skills/debugging-wizard:debugging-wizard"
    "jeffallan/claude-skills:skills/python-pro:python-pro"
    "jeffallan/claude-skills:skills/react-expert:react-expert"
    
    # Diseño (4) - anthropics/skills
    "anthropics/skills:skills/frontend-design:frontend-design"
    "anthropics/skills:skills/skill-creator:skill-creator"
    "anthropics/skills:skills/canvas-design:canvas-design"
    "anthropics/skills:skills/algorithmic-art:algorithmic-art"
    
    # DevOps (3) - jeffallan/claude-skills
    "jeffallan/claude-skills:skills/devops-engineer:devops-engineer"
    "jeffallan/claude-skills:skills/cloud-architect:cloud-architect"
    "jeffallan/claude-skills:skills/architecture-designer:architecture-designer"
    
    # Testing (2) - obra/superpowers
    "obra/superpowers:skills/test-driven-development:test-driven-development"
    "obra/superpowers:skills/receiving-code-review:receiving-code-review"
    
    # Frontend (1) - jeffallan/claude-skills
    "jeffallan/claude-skills:skills/typescript-pro:typescript-pro"
    
    # ━━━ TIER 2 Skills (14 nuevas) ━━━
    
    # Design/Frontend (3) - vercel-labs
    "vercel-labs/agent-skills:skills/web-design-guidelines:web-design-guidelines"
    "vercel-labs/agent-skills:skills/composition-patterns:vercel-composition-patterns"
    "vercel-labs/agent-browser:skills/agent-browser:agent-browser"
    
    # Brainstorming (1) - obra/superpowers
    "obra/superpowers:skills/brainstorming:brainstorming"
    
    # PDF (1) - anthropics/skills
    "anthropics/skills:skills/pdf:pdf"
    
    # DevOps/Infrastructure (2) - jeffallan/claude-skills
    "jeffallan/claude-skills:skills/terraform-engineer:terraform-engineer"
    "jeffallan/claude-skills:skills/monitoring-expert:monitoring-expert"
    
    # Mobile (2) - jeffallan/claude-skills
    "jeffallan/claude-skills:skills/react-native-expert:react-native-expert"
    "jeffallan/claude-skills:skills/flutter-expert:flutter-expert"
    
    # Documentation (1) - jeffallan/claude-skills
    "jeffallan/claude-skills:skills/code-documenter:code-documenter"
    
    # Security (2) - jeffallan/claude-skills + alirezarezvani/claude-skills
    "jeffallan/claude-skills:skills/security-reviewer:security-reviewer"
    "alirezarezvani/claude-skills:ra-qm-team/gdpr-dsgvo-expert:gdpr-dsgvo-expert"
    
    # Testing Advanced (2) - jeffallan/claude-skills
    "jeffallan/claude-skills:skills/playwright-expert:playwright-expert"
    "jeffallan/claude-skills:skills/test-master:test-master"
)

TOTAL=${#SKILLS[@]}
INSTALLED=0
FAILED=0
SKIPPED=0

SKILLS_DIR="$HOME/.skills"
TMP_DIR="/tmp/specleap-skills-$$"

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
        ((SKIPPED++))
        continue
    fi
    
    # Clonar repo si no existe
    repo_dir="$TMP_DIR/$(echo $repo | tr '/' '_')"
    if [ ! -d "$repo_dir" ]; then
        if ! git clone -q "https://github.com/$repo.git" "$repo_dir" 2>/dev/null; then
            echo -e "${RED}FAIL${NC} (repo not accessible)"
            ((FAILED++))
            continue
        fi
    fi
    
    # Verificar SKILL.md
    if [ ! -f "$repo_dir/$path/SKILL.md" ]; then
        echo -e "${RED}FAIL${NC} (SKILL.md not found)"
        ((FAILED++))
        continue
    fi
    
    # Copiar skill
    cp -r "$repo_dir/$path" "$SKILLS_DIR/$name"
    echo -e "${GREEN}OK${NC}"
    ((INSTALLED++))
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
    echo -e "${GREEN}All skills already installed!${NC}"
    exit 0
fi

if [ $FAILED -gt 0 ]; then
    echo -e "${YELLOW}Warning: Some skills failed to install${NC}"
    echo "This may affect code quality. Check network connection and try again."
    exit 1
fi

echo -e "${GREEN}Agent Skills installation complete!${NC}"
