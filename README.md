<p align="center">
  <img src="assets/specleap-logo.png" alt="SpecLeap Framework" width="420" />
</p>

<p align="center">
  <strong>Framework de Spec-Driven Development para desarrollo asistido por IA.</strong>
</p>

<p align="center">
  <a href="https://github.com/ConceptualCreative/specleap-framework/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-3b82f6.svg" alt="MIT License" /></a>
  <a href="https://www.npmjs.com/package/specleap-framework"><img src="https://img.shields.io/npm/v/specleap-framework.svg?color=22c55e&label=npm" alt="npm version" /></a>
  <img src="https://img.shields.io/badge/agents-3-6366f1" alt="3 agents" />
  <img src="https://img.shields.io/badge/commands-10-f97316" alt="10 commands" />
  <img src="https://img.shields.io/badge/skills-34-22c55e" alt="34 Agent Skills" />
  <img src="https://img.shields.io/badge/hooks-1-ec4899" alt="1 hook" />
  <img src="https://img.shields.io/badge/rules-4-eab308" alt="4 rules" />
  <img src="https://img.shields.io/badge/built%20for-Claude%20Code-000000" alt="Built for Claude Code" />
  <a href="https://ko-fi.com/specleap"><img src="https://img.shields.io/badge/Ko--fi-Support%20SpecLeap-FF5E5B?logo=ko-fi&logoColor=white" alt="Ko-fi" /></a>
</p>

SpecLeap convierte cualquier IDE con asistente de IA en un entorno de desarrollo spec-first. Combina un contrato de proyecto inmutable, agentes conversacionales especializados, 34 Agent Skills profesionales y un pipeline de validación en tres capas para entregar código consistente y probado sin improvisación.

**Versión actual:** 2.1.14 · **Licencia:** MIT · **Autor:** Styng Arias ([ConceptualCreative](https://conceptualcreative.com))

---

## Tabla de Contenidos

- [Instalación Rápida](#instalación-rápida)
- [Qué Aporta](#qué-aporta)
- [Comandos Conversacionales](#comandos-conversacionales)
- [Agent Skills](#agent-skills)
- [Cuestionario Interactivo](#cuestionario-interactivo)
- [Pipeline de Validación](#pipeline-de-validación)
- [Estructura del Framework](#estructura-del-framework)
- [Tokens Requeridos](#tokens-requeridos)
- [IDEs Compatibles](#ides-compatibles)
- [Dos Modos de Trabajo](#dos-modos-de-trabajo)
- [Documentación](#documentación)
- [Preguntas Frecuentes (FAQ)](#preguntas-frecuentes-faq)
- [Licencia y Contribución](#licencia-y-contribución)

---

## Instalación Rápida

Hay dos formas de instalar SpecLeap. Elige según tu preferencia:

### Opción A: Vía npm (instalación interactiva, recomendado)

```bash
npx specleap-framework@latest
```

El instalador te **pregunta dónde quieres la carpeta y con qué nombre** antes de copiar nada. Ideal si quieres un setup guiado paso a paso.

Ejemplo de lo que verás:

```
📁 ¿En qué carpeta base instalar SpecLeap?
   Default: /Users/tu-usuario/Desktop
Carpeta base: ~/Downloads

📝 ¿Qué nombre quieres para la carpeta?
   Default: specleap-framework
Nombre: mi-app-tienda

→ Resultado: /Users/tu-usuario/Downloads/mi-app-tienda/
```

### Opción B: Vía git clone (control desde la terminal)

```bash
git clone https://github.com/ConceptualCreative/specleap-framework.git
cd specleap-framework
npm run setup     # cross-platform (macOS, Linux y Windows)
```

> `npm run setup` localiza bash automáticamente (en Windows usa Git Bash), así
> que funciona igual en cualquier sistema. Si prefieres, en macOS/Linux o dentro
> de una terminal **Git Bash** puedes ejecutar directamente `bash setup.sh`.

Cuando arranque `setup.sh` pregunta **cómo quieres que se llame la carpeta**. Si pulsas Enter mantiene el nombre del clon. Si escribes otro, el setup la renombra y sigue. En Windows esa carpeta puede estar en uso por el propio instalador: si el rename falla, continúa con el nombre actual y no aborta. Lo fiable en Windows es clonar ya con el nombre final (`git clone <url> mi-proyecto`). Después sigue con idioma, tokens, skills y CodeRabbit.

Atajo: si ya sabes el nombre, lo pasas a `git clone` para evitar el rename:

```bash
git clone https://github.com/ConceptualCreative/specleap-framework.git mi-proyecto
cd mi-proyecto
npm run setup
# El setup pregunta el nombre igualmente; pulsa Enter para mantener "mi-proyecto".
```

### Diferencias rápidas

| | Vía npm | Vía git clone |
|---|---|---|
| **Pregunta carpeta y nombre** | ✅ Sí, antes de copiar | Pregunta el nombre al arrancar. En Windows, si la carpeta está en uso, se queda el nombre del clon |
| **Requiere Node.js** | ✅ Sí (≥ 18) | ✅ Sí (≥ 18), para `npm run setup` |
| **Trae los archivos** | npm los descarga | git los clona del repo |
| **Ideal para** | Empezar rápido, no recordar el flujo de git | Devs que ya manejan git fluidamente |

A partir de aquí ambos flows son idénticos: el `setup.sh` solicita los tokens de GitHub y Asana, instala los 34 Agent Skills en `~/.claude/skills/` y genera la estructura base. Tiempo total: 10 a 15 minutos.

**Requisitos previos:**

- Vía npm → Node.js ≥ 18, Git, Bash.
- Vía git clone → Node.js ≥ 18, Git, Bash.
- **Windows** → instala [Git para Windows](https://git-scm.com/download/win), que incluye **Git Bash**. El instalador lo detecta automáticamente. (macOS y Linux ya traen Bash.)

---

## Qué Aporta

El desarrollo asistido por IA suele improvisar sin contexto, repetir errores pasados y dejar que el alcance se escape silenciosamente. SpecLeap impone una disciplina spec-first:

- Un **CONTRATO.md inmutable** define el proyecto y no cambia una vez aprobado. Las mejoras posteriores se registran en `ANEXOS.md`.
- Un banco de memoria `context/` guarda arquitectura, stack, convenciones y un log de decisiones técnicas.
- Tres agentes especializados (`backend`, `frontend`, `producto`) adoptan el rol adecuado según la tarea.
- Comandos conversacionales en español guían los ciclos de refinamiento, planificación, implementación y documentación.
- Un pipeline de validación de tres capas (pre-commit hooks, tests en `implementar` y CodeRabbit en el PR) bloquea merges de baja calidad.

---

## Comandos Conversacionales

Los comandos se escriben como palabras planas, sin prefijo (ni `/` ni `.`). El asistente detecta la palabra clave y ejecuta las instrucciones definidas en `.commands/*.md`.

| Comando | Descripción |
|---------|-------------|
| `Hola` | Inicia sesión: lista proyectos o arranca uno nuevo con el cuestionario |
| `refinar [proyecto]-XXX` | Refina la user story de una tarea Asana |
| `planificar [proyecto]-XXX` | Genera un plan de implementación desde el contrato |
| `implementar @plan.md` | Ejecuta el plan: rama, código, tests, PR |
| `explicar [concepto]` | Explica código, arquitectura o decisiones |
| `documentar` | Actualiza la documentación técnica |
| `adoptar` | Analiza un proyecto legacy y genera un CONTRATO retroactivo |
| `crear-tickets` | Alias de `planificar` |
| `ayuda` | Lista todos los comandos disponibles |

El prefijo `/` está reservado por Claude Code para sus propios slash commands (`/help`, `/clear`, etc.), por lo que los comandos de SpecLeap deben escribirse sin él para evitar colisión.

---

## Agent Skills

SpecLeap instala **34 Agent Skills curados** en `~/.claude/skills/` (path canónico que Claude Code auto-descubre) durante el setup. Se activan automáticamente cuando el contexto lo requiere. Cada skill viene de un repo público mantenido por su autor original.

| Categoría | Skills |
|-----------|--------|
| Core / Quality (5) | `verification-before-completion`, `systematic-debugging`, `requesting-code-review`, `receiving-code-review`, `test-driven-development` |
| Backend (4) | `laravel-specialist`, `api-designer`, `database-optimizer`, `supabase-postgres-best-practices` |
| Frontend (4) | `react-expert`, `typescript-pro`, `vercel-react-best-practices`, `shadcn` |
| Diseño (11) | `frontend-design`, `web-design-guidelines`, `extract-design-system`, `ui-ux-pro-max`, `impeccable`, `design-taste-frontend`, `emil-design-eng`, `animate`, `animation-performance`, `break-ui`, `mobile-native` |
| Seguridad (2) | `security-reviewer`, `gdpr-dsgvo-expert` |
| Proceso (8) | `code-reviewer`, `brainstorming`, `writing-plans`, `executing-plans`, `using-git-worktrees`, `subagent-driven-development`, `dispatching-parallel-agents`, `finishing-a-development-branch` |

La skill `verification-before-completion` aplica el principio *"sin evidencia fresca no se cierra"*: el asistente debe ejecutar verificaciones reales (tests, lint, curl) y pegar la salida antes de marcar nada como completado.

---

## Cuestionario Interactivo

Tras decir `Hola` y elegir "Proyecto nuevo", SpecLeap arranca un cuestionario de **58 preguntas** con checkpoint automático cada 10 preguntas. Duración estimada: 15 a 20 minutos.

El cuestionario cubre 20 secciones que van desde la identidad del proyecto (objetivo, problema, audiencia) hasta restricciones (plazo, presupuesto, fuera de alcance), pasando por stack, funcionalidades, sistema de usuarios, panel de administración, almacenamiento, pagos, notificaciones, diseño, arquitectura, despliegue, seguridad, rendimiento y testing.

Al finalizar se genera:

- `proyectos/[nombre]/CONTRATO.md` con YAML frontmatter
- `context/` completo (`brief.md`, `architecture.md`, `tech-stack.md`, `conventions.md`, `decisions.md`)
- Propuesta de estructura Asana (con confirmación manual antes de crear las tareas)

El sistema detecta sesiones incompletas al reiniciarlo y permite reanudar desde la última pregunta respondida.

---

## Pipeline de Validación

Un cambio solo llega a merge si pasa las tres capas automáticas:

| Capa | Momento | Duración | Valida |
|------|---------|----------|--------|
| Git hooks pre-commit | Antes de cada commit | <5 s | Sintaxis, linters, formato, inmutabilidad del CONTRATO |
| Validación en `implementar` | Al terminar una feature | 1 a 5 min | Tests unitarios e integración, specs, cobertura ≥ 80% |
| CodeRabbit en PR | Al abrir el Pull Request | 5 a 10 min | Arquitectura, seguridad, lógica de negocio, complejidad |

Instalación de los hooks desde la raíz del proyecto:

```bash
bash scripts/install-git-hooks.sh
```

La configuración de CodeRabbit vive en `.coderabbit.yaml` con perfil `assertive` y comentarios en español.

---

## Estructura del Framework

```
specleap/
├── proyectos/                Proyectos independientes
│   └── mi-proyecto/
│       ├── CONTRATO.md       Contrato inmutable
│       ├── ANEXOS.md         Mejoras y módulos adicionales
│       ├── context/          Memory bank del proyecto
│       └── specs/            Planes de implementación por ticket
├── .agents/                  Agentes (backend, frontend, producto)
├── .commands/                Comandos conversacionales
├── rules/                    Standards globales (PHP/Laravel, React, Tailwind, docs)
├── scripts/                  Automatización (cuestionario, Asana, skills, hooks)
├── openspec/                 CLI opcional para workflow formal
├── CLAUDE.md                 Contexto para Claude Code
├── AGENTS.md                 Contexto genérico multi-IDE
├── GEMINI.md                 Contexto para Google Gemini
├── codex.md                  Contexto para GitHub Copilot
└── SETUP.md                  Guía de instalación completa
```

Cada proyecto dentro de `proyectos/` es independiente, con su propio contrato y memoria, y se crea dinámicamente durante el flujo de `Hola`.

---

## Tokens Requeridos

Durante el setup se solicitan dos tokens que el instalador guarda en la configuración del IDE:

**GitHub Personal Access Token**
URL: https://github.com/settings/tokens
Tipo: classic · Scopes: `repo`, `workflow`

**Asana Personal Access Token**
URL: https://app.asana.com/0/my-apps
El token empieza por `0/`.

---

## IDEs Compatibles

SpecLeap es agnóstico al editor. Funciona con cualquier IDE que incorpore un asistente de IA:

- VSCode con Claude Code, GitHub Copilot o Continue
- Cursor
- JetBrains (IntelliJ, PhpStorm, WebStorm) con AI Assistant
- Vim y Neovim con plugins de IA
- Zed

El framework detecta el IDE y aplica los archivos de contexto apropiados (`CLAUDE.md`, `.cursorrules`, `GEMINI.md`, `codex.md`).

---

## Dos Modos de Trabajo

**Modo conversacional** — Recomendado para equipos pequeños o desarrollo individual. El flujo se ejecuta escribiendo los comandos en el chat con el asistente.

**Modo CLI formal (OpenSpec)** — Recomendado para equipos grandes o distribuidos con requisitos de trazabilidad. Expone comandos de terminal para gestionar propuestas de cambio con design, tasks y testing report estructurado:

```bash
openspec new CHANGE-001 "Añadir autenticación JWT"
openspec ff CHANGE-001
openspec apply CHANGE-001
openspec verify CHANGE-001
openspec code-review CHANGE-001
openspec archive CHANGE-001
```

Ambos modos coexisten. Lo habitual es trabajar conversacionalmente en el día a día y reservar el CLI para cambios grandes con auditoría completa.

---

## Documentación

- [SETUP.md](SETUP.md) — Guía de instalación paso a paso
- [openspec/README.md](openspec/README.md) — Referencia del CLI formal
- `.commands/ayuda.md` — Lista completa de comandos conversacionales
- `.agents/` — Definiciones de los tres roles especializados
- `rules/` — Standards globales por tecnología
- `proyectos/_template/CONTRATO.md` — Plantilla de contrato

---

## Convertir documentos a Markdown (opcional)

Si tienes el brief de un cliente en PDF, user stories en Word, o specs antiguas en Excel, SpecLeap incluye un wrapper sobre [Microsoft markitdown](https://github.com/microsoft/markitdown) para convertirlos a Markdown que el framework pueda usar como contexto.

**Instalación de markitdown** (dependencia opcional):

```bash
pip install markitdown
# o, si usas uv:
uv tool install markitdown
```

Requiere Python 3.10+. No es obligatorio: SpecLeap funciona perfectamente sin él. Solo lo necesitas si vas a alimentar archivos no-Markdown.

**Uso:**

```bash
# Un archivo individual
bash scripts/convert-docs.sh brief.pdf
# → genera brief.md

# Una carpeta entera (recursivo, max 3 niveles)
bash scripts/convert-docs.sh ./briefings/
# → convierte todos los pdf/docx/xlsx/pptx/html/csv/json/xml/epub que encuentre

# Ayuda
bash scripts/convert-docs.sh --help
```

Formatos soportados: **PDF, Word, PowerPoint, Excel, HTML, CSV, JSON, XML, EPub, imágenes (con OCR), audio (con transcripción)**.

Si markitdown no está instalado, el script muestra un mensaje claro con las instrucciones de instalación y termina sin tocar nada.

---

## Preguntas Frecuentes (FAQ)

Las preguntas habituales están respondidas en archivos dedicados:

- **Español:** [docs/faq.es.md](docs/faq.es.md)
- **English:** [docs/faq.en.md](docs/faq.en.md)

Cubren temas como vendor lock-in, cuándo SDD se rentabiliza, compatibilidad con asistentes que no son Claude Code, escalado en equipo, y cómo SDD complementa (no reemplaza) a TDD/Agile/Scrum.

Si tu pregunta no está cubierta, abre un issue en GitHub o escribe a `info@specleap.com`.

---

## Licencia y Contribución

Distribuido bajo licencia MIT. Ver [LICENSE](LICENSE).

Para contribuir:

1. Haz fork del repositorio.
2. Crea una rama: `git checkout -b feature/mi-cambio`.
3. Aplica los cambios y verifica que las tres capas de validación pasan.
4. Abre un Pull Request siguiendo Conventional Commits.

Mantenido por Styng Arias — [ConceptualCreative](https://conceptualcreative.com).

**Repositorio:** https://github.com/ConceptualCreative/specleap-framework
**Issues y feedback:** https://github.com/ConceptualCreative/specleap-framework/issues
**Sitio web:** https://specleap.com

Si SpecLeap te resulta útil y quieres apoyar el mantenimiento, puedes hacerlo en [Ko-fi](https://ko-fi.com/specleap).
