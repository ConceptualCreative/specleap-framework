# 🏛️ SpecLeap — Spec-Driven Development Framework

> **Forja tu arquitectura de software con IA.**

Un framework de desarrollo que combina contratos inmutables, agentes conversacionales y standards de código para entregar software de calidad sin improvisación.

---

## 🎯 ¿Qué es SpecLeap?

SpecLeap transforma cualquier IDE con asistente de IA en una máquina de desarrollo **spec-first**:

- 📋 **CONTRATO.md inmutable** — Define alcance y nunca cambia
- 🤖 **Agentes especializados** — Backend, Frontend, Producto
- 💬 **Comandos en español** — `refinar`, `planificar`, `implementar`
- 📦 **Multi-proyecto** — Cada proyecto independiente con su contrato
- 📚 **Standards globales** — Laravel, React, documentación
- 🔧 **CLI opcional** — `openspec` para automatización

---

## 💡 El Problema que Resuelve

❌ **Sin SpecLeap:**
- La IA improvisa código sin contexto
- Specs incompletas → implementación incorrecta
- Sin memoria → repite errores
- Cambios de scope sin control

✅ **Con SpecLeap:**
- CONTRATO define alcance inmutable
- Context/ guarda decisiones arquitectónicas
- Agentes especializados siguen standards
- Comandos conversacionales guían el flujo
- Memoria persistente por proyecto

---

## 🚀 Instalación

### Opción 1: Instalación desde npm (Recomendado)

```bash
npx specleap-framework@latest
```

**Instalador interactivo que pide todos los tokens:**
- ✅ GitHub token (control versiones + CodeRabbit)
- ✅ Asana token + workspace (backlog automático)
- ✅ Instala 34 Agent Skills automáticamente
- ✅ Configura CodeRabbit (.coderabbit.yaml)
- ✅ Crea estructura completa
- ⏱️ **Tiempo total: 10-15 minutos**

### Opción 2: Clonar desde GitHub

```bash
git clone https://github.com/ConceptualCreative/specleap-framework.git
cd specleap-framework/
bash setup.sh
```

**Mismo instalador interactivo. La diferencia es solo el método de descarga.**

---

## 📋 Tokens Necesarios (se piden durante instalación)

### GitHub Token (Obligatorio)

**Cómo obtener los tokens:**

1. **GitHub Token:**
   - Ve a https://github.com/settings/tokens
   - "Generate new token (classic)"
   - Scopes: `repo`, `workflow`

2. **Asana Token:**
   - Ve a https://app.asana.com/0/my-apps
   - "Create new token"
   - Nombre: "SpecLeap Integration"
   - Copia el token (empieza con `0/`)

**El instalador te pedirá estos tokens y configurará todo automáticamente.**

---

## ⭐ Agent Skills — Lo Que Hace la Diferencia

SpecLeap incluye **20 skills especializadas** que transforman la calidad del código:

### Sin Skills vs Con Skills

| Aspecto | Sin Skills | Con Skills TIER 1 |
|---------|-----------|-------------------|
| **Diseño** | Bootstrap genérico | Estilo Vercel/Linear profesional |
| **Seguridad** | Vulnerabilidades básicas | OWASP Top 10 + STRIDE threat modeling |
| **Código** | Duplicación frecuente | DRY automático, verifica antes de crear |
| **APIs** | Diseño inconsistente | REST/GraphQL best practices |
| **Tests** | Coverage <60% | TDD methodology, coverage >=90% |

### 34 Agent Skills Profesionales

SpecLeap instala automáticamente **34 skills de calidad profesional** durante el setup.

#### 🔄 Consistencia & Code Quality (6)
- **Verification-before-completion** ⭐ **CRÍTICO**
- Systematic debugging
- Code review (requesting + receiving)
- Security reviewer
- GDPR/DSGVO compliance expert

#### 🎨 Diseño & Frontend (7)
- Frontend design (Anthropic)
- Web design guidelines (Vercel)
- Vercel composition patterns
- Agent browser automation
- Canvas design
- Algorithmic art
- Skill creator

#### 🛠️ Backend & APIs (8)
- Laravel specialist
- API designer
- Database optimizer
- Code documenter
- Python pro
- React expert
- TypeScript pro
- Debugging wizard

#### ☁️ DevOps & Infrastructure (5)
- DevOps engineer
- Cloud architect
- Architecture designer
- Terraform engineer
- Monitoring expert

#### 🧪 Testing (5)
- Test-driven development
- Playwright expert (E2E)
- Test master
- Code reviewer
- Receiving code review

#### 📱 Mobile Development (2)
- React Native expert
- Flutter expert

#### 💡 Otros (1)
- Brainstorming
- PDF analysis

**Instalación:** Automática durante `setup.sh` — Total: **34 skills** — [Ver SETUP.md](SETUP.md)

---

## 🎯 Cuestionario Interactivo — De Idea a CONTRATO en 20 Minutos

**Nuevo en SpecLeap:** Sistema de 58 preguntas que genera tu CONTRATO.md automáticamente.

### ¿Cómo Funciona?

```bash
# Ejecuta el cuestionario
./scripts/generate-contrato.sh

# Te hace 58 preguntas sobre tu proyecto
# Guarda progreso cada 10 preguntas (puedes interrumpir)
# Genera CONTRATO.md completo con YAML frontmatter
```

### Lo Que Obtienes

✅ **CONTRATO.md completo** con:
- Información del proyecto (nombre, responsable, fecha)
- Identidad (objetivo, problema que resuelve, público objetivo)
- Stack tecnológico (backend, frontend, base de datos, DevOps)
- Funcionalidades core y secundarias
- Sistema de usuarios (roles, autenticación, permisos)
- Diseño (colores, estilo visual, responsive)
- Arquitectura (patrón, separación)
- Seguridad (nivel, GDPR, datos sensibles)
- Rendimiento (targets de carga, usuarios concurrentes)
- Testing (unit, integration, e2e, coverage)
- Restricciones (plazo, presupuesto, fuera de alcance)

✅ **Validaciones inteligentes:**
- Tipos de datos (string, select, boolean, number, array)
- Rangos y longitudes
- Patterns regex (slug, hexcolor, etc.)
- Skip condicional (si no tiene auth, no pregunta métodos)
- Auto-sugerencias (si eliges Laravel, sugiere PHP 8.3)

✅ **Guardado parcial:**
- Checkpoint cada 10 preguntas
- Puedes interrumpir y continuar después
- Detecta sesiones incompletas automáticamente

✅ **Integración Asana:**
- Genera backlog (secciones + user tareas)
- Preview visual antes de crear
- Confirmación manual
- Actualiza CONTRATO.md con metadata Asana

### Workflow Completo

```
1. Ejecuta cuestionario (20 min)
   ↓
2. Responde 58 preguntas
   ↓
3. CONTRATO.md generado automáticamente
   ↓
4. Push a GitHub (OBLIGATORIO — control de versiones)
   ↓
5. planificar → crea backlog Asana
   ↓
6. implementar → desarrolla según spec
```

**⚠️ IMPORTANTE:** El CONTRATO.md DEBE guardarse en GitHub. Es la fuente de verdad del proyecto y debe estar versionado junto con el código.

### Ejemplo de Uso

```bash
$ cd specleap
$ ./scripts/generate-contrato.sh

🎯 SpecLeap — Generador de CONTRATO.md
════════════════════════════════════════

⏱️  Tiempo estimado: 15-20 minutos
💾 Guardado automático cada 10 preguntas
🔄 Puedes interrumpir con Ctrl+C

¿Listo para comenzar? [s/N]: s

━━━ Información del Proyecto ━━━

Pregunta 1/56: ¿Nombre del proyecto? (slug-style)
💡 Usa solo minúsculas, números y guiones
📝 Ejemplo: mi-proyecto
> mi-tienda-online

Pregunta 2/56: ¿Nombre completo para mostrar?
💡 Puede tener mayúsculas, espacios
📝 Ejemplo: Mi Proyecto Awesome
> Mi Tienda Online

... (54 preguntas más)

✅ ¡Cuestionario completado! 🎉

━━━ Generando CONTRATO.md ━━━

✅ CONTRATO.md generado exitosamente
📄 Ubicación: proyectos/mi-tienda-online/CONTRATO.md
```

**Más información:** Ver [docs/SPEC-CUESTIONARIO-INTERACTIVO.md](docs/SPEC-CUESTIONARIO-INTERACTIVO.md)

---

## 📦 Estructura del Framework

```
specleap/
├── proyectos/                    # Proyectos independientes
│   ├── _template/                # Template para nuevos proyectos
│   │   ├── CONTRATO.md           # 🔒 Contrato inmutable
│   │   ├── ANEXOS.md             # ✏️ Mejoras/módulos adicionales
│   │   ├── context/              # Memory-bank del proyecto
│   │   │   ├── brief.md
│   │   │   ├── architecture.md
│   │   │   ├── tech-stack.md
│   │   │   ├── conventions.md
│   │   │   ├── decisions.md
│   │   │   ├── personas.md
│   │   │   └── user-stories.md
│   │   └── openspec/             # CLI state (propuestas)
│   │       └── proposals/
│   └── mi-proyecto/              # Tu proyecto activo
│       └── [misma estructura]
├── .agents/                      # Agentes especializados
│   ├── backend.md
│   ├── frontend.md
│   └── producto.md
├── .commands/                    # Comandos conversacionales
│   ├── inicio.md                 # Cuestionario 58 preguntas
│   ├── refinar.md
│   ├── planificar.md
│   ├── implementar.md
│   ├── documentar.md
│   ├── explicar.md
│   └── adoptar.md
├── rules/                        # Standards globales
│   ├── PHP-LARAVEL.md
│   ├── JAVASCRIPT-REACT.md
│   ├── CSS-TAILWIND.md
│   └── DOCS.md
├── scripts/                      # Automatización
│   ├── generate-contrato.sh      # Cuestionario interactivo ⭐
│   ├── generate-asana-structure.sh
│   ├── analyze-project.sh
│   ├── setup-mcp.sh              # Install Asana + Skills
│   └── install-skills.sh         # Agent Skills installer
├── openspec/                     # CLI (opcional)
│   ├── bin/openspec
│   └── src/
├── CLAUDE.md                     # Reglas generales para IA
├── AGENTS.md                     # Orquestación de agentes
└── SETUP.md                      # Guía completa de setup
```

---

## 🎮 Comandos Conversacionales

Habla con Claude/Cursor/Continue usando comandos en español:

### Para Nuevos Proyectos

```
Hola
→ Inicia cuestionario de 58 preguntas
→ Genera CONTRATO.md completo automáticamente
```

### Para Proyectos Existentes

```
refinar "añadir sistema de notificaciones push"
→ Analiza viabilidad
→ Genera propuesta de cambio
→ Actualiza context/

planificar
→ Lee CONTRATO.md
→ Genera backlog Asana
→ Crea secciones + user stories

implementar "login con google"
→ Verifica si está en CONTRATO
→ Lee context/ para contexto
→ Genera código siguiendo standards

documentar "api de usuarios"
→ Genera docs API (OpenAPI/Swagger)
→ Actualiza README técnico

explicar "arquitectura del sistema"
→ Genera diagrama + explicación
→ Basado en context/architecture.md

adoptar
→ Analiza proyecto existente
→ Genera CONTRATO retroactivo
→ Extrae arquitectura y decisiones
```

**Detalle completo:** Ver [docs/COMANDOS.md](docs/COMANDOS.md)

---

## 🤔 Dos Formas de Trabajar: Conversacional vs CLI Formal

SpecLeap ofrece **dos workflows** que conviven perfectamente según tus necesidades:

### 🗣️ **Modo Conversacional** (Recomendado para empezar)

**Usa comandos en chat** con tu asistente IA (Claude, Copilot, etc.):

```
# Ver todos los comandos disponibles
ayuda

# Comandos principales
refinar "Como usuario quiero login"
planificar
implementar
documentar
```

**Cuándo usarlo:**
- ✅ Equipos pequeños (1-3 devs) o desarrollo individual
- ✅ Prefieres chat natural vs terminal
- ✅ Desarrollo ágil y rápido
- ✅ Proyectos personales o startups

---

### ⚙️ **Modo CLI Formal** (OpenSpec)

**Usa comandos de terminal** para workflow estructurado:

```bash
# Ver todos los comandos CLI
openspec --help

# Workflow completo con propuestas formales
openspec new CHANGE-001 "Añadir autenticación JWT"
openspec ff CHANGE-001        # Fast-forward: genera propuesta completa
openspec apply CHANGE-001     # Implementa
openspec verify CHANGE-001    # Verifica tests + specs
openspec code-review CHANGE-001  # Review con CodeRabbit
openspec archive CHANGE-001   # Archiva completado
```

**Cuándo usarlo:**
- ✅ Equipos grandes (4+ devs) o distribuidos
- ✅ Necesitas propuestas de cambio formales y trazables
- ✅ Workflow enterprise con auditoría y trazabilidad completa

---

### 🔄 **¿Se Pueden Combinar?**

**¡Sí!** Usa conversacional para el día a día y CLI para cambios grandes:

```
# Desarrollo normal (conversacional)
implementar "fix bug en login"

# Feature grande (CLI formal con trazabilidad)
openspec new CHANGE-015 "Rediseño completo sistema de permisos"
openspec ff CHANGE-015
openspec apply CHANGE-015
```

**Detalle completo CLI:** Ver `openspec/README.md` y `openspec/cli/COMMAND_REFERENCE.md`

---

## 🎨 Funciona con tu IDE Favorito

**SpecLeap es agnóstico al IDE.** Funciona con **cualquier editor que tenga asistente de IA**:

- ✅ **VSCode** — Con GitHub Copilot, Claude Code, Continue extension
- ✅ **Cursor** — IDE nativo con Claude integrado
- ✅ **JetBrains** (IntelliJ, PhpStorm, WebStorm) — Con AI Assistant
- ✅ **Vim/Neovim** — Con plugins de IA (copilot.vim, etc.)
- ✅ **Zed** — Editor moderno con IA integrada
- ✅ **Cualquier IDE con asistente IA** — Si tu editor tiene IA, SpecLeap funciona

**Cómo funciona:**
- Lee archivos del proyecto (CLAUDE.md, GEMINI.md, .cursorrules, .copilot-instructions.md)
- Aplica Agent Skills automáticamente
- Usa comandos conversacionales o CLI según tu preferencia

**No hay IDE "recomendado"** — Usa el que más te guste. SpecLeap se adapta.

---

## 🛡️ Sistema de Validación en 3 Capas

SpecLeap garantiza calidad de código con **3 capas de validación automática**:

### **🔹 Capa 1: Git Hooks Pre-Commit** (Validación rápida - <5 seg)

**Se ejecuta ANTES de cada commit automáticamente.**

✅ **Valida:**
- Sintaxis (PHP, JS/TS)
- Linters (ESLint, PHPStan)
- Formatters (Prettier, PHP-CS-Fixer)
- CONTRATO.md no se modifica (es inmutable)
- No hay console.log / var_dump olvidados

❌ **Si falla:** Rechaza el commit y muestra errores

**Instalación:**
```bash
cd tu-proyecto
bash scripts/install-git-hooks.sh
```

**Para saltarte (NO recomendado):**
```bash
git commit --no-verify -m "mensaje"
```

---

### **🔹 Capa 2: Validación Completa en `implementar`** (1-5 min)

**Se ejecuta al terminar una feature antes de push.**

✅ **Valida:**
- Tests unitarios
- Tests de integración
- Validación vs CONTRATO.md
- Validación vs specs
- Coverage > 80%

❌ **Si falla:** NO hace push ni crea PR

✅ **Si pasa:** Commit + Push + Crea PR automáticamente

**Uso:**
```
implementar "login con Google"
→ Escribe código
→ Valida TODO automáticamente
→ Si pasa: push + PR creado
```

---

### **🔹 Capa 3: CodeRabbit en PR** (Revisión profunda - 5-10 min)

**Se ejecuta automáticamente al crear PR en GitHub.**

✅ **Valida:**
- Arquitectura y patrones
- Seguridad (vulnerabilidades)
- Lógica de negocio
- Cumplimiento de specs
- Complejidad ciclomática
- Documentación

✅ **Comenta en el PR con:**
- Problemas encontrados
- Sugerencias de mejora
- Labels automáticos
- Estimación de esfuerzo de review

**Setup:**
```bash
# 1. .coderabbit.yaml ya está incluido en SpecLeap
# 2. Instala CodeRabbit en tu repo: https://github.com/apps/coderabbit-ai
# 3. Crea un PR → CodeRabbit revisa automáticamente
```

**Perfil configurado:** "assertive" (riguroso pero constructivo)  
**Idioma:** Español  
**Más info:** Ver `.coderabbit.yaml`

---

### **🎯 Resultado: Código de Calidad Garantizado**

```
Escribes código
     ↓
🔹 Capa 1: Pre-commit hook valida básicos
     ↓ (si pasa)
git commit exitoso
     ↓
Comando `implementar` termina
     ↓
🔹 Capa 2: Validación completa (tests + specs)
     ↓ (si pasa)
Push + PR creado
     ↓
🔹 Capa 3: CodeRabbit revisa arquitectura + seguridad
     ↓
Merge (solo si las 3 capas pasan)
```

**Beneficios:**
- ✅ Menos bugs en producción
- ✅ Code reviews más rápidos (lo obvio ya está validado)
- ✅ Aprendes de CodeRabbit (explica el "por qué")
- ✅ Cumplimiento de specs garantizado

---

## 📚 Documentación Completa

- 📖 [SETUP.md](SETUP.md) — Instalación paso a paso
- 🎯 `.commands/inicio.md` — Sistema 58 preguntas interactivo
- 💬 `.commands/ayuda.md` — Lista completa de comandos
- 🛠️ `openspec/README.md` — CLI formal OpenSpec
- 🤖 `.agents/` — Agentes especializados (backend, frontend, producto)
- ⭐ `scripts/install-skills.sh` — 34 Agent Skills profesionales
- 📋 `proyectos/_template/CONTRATO.md` — Template contrato
- 🏗️ `CLAUDE.md` — Configuración para Claude Code

---

## 💖 Apoya el Proyecto

SpecLeap es **100% gratuito y open-source**. Si te resulta útil, puedes apoyar su desarrollo:

[![Ko-fi](https://img.shields.io/badge/Ko--fi-Support%20SpecLeap-FF5E5B?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/specleap)

Las donaciones nos ayudan a:
- ✅ Mantener el framework actualizado
- ✅ Desarrollar nuevas features
- ✅ Mejorar documentación
- ✅ Crear más Agent Skills
- ✅ Soporte a la comunidad

---

## 📜 Licencia

MIT License - Ver [LICENSE](LICENSE)

---

## 🤝 Contribuciones

¡Contribuciones bienvenidas! Por favor:

1. Fork el proyecto
2. Crea una branch (`git checkout -b feature/nueva-feature`)
3. Commit tus cambios (`git commit -am 'Add nueva feature'`)
4. Push a la branch (`git push origin feature/nueva-feature`)
5. Abre un Pull Request

---

## 🔗 Enlaces

- 🌐 **Website:** [specleap.com](https://specleap.com)
- 📦 **GitHub:** [github.com/ConceptualCreative/specleap-framework](https://github.com/ConceptualCreative/specleap-framework)
- 💬 **Comunidad:** (próximamente Discord/Slack)
- 📧 **Contacto:** [Abrir Issue en GitHub](https://github.com/ConceptualCreative/specleap-framework/issues)

---

**Hecho con ❤️ por la comunidad SpecLeap**
