# Comando: inicio (Protocolo "Hola")

**Trigger:** Usuario escribe exactamente "Hola" (case-insensitive)

**Objetivo:** Iniciar sesión de trabajo cargando el contexto del proyecto y determinando qué tarea realizar.

---

## Flujo Completo

### Paso 1: Listar Proyectos Disponibles

Ejecuta bash para listar proyectos:

```bash
ls proyectos/
```

**Output esperado:**
```
_template
app-tienda
api-backend
dashboard-analytics
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

### Paso A1: Nombre del Proyecto

Usar `AskUserQuestion`:

```markdown
## Proyecto

¿Cuál es el nombre del nuevo proyecto?

○ **Nombre con guiones** (Recomendado)
  Ejemplo: mi-proyecto-web, app-mobile, api-backend

○ **Nombre simple**
  Ejemplo: portfolio, dashboard, ecommerce

○ **Other**
```

Esperar respuesta (ej: "Nombre con guiones")

Luego preguntar:

```markdown
¿Cuál es el nombre exacto del proyecto?

Por ejemplo: `mi-proyecto-web`, `app-tienda`, `api-users`, `landing-corporativa`
```

Esperar nombre (ej: "casa-de-peli")

**Validar nombre:**
- Solo minúsculas, números y guiones
- Mínimo 3 caracteres
- Máximo 50 caracteres
- Pattern: `^[a-z0-9-]+$`

Si es inválido:
```markdown
❌ **Error:** El nombre debe tener solo minúsculas, números y guiones.

Ejemplo válido: `casa-de-peli`, `mi-tienda-online`, `api-rest-v2`

Por favor, intenta de nuevo:
```

Si es válido, continuar.

---

### Paso A2: Iniciar Cuestionario (58 preguntas)

```markdown
Perfecto, vamos a crear el proyecto **casa-de-peli**.

Para generar el CONTRATO completo, necesito hacerte **58 preguntas** sobre el proyecto.

⏱️ **Tiempo estimado:** 15-20 minutos
💾 **Guardado automático:** Cada 10 preguntas
♻️ **Puedes pausar y continuar después**

**¿Comenzamos?**
```

Esperar confirmación (usuario responde: "Sí", "Adelante", "Ok", etc.)

---

### Paso A3: Preguntas (Leer desde questions.json)

**IMPORTANTE:** Leer `scripts/lib/questions.json` y procesar las preguntas en orden.

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
cp -r proyectos/_template proyectos/casa-de-peli

# Guardar CONTRATO.md
# (Usar Write con el contenido generado)

# Crear context/ con información específica
```

Generar archivos adicionales:

**context/brief.md:**
```markdown
# Brief — casa-de-peli

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
# Tech Stack — casa-de-peli

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
# Arquitectura — casa-de-peli

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
# Convenciones — casa-de-peli

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
# Decisiones — casa-de-peli

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
✅ **Proyecto casa-de-peli creado exitosamente**

**Estructura creada:**

```
proyectos/casa-de-peli/
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

## Flujo B: Proyecto Existente (Trabajar en proyecto ya creado)

### Paso B1: Seleccionar Proyecto

```markdown
**¿En cuál proyecto vas a trabajar?**

Proyectos disponibles:
1. app-tienda
2. api-backend
3. dashboard-analytics

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
- Dime el ID del ticket (ejemplo: app-tienda-23)
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
