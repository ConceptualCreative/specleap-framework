# Protocolo de Inicio de Sesión — SpecLeap

> Procedimiento obligatorio al iniciar cualquier sesión de desarrollo.

## Al Iniciar Sesión

### Paso 1: Identificar Proyecto

```
¿En qué proyecto vamos a trabajar?
```

Cargar el contexto del proyecto desde `context/`:
- `context/brief.md` — Resumen del proyecto
- `context/tech-stack.md` — Stack y versiones
- `context/conventions.md` — Patrones y convenciones

### Paso 2: Verificar Estado Git

```bash
git status                    # ¿Hay cambios pendientes?
git branch                    # ¿En qué rama estamos?
git log --oneline -5          # ¿Últimos commits?
git stash list                # ¿Hay stashes pendientes?
```

Si hay trabajo en progreso sin commit → preguntar antes de continuar.

### Paso 3: Identificar Tipo de Tarea

| Tipo | Flujo |
|------|-------|
| **Nueva feature** | Ticket → Spec → Rama → Implementar → Test → PR |
| **Fix/Bug** | Ticket → Analizar → Rama → Fix → Test → PR |
| **Refactor** | Ticket → Spec de cambio → Rama → Refactor → Test → PR |
| **Documentación** | Actualizar docs/context → Commit → PR |
| **Investigación** | Documentar hallazgos en context/ |

### Paso 4: Verificar Ticket

```
¿Hay un ticket en Asana asociado a esta tarea?
```

- **Sí** → Usar el ID del ticket (SCRUM-XX) en rama y commits
- **No** → Crear el ticket antes de empezar

**No se empieza desarrollo sin ticket.**

### Paso 5: Verificar Spec

```
¿Existe una spec para esta funcionalidad?
```

- **Sí** → Leerla antes de implementar
- **No** → Crearla con `openspec new` antes de codificar
- **Parcial** → Completarla antes de implementar

## Al Finalizar Sesión

### 1. Guardar Progreso

```bash
git add -A
git commit -m "SCRUM-XX: wip: descripción del progreso"
```

### 2. Actualizar Contexto (si aplica)

Si durante la sesión se tomaron decisiones importantes:
- Actualizar `context/decisions.md`
- Actualizar specs si cambiaron requisitos

### 3. Documentar Estado

Dejar nota clara de:
- Qué se completó
- Qué queda pendiente
- Bloqueos encontrados

## Flujo Completo de Feature

```
1. TICKET (Asana)
   └── Crear/asignar ticket SCRUM-XX

2. SPEC (SpecLeap)
   └── openspec new "feature"
   └── Revisar spec → Aprobar

3. PLANIFICACIÓN
   └── openspec ff (genera design + tasks)
   └── Revisar design → Aprobar

4. DESARROLLO
   ├── git checkout stage && git pull
   ├── git checkout -b feature/SCRUM-XX-nombre
   ├── Análisis previo (buscar código existente)
   ├── Implementar siguiendo patrones del proyecto
   └── Tests unitarios + integración

5. VERIFICACIÓN
   └── openspec verify

6. REVIEW
   ├── openspec code-review
   └── PR con referencia a SCRUM-XX y SPEC-XXX

7. MERGE
   └── Squash merge a stage (con aprobación)

8. POST-DESARROLLO
   ├── Actualizar context/ si hubo decisiones
   ├── Actualizar spec si cambió
   └── Cerrar ticket en Asana
```

---

*Seguir este protocolo garantiza que ninguna tarea se ejecuta sin contexto, sin ticket, ni sin spec.*
