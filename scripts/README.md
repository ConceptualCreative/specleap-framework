# SpecLeap Scripts

Colección de scripts de automatización para SpecLeap.

---

## 📋 Scripts Disponibles

### `install-git-hooks.sh`

**Propósito:** Instalar git hooks de validación automática en proyectos

**Uso:**
```bash
# Desde la raíz del proyecto
bash scripts/install-git-hooks.sh

# O especificando ruta
bash scripts/install-git-hooks.sh /path/to/proyecto
```

**Qué instala:**
- **Pre-commit hook** — Validación rápida antes de cada commit

**Validaciones incluidas:**
- ✅ Sintaxis PHP (php -l)
- ✅ ESLint (JS/TS)
- ✅ Prettier (formateo)
- ✅ PHPStan (análisis estático PHP)
- ✅ PHP-CS-Fixer (estilo PHP)
- ✅ CONTRATO.md no se modifica (es inmutable)
- ✅ No hay TODOs críticos
- ✅ No hay código debug (console.log, var_dump, dd())

**Tiempo de ejecución:** <5 segundos

**Saltarse validación (NO recomendado):**
```bash
git commit --no-verify -m "mensaje"
```

---

### `install-skills.sh`

**Propósito:** Instalar los 34 Agent Skills curados del framework en `~/.claude/skills/` (path canónico que Claude Code auto-descubre). Si existe `~/.skills/` de instalaciones previas (versiones ≤ 2.2.1), se crea un symlink desde el path canónico para mantener compatibilidad.

**Uso:**
```bash
bash scripts/install-skills.sh
```

**Instala:** 34 skills curados para el stack de SpecLeap (Laravel + React + TypeScript + PostgreSQL) más diseño y motion.

**Categorías:**
- Core / Quality (5): `verification-before-completion`, `systematic-debugging`, `requesting-code-review`, `receiving-code-review`, `test-driven-development`
- Backend (4) — Laravel + PostgreSQL: `laravel-specialist`, `api-designer`, `database-optimizer`, `supabase-postgres-best-practices`
- Frontend (4) — React + TS + shadcn: `react-expert`, `typescript-pro`, `vercel-react-best-practices`, `shadcn`
- Diseño (11): `frontend-design`, `web-design-guidelines`, `extract-design-system`, `ui-ux-pro-max`, `impeccable`, `design-taste-frontend`, `emil-design-eng`, `animate`, `animation-performance`, `break-ui`, `mobile-native`
- Seguridad (2): `security-reviewer`, `gdpr-dsgvo-expert`
- Proceso (8): `code-reviewer`, `brainstorming`, `writing-plans`, `executing-plans`, `using-git-worktrees`, `subagent-driven-development`, `dispatching-parallel-agents`, `finishing-a-development-branch`

Si una skill del catálogo ya existe, el script la sustituye por la copia actual de upstream. Las skills propias con otro nombre no se tocan. Puede volver a ejecutarse con seguridad.

---

## 🔧 Troubleshooting

### Git hooks no se ejecutan

**Causa:** Permisos incorrectos

**Solución:**
```bash
chmod +x .git/hooks/pre-commit
```

### ESLint no encontrado

**Solución:**
```bash
npm install -D eslint
# o globalmente
npm install -g eslint
```

### PHPStan no encontrado

**Solución:**
```bash
composer require --dev phpstan/phpstan
# o globalmente
composer global require phpstan/phpstan
```

### Hook muy lento

**Causa:** Demasiados archivos staged

**Solución:** Commit en batches más pequeños
```bash
git add archivo1.js
git commit -m "feat: archivo 1"
git add archivo2.js
git commit -m "feat: archivo 2"
```

---

## 📚 Referencias

- **Git Hooks:** https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks
- **ESLint:** https://eslint.org
- **PHPStan:** https://phpstan.org
- **PHP-CS-Fixer:** https://cs.symfony.com
