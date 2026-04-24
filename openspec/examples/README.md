# OpenSpec — Ejemplos Completos

Ejemplos end-to-end del workflow completo de SpecLeap.

## 📚 Ejemplos Disponibles

### CHANGE-SAMPLE-001: Autenticación de Usuario

**Categoría:** Backend / Security  
**Stack:** PHP (Laravel) / JWT  
**Complejidad:** Alta  
**Estado:** Completado

Sistema completo de autenticación con email y contraseña, tokens JWT, rate limiting, y protección contra brute force.

**Qué demuestra:**
- ✅ Workflow completo (enrich → new → ff → apply → verify → code-review → archive)
- ✅ User story refinada con AI
- ✅ Propuesta completa (proposal + design + tasks)
- ✅ Delta specs (functional + technical)
- ✅ Testing Report real (60 tests, 91% coverage)
- ✅ CodeRabbit integration
- ✅ ADRs (Architecture Decision Records)

**Ver:** [CHANGE-SAMPLE-001-user-authentication/README.md](./CHANGE-SAMPLE-001-user-authentication/README.md)

---

## 🎯 Cómo Usar los Ejemplos

### 1. Aprender el Flujo

Navega los ejemplos en orden de archivos:

```
00-original-user-story.md     # INPUT inicial
    ↓
01-refined-user-story.md      # Refinada con AI (/enrich)
    ↓
proposal.md                   # QUÉ y POR QUÉ (/new)
design.md                     # CÓMO técnico (/ff)
tasks.md                      # Tareas + Testing Report
    ↓
specs/                        # Delta specs aplicados
    ↓
COMPLETION_REPORT.md          # Reporte final (/archive)
```

### 2. Adaptar a Tu Proyecto

```bash
# Copiar estructura a tu proyecto
cp -r openspec/examples/CHANGE-SAMPLE-001-* openspec/changes/CHANGE-001-mi-feature/

# Editar archivos con tu contexto
# - Reemplazar stack (Laravel → tu framework)
# - Ajustar arquitectura
# - Adaptar testing strategy

# Ejecutar workflow completo
openspec verify CHANGE-001
openspec code-review CHANGE-001 --create-pr
```

### 3. Crear Tu Propio Ejemplo

```bash
# Empezar desde cero
openspec new --auto "Mi Feature" --ticket [proyecto]-XXX
openspec ff CHANGE-XXX
# ... editar manualmente ...
openspec apply CHANGE-XXX
```

---

## 📖 Guías por Tipo de Proyecto

### Backend API

**Ejemplo:** CHANGE-SAMPLE-001 (Autenticación)

**Incluye:**
- Endpoints API (REST)
- Modelo de datos
- Validación de inputs
- Seguridad (autenticación, autorización)
- Testing (unit + integration)

**Comandos clave:**
```bash
openspec enrich "API para gestionar usuarios"
openspec new --auto "CRUD de usuarios" --priority high
openspec ff CHANGE-XXX
```

### Frontend Component

**Ejemplo:** (próximamente)

**Incluiría:**
- Componentes UI
- State management
- API integration
- Testing (unit + e2e)

### Microservicio

**Ejemplo:** (próximamente)

**Incluiría:**
- Service architecture
- Message queue integration
- Service discovery
- Distributed tracing

### Database Migration

**Ejemplo:** (próximamente)

**Incluiría:**
- Schema changes
- Data migration
- Rollback plan
- Performance impact

---

## 🔍 Anatomía de un Ejemplo Completo

### Archivos Requeridos

| Archivo | Propósito | Generado Por |
|---------|-----------|--------------|
| `README.md` | Guía del ejemplo | Manual |
| `00-original-user-story.md` | User story inicial | Manual (usuario) |
| `01-refined-user-story.md` | User story refinada | `/enrich` (AI) |
| `proposal.md` | QUÉ y POR QUÉ | `/new` (template) |
| `design.md` | CÓMO técnico | `/ff` (AI) o manual |
| `tasks.md` | Tareas + Testing Report | `/ff` (AI) o manual |
| `specs/` | Delta specs | Manual |
| `COMPLETION_REPORT.md` | Reporte final | `/archive` |

### Archivos Opcionales

| Archivo | Propósito |
|---------|-----------|
| `diagrams/` | Diagramas de arquitectura (PNG, SVG) |
| `migrations/` | Scripts SQL de ejemplo |
| `code-samples/` | Snippets de código implementado |
| `screenshots/` | Capturas de UI (si aplica) |

---

## 💡 Mejores Prácticas

### 1. User Stories Refinadas

❌ **Mal:**
```
Como usuario quiero login
```

✅ **Bien:**
```
Como usuario registrado del sistema,
quiero autenticarme con email y contraseña
para acceder de forma segura a mi cuenta y funcionalidades personalizadas.

GIVEN un usuario registrado
WHEN ingresa credenciales correctas
THEN accede al dashboard
AND recibe token JWT válido por 24h
```

### 2. Propuestas Completas

Incluir siempre:
- ✅ Resumen ejecutivo (2-3 oraciones)
- ✅ Contexto y problema a resolver
- ✅ Propuesta de solución
- ✅ Alcance (incluido + excluido)
- ✅ Riesgos y mitigaciones
- ✅ Estimación inicial

### 3. Diseño Técnico Detallado

Incluir siempre:
- ✅ Diagrama de componentes (ASCII o imagen)
- ✅ Modelo de datos (DDL o diagrama ER)
- ✅ API contracts (request/response examples)
- ✅ ADRs (decisiones técnicas justificadas)
- ✅ Testing strategy (unit, integration, e2e)
- ✅ Plan de rollback

### 4. Tareas Desglosadas

Cada tarea debe tener:
- ✅ ID único (TASK-001, TASK-002, ...)
- ✅ Estimación (story points)
- ✅ Criterios de aceptación claros
- ✅ Dependencias explícitas
- ✅ Branch name sugerido

### 5. Delta Specs Claros

Usar notación de cambios:
```markdown
## Escenario X: Login exitoso

- GIVEN un usuario registrado
- WHEN ingresa credenciales válidas
+ AND el sistema verifica 2FA (NUEVO)
- THEN genera token JWT
~ AND redirige al dashboard (MODIFICADO: añadir analytics)
```

---

## 🧪 Validación de Ejemplos

Antes de publicar un ejemplo, verificar:

### Checklist de Calidad

- [ ] README.md completo con guía de uso
- [ ] User story original → refinada incluida
- [ ] Proposal + design + tasks completos
- [ ] Delta specs con formato correcto
- [ ] Testing Report con datos reales (no template vacío)
- [ ] Sin placeholders ("TODO", "XXX", "...")
- [ ] Archivos markdown válidos (sin errores de formato)
- [ ] Comandos CLI documentados y probados
- [ ] Referencias a specs source of truth correctas

### Test del Ciclo Completo

```bash
# 1. Verificar que los comandos funcionan
cd openspec/examples/CHANGE-SAMPLE-XXX/
openspec verify CHANGE-SAMPLE-XXX --dry-run

# 2. Validar YAML
yq eval ../config.yaml > /dev/null

# 3. Validar markdown
markdownlint *.md

# 4. Verificar links
markdown-link-check README.md
```

---

## 🚀 Contribuir Ejemplos

¿Quieres añadir un ejemplo nuevo?

### 1. Estructura

```bash
# Crear directorio
mkdir -p openspec/examples/CHANGE-SAMPLE-XXX-nombre/

# Crear archivos base
touch README.md
touch 00-original-user-story.md
# ... etc
```

### 2. Contenido

Usar CHANGE-SAMPLE-001 como plantilla:
- Copiar estructura de archivos
- Adaptar contenido a tu caso de uso
- Mantener mismo nivel de detalle

### 3. Validación

```bash
# Ejecutar checklist de calidad
./scripts/validate-example.sh CHANGE-SAMPLE-XXX

# Revisar con AI
openspec verify CHANGE-SAMPLE-XXX
```

### 4. Pull Request

- Título: `docs: Añadir ejemplo CHANGE-SAMPLE-XXX (descripción)`
- Descripción:
  - Qué demuestra el ejemplo
  - Stack/tecnologías usadas
  - Comandos CLI cubiertos
  - Lecciones aprendidas

---

## 📊 Índice de Ejemplos por Categoría

### Backend
- ✅ CHANGE-SAMPLE-001: Autenticación JWT
- 🔜 CHANGE-SAMPLE-002: CRUD con validación
- 🔜 CHANGE-SAMPLE-003: API con paginación

### Frontend
- 🔜 CHANGE-SAMPLE-010: Componente de formulario
- 🔜 CHANGE-SAMPLE-011: State management con Redux

### DevOps
- 🔜 CHANGE-SAMPLE-020: CI/CD pipeline
- 🔜 CHANGE-SAMPLE-021: Docker compose setup

### Seguridad
- ✅ CHANGE-SAMPLE-001: Autenticación (incluye rate limiting)
- 🔜 CHANGE-SAMPLE-030: 2FA implementation

### Performance
- 🔜 CHANGE-SAMPLE-040: Caché con Redis
- 🔜 CHANGE-SAMPLE-041: Query optimization

---

## 🔗 Referencias

- [OpenSpec CLI](../cli/README.md)
- [Metodología SDD](../../.continue/rules/01-sdd-methodology.md)
- [Templates](../templates/)
- [Config Reference](../config.yaml)

---

**Última actualización:** 2026-02-12  
**Ejemplos totales:** 1 (más en desarrollo)
