# 📖 Referencia Completa de Comandos — OpenSpec CLI

Documentación detallada de todos los comandos del workflow de SpecLeap.

---

## 📋 Índice de Comandos

| Comando | Fase | Descripción |
|---------|-----------|-------------|
| [`openspec`](#openspec) | — | Dispatcher principal + ayuda |
| [`enrich`](#enrich) | Learn | Refinar user story con AI |
| [`new`](#new) | Learn | Crear propuesta de cambio |
| [`ff`](#ff) | Learn | Fast-forward (generar con AI) |
| [`apply`](#apply) | Implement | Aplicar propuesta (branch + deltas) |
| [`verify`](#verify) | Deploy | Verificar tests + specs |
| [`code-review`](#code-review) | Review | Solicitar review + crear PR |
| [`archive`](#archive) | Review | Archivar propuesta completada |
| [`report`](#report) | Deploy | Generar testing report |
| [`status`](#status) | — | Ver estado de propuestas |

---

## `openspec`

Dispatcher principal que ejecuta subcomandos.

### Uso

```bash
openspec <comando> [opciones]
openspec --help
openspec --version
```

### Opciones

| Opción | Descripción |
|--------|-------------|
| `-h, --help` | Mostrar ayuda |
| `-v, --version` | Mostrar versión |

### Ejemplos

```bash
# Ver ayuda general
openspec --help

# Ver versión
openspec --version

# Ejecutar comando
openspec new CHANGE-001 "Mi feature"
```

### Exit Codes

- `0` — Éxito
- `1` — Comando no encontrado

---

## `enrich`

Refina una user story simple con AI, añadiendo contexto, criterios de aceptación, y estimaciones.

### Uso

```bash
openspec enrich <user-story> [opciones]
openspec enrich --file <path> [opciones]
```

### Opciones

| Opción | Tipo | Descripción |
|--------|------|-------------|
| `--file <path>` | string | Leer user story desde archivo |
| `--output <path>` | string | Guardar resultado (default: STDOUT) |
| `--model <model>` | string | Modelo AI a usar (default: auto) |
| `-h, --help` | — | Mostrar ayuda |

### AI CLI Soportados

- **oracle** — Preferido si está instalado
- **gh copilot** — Requiere `gh extension install github/gh-copilot`
- **ai-cli** — Requiere AI CLI instalado

### Ejemplos

```bash
# User story inline
openspec enrich "Como usuario quiero hacer login"

# Desde archivo
openspec enrich --file stories/US-123.md

# Guardar resultado
openspec enrich "Como usuario..." --output us-refined.md

# Especificar modelo
openspec enrich "Como usuario..." --model anthropic/claude-sonnet-4
```

### Output

User story refinada en markdown con:
- Título y descripción
- Contexto del negocio
- Criterios de aceptación (GIVEN/WHEN/THEN)
- Casos de uso adicionales
- Requisitos no funcionales
- Estimación inicial
- Fuera de alcance

### Exit Codes

- `0` — Éxito
- `1` — AI CLI no encontrado
- `1` — Input vacío o inválido

---

## `new`

Crea una nueva propuesta de cambio con estructura completa (proposal, design, tasks).

### Uso

```bash
openspec new [CHANGE-ID] <título> [opciones]
openspec new --auto <título> [opciones]
```

### Opciones

| Opción | Tipo | Descripción |
|--------|------|-------------|
| `--auto` | — | Generar ID automáticamente |
| `--from <file>` | string | Crear desde user story refinada |
| `--ticket <id>` | string | Asociar con ID del ticket (ej: app-tienda-23) |
| `--priority <level>` | string | Prioridad: critical\|high\|medium\|low |
| `--author <name>` | string | Autor (default: git user) |
| `-h, --help` | — | Mostrar ayuda |

### Ejemplos

```bash
# ID manual
openspec new CHANGE-001 "Implementar autenticación JWT"

# ID automático
openspec new --auto "Sistema de notificaciones"

# Con ticket y prioridad
openspec new --auto "Login social" --ticket app-tienda-23 --priority high

# Desde user story refinada
openspec new --auto "Auth" --from us-refined.md --ticket app-tienda-24
```

### Output

Crea directorio: `openspec/changes/CHANGE-XXX-nombre/`

**Archivos creados:**
- `proposal.md` — QUÉ y POR QUÉ
- `design.md` — CÓMO (diseño técnico)
- `tasks.md` — Tareas y Testing Report
- `README.md` — Guía de próximos pasos
- `specs/` — Directorio para delta specs

### Exit Codes

- `0` — Éxito
- `1` — ID inválido o ya existe
- `1` — Título vacío

---

## `ff`

Fast-forward: genera automáticamente con AI el contenido de proposal.md, design.md y tasks.md.

### Uso

```bash
openspec ff <CHANGE-ID> [opciones]
```

### Opciones

| Opción | Tipo | Descripción |
|--------|------|-------------|
| `--model <model>` | string | Modelo AI a usar (default: auto) |
| `--skip-proposal` | — | Omitir generación de proposal.md |
| `--skip-design` | — | Omitir generación de design.md |
| `--skip-tasks` | — | Omitir generación de tasks.md |
| `-h, --help` | — | Mostrar ayuda |

### Prerequisitos

- Propuesta creada con `openspec new`
- Al menos `proposal.md` con contexto básico

### Ejemplos

```bash
# Generar todo
openspec ff CHANGE-001

# Solo design y tasks (proposal ya completo)
openspec ff CHANGE-002 --skip-proposal

# Usar modelo específico
openspec ff CHANGE-003 --model anthropic/claude-opus-4
```

### Output

**Archivos actualizados:**
- `design.md` — Diseño técnico completo (arquitectura, API, ADRs)
- `tasks.md` — Tareas desglosadas con estimaciones
- *(proposal.md no se toca si ya tiene contenido)*

### Notas Importantes

⚠️ **REVISAR SIEMPRE** el output del AI antes de aplicar. El AI puede generar:
- Placeholders ("TODO", "...", "XXX")
- Suposiciones incorrectas
- Código que no se ajusta a tu stack

### Exit Codes

- `0` — Éxito
- `1` — Propuesta no encontrada
- `1` — AI CLI no disponible

---

## `apply`

Aplica una propuesta aprobada: crea branch Git, aplica delta specs, y actualiza estado.

### Uso

```bash
openspec apply <CHANGE-ID> [opciones]
```

### Opciones

| Opción | Tipo | Descripción |
|--------|------|-------------|
| `--no-branch` | — | No crear branch de Git |
| `--base <branch>` | string | Branch base (default: develop) |
| `--dry-run` | — | Simular sin hacer cambios |
| `-h, --help` | — | Mostrar ayuda |

### Prerequisitos

- Propuesta completada y revisada
- Git repositorio inicializado
- Base branch existente

### Ejemplos

```bash
# Aplicar propuesta
openspec apply CHANGE-001

# Con base branch diferente
openspec apply CHANGE-002 --base main

# Simular (sin hacer cambios)
openspec apply CHANGE-003 --dry-run

# Sin crear branch (ya estás en uno)
openspec apply CHANGE-004 --no-branch
```

### Acciones Realizadas

1. ✅ Crea branch: `feat/CHANGE-XXX-nombre` (desde `develop`)
2. ✅ Aplica delta specs desde `changes/CHANGE-XXX/specs/` a `specs/`
3. ✅ Actualiza estado de propuesta: `draft` → `in_progress`
4. ✅ Commit inicial del setup

### Output

```
✓ Branch creado: feat/CHANGE-001-autenticacion
✓ Delta specs aplicadas: 2 archivos
✓ Estado actualizado: in_progress
✓ Commit: chore(openspec): iniciar implementación de CHANGE-001

Próximos pasos:
  1. Implementar según design.md y tasks.md
  2. Usar AI assistant (Continue, Copilot) con las specs
  3. Escribir tests según Testing Strategy
  4. openspec verify CHANGE-001
```

### Exit Codes

- `0` — Éxito
- `1` — Propuesta no encontrada
- `1` — Branch ya existe
- `1` — Working directory sucio (cambios sin commitear)

---

## `verify`

Verifica que una propuesta cumpla requisitos antes de PR: ejecuta tests, valida cobertura, y verifica specs.

### Uso

```bash
openspec verify <CHANGE-ID> [opciones]
```

### Opciones

| Opción | Tipo | Descripción |
|--------|------|-------------|
| `--skip-tests` | — | Omitir ejecución de tests |
| `--skip-specs` | — | Omitir validación de specs |
| `--coverage <min>` | number | Cobertura mínima (default: 80) |
| `-h, --help` | — | Mostrar ayuda |

### Test Frameworks Detectados

- **PHPUnit** — `phpunit.xml` o `phpunit.xml.dist`
- **Jest** — `package.json` con jest configurado

### Ejemplos

```bash
# Verificación completa
openspec verify CHANGE-001

# Solo tests (specs ya validadas)
openspec verify CHANGE-002 --skip-specs

# Cobertura personalizada
openspec verify CHANGE-003 --coverage 90
```

### Verificaciones Realizadas

1. ✅ **Tests:**
   - Ejecuta suite completa (unit + integration)
   - Valida que pasen todos los tests
   - Verifica cobertura mínima

2. ✅ **Specs:**
   - Valida que delta specs estén aplicados
   - Verifica YAML válido en `config.yaml`
   - Busca placeholders sin completar

3. ✅ **Archivos:**
   - Verifica que proposal/design/tasks estén completos
   - Detecta "TODO", "FIXME", "XXX", "..."

### Output

```
✓ Tests pasaron: 45/45 (0 fallidos)
✓ Cobertura: 91% (>= 80%)
✓ Specs aplicadas: 2 archivos
✓ Archivos completos: proposal.md, design.md, tasks.md

Verificación EXITOSA

Próximos pasos:
  1. openspec code-review CHANGE-001 --create-pr
  2. Crear Pull Request
  3. Esperar aprobación de CodeRabbit + equipo
```

### Exit Codes

- `0` — Verificación exitosa
- `1` — Tests fallidos
- `1` — Cobertura insuficiente
- `1` — Specs no aplicadas
- `1` — Archivos incompletos

---

## `code-review`

Solicita code review: verifica tests, crea PR, y activa CodeRabbit.

### Uso

```bash
openspec code-review <CHANGE-ID> [opciones]
```

### Opciones

| Opción | Tipo | Descripción |
|--------|------|-------------|
| `--create-pr` | — | Crear Pull Request automáticamente |
| `--base <branch>` | string | Branch base para PR (default: develop) |
| `--draft` | — | Crear PR como draft |
| `-h, --help` | — | Mostrar ayuda |

### Prerequisitos

- Branch feature creado
- Tests pasando (`openspec verify` OK)
- CLI `gh` configurado (para crear PRs)
- CodeRabbit activo en el repo

### Ejemplos

```bash
# Solo verificar (no crear PR)
openspec code-review CHANGE-001

# Verificar y crear PR
openspec code-review CHANGE-002 --create-pr

# PR como draft
openspec code-review CHANGE-003 --create-pr --draft

# Con base branch diferente
openspec code-review CHANGE-004 --create-pr --base main
```

### Acciones Realizadas

1. ✅ Ejecuta `openspec verify` primero
2. ✅ Pushea branch a remoto
3. ✅ Crea Pull Request (si `--create-pr`)
4. ✅ Extrae ticket id de proposal.md para título PR
5. ✅ CodeRabbit hace review automático
6. ✅ Actualiza estado: `in_progress` → `testing`

### Formato del PR

**Título:**
```
app-tienda-23 — Implementar Autenticación JWT
```

**Body:**
```markdown
## Propuesta
CHANGE-001 — Implementar Autenticación de Usuario

## Descripción
[Resumen ejecutivo desde proposal.md]

## Archivos Clave
- `openspec/changes/CHANGE-001/proposal.md` — QUÉ y POR QUÉ
- `openspec/changes/CHANGE-001/design.md` — CÓMO
- `openspec/changes/CHANGE-001/tasks.md` — Testing Report

## Testing Report
Ver `tasks.md` para resultados completos.

## Referencias
- Propuesta: openspec/changes/CHANGE-001/
- Ticket: app-tienda-23

---
**Code Review:** CodeRabbit está activo.
```

### Output

```
✓ Verificación pasada
✓ Branch pusheado: feat/CHANGE-001-auth
✓ Pull Request creado: #45
✓ Estado actualizado: testing

CodeRabbit revisará automáticamente el PR
Revisa los comentarios y aplica cambios sugeridos

Cuando el review esté aprobado:
  openspec archive CHANGE-001
```

### Exit Codes

- `0` — Éxito
- `1` — Verificación falló
- `1` — No se pudo pushear branch
- `1` — Error al crear PR

---

## `archive`

Archiva una propuesta completada y mergeada: actualiza estado, elimina branch, y genera reporte final.

### Uso

```bash
openspec archive <CHANGE-ID> [opciones]
```

### Opciones

| Opción | Tipo | Descripción |
|--------|------|-------------|
| `--keep-branch` | — | No eliminar branch feature |
| `--no-merge` | — | No verificar merge (útil si ya mergeado) |
| `-h, --help` | — | Mostrar ayuda |

### Prerequisitos

- PR mergeado a base branch
- Code review aprobado

### Ejemplos

```bash
# Archivar y eliminar branch
openspec archive CHANGE-001

# Conservar branch
openspec archive CHANGE-002 --keep-branch

# Sin verificar merge (ya mergeado manualmente)
openspec archive CHANGE-003 --no-merge
```

### Acciones Realizadas

1. ✅ Verifica que PR esté mergeado (si gh disponible)
2. ✅ Actualiza estado: `testing` → `completed`
3. ✅ Añade fecha de completación a proposal.md
4. ✅ Marca specs como `implemented`
5. ✅ Elimina branch feature (local + remoto)
6. ✅ Genera `COMPLETION_REPORT.md`

### Output

```
✓ PR verificado como mergeado
✓ Propuesta archivada: CHANGE-001
✓ Specs actualizadas: 2 archivos (state: implemented)
✓ Branch eliminado: feat/CHANGE-001-auth
✓ Reporte generado: COMPLETION_REPORT.md

Propuesta completada exitosamente

Reporte final: openspec/changes/CHANGE-001-auth/COMPLETION_REPORT.md
```

### Reporte Generado

**`COMPLETION_REPORT.md` incluye:**
- Fecha de completación
- Archivos generados
- Specs actualizadas
- Commits relacionados
- Estado final

### Exit Codes

- `0` — Éxito
- `1` — Propuesta no encontrada
- `1` — PR no mergeado (si verificando)

---

## `report`

Genera testing report automáticamente desde resultados de tests (PHPUnit, Jest, etc.).

### Uso

```bash
openspec report [CHANGE-ID] [opciones]
```

### Opciones

| Opción | Tipo | Descripción |
|--------|------|-------------|
| `--format <fmt>` | string | Formato: markdown\|json\|text (default: markdown) |
| `--output <file>` | string | Archivo de salida (default: STDOUT) |
| `-h, --help` | — | Mostrar ayuda |

### Ejemplos

```bash
# Generar para proyecto
openspec report

# Generar para propuesta específica
openspec report CHANGE-001

# Formato JSON
openspec report --format json --output report.json

# Formato texto plano
openspec report CHANGE-002 --format text
```

### Test Frameworks Detectados

- **PHPUnit** — Parse output de `phpunit --testdox --coverage-text`
- **Jest** — Parse output de `npm test -- --coverage --json`

### Output (markdown)

```markdown
## Testing Report

| Suite | Tests | Passed | Failed | Coverage |
|-------|-------|--------|--------|----------|
| Unit | 45 | 45 | 0 | 91% |
| Integration | 12 | 12 | 0 | N/A |
| E2E | 3 | 3 | 0 | N/A |

**Fecha:** 2026-02-12 22:45:00

### Resumen
- Total tests: 60
- Pasados: 60
- Fallidos: 0
- Cobertura: 91%

### CodeRabbit Status
- [ ] Review pendiente
- [ ] Cambios requeridos
- [ ] Aprobado
```

### Actualización Automática

Si se proporciona `CHANGE-ID`, actualiza automáticamente `tasks.md` con el reporte.

### Exit Codes

- `0` — Éxito
- `1` — Test framework no detectado
- `1` — Tests fallaron (exit code del framework)

---

## `status`

Muestra el estado actual de todas las propuestas (activas o todas).

### Uso

```bash
openspec status [opciones]
```

### Opciones

| Opción | Tipo | Descripción |
|--------|------|-------------|
| `--all` | — | Mostrar todas (incluidas completadas) |
| `--state <state>` | string | Filtrar por estado |
| `--format <fmt>` | string | Formato: table\|json\|list (default: table) |
| `-h, --help` | — | Mostrar ayuda |

### Estados Disponibles

- `draft` — Borrador
- `review` — En revisión
- `approved` — Aprobada
- `in_progress` — En desarrollo
- `testing` — En testing
- `completed` — Completada
- `archived` — Archivada
- `rejected` — Rechazada

### Ejemplos

```bash
# Ver propuestas activas
openspec status

# Ver todas (incluidas completadas)
openspec status --all

# Filtrar por estado
openspec status --state in_progress

# Formato JSON
openspec status --format json

# Formato lista
openspec status --format list
```

### Output (table)

```
ID          | Título                          | Estado       | Prioridad | Autor        | Fecha
------------|--------------------------------|--------------|-----------|--------------|----------
CHANGE-001  | Autenticación JWT              | in_progress  | high      | SpecLeap Team       | 2026-02-12
CHANGE-002  | Sistema notificaciones         | draft        | medium    | SpecLeap Team       | 2026-02-13
CHANGE-003  | Optimizar queries DB           | testing      | high      | Backend Team | 2026-02-10

Total: 3 propuesta(s)

  in_progress: 1
  draft: 1
  testing: 1
```

### Exit Codes

- `0` — Éxito (siempre, incluso si 0 propuestas)

---

## 🔧 Variables de Entorno

El CLI respeta estas variables (si están definidas):

| Variable | Descripción | Default |
|----------|-------------|---------|
| `OPENSPEC_AI_CLI` | Forzar AI CLI: oracle\|gh\|ai-cli | auto-detect |
| `OPENSPEC_MODEL` | Modelo AI por defecto | auto |
| `OPENSPEC_BASE_BRANCH` | Branch base | develop |
| `OPENSPEC_COVERAGE_MIN` | Cobertura mínima | 80 |

**Ejemplo:**

```bash
export OPENSPEC_AI_CLI=oracle
export OPENSPEC_MODEL=anthropic/claude-sonnet-4
export OPENSPEC_COVERAGE_MIN=90

openspec enrich "Como usuario..."  # Usará oracle + sonnet-4
openspec verify CHANGE-001         # Requerirá 90% coverage
```

---

## 📊 Exit Codes Comunes

| Código | Significado |
|--------|-------------|
| `0` | Éxito |
| `1` | Error general (ver output) |
| `127` | Comando no encontrado |

---

## 🐛 Troubleshooting

### "Comando no encontrado: openspec"

**Causa:** CLI no está en `$PATH`

**Solución:**
```bash
export PATH="$PATH:$(pwd)/openspec/cli"
# O añadir a ~/.zshrc o ~/.bashrc
```

### "No se encontró CLI de AI"

**Causa:** oracle, gh copilot, u ai-cli no instalados

**Solución:**
```bash
# Instalar oracle (recomendado)
npm install -g @anthropic-ai/oracle

# O gh copilot
gh extension install github/gh-copilot

# O ai-cli
# Ver https://specleap.com
```

### "Tests fallaron"

**Causa:** Tests no pasan en `openspec verify`

**Solución:**
1. Ejecutar tests manualmente: `phpunit` o `npm test`
2. Corregir código hasta que pasen
3. Re-intentar `openspec verify`

### "Branch ya existe"

**Causa:** Ya existe `feat/CHANGE-XXX-nombre`

**Solución:**
```bash
# Eliminar branch existente
git branch -D feat/CHANGE-001-nombre

# O usar --no-branch si ya estás en el branch correcto
openspec apply CHANGE-001 --no-branch
```

---

## 📚 Ver También

- [CLI README](./README.md) — Guía de uso general
- [Ejemplo Completo](../examples/CHANGE-SAMPLE-001-user-authentication/README.md)
- [Metodología SDD](../../.continue/rules/01-sdd-methodology.md)
- [Templates](../templates/)

---

**Última actualización:** 2026-02-12  
**Versión CLI:** 1.0.0
