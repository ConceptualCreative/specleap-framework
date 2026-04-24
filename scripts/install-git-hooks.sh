#!/bin/bash
# Install Git hooks for SpecLeap projects
# Usage: bash scripts/install-git-hooks.sh [project-path]

set -e

PROJECT_PATH="${1:-.}"
HOOKS_DIR="$PROJECT_PATH/.git/hooks"

if [ ! -d "$PROJECT_PATH/.git" ]; then
  echo "❌ Error: No es un repositorio Git"
  echo "   Ejecuta desde la raíz del proyecto o pasa la ruta como argumento"
  exit 1
fi

echo "🔧 Instalando Git hooks en: $PROJECT_PATH"

# Crear pre-commit hook
cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/bin/bash
# SpecLeap Pre-Commit Hook
# Validación rápida antes de cada commit

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "🔍 SpecLeap: Validando commit..."

ERRORS=0

# 1. Detectar archivos staged
STAGED_JS=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|ts|jsx|tsx)$' || true)
STAGED_PHP=$(git diff --cached --name-only --diff-filter=ACM | grep '\.php$' || true)
STAGED_SPECS=$(git diff --cached --name-only --diff-filter=ACM | grep -E 'CONTRATO\.md|ANEXOS\.md|openspec/.*\.md$' || true)

# 2. Linters JavaScript/TypeScript
if [ -n "$STAGED_JS" ]; then
  echo "  → Validando JS/TS..."
  
  if command -v eslint &> /dev/null; then
    if ! eslint $STAGED_JS; then
      echo -e "${RED}❌ ESLint encontró errores${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi
  
  if command -v prettier &> /dev/null; then
    if ! prettier --check $STAGED_JS 2>/dev/null; then
      echo -e "${YELLOW}⚠️  Prettier: código no formateado${NC}"
      echo "   Ejecuta: prettier --write $STAGED_JS"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi

# 3. Linters PHP
if [ -n "$STAGED_PHP" ]; then
  echo "  → Validando PHP..."
  
  # PHP Syntax Check
  for file in $STAGED_PHP; do
    if ! php -l "$file" > /dev/null 2>&1; then
      echo -e "${RED}❌ Error de sintaxis PHP: $file${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  done
  
  # PHPStan (si está instalado)
  if command -v phpstan &> /dev/null || [ -f vendor/bin/phpstan ]; then
    PHPSTAN_CMD=$(command -v phpstan || echo "vendor/bin/phpstan")
    if ! $PHPSTAN_CMD analyze $STAGED_PHP --level=5 --no-progress 2>/dev/null; then
      echo -e "${RED}❌ PHPStan encontró errores${NC}"
      ERRORS=$((ERRORS + 1))
    fi
  fi
  
  # PHP CS Fixer (si está instalado)
  if command -v php-cs-fixer &> /dev/null || [ -f vendor/bin/php-cs-fixer ]; then
    FIXER_CMD=$(command -v php-cs-fixer || echo "vendor/bin/php-cs-fixer")
    if ! $FIXER_CMD fix $STAGED_PHP --dry-run --diff 2>/dev/null; then
      echo -e "${YELLOW}⚠️  PHP CS Fixer: código no formateado${NC}"
      echo "   Ejecuta: $FIXER_CMD fix $STAGED_PHP"
      ERRORS=$((ERRORS + 1))
    fi
  fi
fi

# 4. Validar specs
if [ -n "$STAGED_SPECS" ]; then
  echo "  → Validando specs..."
  
  # Verificar que CONTRATO.md no se modifica (debe ser inmutable)
  if echo "$STAGED_SPECS" | grep -q "CONTRATO\.md"; then
    echo -e "${RED}❌ CONTRATO.md es inmutable${NC}"
    echo "   Usa ANEXOS.md para agregar funcionalidades"
    ERRORS=$((ERRORS + 1))
  fi
fi

# 5. Prevenir commits con TODOs críticos
TODO_FILES=$(git diff --cached --name-only --diff-filter=ACM | xargs grep -l "TODO.*CRITICAL\|FIXME.*URGENT" 2>/dev/null || true)
if [ -n "$TODO_FILES" ]; then
  echo -e "${RED}❌ Commits contienen TODOs críticos:${NC}"
  echo "$TODO_FILES"
  ERRORS=$((ERRORS + 1))
fi

# 6. Prevenir commits con console.log / var_dump
DEBUG_FILES=$(git diff --cached --name-only --diff-filter=ACM | xargs grep -l "console\.log\|var_dump\|dd(" 2>/dev/null || true)
if [ -n "$DEBUG_FILES" ]; then
  echo -e "${YELLOW}⚠️  Archivos contienen código debug:${NC}"
  echo "$DEBUG_FILES"
  echo "   ¿Estás seguro? (Los tests pueden fallar)"
fi

# Resultado
if [ $ERRORS -gt 0 ]; then
  echo ""
  echo -e "${RED}❌ Pre-commit falló con $ERRORS error(es)${NC}"
  echo "   Corrige los errores y vuelve a hacer commit"
  echo ""
  echo "   Si necesitas saltarte esta validación (NO recomendado):"
  echo "   git commit --no-verify -m \"mensaje\""
  exit 1
fi

echo -e "${GREEN}✅ Validación pre-commit exitosa${NC}"
exit 0
EOF

chmod +x "$HOOKS_DIR/pre-commit"

# Crear pre-push hook (bloquea push directo a main/stage)
cat > "$HOOKS_DIR/pre-push" << 'EOF'
#!/bin/bash
# SpecLeap Pre-Push Hook
# Bloquea pushes directos a las ramas protegidas (main, stage).
# Defensa local — equivalente a un Branch Protection Rule, mientras
# el repo sea privado en plan free (los Rulesets de GitHub solo están
# disponibles con Pro o repo público).

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

PROTECTED_BRANCHES=("main" "stage")

# git pre-push hooks reciben argumentos: <remote> <url>
# y por stdin líneas: <local_ref> <local_sha> <remote_ref> <remote_sha>
remote="$1"
url="$2"

while read -r local_ref local_sha remote_ref remote_sha; do
    # remote_ref es del estilo refs/heads/main, refs/heads/stage, refs/heads/feature/...
    branch_name="${remote_ref#refs/heads/}"

    for protected in "${PROTECTED_BRANCHES[@]}"; do
        if [ "$branch_name" = "$protected" ]; then
            echo ""
            echo -e "${RED}╔═════════════════════════════════════════════════════════╗${NC}"
            echo -e "${RED}║ SpecLeap: push directo a rama protegida BLOQUEADO       ║${NC}"
            echo -e "${RED}╚═════════════════════════════════════════════════════════╝${NC}"
            echo ""
            echo -e "  Rama destino: ${YELLOW}$branch_name${NC}"
            echo -e "  Remote:       ${YELLOW}$remote${NC} ($url)"
            echo ""
            echo "  El flujo SpecLeap requiere pull requests para integrar cambios:"
            echo "    feature/<proyecto>-<ticket>-<desc>  →  stage  →  main"
            echo ""
            echo "  Pasos:"
            echo "    1. Crea una feature branch:"
            echo -e "       ${GREEN}git checkout -b feature/[proyecto]-[ticket]-[desc]${NC}"
            echo ""
            echo "    2. Haz tus commits ahí y pushea esa branch:"
            echo -e "       ${GREEN}git push -u origin feature/[proyecto]-[ticket]-[desc]${NC}"
            echo ""
            echo "    3. Abre PR contra ${YELLOW}stage${NC} en GitHub."
            echo ""
            echo "  Si necesitas saltarte esto (emergencia, NO recomendado):"
            echo "    git push --no-verify"
            echo ""
            echo "  Más info: CONTRIBUTING.md"
            echo ""
            exit 1
        fi
    done
done

exit 0
EOF

chmod +x "$HOOKS_DIR/pre-push"

echo "✅ Git hooks instalados exitosamente"
echo ""
echo "📝 Hooks instalados:"
echo "   • pre-commit  — valida linters, formatters y specs antes de cada commit"
echo "   • pre-push    — bloquea pushes directos a main y stage (flujo feature → stage → main)"
echo ""
echo "💡 Para saltarte una validación (NO recomendado):"
echo "   git commit --no-verify -m \"mensaje\"   # bypassea pre-commit"
echo "   git push --no-verify                  # bypassea pre-push"
