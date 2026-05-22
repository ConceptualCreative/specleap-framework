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

**Propósito:** Instalar los 34 Agent Skills del framework en `~/.claude/skills/` (path canónico que Claude Code auto-descubre). Si existe `~/.skills/` de instalaciones previas (versiones ≤ 2.2.0), se crea un symlink desde el path canónico para mantener compatibilidad.

**Uso:**
```bash
bash scripts/install-skills.sh
```

**Instala:** 34 skills (20 TIER 1 + 14 TIER 2).

**Categorías:**
- Consistencia: `verification-before-completion`, `systematic-debugging`, `requesting-code-review`, `receiving-code-review`, `code-reviewer`, `debugging-wizard`
- Backend: `laravel-specialist`, `api-designer`, `database-optimizer`, `python-pro`, `react-expert`, `typescript-pro`
- Diseño y frontend: `frontend-design`, `canvas-design`, `algorithmic-art`, `skill-creator`, `web-design-guidelines`, `vercel-composition-patterns`, `agent-browser`
- DevOps: `devops-engineer`, `cloud-architect`, `architecture-designer`, `terraform-engineer`, `monitoring-expert`
- Mobile: `react-native-expert`, `flutter-expert`
- Testing: `test-driven-development`, `playwright-expert`, `test-master`
- Seguridad: `security-reviewer`, `gdpr-dsgvo-expert`
- Documentación y otros: `code-documenter`, `brainstorming`, `pdf`

El script detecta las skills ya instaladas y las salta. Puede volver a ejecutarse con seguridad.

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
