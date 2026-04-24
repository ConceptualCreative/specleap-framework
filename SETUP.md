# SpecLeap — Instalación Rápida

## ⚡ Quick Start (5 minutos)

### Paso 1: Clonar el repositorio

```bash
git clone https://github.com/ConceptualCreative/specleap-framework.git
cd specleap-framework
```

### Paso 2: Ejecutar instalador

```bash
bash install.sh
```

**Qué hace:**
- Selecciona idioma (Español/English)
- Crea estructura de carpetas
- Genera archivos base

### Paso 3: Responder cuestionario

El instalador te hará **58 preguntas** sobre tu proyecto:
- Nombre del proyecto
- Objetivo y problema que resuelve
- Stack tecnológico (Laravel, React, etc.)
- Funcionalidades principales
- Usuarios y roles
- Seguridad y rendimiento

**Tiempo:** 10-15 minutos

**Resultado:** Genera automáticamente:
- `CONTRATO.md` — Especificación inmutable del proyecto
- `context/` — Arquitectura, diseño, decisiones técnicas
- `.agents/` — 3 agentes especializados (Backend, Frontend, Producto)
- `.commands/` — 8 comandos conversacionales

### Paso 4: Abrir en tu IDE

```bash
code .        # VSCode
# o
cursor .      # Cursor
```

**¡Listo!** Di **"Hola"** en el chat con Claude/Cursor y empieza a trabajar.

---

## 🎯 Primeros Pasos

### Comandos Conversacionales

Escribe estos comandos directamente en el chat con Claude/Cursor:

| Comando | Qué hace |
|---------|----------|
| `ayuda` | Lista TODOS los comandos disponibles |
| `refinar "añadir login social"` | Propone cambios al CONTRATO |
| `planificar` | Genera backlog en Asana |
| `implementar "crear API usuarios"` | Valida contra CONTRATO e implementa |
| `documentar "API REST"` | Genera docs OpenAPI/Swagger |
| `explicar arquitectura` | Explica decisiones técnicas |

### OpenSpec CLI Formal (Enterprise)

Alternativa al workflow conversacional. Para equipos que requieren propuestas formales y trazabilidad:

```bash
# Proponer cambio
./openspec/cli/openspec new "añadir carrito de compras"

# Ver propuesta
./openspec/cli/openspec show 001-carrito

# Aprobar
./openspec/cli/openspec approve 001-carrito

# Verificar implementación
./openspec/cli/openspec verify 001-carrito
```

---

## 🔌 Sistema de Calidad (Componentes Obligatorios)

**⚠️ IMPORTANTE:** Estos NO son opcionales. SpecLeap requiere estos componentes para SDD profesional:
- **Asana** — Gestión de backlog (comando `planificar`)
- **CodeRabbit** — Code review automático en PRs
- **Agent Skills** — Best practices automáticas (20 skills TIER 1)
- **Git Hooks** — Validación pre-commit local
- **GitHub** — Control de versiones y colaboración

Sin estos componentes, SpecLeap es solo un conjunto de archivos markdown.

---

### 1. Asana (Gestión de Backlog)

**¿Por qué?** Comando `planificar` genera automáticamente épicas y user stories en Asana.

#### Setup en 3 pasos:

**1. Obtener token Asana:**
- Ve a [app.asana.com/0/my-apps](https://app.asana.com/0/my-apps)
- Click **"Create new token"**
- Nombre: `SpecLeap Integration`
- Copia el token (empieza con `0/`)

**2. Obtener Workspace ID:**

```bash
curl -H "Authorization: Bearer TU_TOKEN_AQUI" \
     https://app.asana.com/api/1.0/workspaces
```

Copia el `"gid"` de tu workspace.

**3. Configurar .env:**

Edita `.env` en la raíz de SpecLeap:

```bash
ASANA_ACCESS_TOKEN="0/1234567890abcdef..."
ASANA_WORKSPACE_ID="1234567890123456"
```

**Verificar:**

```bash
# En el chat con Claude:
planificar

# Debería crear proyecto en Asana con:
# - Épicas (Features principales)
# - User Stories (Funcionalidades)
# - Tasks (Tareas técnicas)
```

---

### 2. CodeRabbit (Code Review Automático)

**¿Qué es?** Bot que revisa PRs automáticamente en GitHub.

#### Setup:

```bash
# 1. Copiar config al proyecto
cp .coderabbit.yaml tu-proyecto/.coderabbit.yaml

# 2. Commit y push
git add .coderabbit.yaml
git commit -m "Add CodeRabbit config"
git push origin main

# 3. Instalar app GitHub
# Ve a: https://github.com/apps/coderabbitai
# Click "Install"
```

**Resultado:** CodeRabbit revisará automáticamente tus PRs con:
- ✅ Security analysis
- ✅ Best practices
- ✅ Performance suggestions
- ✅ Code smells

---

### 3. Agent Skills (34 profesionales)

Extensiones para Claude/Cursor que aplican best practices automáticamente al contexto de cada tarea.

Instalación:

```bash
bash scripts/install-skills.sh
```

Se descargan e instalan 34 skills en `~/.skills/` (20 TIER 1 más 14 TIER 2):

- **Consistencia (6):** `verification-before-completion`, `systematic-debugging`, `requesting-code-review`, `receiving-code-review`, `code-reviewer`, `debugging-wizard`
- **Backend (6):** `laravel-specialist`, `api-designer`, `database-optimizer`, `python-pro`, `react-expert`, `typescript-pro`
- **Diseño y frontend (7):** `frontend-design`, `canvas-design`, `algorithmic-art`, `skill-creator`, `web-design-guidelines`, `vercel-composition-patterns`, `agent-browser`
- **DevOps (5):** `devops-engineer`, `cloud-architect`, `architecture-designer`, `terraform-engineer`, `monitoring-expert`
- **Mobile (2):** `react-native-expert`, `flutter-expert`
- **Testing (3):** `test-driven-development`, `playwright-expert`, `test-master`
- **Seguridad (2):** `security-reviewer`, `gdpr-dsgvo-expert`
- **Documentación y otros (3):** `code-documenter`, `brainstorming`, `pdf`

Verificar lo instalado:

```bash
ls ~/.skills/
```

---

### 4. Git Hooks (Validación Local Pre-Commit)

**Diferencia Git Hooks vs GitHub:**
- **Git Hooks** = Validación LOCAL (en tu máquina) ANTES de hacer commit
- **GitHub** = Repositorio REMOTO para push, pull, PRs y colaboración
- Ambos son OBLIGATORIOS para SDD profesional

**¿Por qué?** Valida código ANTES de hacer commit (linters, formatters, tests).

#### Instalación:

```bash
cd tu-proyecto
bash scripts/install-git-hooks.sh
```

**Qué valida:**
- ✅ ESLint (JavaScript/React)
- ✅ Prettier (formato código)
- ✅ PHPStan (análisis estático PHP)
- ✅ PHP-CS-Fixer (estándares PSR-12)
- ✅ Previene debug code (console.log, var_dump)
- ✅ Previene modificación CONTRATO.md

**Ejemplo:**

```bash
git commit -m "feat: add login"

→ 🔍 SpecLeap: Validando commit...
→   ✓ ESLint: OK
→   ✓ Prettier: OK
→   ✓ PHPStan: OK
→ ✅ Validación pre-commit exitosa

[main a1b2c3d] feat: add login
 3 files changed, 45 insertions(+)
```

**Si falla:**

```bash
git commit -m "feat: add login"

→ 🔍 SpecLeap: Validando commit...
→   ✗ ESLint: 2 errores encontrados
→     - src/Login.jsx:15 - 'userName' is defined but never used
→     - src/Login.jsx:23 - Missing return statement
→ ❌ Validación fallida. Corrige los errores y vuelve a intentar.
```

El commit es rechazado. Corrige y vuelve a intentar.

---

## 📚 Documentación Completa

### Guías Detalladas

- 📖 [README.md](README.md) — Overview del framework
- 💬 [docs/COMANDOS.md](docs/COMANDOS.md) — 8 comandos conversacionales explicados
- 🛠️ [docs/CLI-OPENSPEC.md](docs/CLI-OPENSPEC.md) — OpenSpec CLI formal (enterprise)
- 🤖 [docs/AGENTES.md](docs/AGENTES.md) — 3 agentes especializados
- ⭐ [docs/SKILLS-REFERENCE.md](docs/SKILLS-REFERENCE.md) — Quick reference 20 Agent Skills
- 🎯 [docs/SPEC-CUESTIONARIO-INTERACTIVO.md](docs/SPEC-CUESTIONARIO-INTERACTIVO.md) — Sistema 58 preguntas

### Prerequisitos del Sistema

- **Git** — Control de versiones
- **Node.js v20+** — Para cliente npm packages
- **npm** o **pnpm** — Gestor de paquetes

#### Opcional (según tu stack):

- **PHP 8.3+** — Para proyectos Laravel
- **Composer** — Gestor dependencias PHP
- **PostgreSQL/MySQL** — Base de datos
- **Docker** — Entornos containerizados

---

## 🆘 Troubleshooting

### "Command not found: openspec"

```bash
# Usa ruta relativa
./openspec/cli/openspec --version

# O agrega a PATH (opcional)
export PATH="$PATH:$(pwd)/openspec/cli"
```

### "Agent Skills no aparecen en mi IDE"

1. Verifica instalación:
```bash
ls -la ~/.skills/
```

2. Reinicia tu IDE (VSCode/Cursor/JetBrains)

3. Verifica config MCP:
```bash
cat ~/.config/claude/claude_desktop_config.json
```

### "Error al generar backlog Asana"

1. Verifica que `.env` tiene token correcto:
```bash
cat .env | grep ASANA
```

2. Test API:
```bash
curl -H "Authorization: Bearer $ASANA_ACCESS_TOKEN" \
     https://app.asana.com/api/1.0/users/me
```

Si da error 401: Token inválido. Genera uno nuevo en Asana.

### "Git hooks no se ejecutan"

```bash
# Verifica permisos
ls -la .git/hooks/pre-commit

# Debe ser ejecutable (-rwxr-xr-x)
# Si no lo es:
chmod +x .git/hooks/pre-commit
```

---

## ✅ Checklist de Setup Completo

- [ ] SpecLeap clonado y `install.sh` ejecutado
- [ ] Cuestionario 58 preguntas completado
- [ ] CONTRATO.md generado automáticamente
- [ ] IDE abierto (VSCode/Cursor) y chat con Claude funcional
- [ ] Comando `ayuda` ejecutado exitosamente
- [ ] **Asana configurado en `.env`** (OBLIGATORIO)
- [ ] **20 Agent Skills instaladas en ~/.skills/** (OBLIGATORIO)
- [ ] **Git hooks instalados** (OBLIGATORIO)
- [ ] **CodeRabbit configurado en GitHub** (OBLIGATORIO)
- [ ] **Repositorio pusheado a GitHub** (OBLIGATORIO)

---

**¡Listo para construir software spec-first! 🚀**

**Próximo paso:** Di `"ayuda"` en el chat para ver todos los comandos disponibles.
