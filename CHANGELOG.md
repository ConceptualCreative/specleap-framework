# SpecLeap Framework Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- **Instalación en Windows reparada (ambas vías).** El instalador dependía de comandos Unix (`cp -R`, `bash`) invocados desde PowerShell/cmd, donde no existen, lo que rompía la instalación en Windows:
  - **Vía npx** fallaba en la copia con `"cp" no se reconoce como un comando…`. Ahora `bin/specleap` copia con `fs.cpSync` (API nativa de Node, multiplataforma), sin depender de `cp`.
  - **Vía git clone** no llegaba a configurar idioma/tokens/skills porque `bash setup.sh` no encuentra `bash` en PowerShell. Ahora `npm run setup` localiza bash automáticamente (Git Bash en Windows) vía un nuevo modo `bin/specleap --here`.
  - **Localizador de bash cross-platform** (`findBash`): en macOS/Linux usa `bash` (comportamiento idéntico al anterior); en Windows busca Git Bash en rutas estándar y lo deriva de `where git`. Si no hay bash, muestra instrucciones claras para instalar Git para Windows en lugar de fallar de forma opaca.
  - La copia excluye `node_modules` y `.git` por seguridad.
- **Conteo de skills corregido a 20 (era "34").** `setup.sh` (cabecera del Paso 4 y listado completo ES/EN) seguía anunciando "34 Agent Skills" con un desglose TIER 1/TIER 2 obsoleto (Python, Flutter, Canvas, Terraform, Playwright, PDF… eliminados en v2.3.0). Ahora muestra los 20 skills reales agrupados por categoría (Core/Calidad, Backend, Frontend, Diseño, Seguridad, Proceso). Misma corrección aplicada en `docs/faq.es.md` y `docs/faq.en.md`.

### Documentation

- README.md y SETUP.md: instrucciones de instalación actualizadas para Windows (Git Bash) y `npm run setup` como arranque cross-platform de la vía git clone.

## [2.3.0] - 2026-05-23

### Changed (BREAKING)

- **Lista de Agent Skills reducida de 34 a 20**, curada para el stack real de SpecLeap (Laravel + React + TypeScript + PostgreSQL + shadcn). Cada skill viene de un repo público mantenido por su autor, sin invenciones. Detalle:
  - **Eliminados** (14 skills que no encajan con el público objetivo): `python-pro`, `flutter-expert`, `react-native-expert`, `algorithmic-art`, `canvas-design`, `pdf`, `skill-creator`, `terraform-engineer`, `monitoring-expert`, `cloud-architect`, `devops-engineer`, `architecture-designer`, `agent-browser`, `playwright-expert`, `test-master`, `debugging-wizard`, `code-documenter`, `vercel-composition-patterns`.
  - **Añadidos** (4 skills nuevos que estaban prometidos pero nunca se instalaban): `supabase-postgres-best-practices` (supabase/agent-skills), `vercel-react-best-practices` (vercel-labs/agent-skills, antes path obsoleto), `shadcn` (shadcn-ui/ui), `extract-design-system` (arvindrk/extract-design-system).
  - **Mantenidos** (16 skills): `verification-before-completion`, `systematic-debugging`, `requesting-code-review`, `receiving-code-review`, `test-driven-development`, `laravel-specialist`, `api-designer`, `database-optimizer`, `react-expert`, `typescript-pro`, `frontend-design`, `web-design-guidelines`, `security-reviewer`, `gdpr-dsgvo-expert`, `code-reviewer`, `brainstorming`.
- **Validado end-to-end**: `bash scripts/install-skills.sh` ejecutado contra sandbox limpio descarga los 20 skills sin fallos.

### Fixed

- **CLAUDE.md ya no contiene skills "fantasma"**. Antes documentaba 16 skills que NO existían en ningún repo público (`backend-api-security`, `tailwind-design-system`, `shadcn-ui`, `responsive-design`, `code-review-excellence`, `api-design-principles`, `error-handling-patterns`, `postgresql-table-design`, `sast-configuration`, `stride-analysis-patterns`, `security-requirement-extraction`, `frontend-mobile-security`, `vercel-react-best-practices` con nombre incorrecto, `laravel-standards`, `react-standards`, `frontend-standards`). Esto causaba que el modelo "alucinara" nombres de skills cuando el contexto las invocaba. Ahora CLAUDE.md menciona SÓLO los 20 realmente instalados.
- **Path de `gdpr-dsgvo-expert` corregido** en `install-skills.sh`. El path real en `alirezarezvani/claude-skills` es `ra-qm-team/skills/gdpr-dsgvo-expert`, no `ra-qm-team/gdpr-dsgvo-expert`. Sin este fix, el skill no se instalaba.

### Documentation

- `CLAUDE.md`, `README.md`, `SETUP.md`, `scripts/README.md` reescritos para reflejar los 20 skills curados con sus categorías reales (Core/Quality 5, Backend 4, Frontend 4, Diseño 3, Seguridad 2, Process 2).
- LP (`specleap.com`) actualizada: hero "20 Agent Skills curados", desglose por 6 categorías con los nombres exactos de skills reales, sin TIER 1/TIER 2 (innecesario al curar la lista). Tanto ES como EN.

## [2.2.1] - 2026-05-22

### Fixed

- **Bug crítico: los Agent Skills no se cargaban en Claude Code.** `scripts/install-skills.sh` instalaba en `$HOME/.skills/`, que es un path obsoleto que Claude Code dejó de monitorizar. El path canónico que auto-descubre Claude Code es `$HOME/.claude/skills/`. Resultado del bug: todos los usuarios de SpecLeap (incluido Styng) tenían los 34 Agent Skills instalados pero **invisibles** para el runtime — ninguno se activaba por contexto. Detectado tras consultar la doc oficial de Claude Code: solo lee skills de `~/.claude/skills/` (user-level) y `.claude/skills/` (project-level).
  - **Fix**: `scripts/install-skills.sh` ahora instala en `$HOME/.claude/skills/`. Si detecta una instalación legacy en `$HOME/.skills/` (de versiones ≤ 2.2.0), crea un symlink desde el path canónico apuntando al legacy. Así los usuarios existentes no tienen que mover archivos ni reinstalar — solo ejecutar `bash scripts/install-skills.sh` una vez para que el symlink se cree.
  - **Migración manual** (alternativa al symlink automático): `ln -s ~/.skills ~/.claude/skills`.
  - **Verificación**: tras el fix, decirle "Hola" a Claude Code dentro del proyecto y pedir algo que dispare un skill conocido (ej: "qué debo verificar antes de cerrar un ticket") debe activar `verification-before-completion`.

### Changed

- **`CLAUDE.md`, `README.md`, `SETUP.md`, `scripts/README.md`, `.commands/compliance.md`** actualizados para reflejar el path canónico `~/.claude/skills/` y documentar la compatibilidad con instalaciones legacy.

## [2.2.0] - 2026-05-02

### Changed

- **`setup.sh` — el prompt del nombre de carpeta se movió a DESPUÉS del Paso 1 (idioma)**, antes del Paso 2 (GitHub). Ahora sale en el idioma elegido (sólo ES o sólo EN, no bilingüe a la vez como en v2.1.14). El comportamiento funcional es idéntico (Enter para mantener nombre actual con default `specleap-framework`, valida caracteres, renombra in-place si se cambia, salta si `SPECLEAP_INSTALL_PATH` ya está set por `bin/specleap`). Reportado por Styng tras testear v2.1.14: el bloque salía con texto bilingüe simultáneo porque se ejecutaba antes de saber qué idioma había elegido el usuario.

- **`.commands/inicio.md` — nuevo Paso 0 (antes de listar proyectos) que ofrece instalar `markitdown`** (Microsoft, MIT, Python 3.10+) como herramienta opcional. Convierte PDF/Word/Excel/PowerPoint/HTML/CSV/JSON/XML/EPUB a Markdown. Cuando SpecLeap procesa documentos no-markdown durante el flujo conversacional, esta conversión previa baja el consumo de tokens entre 20% y 50%. El prompt se ejecuta UNA SOLA VEZ por sesión "Hola", es bilingüe (ES default, EN si el usuario habla en inglés), y nunca bloquea el flujo principal: si el usuario dice "No" o "Más tarde" se sigue normalmente con el listado de proyectos. Si dice "Sí", se verifica con `command -v markitdown` y se muestran instrucciones de instalación (`pip install 'markitdown[all]'` o `pipx install`) si no está. Pedido por Styng tras validar v2.1.14: quería que tras "Hola" se ofreciera la herramienta antes de empezar el primer proyecto.

### Fixed

- **Bug Asana: `.env` no se cargaba en sesiones nuevas de Claude Code.** `setup.sh` guarda `ASANA_ACCESS_TOKEN` y `ASANA_WORKSPACE_GID` en `.env` del proyecto SpecLeap, pero la shell que arranca Claude Code no lo carga automáticamente. Resultado: `crear-tickets` y `planificar` reportaban "ASANA_ACCESS_TOKEN no configurado" aunque el token sí existía en el `.env`.
  - **Fix**: `scripts/generate-asana-structure.sh` y `scripts/create-asana-tasks.sh` cargan `.env` con `set -a && source .env && set +a` al inicio (red de seguridad).
  - **Fix**: `.commands/planificar.md` instruye a la AI a hacer la misma carga ANTES de comprobar el token, dando un mensaje claro al usuario si falta.
  - **Fix**: `setup.sh` exporta tanto `ASANA_WORKSPACE_ID` como `ASANA_WORKSPACE_GID` (mismo valor) en `.env`, porque distintos scripts usan distintos nombres y antes había que hacer un roundtrip a la API para resolverlo.
  - **Reportado por Styng** durante test 2026-05-01 de v2.1.14.

### Changed

- **Ejemplos sesgados en cuestionario y comandos sustituidos por nombres genéricos neutros.** Antes los ejemplos eran `casa-de-peli`, `app-tienda`, `Mi Proyecto Awesome`, `Casa de Películas`, `Tienda Online de Café`, `Juan Pérez`, etc. Cambiados a `task-manager`, `inventory-app`, `crm-suite`, `Task Manager Pro`, `María García`, etc. Afecta: `scripts/lib/questions.es.json`, `scripts/lib/questions.en.json`, `.commands/inicio.md`, `.commands/explicar.md`, `.commands/implementar.md`, `.commands/planificar.md`, `.commands/nuevo/README.md`, `.commands/nuevo/responses-example.yaml`. Reportado por Styng: los ejemplos eran reconocibles como proyectos suyos y eso confunde a usuarios nuevos.
- **Pregunta 9 (competidores) ahora explica el "para qué".** Antes el `help` decía solo "Productos similares que te sirven de inspiración" — el usuario no entendía por qué se preguntaba. Ahora dice "Si conoces apps similares, las usaré como referencia para sugerir features y patrones de UX. Si no, escribe `ninguno` o déjalo vacío".

### Added

- **Tres modos de cuestionario al inicio del Flujo A (proyecto nuevo): MVP, Proyecto serio, Modo creativo.** Después de pedir el nombre del proyecto, `.commands/inicio.md` lanza un `AskUserQuestion` (Paso A0) preguntando qué tipo de proyecto se va a montar:
  - **MVP** (58 preguntas, 15-20 min) — proyecto pequeño / prototipo / 1 persona o equipo pequeño. Es el comportamiento histórico.
  - **Proyecto serio** (93 preguntas, 25-35 min) — equipo + departamentos + compliance + SLAs. Las 58 base + 35 nuevas: governance (5), departamentos involucrados (3), integraciones empresariales (5: SSO, ERP, CRM, BI, payroll), SLAs y resiliencia (5: uptime/RTO/RPO/DR/on-call), compliance (4: frameworks, DPO, audit log retention, data residency), roadmap por fases (3), procesos de release (3: feature flags, deploy strategy, rollback), observabilidad (3: APM/alerting/dashboards), multi-X (4: idiomas, tenant, regiones, i18n strategy).
  - **Modo creativo** (5-10 min) — el usuario describe el proyecto en un párrafo libre; la AI extrae lo dicho con razonamiento estructurado, muestra un resumen para validar, y solo pregunta los **campos críticos** que no fueron mencionados (`scripts/lib/critical_fields.json` define 18 críticos para MVP y 11 extra para Serio).

- **Transiciones bidireccionales entre modos (Paso A9).** Tras generar el CONTRATO en cualquier modo, ofrecer al usuario:
  - Mantener como está → seguir a `crear-tickets`.
  - Pasar a Serio → contestar las 35 preguntas extra de governance/compliance/SLAs (manteniendo las respuestas existentes).
  - Pasar a Creativo → describir matices en un párrafo libre que se añade como sección "Contexto Adicional" del CONTRATO.
  El paso es iterativo: se puede repetir para ir construyendo el CONTRATO incrementalmente.

- **`scripts/lib/questions.es.json` y `scripts/lib/questions.en.json` ahora marcan cada pregunta con un campo `modes`.** Las 58 base llevan `["mvp", "serio"]` (aparecen en ambos modos); las 35 nuevas llevan `["serio"]` (solo en modo serio). El cuestionario filtra por modo elegido antes de renderizar.

- **Nuevo archivo `scripts/lib/critical_fields.json`** que define los campos mínimos que el modo creativo verifica tras la extracción del párrafo del usuario. Si falta alguno, la AI hace una pregunta dirigida con contexto explicando POR QUÉ se necesita.

### Removed

- **`composer.json`** — residual de un proyecto Laravel previo (`barryvdh/laravel-dompdf`). SpecLeap no usa Composer ni PHP en sus dependencias; el archivo nunca debió formar parte del paquete npm.
- **`package-lock.json`** — sin sentido en un paquete que no declara `dependencies` ni `devDependencies` en `package.json`. Solo añadía ruido al diff.

## [2.1.14] - 2026-05-01

### Changed

- **`setup.sh` ahora pregunta SIEMPRE el nombre de la carpeta como Paso 0**, antes de la selección de idioma y antes de pedir cualquier token. Si el usuario escribe un nombre distinto al actual, el script renombra la carpeta in-place (`mv`) y sigue trabajando desde el nuevo path. Si pulsa Enter, se mantiene el nombre que ya tiene.
- El warning condicional introducido en v2.1.13 (que solo aparecía cuando la carpeta se llamaba exactamente `specleap-framework`) se elimina: el nuevo prompt activo lo reemplaza por completo, sin importar cómo se llame la carpeta de partida.

#### Por qué

Reportado por Styng tras testear v2.1.13: él esperaba un prompt activo, no un warning condicional. Con `git clone <url> mi-proyecto && cd mi-proyecto && bash setup.sh`, la v2.1.13 no preguntaba nada porque la carpeta no se llamaba `specleap-framework` (el filtro original era demasiado estrecho). Ahora el flujo es uniforme: el usuario siempre tiene la oportunidad de elegir el nombre, sin tener que recordar la sintaxis del segundo argumento de `git clone`.

#### Detalles del flujo

- Validación del nombre: letras, números, `-`, `_` y `.`, no puede empezar con `.`, máximo 100 caracteres. El prompt re-pregunta hasta que sea válido.
- Si el nombre escrito coincide con el actual, no hace `mv` (no-op), simplemente continúa.
- Si el nuevo path ya existe, se mantiene el nombre actual y se imprime un aviso (no aborta el setup).
- Si `SPECLEAP_INSTALL_PATH` ya está set (caso `npx` que pasa por `bin/specleap`), el bloque se salta entero — `bin/specleap` ya pidió el nombre antes de copiar archivos.
- El proceso bash sobrevive al `mv` del directorio activo porque mantiene el inode, no el path; tras el rename hace `cd` al nuevo path antes de continuar.

#### Tests cubiertos (4 escenarios, todos pasaron)

1. Enter en una carpeta llamada `specleap-framework` → mantiene nombre, no renombra.
2. Carpeta `mi-proyecto` + nombre nuevo `tienda-online` → renombra, vieja desaparece, nueva existe.
3. Carpeta `inicio` + nombre inválido `mi proyecto con espacios` + nombre válido `mi-proyecto-valido` → re-pregunta y luego renombra.
4. Carpeta `specleap-framework` + `SPECLEAP_INSTALL_PATH` set → no pregunta, va directo a Paso 1/6.

### Updated

- `README.md` y `SETUP.md`: la sección "Opción B: vía git clone" ahora explica que `setup.sh` pregunta el nombre como Paso 0 y que pasarlo a `git clone` es solo un atajo, no una obligación.

## [2.1.13] - 2026-05-01

### Fixed

- **Confusion between the two install flows.** Reported by Styng during testing: with `git clone … && bash setup.sh`, the installer was not asking the carpeta-base / folder-name prompts that `bin/specleap` (the npx entry point) does ask. That looked like a regression but it's by design — the prompts live in `bin/specleap` (Node), not in `setup.sh` (bash). When the user clones with git they already chose where the code lives, and the second positional argument of `git clone` is the canonical way to set a custom folder name. The fix is making the difference obvious in docs and in runtime.

#### Changes

- `setup.sh` now prints a bilingual heads-up at the very start (before the language step) when the current folder is named `specleap-framework` (the `git clone` default) AND the script was invoked without `bin/specleap` having set `SPECLEAP_INSTALL_PATH`. The user gets a one-second pause, an explanation of how to clone with a custom name (`git clone <url> mi-proyecto`), and a [S/n] confirmation before continuing. If they cancel, the script exits 0 cleanly.
- `README.md`: rewrote the "Instalación Rápida" section as two clearly-labeled options (Opción A: vía npx — interactive prompts; Opción B: vía git clone — direct, name controlled by `git clone <url> <nombre>`) plus a comparison table so the reader picks intentionally.
- `SETUP.md`: replicated the same comparison upfront in the Quick Start section, with full examples for each path.

### Notes

- No code-path change in the actual installation logic. `bin/specleap` keeps its prompts; `setup.sh` runs the same setup it always ran. Only documentation and a single pre-check in `setup.sh` change.
- The pre-check in `setup.sh` is opt-out (Enter or `S` to continue), so users who really want a folder named `specleap-framework` aren't forced to do anything extra.

## [2.1.12] - 2026-04-30

### Added

- **`scripts/convert-docs.sh`** — wrapper sobre [Microsoft markitdown](https://github.com/microsoft/markitdown) para convertir PDF, Word, PowerPoint, Excel, HTML, CSV, JSON, XML, EPub, imágenes (OCR) y audio (transcripción) a Markdown que el framework pueda usar como contexto. markitdown es una **dependencia opcional** (no se incluye en el tarball npm, no se instala automáticamente): si no está presente, el script muestra el mensaje de instalación (`pip install markitdown` o `uv tool install markitdown`) y termina con exit 1 sin tocar ningún archivo. Bilingüe ES/EN según `SPECLEAP_LANG`.
- Acepta tanto un archivo individual (`brief.pdf` → `brief.md`) como una carpeta entera (recursivo, max 3 niveles, filtra por extensiones soportadas).
- Documentación en `README.md` (sección "Convertir documentos a Markdown") y `SETUP.md` (sección "Herramientas Opcionales") con caso de uso típico (briefs de cliente, user stories exportadas, reference docs).

### Notes

- Decisión de diseño: markitdown se queda como opcional para no imponer Python 3.10+ a usuarios que no lo necesiten. SpecLeap solo requiere bash + node + git + curl + jq como antes.
- Caso de uso típico: cliente entrega brief en PDF → `bash scripts/convert-docs.sh brief.pdf` → `brief.md` → se referencia desde el cuestionario inicial. El AI gana contexto rico desde el primer comando.

## [2.1.11] - 2026-04-30

### Fixed

- **`setup.sh` was lying about how many Agent Skills get installed.** The "Paso 4/6" header correctly read "34 skills" but the description right below said "SpecLeap incluye 20 Agent Skills profesionales" with a four-bullet breakdown that summed to exactly 20 — leftover text from before the 14 TIER 2 skills were added in v2.1.0. Reported by Styng during v2.1.10 testing.

#### What the user sees now

- The full count (34) is stated up front.
- TIER 1 (20) is broken down into its 6 actual categories: Consistency (3), Backend/Dev (7), Design (4), DevOps (3), Testing (2), Frontend (1).
- TIER 2 (14) is broken down into its 8 actual categories: Design/Frontend advanced (3), Mobile (2), Security audits/GDPR (2), Testing advanced (2), Infrastructure (2), Brainstorming (1), PDF (1), Documentation (1).
- Both blocks are localised (ES + EN) and visually grouped with bold tier headers so the user can scan them quickly before deciding whether to install.

The numbers now match exactly what `scripts/install-skills.sh` actually downloads from upstream repos (obra/superpowers, jeffallan/claude-skills, anthropics/skills, vercel-labs/agent-*, alirezarezvani/claude-skills).

## [2.1.10] - 2026-04-30

### Added

- **Installer now also asks for the folder name**, on top of the base folder prompt added in v2.1.9. The user can keep `specleap-framework` (the default) or pick a custom name like `mi-app-tienda` straight from the prompt — no more renaming after install with `mv`.
- **Two-argument CLI form:** `npx specleap-framework@latest <base> [<name>]`. Both positional. If `<name>` is omitted, the prompt asks. If `<base>` is also omitted, both prompts run interactively.
- **Folder name validation:** allows letters, numbers, `-`, `_` and `.`, must not start with `.`, must be ≤100 chars. Invalid input on the prompt re-asks until valid; invalid input on the CLI argument aborts with a clear bilingual error and exit 1.

### Changed

- The "ya existe" abort message now reads "elige otra carpeta o nombre" (instead of just "elige otra carpeta base"), matching the new flexibility.

### Notes

- Backwards compatible with v2.1.9: same env var (`SPECLEAP_INSTALL_PATH`) handed off to `setup.sh`, same final summary block, same fallback behaviour for direct `bash setup.sh` invocations.
- Decision rationale: keep the prompt-based flow (no native GUI dialog) so the installer keeps working over SSH, in CI/CD pipelines and inside containers — exactly the kind of environments where a Mac-only `osascript` dialog would have broken things.

## [2.1.9] - 2026-04-30

### Added

- **Interactive base-folder prompt during `npx specleap-framework@latest`.** The installer now asks where to install before copying anything. Previously it dropped the `specleap-framework/` folder silently into the user's current working directory, leaving them unsure of the final location.

#### How it works

- `bin/specleap` (the entry point invoked by `npx`) now accepts an optional CLI argument with the base folder, e.g. `npx specleap-framework@latest ~/Downloads`. If the argument is omitted, an interactive bilingual prompt asks for the base folder, with the current working directory as default.
- The folder name is **always** `specleap-framework` (not configurable). If the user wants a different name, they rename it after install with `mv`.
- The base path supports `~`, `~/relative`, plain relative paths, and absolute paths. The resolved path is shown back to the user before copying.
- If the resolved target already exists, the installer aborts with a clear bilingual message instead of silently overwriting.
- The installer creates the base folder if it does not exist.

### Changed

- **Final summary of `setup.sh` now prints the absolute install path prominently.** Block at the end of the installer reads `📍 SpecLeap instalado en: <ruta>` (or `📍 SpecLeap installed at: <path>` in English). Reported by Styng during v2.1.8 testing — after a long setup, the path was effectively lost in the scrollback.
- **Next-steps list now starts with `cd "<install_path>"`** so the user knows how to reach the project regardless of where they ran `npx` from.

### Notes

- Backwards compatible: existing scripts that depend on `setup.sh` running from the project root still work — the env var `SPECLEAP_INSTALL_PATH` is set by `bin/specleap` but `setup.sh` falls back to `pwd` if absent.
- The folder-name decision (always `specleap-framework`) keeps documentation, generated paths and tutorials consistent across users.

## [2.1.8] - 2026-04-26

### Fixed

- **`setup.sh` token validation no longer aborts on the first wrong input.** Both the GitHub and the Asana token prompts now retry up to 3 times before asking the user whether to retry the round again or cancel the installation. Empty input doesn't consume an attempt (it's almost always a paste/typo, not a real failure). Reported by Styng during a manual test where pasting a partial Asana token killed the installer outright with no recovery path.

#### Behavioural details

- 3 attempts per round, then the installer prints the actual count and asks `[R]eintentar / [C]ancelar` (Spanish) or `[R]etry / [C]ancel` (English) depending on the chosen language.
- Choosing `R` (default) resets the attempt counter and lets the user try 3 more times — useful when they realise mid-prompt that they grabbed the wrong token.
- Choosing `C` exits cleanly with code 1 and the message `Instalación cancelada por el usuario` / `Installation cancelled by user`.
- After every invalid token, a tip is printed reminding the user about required scopes (GitHub: `repo`, `workflow`) or token format (Asana: Personal Access Token).
- Empty token input prints a localised reminder of the expected format and re-prompts without spending an attempt.

No changes to the validation logic itself (still calls `https://api.github.com/user` and `https://app.asana.com/api/1.0/workspaces`), so behaviour with valid tokens is unchanged.

## [2.1.7] - 2026-04-25

### Added

- **Bilingual setup questionnaire** (Phase 1 of i18n rollout) — `scripts/lib/questions.json` was split into `questions.es.json` and `questions.en.json`, both with all 58 questions. `generate-contrato.sh` now resolves the file at runtime from `SPECLEAP_LANG` (set by `setup.sh` from the user's choice or by `.specleap/config.json`), falling back to Spanish if the requested locale file is missing. Question IDs, numbers, options, validations and conditional logic (`skip_if`, `auto_suggest`) are preserved verbatim across both files for behavioural parity.
- **Bilingual openspec CLI `--help` output** (Phase 2 of i18n rollout) — the `usage()` function in all nine subcommands (`apply`, `archive`, `code-review`, `enrich`, `ff`, `new`, `report`, `status`, `verify`) now prints English when `SPECLEAP_LANG=en`. A new `cli_lang()` helper in `openspec/cli/common.sh` resolves the active language from the env var, then `.specleap/config.json`, then falls back to `es`. Spanish output is byte-identical to the previous version, so existing users see no change.
- **Bilingual FAQ** documenting the eight most common questions (vendor lock-in, SDD vs vibe coding, project size threshold, working without Claude Code, switching AI providers mid-project, Asana requirement, team scaling, relation to TDD/Agile/Scrum). Lives at `docs/faq.es.md` and `docs/faq.en.md`, linked from the README. Same content also rendered as a public section on `specleap.com/#faq` and `specleap.com/en/#faq`.
- **Branch protection workflow** — new `pre-push` git hook installed alongside `pre-commit` by `scripts/install-git-hooks.sh`. The hook blocks direct pushes to `main` and `stage`, redirecting contributors to the documented `feature → stage → main` flow. Bypassable with `--no-verify` for emergencies. Companion document `CONTRIBUTING.md` describes the workflow, commit conventions and hook setup.

### Notes

- The `.specleap/i18n/{es,en}.json` runtime catalog and the `t()` helper in `.specleap/i18n.sh` continue to be used for short labels and runtime messages. The bilingual files added in this release (`questions.<lang>.json`) follow the project's separate-files convention for larger localised content.
- The repository now has a `stage` branch as a permanent integration target; release tags are cut from `main` after a `stage → main` merge.
- This release is the first to ship the openspec CLI with English `--help` to npm. Local i18n catalog (`.specleap/i18n/`) was already in the v2.1.5 tarball.

## [2.1.6] - 2026-04-24

### Changed

- **`package.json` `bin` field** — switched from string form `"bin": "bin/specleap"` to object form `"bin": { "specleap": "bin/specleap" }`. This makes `npx specleap` work directly; previously the string form made npm link the executable as `specleap-framework` (the package name), forcing users to type `npx specleap-framework` — longer and counter-intuitive.
- **`package.json` `repository.url`** — added the `git+` prefix (`git+https://github.com/…`) to comply with the canonical [package.json spec](https://docs.npmjs.com/cli/configuring-npm/package-json#repository) and silence the normalization warning npm emitted on every publish.

### Fixed

- **`.gitignore`** — added `**/__pycache__/` and `**/*.pyc` so Python bytecode generated at runtime by the `ui-ux-pro-max` skill never sneaks into the repo. Companion to the `.npmignore` rule already shipping since v2.1.5 that keeps the tarball clean.
- **Removed tracked `.pyc` artifacts** from `.claude/skills/ui-ux-pro-max/scripts/__pycache__/` that had slipped into the repo before the gitignore rule existed.

### Notes

- No behavioral change to scripts, agents, commands, i18n or validation pipeline. Pure maintenance release to polish the packaging.

## [2.1.5] - 2026-04-24

### Fixed

- **npm tarball packaging** — the v2.1.4 tarball was missing critical files. Added `.specleap/i18n/**` (ES/EN translations used by `setup.sh` and runtime scripts), `.specleap/i18n.sh` (loader), `openspec/**` (optional formal CLI + templates + examples), and `CHANGELOG.md` to the `files` whitelist in `package.json`. Without `.specleap/i18n/`, the setup process would fall back to raw keys instead of localized messages. Without `openspec/**`, the documented formal CLI was unreachable from npm-installed copies.
- **`.npmignore`** — the overly broad `.specleap/` exclusion was replaced with a precise `.specleap/config.json` exclusion (only the actual secret). Added `**/__pycache__/` and `**/*.pyc` to prevent Python bytecode leaking into the published package.

### Notes

- Version 2.1.4 was tagged locally and pushed to the private GitHub repo but **never published to npm**, so no user ever received the incomplete tarball. The tag `v2.1.4` remains in GitHub as historical marker of the install-skills.sh fix commit, while `v2.1.5` is the first release published to the npm registry after the ownership transfer to ConceptualCreative.

## [2.1.4] - 2026-04-24

### Fixed

- **`scripts/install-skills.sh`** — replaced four occurrences of `((VAR++))` counter increments with `VAR=$((VAR + 1))` plain assignments. The post-increment form returns exit code 1 when the variable starts at 0 (arithmetic expression evaluates to 0 → bash interprets as false), which under `set -e` killed the installer after the first skill. Installation now completes all 34 skills as expected on bash 3.2+ (macOS default) and newer shells. Reported by a collaborator during smoke testing.

## [2.1.3] - 2026-04-23

### Changed

- **Repository ownership transferred** from `iapanderson/specleap-framework` to `ConceptualCreative/specleap-framework`. Old URLs keep working via GitHub 301 redirect.
- Migrated residual Jira / SCRUM references to Asana / `[proyecto]-XXX` across `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `codex.md`, `README.md`.
- Renamed "Slash Command Detection" section in `CLAUDE.md` to "Command Detection"; added a format note clarifying that commands are plain keywords with no `/` or `.` prefix to avoid collision with Claude Code native slash commands.
- Fixed 11 broken `.commandsXXX.md` paths in `.commands/inicio.md`.
- Updated `package.json` author metadata to `Styng Arias <developers@conceptualcreative.com>` and repository URLs to `ConceptualCreative/specleap-framework`.
- Renamed `generate-jira-structure.sh` reference to `generate-asana-structure.sh` in README tree diagram.
- Fixed TIER 2 comment in `scripts/install-skills.sh` (13 → 14 new skills).
- Redesigned `README.md` from 624 to 248 lines: removed all decorative emojis, added table of contents, consolidated validation pipeline into a single table, flat TIER 1 / TIER 2 skill tables.
- Fixed legacy i18n key typo: `scripts.creating_effort` → `scripts.creating_structure` in `en.json`.
- Updated Agent Skills count message in `setup.sh` (20 → 34).

### Added

#### Quality infrastructure

- **`.quality/` directory** with versioned `baselines/baseline.json` (coverage min 80 / target 90, complexity 10 per function, duplicates max 3%) and per-feature `evidence/[slug]/` folder for audit trail (gitignored).
- **`scripts/quality-baseline.sh`** — helper with three verbs: `init`, `snapshot`, `new-evidence [slug]`. Populates `repo_snapshot` (LOC, files, agents, commands, skills) and creates evidence stubs for each feature.
- **`scripts/quality-healing.sh`** — healing telemetry log with three verbs: `log`, `show`, `stats`. JSONL format per feature at `.quality/evidence/[slug]/healing.jsonl` with fields `ts`, `phase`, `severity`, `action`, `detail`, `file`.

#### Spec-guard hook

- **`.claude/hooks/spec-guard.sh`** — `PreToolUse` hook that blocks `Write` / `Edit` / `NotebookEdit` on files under `src/`, `app/`, `tests/`, `test/`, `lib/` when the current git branch is `main`, `stage` or `develop`. Fail-open on internal errors (no git, no jq, malformed stdin). Pedagogical block message suggests creating a `feature/[proyecto]-[ticket]-[desc]` branch and recalls the `feature → stage → main` flow.
- **`.claude/settings.json.template`** — hook wiring snippet that consumer projects merge into their own `.claude/settings.json`.

#### Compliance audit

- **`compliance` command** (`.commands/compliance.md`) — conversational trigger (`compliance`, `auditoria`, `audit`) that runs the self-audit and reports back.
- **`scripts/compliance-audit.sh`** — six-dimension self-audit with 0–100 score per dimension and averaged total:
  - *Version* — `package.json` version vs last git tag
  - *Skills* — `~/.skills/` count vs README / baseline counters
  - *i18n* — key parity between `es.json` and `en.json`
  - *Hooks* — `spec-guard.sh` present, shebang, executable, referenced in settings template
  - *Baseline* — `repo_snapshot` freshness (≤20% drift)
  - *Docs* — no legacy brand residuals in root `*.md`
- Writes per-run JSON detail to `.quality/evidence/compliance/audit-TS.json` (gitignored).

#### Internationalisation

- New namespaces `quality.baseline`, `quality.healing`, `quality.spec_guard`, `quality.compliance` in `.specleap/i18n/es.json` and `en.json`. All new runtime messages go through the existing `t "key.path"` helper.

### Removed

- **`scripts/setup-mcp.sh`** — obsolete Jira-MCP installer that contradicted the actual Asana-via-API flow handled by `setup.sh`. It claimed to install the Asana client but in practice prompted for Atlassian credentials and wrote a Jira MCP block into IDE config. Removed entirely; Asana is wired through `setup.sh` (direct API + token in `.env`), not through MCP.
- References to `openclaw` in `.commands/planificar.md` (legacy orchestration tool, no longer relevant to the public framework).
- Historical `CHANGELOG.md` entry no longer spells out the concrete personal emails that had been removed in v2.0; rewritten to "Legacy personal emails (removed)".

### Fixed

- **`SETUP.md`** Agent Skills section: updated from "20 Skills" to "34 profesionales" (20 TIER 1 + 14 TIER 2), pointed to `scripts/install-skills.sh` (the real installer), removed decorative emojis and the reference to `docs/SKILLS-REFERENCE.md` (deleted in v2.0).
- **`scripts/README.md`**: removed the obsolete `setup-mcp.sh` section and updated `install-skills.sh` description to 34 skills with full category breakdown.
- **`.gitignore`**: added `.specleap/config.json` (generated per-user by `setup.sh`, contains `github_user` and `asana_workspace`; must never be committed).

### Changed (deep cleanup pass)

A thorough pre-release audit revealed ~60 additional legacy references missed by the first cleanup pass. This round completes the migration:

- **`openspec/` CLI made tracker-agnostic** instead of Jira-coupled. The flag `--jira <key>` becomes `--ticket <id>`, variable `JIRA_KEY` becomes `TICKET_ID`, function `parse_jira_key()` becomes `parse_ticket_id()`. Regex updated from `[A-Z]+-[0-9]+` to `[a-zA-Z0-9-]+-[0-9]+` so it accepts the SpecLeap convention `app-tienda-23`, `channel-pms-107`, etc.
- Templates (`openspec/templates/proposal.md`, `tasks.md`, `.coderabbit.yaml`) now use `TICKET-XXX` as the neutral placeholder (git-friendly for branch names, no brackets).
- Examples in `openspec/examples/CHANGE-SAMPLE-001-user-authentication/` rewritten to use `app-tienda-NN` tickets instead of `PROJ-NNN`.
- `.agents/backend.md`, `.agents/frontend.md`, `.agents/producto.md` updated (13 Jira mentions across the three roles) to use Asana terminology and the real `ASANA_ACCESS_TOKEN` flow instead of a fictional "Jira MCP".
- `.cursorrules`, `.continuerules`, `.clinerules`, `.continue/rules/04-git-workflow.md`, `.github/copilot-instructions.md`, `.coderabbit.yaml` updated with Asana/ticket terminology and `app-tienda-23` example.
- `rules/git-workflow.md`, `rules/session-protocol.md` updated to mention Asana explicitly.
- `scripts/generate-contract.sh` YAML frontmatter block `jira: {...}` replaced with `asana: {...}` (workspace_id, section_count, task_count, synced_at).
- `scripts/lib/render-contrato.py` and `.continuerules` had residual "ArchSpec" branding in headers/titles; now "SpecLeap".
- `.quality/README.md` example `channel-pms-107` (a real internal project name leaked) replaced with neutral `api-backend-45`.

### Removed (deep cleanup pass)

- **`scripts/lib/jira-project-utils.sh`** (222 lines) — Jira project utilities. No caller imported it (`grep -r` returned 0 usages).
- **`scripts/test-cuestionario.sh`** (428 lines) — Jira-oriented test harness that referenced the already-renamed `generate-jira-structure.sh` (now `generate-asana-structure.sh`) and had no invocations anywhere in the repo.

### Fixed (deep cleanup pass)

- `.agents/producto.md` line 374: the word "Transiciona" was split across a blank line ("Transi\n\nciona"); restored as a single word.

---

## [2.1.1] - 2026-04-04

### Added
- **GDPR/DSGVO expert** skill (alirezarezvani/claude-skills) — GDPR compliance validation

### Changed
- Total skills: 33 → **34**

## [2.1.0] - 2026-04-04

### Added

#### 🎯 13 New Agent Skills (Total: 33)

**Design & Frontend (3):**
- `web-design-guidelines` (vercel-labs) — Vercel-style design patterns
- `vercel-composition-patterns` (vercel-labs) — React composition best practices
- `agent-browser` (vercel-labs) — Browser automation for testing

**Brainstorming & Documentation (2):**
- `brainstorming` (obra/superpowers) — Ideation techniques for spec refinement
- `pdf` (anthropics) — PDF analysis and manipulation

**DevOps & Infrastructure (2):**
- `terraform-engineer` (jeffallan) — Infrastructure as Code with Terraform
- `monitoring-expert` (jeffallan) — Performance profiling and monitoring

**Mobile Development (2):**
- `react-native-expert` (jeffallan) — React Native mobile development
- `flutter-expert` (jeffallan) — Flutter cross-platform development

**Documentation (1):**
- `code-documenter` (jeffallan) — Automatic code documentation generation

**Security (1):**
- `security-reviewer` (jeffallan) — Security review and pentesting patterns

**Testing Advanced (2):**
- `playwright-expert` (jeffallan) — E2E testing with Playwright
- `test-master` (jeffallan) — Advanced testing methodologies

**Total:** 20 → **33 skills** (+65% improvement)

### Changed
- Updated `scripts/install-skills.sh` header to reflect 33 total skills
- Updated `README.md` skills section with complete categorization
- Bumped version to `2.1.0` (minor version: new features added)

### Added - 2026-03-20

#### 🛡️ 3-Layer Validation System
- **Git hooks pre-commit** (`scripts/install-git-hooks.sh`) - Automatic validation in <5 seconds
  - Validates syntax, linters, formatters
  - Prevents CONTRATO.md modifications (immutable)
  - Prevents debug code (console.log, var_dump)
  - Rejects commits that fail validation
- **Full validation in `implementar` command** - Exhaustive checks (1-5 min)
  - Unit tests + integration tests
  - Validation vs CONTRATO.md and specs
  - Coverage >= 80% requirement
  - Only pushes if ALL tests pass
- **CodeRabbit integration** - Deep PR review (5-10 min)
  - Architecture, security, business logic validation
  - Automatic comments on PRs
  - Profile "assertive" configured
  - `.coderabbit.yaml` included

#### ❓ Help Command & Discoverability
- Created `.commands/ayuda.md` - Complete command reference
- Lists ALL available commands (conversational + CLI)
- Explains when to use each workflow
- Updated `CLAUDE.md` to auto-detect `ayuda`, `help`, `comandos`

#### 📚 Documentation & Clarity
- **OpenSpec vs Conversational workflows** - Clear distinction when to use each
  - Conversational: Small teams, rapid development
  - OpenSpec CLI: Enterprise, formal proposals, traceability
  - Both can coexist and complement each other
- **CodeRabbit clarification** - Works with BOTH workflows, not just OpenSpec
- **README.md** - Complete system explanation with 3-layer validation
- **SETUP.md** - Git hooks installation as Step 4
- **scripts/README.md** - Scripts reference guide

### Changed - 2026-03-20

#### URLs & Branding
- All repository URLs updated: `specleap` → `specleap-framework`
- "Conceptual Creative" → "SpecLeap Community/Contributors"
- "Pamela Anderson" → "SpecLeap Contributor" (in examples)
- Package.json repository URLs corrected

#### Documentation Links
- Fixed broken `docs/` references (directory was removed)
- Updated to point to actual existing files
- `.commands/`, `openspec/`, `.agents/` references

### Removed - 2026-03-20

#### Security & Privacy
- `openspec/cli/jira.sh` - Private Jira credentials
- `docs/` directory (7 files, 2,630 lines) - Old ArchSpec landing with private references
- All mentions of:
  - conceptualcreative.com domains
  - Private Atlassian URLs
  - Legacy personal emails (removed)
  - Internal project names

### Fixed - 2026-03-20

- Survey count corrected: 58 questions (not 56)
- Git ignore: Added `kofi-images/` to prevent accidental push

---

## Statistics - 2026-03-20

**Files changed:** 24  
**Lines added:** ~2,500  
**Lines removed:** ~2,650 (mostly private data cleanup)  
**Commits:** 4

**Key improvements:**
- ✅ 100% private data removed
- ✅ Quality validation system implemented
- ✅ Complete discoverability (help command)
- ✅ Clear workflow distinction (conversational vs CLI)
- ✅ Professional documentation

---

## Migration Guide

### For Existing Users

#### To enable git hooks:
```bash
cd your-project
bash scripts/install-git-hooks.sh
```

#### To discover all commands:
In chat with your AI assistant:
```
ayuda
```

Or in terminal:
```bash
openspec --help
```

#### To understand when to use CLI vs conversational:
- **Small team (1-3 devs):** Use conversational commands in chat
- **Large team (4+ devs):** Use OpenSpec CLI for formal proposals
- **Both:** Use conversational for daily work, CLI for big changes

---

## Coming Soon

- [ ] Integration tests for git hooks
- [ ] CI/CD templates
- [ ] More Agent Skills (TIER 2)
- [ ] Docker support
- [ ] VS Code extension

---

**Full details:** See individual commit messages and PR descriptions.
