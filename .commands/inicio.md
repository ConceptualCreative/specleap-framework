# Comando: inicio (Protocolo "Hola")

**Trigger:** Usuario escribe exactamente "Hola" (case-insensitive)

**Objetivo:** Iniciar sesión de trabajo cargando el contexto del proyecto y determinando qué tarea realizar.

---

## Flujo Completo

### Paso 0: Ofrecer Instalación de markitdown (Herramienta Opcional)

**ANTES de listar proyectos**, preguntar al usuario si quiere instalar **markitdown** (herramienta opcional de Microsoft que convierte PDF/Word/Excel/PowerPoint/HTML a Markdown). Esta conversión reduce significativamente el consumo de tokens cuando SpecLeap procesa documentos no-markdown durante el flujo (briefs en PDF, requisitos en Word, etc.).

**Importante:** Este paso solo se ejecuta UNA VEZ por sesión "Hola". Si el usuario ya respondió antes en la misma sesión, saltar este paso.

#### Detectar idioma del usuario

Por defecto, el idioma de SpecLeap es **español** (ver `CLAUDE.md`). Si el usuario te ha hablado en inglés o ha configurado el framework en inglés, usa la versión en inglés del prompt.

#### Texto del prompt (Español)

```markdown
¡Hola! 👋 Antes de empezar con tu proyecto, una pregunta rápida:

🔧 **Herramienta opcional disponible: markitdown**

`markitdown` es una utilidad de Microsoft (open source, MIT) que convierte:
- 📄 PDF → Markdown
- 📝 Word (.docx) → Markdown
- 📊 Excel (.xlsx) / PowerPoint (.pptx) → Markdown
- 🌐 HTML, CSV, JSON, XML, EPUB → Markdown

**¿Por qué te interesa?** Cuando trabajemos con documentos (briefs, requisitos, contratos antiguos en PDF/Word), si los conviertes primero a Markdown con esta herramienta, el consumo de tokens baja entre **20% y 50%** y yo entiendo mejor el contenido.

**Requisitos:** Python 3.10+ y `pip` instalados.

**¿Quieres instalarlo ahora?** (Sí / No / Ya está instalado)
```

#### Texto del prompt (English)

```markdown
Hi! 👋 Before we start with your project, a quick question:

🔧 **Optional tool available: markitdown**

`markitdown` is a Microsoft utility (open source, MIT) that converts:
- 📄 PDF → Markdown
- 📝 Word (.docx) → Markdown
- 📊 Excel (.xlsx) / PowerPoint (.pptx) → Markdown
- 🌐 HTML, CSV, JSON, XML, EPUB → Markdown

**Why does this matter?** When we work with documents (briefs, requirements, legacy contracts in PDF/Word), converting them to Markdown first with this tool reduces token consumption by **20%–50%** and I understand the content better.

**Requirements:** Python 3.10+ and `pip` installed.

**Do you want to install it now?** (Yes / No / Already installed)
```

#### Acción según respuesta

**Si el usuario responde "Sí" / "Yes":**

1. Verificar si ya está instalado ejecutando:
   ```bash
   command -v markitdown
   ```

2. **Si NO está instalado**, mostrar comando de instalación según OS:

   **Español:**
   ```markdown
   📦 **Instalación de markitdown**

   Ejecuta en tu terminal (fuera de Claude Code):

   ```bash
   pip install 'markitdown[all]'
   ```

   **Si usas pipx (recomendado para CLIs Python):**
   ```bash
   pipx install 'markitdown[all]'
   ```

   **Si tienes Python 3.10+ pero no `pip`:**
   - macOS: `brew install python` (incluye pip)
   - Linux: `sudo apt install python3-pip` (Debian/Ubuntu)
   - Windows: descarga desde [python.org](https://www.python.org/downloads/)

   Una vez instalado, podrás usar:
   ```bash
   bash scripts/convert-docs.sh archivo.pdf
   bash scripts/convert-docs.sh carpeta/
   ```

   **¿Sigo con la creación del proyecto?** (Sí / Espera, voy a instalarlo primero)
   ```

   **English:**
   ```markdown
   📦 **Install markitdown**

   Run in your terminal (outside Claude Code):

   ```bash
   pip install 'markitdown[all]'
   ```

   **If you use pipx (recommended for Python CLIs):**
   ```bash
   pipx install 'markitdown[all]'
   ```

   **If you have Python 3.10+ but no `pip`:**
   - macOS: `brew install python` (includes pip)
   - Linux: `sudo apt install python3-pip` (Debian/Ubuntu)
   - Windows: download from [python.org](https://www.python.org/downloads/)

   Once installed, you'll be able to use:
   ```bash
   bash scripts/convert-docs.sh file.pdf
   bash scripts/convert-docs.sh folder/
   ```

   **Continue with project creation?** (Yes / Wait, I'll install it first)
   ```

3. **Si YA está instalado**, confirmar y seguir:

   **Español:**
   ```markdown
   ✅ `markitdown` ya está instalado en tu sistema. Perfecto, sigamos con tu proyecto.
   ```

   **English:**
   ```markdown
   ✅ `markitdown` is already installed on your system. Great, let's continue with your project.
   ```

**Si el usuario responde "No":**

**Español:**
```markdown
👍 Sin problema. Si más adelante quieres instalarlo, puedes ejecutar `pip install 'markitdown[all]'` o leer `scripts/convert-docs.sh --help`.

Sigamos con tu proyecto.
```

**English:**
```markdown
👍 No problem. If you want to install it later, run `pip install 'markitdown[all]'` or read `scripts/convert-docs.sh --help`.

Let's continue with your project.
```

**Si el usuario responde "Ya está instalado" / "Already installed":**

Verificar con `command -v markitdown`. Si está → confirmar. Si no → mostrar instrucciones de instalación.

#### Después de la respuesta

Continúa con **Paso 1** (listar proyectos) sin importar la respuesta. La instalación de markitdown nunca bloquea el flujo principal.

---

### Paso 1: Listar Proyectos Disponibles

> **Nota:** Si el usuario va a crear un proyecto nuevo (Flujo A más adelante), antes de empezar el cuestionario lanzaremos el **Paso A0 — Selección de Modo** (MVP / Serio / Creativo). Si va a trabajar en un proyecto existente o adoptar legacy, ese paso se omite.

Ejecuta bash para listar proyectos:

```bash
ls proyectos/
```

**Output esperado:**
```
_template
task-manager
inventory-app
crm-suite
...
```

### Paso 2: Saludar y Presentar Proyectos

```markdown
¡Hola! 👋 Bienvenido a SpecLeap.

**Proyectos disponibles:**

[Listar proyectos excluyendo _template]

**¿Quieres crear un proyecto nuevo, o trabajar con uno existente que aún no esté registrado?**
```

### Paso 3: Esperar Respuesta del Usuario

Usar `AskUserQuestion` (modal interactivo):

```markdown
## ¿Qué tipo de trabajo realizarás hoy?

○ **Proyecto nuevo** — Crear proyecto desde cero
○ **Proyecto existente** — Trabajar en un proyecto ya creado
○ **Adoptar proyecto legacy** — Integrar proyecto existente en SpecLeap
```

---

## Flujo A: Proyecto Nuevo (Cuestionario Interactivo)

### Paso A0: Selección de Modo de Trabajo

**ANTES de pedir el nombre del proyecto**, preguntar al usuario qué tipo de proyecto va a montar. Esto determina cuántas preguntas se le harán y por qué carriles.

Usar `AskUserQuestion`:

```markdown
## Tipo de proyecto que vas a crear

○ **MVP** — proyecto pequeño, prototipo o piloto.
  - 58 preguntas estructuradas (~15-20 min).
  - Ideal para 1 persona o equipo pequeño.

○ **Proyecto serio** — equipo grande, varios departamentos, compliance, SLAs.
  - 93 preguntas estructuradas (~25-35 min).
  - Cubre governance, integraciones empresariales, SLAs, compliance, roadmap por fases, observabilidad, multi-tenant/i18n.

○ **Modo creativo** — describes tu proyecto en un párrafo, yo extraigo y solo te pregunto los huecos.
  - 5-10 minutos.
  - Ideal si ya tienes claro qué quieres construir y prefieres conversar antes que rellenar formulario.
```

Guardar la elección como variable de sesión `MODE` (valores: `mvp`, `serio`, `creativo`).

#### Si elige MVP

Continúa con Paso A1 normal. El cuestionario filtra `questions.es.json` por `modes` que contengan `"mvp"` (= 58 preguntas).

#### Si elige Proyecto serio

Continúa con Paso A1 normal. El cuestionario filtra por `modes` que contengan `"serio"` (= 93 preguntas, las 58 de MVP + 35 nuevas de governance/compliance/SLAs/etc.).

#### Si elige Modo creativo

**Saltar Paso A1, A2, A3.** Ir directamente al Paso A1.5 (Modo Creativo) descrito más abajo.

---

### Paso A1: Nombre del Proyecto

Usar `AskUserQuestion`:

```markdown
## Proyecto

¿Cuál es el nombre del nuevo proyecto?

○ **Nombre con guiones** (Recomendado)
  Ejemplo: task-manager, inventory-app, crm-suite

○ **Nombre simple**
  Ejemplo: portfolio, dashboard, analytics

○ **Other**
```

Esperar respuesta (ej: "Nombre con guiones")

Luego preguntar:

```markdown
¿Cuál es el nombre exacto del proyecto?

Por ejemplo: `task-manager`, `inventory-app`, `crm-suite`, `landing-corporativa`
```

Esperar nombre (ej: "task-manager")

**Validar nombre:**
- Solo minúsculas, números y guiones
- Mínimo 3 caracteres
- Máximo 50 caracteres
- Pattern: `^[a-z0-9-]+$`

Si es inválido:
```markdown
❌ **Error:** El nombre debe tener solo minúsculas, números y guiones.

Ejemplo válido: `task-manager`, `inventory-app`, `crm-suite`

Por favor, intenta de nuevo:
```

Si es válido, continuar.

---

### Paso A1.5: Modo Creativo (solo si `MODE = creativo`)

**Si el usuario eligió MVP o Serio en el Paso A0, saltar este paso e ir directamente al Paso A2.**

#### A1.5.1 — Pedir descripción libre

```markdown
🎨 **Modo Creativo activado.**

Cuéntame tu proyecto en un párrafo (o varios). No te preocupes por el orden ni por dejarte cosas — yo extraeré lo que dijiste y te preguntaré solo lo que falte.

**Ideas que me ayudan:** qué hace, para quién es, qué stack imaginas, qué prioridades tienes, fechas, presupuesto, qué NO quieres, restricciones legales, integraciones que necesitas, equipo que lo va a usar.

**Tu descripción:**
```

Esperar a que el usuario escriba su párrafo. Aceptar respuestas multi-línea hasta que pulse Enter sobre línea vacía o escriba `FIN` en una línea propia.

#### A1.5.2 — Extracción estructurada

Sobre el texto del usuario, hacer una pasada de extracción mapeando lo dicho a los IDs de `questions.es.json` (`.en.json`). Llenar un dict interno `extracted = {id: valor}`.

**Reglas de extracción:**

- **No alucinar.** Si el usuario no mencionó algo, ese ID se queda vacío.
- **Inferencias seguras**: si dice "una app web React + Laravel", inferir `stack.backend.framework: laravel`, `stack.frontend.framework: react`. Si dice "una app", NO inferir framework.
- **Para texto libre** (como `identity.objective`, `identity.problem_solved`), usar las frases del usuario lo más literal posible, recortando a los `max_length` permitidos.
- **Para selects/multiselects**, mapear a las opciones canónicas del JSON. Si el usuario usa sinónimos (ej: "PostgreSQL 16" → `stack.database.engine: postgresql` + `stack.database.version: 16.x`), normalizar.
- **Confianza**: si una inferencia tiene <70% certeza, NO la rellenes — pregúntala después.

#### A1.5.3 — Mostrar resumen extraído al usuario

```markdown
✅ **Esto es lo que entendí de tu descripción:**

[Renderizar como tabla o lista los IDs extraídos con su valor]

| Campo | Valor |
|-------|-------|
| Nombre proyecto | [extracted.project.name] |
| Audiencia | [extracted.identity.target_audience] |
| Stack backend | [extracted.stack.backend.framework] |
| ... | ... |

**¿Está bien?** Responde:
- **Sí** — sigamos con las preguntas que faltan
- **Corregir [ID]** — quiero cambiar X
- **Reescribir** — déjame describir el proyecto otra vez
```

Si el usuario corrige, actualizar `extracted` y volver a mostrar.

#### A1.5.4 — Pedir solo los huecos críticos

Leer `scripts/lib/critical_fields.json` y filtrar:

- Si MODE original era `creativo` puro → usar `mvp_critical` (18 campos).
- Si el usuario después decide subir a serio (ver Paso A6 transiciones) → usar `mvp_critical + serio_critical_extra` (29 campos).

Para cada campo crítico que NO esté en `extracted` o esté vacío:

1. Buscar la pregunta correspondiente en `questions.es.json` por su `id`.
2. Renderizarla igual que en Paso A3 (con su `text`, `help`, `example`).
3. Encabezar con un mensaje contextual explicando POR QUÉ se pregunta:

```markdown
🔍 **Falta info clave**: [resumen del por qué importa].

[Renderizar pregunta normal con text + help + example]
```

Ejemplo:

```markdown
🔍 **Falta info clave**: no mencionaste si el sistema necesita responsive design. Es importante porque afecta directamente al diseño de los componentes.

### Pregunta — Diseño

**¿Diseño responsive (mobile-first)?**

○ sí
○ no

💡 **Ayuda:** Si esperas usuarios en móvil, recomendado.
```

#### A1.5.5 — Generar CONTRATO con lo extraído + huecos rellenados

Continuar con el Paso A4 normal (Generar CONTRATO.md), usando como respuestas la unión `extracted + huecos rellenados`.

---

### Paso A2: Iniciar Cuestionario

**Cuántas preguntas:**

- Modo `mvp`: 58 preguntas (filtradas por `modes` que contengan `"mvp"`).
- Modo `serio`: 93 preguntas (filtradas por `modes` que contengan `"serio"`).
- Modo `creativo`: este paso se salta — ver Paso A1.5.

**Tiempo estimado:**

- MVP: 15-20 minutos.
- Serio: 25-35 minutos.

```markdown
Perfecto, vamos a crear el proyecto **task-manager** en modo **[MODE]**.

Para generar el CONTRATO completo, necesito hacerte **[N] preguntas** sobre el proyecto.

⏱️ **Tiempo estimado:** 15-20 minutos
💾 **Guardado automático:** Cada 10 preguntas
♻️ **Puedes pausar y continuar después**

**¿Comenzamos?**
```

Esperar confirmación (usuario responde: "Sí", "Adelante", "Ok", etc.)

---

### Paso A3: Preguntas (Leer desde questions.json)

**IMPORTANTE:**

1. Leer `scripts/lib/questions.es.json` (o `.en.json` según el idioma elegido en setup) y procesar las preguntas en orden.
2. **Filtrar por modo**: solo procesar preguntas cuyo array `modes` contenga el modo elegido por el usuario (`mvp`, `serio`, o `creativo` — aunque creativo no usa este flujo).
3. Las preguntas con `modes: ["mvp", "serio"]` aparecen en ambos modos (las 58 base). Las preguntas con `modes: ["serio"]` solo aparecen en modo serio (las 35 nuevas de governance/compliance/SLAs/etc.).

#### Estructura de cada pregunta:

```json
{
  "id": "project.type",
  "number": 1,
  "section": "Tipo de Proyecto",
  "text": "¿Qué tipo de proyecto es?",
  "type": "select",
  "options": ["nuevo", "existente"],
  "required": true,
  "help": "nuevo = desde cero | existente = adoptar proyecto legacy",
  "example": "nuevo"
}
```

#### Renderizar pregunta:

```markdown
### Pregunta 1/58 — Tipo de Proyecto

**¿Qué tipo de proyecto es?**

○ nuevo
○ existente

💡 **Ayuda:** nuevo = desde cero | existente = adoptar proyecto legacy  
📝 **Ejemplo:** nuevo
```

Si la pregunta tiene `skip_if`, evaluar la condición:

```json
"skip_if": {
  "project.type": "nuevo"
}
```

Si la condición se cumple (project.type == "nuevo"), **saltar esta pregunta**.

---

#### Validaciones por tipo:

**type: string**
- Validar `pattern` si existe (regex)
- Validar `min_length` / `max_length`
- Si tiene `auto_suggest`, ofrecer sugerencia según respuesta previa

**type: select**
- Validar que la respuesta esté en `options`
- Mostrar opciones como lista enumerada

**type: multiselect**
- Validar que todas las opciones seleccionadas estén en `options`
- Separador: coma (`,`)

**type: boolean**
- Aceptar: `true`, `false`, `sí`, `no`, `s`, `n`, `yes`, `y`, `1`, `0`
- Normalizar a `true` / `false`

**type: number**
- Validar que sea número
- Validar `min` / `max` si existen

**type: array**
- Separar por coma
- Validar `min_items` / `max_items`

**type: text**
- Validar `max_length` si existe

---

#### Guardado parcial (cada 10 preguntas):

Cuando `number % 10 == 0`:

```markdown
✅ **Checkpoint: 10/58 preguntas completadas**

💾 Progreso guardado. Puedes pausar aquí y continuar después.

**¿Continuamos?**
```

---

### Paso A4: Generar CONTRATO.md

Una vez completadas las 58 preguntas:

```markdown
🎉 **¡Cuestionario completado!**

**Respuestas recopiladas:** 58
**Guardando datos...**
```

Leer `proyectos/_template/CONTRATO.md` como plantilla base.

**Generar CONTRATO.md dinámicamente:**

```yaml
---
meta:
  project: [respuesta: project.name]
  display_name: [respuesta: project.display_name]
  responsible: [respuesta: project.responsible]
  created_at: [fecha actual]
  version: 1.0
---

# [project.display_name]

## Identidad del Proyecto

**Objetivo:** [respuesta: identity.objective]

**Problema que resuelve:** [respuesta: identity.problem_solved]

**Usuario objetivo:** [respuesta: identity.target_audience]

**Referencias/Competidores:** [respuesta: identity.competitors]

---

## Stack Tecnológico

### Backend
- **Framework:** [respuesta: stack.backend.framework] [respuesta: stack.backend.version]
- **Lenguaje:** [respuesta: stack.backend.language]

### Base de Datos
- **Motor:** [respuesta: stack.database.engine] [respuesta: stack.database.version]

### Frontend
- **Framework:** [respuesta: stack.frontend.framework]
- **Lenguaje:** [respuesta: stack.frontend.language]
- **Build Tool:** [respuesta: stack.frontend.build_tool]
- **UI Library:** [respuesta: stack.frontend.ui_library]

### DevOps
- **Hosting:** [respuesta: stack.devops.hosting]
- **CI/CD:** [respuesta: stack.devops.ci_cd]
- **Contenedores:** [respuesta: stack.devops.containers]

---

## Funcionalidades

### Principales (Core)
[Listar respuesta: features.core, cada item como bullet point]

### Secundarias (Nice-to-have)
[Listar respuesta: features.secondary, cada item como bullet point]

---

## Sistema de Usuarios

**Autenticación:**
- Métodos: [respuesta: features.auth.methods]
- 2FA: [respuesta: features.auth.two_factor]

**Registro:** [respuesta: users.registration]

**Roles:** [respuesta: users.roles]

---

## Panel de Administración

**Habilitado:** [respuesta: features.admin_panel.enabled]
**Nivel:** [respuesta: features.admin_panel.level]

---

## Subida de Archivos

**Habilitado:** [respuesta: features.file_uploads.enabled]
**Almacenamiento:** [respuesta: features.file_uploads.storage]

---

## Sistema de Pagos

**Habilitado:** [respuesta: features.payments.enabled]
**Proveedores:** [respuesta: features.payments.providers]

---

## Notificaciones

- **Email:** [respuesta: features.notifications.email]
- **Push:** [respuesta: features.notifications.push]
- **In-App:** [respuesta: features.notifications.in_app]

---

## Diseño

- **Estilo visual:** [respuesta: design.visual_style]
- **Color primario:** [respuesta: design.primary_color]
- **Modo oscuro:** [respuesta: design.dark_mode]
- **Responsive:** [respuesta: design.responsive]

---

## Arquitectura

- **Patrón:** [respuesta: architecture.pattern]
- **Separación:** [respuesta: architecture.separation]

---

## Despliegue

- **HTTPS:** [respuesta: deployment.ssl]
- **Dominio:** [respuesta: deployment.custom_domain]
- **Entornos:** [respuesta: deployment.environments]

---

## Seguridad

- **Nivel:** [respuesta: security.level]
- **GDPR Compliant:** [respuesta: security.gdpr_compliant]
- **Datos Sensibles:** [respuesta: security.sensitive_data]

---

## Rendimiento

- **Tiempo de carga objetivo:** [respuesta: performance.load_time_target]
- **Tiempo respuesta API objetivo:** [respuesta: performance.api_response_target]
- **Usuarios concurrentes esperados:** [respuesta: performance.concurrent_users]

---

## Testing

- **Tests unitarios:** [respuesta: testing.unit]
- **Tests de integración:** [respuesta: testing.integration]
- **Tests E2E:** [respuesta: testing.e2e]
- **Cobertura objetivo:** [respuesta: testing.coverage_target]%

---

## Restricciones

**Plazo de entrega:** [respuesta: constraints.time_limit]

**Fuera de Alcance:**
[Listar respuesta: constraints.out_of_scope, cada item con ❌]

---

## Problemas Potenciales

[Generar automáticamente según las respuestas del cuestionario. Ejemplos:]

- Si `performance.concurrent_users` > 1000: Escalabilidad — Necesario balanceador de carga
- Si `features.payments.enabled` == true: Cumplimiento PCI-DSS
- Si `security.gdpr_compliant` == true: Implementar política de privacidad y consentimiento
- Si `features.file_uploads.enabled` == true: Validación de tipos de archivo y límites de tamaño
```

---

### Paso A5: Mostrar Preview del CONTRATO

```markdown
✅ **CONTRATO.md generado**

**Preview:**

[Mostrar CONTRATO completo o primeras 50 líneas + "..."]

**¿Quieres:**
- **A) Aceptar** — Crear proyecto con este CONTRATO
- **B) Editar** — Modificar algo antes de crear
- **C) Cancelar** — No crear el proyecto

Responde A, B o C:
```

---

### Paso A6: Si el usuario acepta (opción A)

Crear estructura del proyecto:

```bash
# Copiar template
cp -r proyectos/_template proyectos/task-manager

# Guardar CONTRATO.md
# (Usar Write con el contenido generado)

# Crear context/ con información específica
```

Generar archivos adicionales:

**context/brief.md:**
```markdown
# Brief — task-manager

**Proyecto:** [project.display_name]
**Responsable:** [project.responsible]
**Fecha creación:** [fecha actual]

## Resumen Ejecutivo

[Tomar identity.objective y identity.problem_solved para generar resumen de 2-3 párrafos]

## Alcance

**Funcionalidades Core:**
[Listar features.core]

**Fuera de Alcance:**
[Listar constraints.out_of_scope]

## Entregables

- Aplicación web funcional
- Panel de administración
- Documentación técnica
- Tests automatizados

## Timeline

**Plazo:** [constraints.time_limit]
```

**context/tech-stack.md:**
```markdown
# Tech Stack — task-manager

## Backend

- **Framework:** [stack.backend.framework] [stack.backend.version]
- **Lenguaje:** [stack.backend.language]

## Base de Datos

- **Motor:** [stack.database.engine] [stack.database.version]

## Frontend

- **Framework:** [stack.frontend.framework]
- **Lenguaje:** [stack.frontend.language]
- **Build Tool:** [stack.frontend.build_tool]
- **UI Library:** [stack.frontend.ui_library]

## DevOps

- **Hosting:** [stack.devops.hosting]
- **CI/CD:** [stack.devops.ci_cd]
- **Contenedores:** [stack.devops.containers]

## Versiones

[Generar tabla con todas las versiones]

| Tecnología | Versión |
|-----------|---------|
| [stack.backend.framework] | [stack.backend.version] |
| [stack.database.engine] | [stack.database.version] |
| ... | ... |
```

**context/architecture.md:**
```markdown
# Arquitectura — task-manager

## Patrón Arquitectónico

**Seleccionado:** [architecture.pattern]

## Separación de Capas

**Tipo:** [architecture.separation]

[Generar diagrama Mermaid según el patrón seleccionado]

## Flujo de Datos

[Generar descripción del flujo según el patrón]

## Decisiones Arquitectónicas

1. **Backend/Frontend:** [architecture.separation]
   - Justificación: [Generar según la elección]

2. **Base de Datos:** [stack.database.engine]
   - Justificación: [Generar según la elección]
```

**context/conventions.md:**
```markdown
# Convenciones — task-manager

## Nomenclatura

[Generar convenciones según stack.backend.framework]

## Estructura de Carpetas

[Generar según stack.backend.framework + stack.frontend.framework]

## Commits

**Formato:** [tipo]: [descripción corta]

**Tipos:**
- feat: Nueva funcionalidad
- fix: Corrección de bug
- docs: Documentación
- test: Tests
- refactor: Refactorización
- chore: Tareas de mantenimiento

## Code Style

[Generar según lenguajes seleccionados]
```

**context/decisions.md:**
```markdown
# Decisiones — task-manager

**Fecha:** [fecha actual]

## Stack Tecnológico

### Backend: [stack.backend.framework]
**Razón:** [Generar justificación]

### Frontend: [stack.frontend.framework]
**Razón:** [Generar justificación]

### Base de Datos: [stack.database.engine]
**Razón:** [Generar justificación]

## Arquitectura

### Patrón: [architecture.pattern]
**Razón:** [Generar justificación]

## Seguridad

### Nivel: [security.level]
**Razón:** [Generar justificación]

## Testing

### Cobertura: [testing.coverage_target]%
**Razón:** [Generar justificación]
```

**README.md:**
```markdown
# [project.display_name]

> [identity.objective]

## Stack

- Backend: [stack.backend.framework] [stack.backend.version]
- Frontend: [stack.frontend.framework]
- Database: [stack.database.engine] [stack.database.version]

## Instalación

[Generar instrucciones según el stack]

## Desarrollo

[Generar comandos según el stack]

## Testing

[Generar comandos de testing]

## Licencia

[Pendiente definir]
```

---

### Paso A7: Confirmar Creación

```markdown
✅ **Proyecto task-manager creado exitosamente**

**Estructura creada:**

```
proyectos/task-manager/
├── CONTRATO.md          (🔒 inmutable — 58 preguntas procesadas)
├── ANEXOS.md            (✏️ editable)
├── README.md
├── .coderabbit.yaml
└── context/
    ├── brief.md
    ├── architecture.md
    ├── tech-stack.md
    ├── conventions.md
    └── decisions.md
```

**Próximos pasos:**

1. **Revisar CONTRATO.md:**
   Abre `CONTRATO.md` para revisar el contrato completo

2. **Crear tickets en Asana:**
   Lee `.commands/crear-tickets.md` y ejecuta

3. **Empezar desarrollo:**
   Elige un ticket:
   - `refinar [proyecto]-XXX` — Refinar user story
   - `planificar [proyecto]-XXX` — Generar plan de implementación
   - `implementar @plan.md` — Ejecutar el plan

**¿Quieres crear ahora los tickets en Asana?**

[Sí] [No]
```

### Paso A8: Respuesta a creación de tickets

#### Si el usuario responde "Sí":

```markdown
✅ Perfecto. Voy a crear los tickets ahora...
```

**Acción:** Leer `.commands/crear-tickets.md` y ejecutar las instrucciones paso a paso.

#### Si el usuario responde "No":

```markdown
✅ Entendido. Puedes crear los tickets cuando quieras.

**Para crearlos después, escribe:**

```
Lee .commands/crear-tickets.md y ejecuta
```

**O desde terminal:**

```bash
cd proyectos/[nombre-proyecto]
../../scripts/generate-asana-structure.sh CONTRATO.md
```

**Otros comandos disponibles:**

| Comando | Cómo ejecutarlo |
|---------|-----------------|
| Crear tickets Asana | `Lee .commands/crear-tickets.md y ejecuta` |
| Refinar story | `Lee .commands/refinar.md y ejecuta` |
| Planificar implementación | `Lee .commands/planificar.md y ejecuta` |
| Implementar | `Lee .commands/implementar.md y ejecuta` |
| Adoptar proyecto legacy | `Lee .commands/adoptar.md y ejecuta` |

¿Hay algo más en lo que pueda ayudarte?
```

---

### Paso A9: Transición a otro modo (opcional, después de generar CONTRATO)

**Después de que el CONTRATO se haya generado en cualquier modo (MVP, Serio o Creativo)**, ofrecer al usuario la posibilidad de ampliar/refinar mediante otro modo. Esto es opcional — si el usuario ya está conforme, sigue al Paso A8 normal (crear tickets).

#### A9.1 — Ofrecer transición

Usar `AskUserQuestion`:

```markdown
✅ CONTRATO generado en modo **[MODE]**.

¿Quieres ampliarlo o refinarlo?

○ **Mantener como está** — ir directo a `crear-tickets`.

○ **Pasar a modo Serio** — añadir preguntas de governance, compliance, SLAs, integraciones empresariales, multi-tenant. (~35 preguntas extra, 15-20 min).
  - Disponible si vienes de MVP o Creativo.
  - Si vienes de Serio, esta opción no aparece.

○ **Pasar a modo Creativo** — describir aspectos extra del proyecto en un párrafo libre. Útil si quieres añadir contexto, decisiones que no estaban en el cuestionario, anotaciones para el equipo.
  - Disponible siempre.
```

#### A9.2 — Si el usuario elige "Pasar a modo Serio"

1. Mantener todas las respuestas existentes (no preguntar de nuevo).
2. Filtrar las preguntas de `questions.es.json` por `modes` que contengan `"serio"` y que NO tengan respuesta aún en `extracted`.
3. Renderizar y procesar SOLO esas preguntas extra (las 35 nuevas).
4. Regenerar el CONTRATO.md con las respuestas anteriores + las nuevas.
5. Actualizar el campo `meta.mode` en el frontmatter del CONTRATO a `serio`.
6. Mostrar diff resumido al usuario antes de sobrescribir.

#### A9.3 — Si el usuario elige "Pasar a modo Creativo"

1. Pedir párrafo libre con un prompt diferente al inicial:

```markdown
🎨 Tu CONTRATO ya tiene la base. Ahora cuéntame en un párrafo cualquier matiz, contexto, decisión o detalle que NO te haya preguntado y quieras dejar registrado. Lo añadiré a una sección **"Contexto Adicional"** del CONTRATO.
```

2. Tomar el párrafo del usuario y añadirlo al CONTRATO.md como una sección nueva titulada `## Contexto Adicional`, debajo de `## Restricciones`.
3. Actualizar el campo `meta.mode` del frontmatter a `[modo_anterior]+creativo` (ej: `mvp+creativo`, `serio+creativo`).

#### A9.4 — Si el usuario elige "Mantener como está"

Ir al Paso A8 (crear tickets).

#### A9.5 — Iteración

El Paso A9 puede repetirse: tras pasar a Serio o añadir Contexto Adicional, volver a ofrecer A9 hasta que el usuario diga "Mantener". Esto permite construir el CONTRATO de forma incremental.

---

## Flujo B: Proyecto Existente (Trabajar en proyecto ya creado)

### Paso B1: Seleccionar Proyecto

```markdown
**¿En cuál proyecto vas a trabajar?**

Proyectos disponibles:
1. task-manager
2. inventory-app
3. crm-suite

Responde con el número o el nombre:
```

### Paso B2: Cargar Contexto

Leer archivos del proyecto:

1. `proyectos/[proyecto]/CONTRATO.md`
2. `proyectos/[proyecto]/ANEXOS.md` (si existe)
3. `proyectos/[proyecto]/context/brief.md`
4. `proyectos/[proyecto]/context/architecture.md`
5. `proyectos/[proyecto]/context/tech-stack.md`
6. `proyectos/[proyecto]/context/conventions.md`

### Paso B3: Confirmar Carga

```markdown
✅ **Proyecto [nombre] cargado correctamente**

**Contexto:**
- Stack: [Laravel 11 + React 18 + PostgreSQL]
- Arquitectura: [MVC Separado]
- Módulos principales: [Lista de funcionalidades core]

**¿Qué vas a hacer?**
- **A) Desarrollo** — Trabajar en código
- **B) Documentación** — Actualizar docs

Responde A o B:
```

### Paso B4A: Si elige Desarrollo

```markdown
**¿Qué ticket vas a trabajar?**

Opciones:
- Dime el ID del ticket (ejemplo: task-manager-23)
- O describe la tarea que vas a hacer

**Comandos disponibles:**
- `refinar [proyecto]-XXX` — Refinar user story
- `planificar [proyecto]-XXX` — Generar plan de implementación
- `implementar @plan.md` — Ejecutar el plan
- `explicar [concepto]` — Explicar código o arquitectura
```

### Paso B4B: Si elige Documentación

```markdown
**¿Qué documentación vas a actualizar?**

Archivos del proyecto:
- `CONTRATO.md` (🔒 inmutable — solo consulta)
- `ANEXOS.md` (agregar módulos nuevos)
- `context/brief.md` (resumen ejecutivo)
- `context/architecture.md` (decisiones arquitectónicas)
- `context/tech-stack.md` (stack y versiones)
- `context/conventions.md` (patrones de código)
- `context/decisions.md` (log de decisiones)

**Comando disponible:**
- `documentar` — Actualizar documentación técnica
```

---

## Flujo C: Adoptar Proyecto Legacy

Ver `.commands/adoptar.md` para el flujo completo de adopción.

---

## Reglas Críticas

1. **"Hola" es la única palabra clave** — No aceptar "hola como estas", solo "Hola" exacto.

2. **SIEMPRE listar proyectos** — Ejecutar bash para descubrir proyectos, no asumir.

3. **Cargar contexto COMPLETO** — Leer todos los archivos de context/ antes de continuar.

4. **58 preguntas OBLIGATORIAS para proyectos nuevos** — No saltarlas. Son necesarias para CONTRATO completo.

5. **Validar TODAS las respuestas** — Según el tipo y validaciones en questions.json.

6. **Guardar checkpoint cada 10 preguntas** — Para permitir pausar y continuar.

7. **NO modificar CONTRATO.md** después de aceptado — Solo agregar en ANEXOS.md.

8. **Confirmar antes de crear** — Mostrar preview del CONTRATO y esperar aprobación.

---

## Herramientas Disponibles

- **Read** — Leer `scripts/lib/questions.json` y archivos de contexto
- **Write** — Crear archivos del nuevo proyecto
- **AskUserQuestion** — Modales interactivos (usar cuando esté disponible)
- **Bash** — Listar proyectos, copiar template

---

## Referencias

- **Preguntas:** `scripts/lib/questions.json` (58 preguntas completas)
- **Template:** `proyectos/_template/CONTRATO.md`
- **Agentes:** `.agents/backend.md`, `.agents/frontend.md`, `.agents/producto.md`
- **Otros Comandos:** `.commands/refinar.md`, `.commands/planificar.md`, etc.
- **Standards:** `specs/base-standards.mdc`
