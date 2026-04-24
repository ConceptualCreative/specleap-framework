# [CHANGE-XXX] Tareas: Título del Cambio

| Campo | Valor |
|-------|-------|
| ID | CHANGE-XXX |
| Propuesta | `proposal.md` |
| Diseño | `design.md` |
| Fecha | YYYY-MM-DD |
| Sprint | Sprint X |

## Resumen

Total de tareas: X  
Estimación total: X story points  
Ticket Epic: [proyecto]-XXX

## Tareas

### 🏗️ Setup & Scaffolding

#### TASK-001: Crear estructura base
- **Ticket:** [proyecto]-XXX
- **Estimación:** 1 SP
- **Asignado:** @nombre
- **Estado:** ⬜ Pendiente / 🔄 En progreso / ✅ Completada
- **Branch:** `feat/TICKET-XXX-estructura-base`

**Subtareas:**
- [ ] Crear carpeta de feature
- [ ] Configurar rutas
- [ ] Crear archivos base

**Criterios de aceptación:**
- [ ] Estructura creada según design.md
- [ ] Rutas registradas
- [ ] Tests de humo pasan

---

### 📊 Backend / API

#### TASK-002: Implementar modelo de datos
- **Ticket:** [proyecto]-XXX
- **Estimación:** 2 SP
- **Asignado:** @nombre
- **Estado:** ⬜ Pendiente
- **Branch:** `feat/TICKET-XXX-modelo-datos`

**Subtareas:**
- [ ] Crear entidades/modelos
- [ ] Crear migraciones
- [ ] Crear seeders (si aplica)

**Criterios de aceptación:**
- [ ] Migraciones ejecutan sin error
- [ ] Modelo tiene validaciones según spec
- [ ] Tests unitarios del modelo

---

#### TASK-003: Implementar endpoints API
- **Ticket:** [proyecto]-XXX
- **Estimación:** 3 SP
- **Asignado:** @nombre
- **Estado:** ⬜ Pendiente
- **Branch:** `feat/TICKET-XXX-api-endpoints`

**Subtareas:**
- [ ] POST /api/recurso
- [ ] GET /api/recurso/:id
- [ ] PUT /api/recurso/:id
- [ ] DELETE /api/recurso/:id

**Criterios de aceptación:**
- [ ] Endpoints responden según contrato en design.md
- [ ] Validación de inputs
- [ ] Manejo de errores
- [ ] Tests de integración

---

### 🎨 Frontend / UI

#### TASK-004: Implementar componentes UI
- **Ticket:** [proyecto]-XXX
- **Estimación:** 3 SP
- **Asignado:** @nombre
- **Estado:** ⬜ Pendiente
- **Branch:** `feat/TICKET-XXX-ui-components`

**Subtareas:**
- [ ] Componente de lista
- [ ] Componente de formulario
- [ ] Componente de detalle

**Criterios de aceptación:**
- [ ] Componentes renderizan correctamente
- [ ] Responsive design
- [ ] Accesibilidad WCAG 2.1
- [ ] Tests de comportamiento

---

### 🧪 Testing

#### TASK-005: Tests unitarios
- **Ticket:** [proyecto]-XXX
- **Estimación:** 2 SP
- **Asignado:** @nombre
- **Estado:** ⬜ Pendiente
- **Branch:** `feat/TICKET-XXX-unit-tests`

**Cobertura requerida:**
- [ ] Lógica de negocio: 80%+
- [ ] Validadores: 90%+
- [ ] Utils: 90%+

---

#### TASK-006: Tests de integración
- **Ticket:** [proyecto]-XXX
- **Estimación:** 2 SP
- **Asignado:** @nombre
- **Estado:** ⬜ Pendiente
- **Branch:** `feat/TICKET-XXX-integration-tests`

**Escenarios:**
- [ ] Happy path completo
- [ ] Casos de error
- [ ] Edge cases

---

### 📚 Documentación

#### TASK-007: Documentación técnica
- **Ticket:** [proyecto]-XXX
- **Estimación:** 1 SP
- **Asignado:** @nombre
- **Estado:** ⬜ Pendiente
- **Branch:** `docs/TICKET-XXX-documentacion`

**Subtareas:**
- [ ] README del módulo
- [ ] Documentación de API (OpenAPI/Swagger)
- [ ] Actualizar Wiki técnica

---

## Dependencias entre Tareas

```
TASK-001 (Setup)
    ↓
TASK-002 (Modelo) ───┬──▶ TASK-003 (API)
                     │         ↓
                     └──▶ TASK-004 (UI)
                               ↓
                     ┌─────────┴─────────┐
                     ↓                   ↓
              TASK-005 (Unit)    TASK-006 (Integration)
                     └─────────┬─────────┘
                               ↓
                        TASK-007 (Docs)
```

## Testing Report

### Pre-merge Checklist
- [ ] Todos los tests pasan
- [ ] Cobertura mínima alcanzada
- [ ] Sin errores de linting
- [ ] CodeRabbit review aprobado
- [ ] PR review manual aprobado

### Resultados de Tests
| Suite | Tests | Passed | Failed | Coverage |
|-------|-------|--------|--------|----------|
| Unit | X | X | 0 | XX% |
| Integration | X | X | 0 | N/A |
| E2E | X | X | 0 | N/A |

### CodeRabbit Report
- **PR:** #XXX
- **Status:** ✅ Aprobado / ❌ Cambios requeridos
- **Issues encontrados:** X
- **Issues resueltos:** X

## Notas

- Notas adicionales sobre la implementación
- Decisiones tomadas durante el desarrollo
- Problemas encontrados y soluciones
