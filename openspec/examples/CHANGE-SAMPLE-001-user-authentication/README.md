# CHANGE-SAMPLE-001 — Ejemplo Completo: Autenticación de Usuario

Este directorio contiene un ejemplo completo del workflow de SpecLeap, desde la user story original hasta la propuesta completada y archivada.

## 📋 Contenido

```
CHANGE-SAMPLE-001-user-authentication/
├── README.md                        # Este archivo
├── 00-original-user-story.md        # User story inicial (INPUT)
├── 01-refined-user-story.md         # User story refinada (output de /enrich)
├── proposal.md                      # QUÉ y POR QUÉ (output de /new)
├── design.md                        # CÓMO técnico (output de /ff o manual)
├── tasks.md                         # Tareas + Testing Report
├── specs/                           # Delta specs aplicados
│   ├── functional/
│   │   └── F001-authentication.spec.md
│   └── technical/
│       └── T001-jwt-implementation.spec.md
└── COMPLETION_REPORT.md             # Reporte final (output de /archive)
```

## 🔄 Workflow Completo

### Fase 1: ENRICH — Refinar User Story

**Input:**
```markdown
Como usuario del sistema,
quiero poder hacer login con email y contraseña
para acceder a mi cuenta de forma segura.
```

**Comando:**
```bash
openspec enrich "Como usuario quiero hacer login" \
  --output 01-refined-user-story.md
```

**Output:** `01-refined-user-story.md`
- User story en formato completo
- Contexto de negocio
- Criterios de aceptación (GIVEN/WHEN/THEN)
- Requisitos no funcionales
- Estimación inicial

---

### Fase 2: NEW — Crear Propuesta

**Comando:**
```bash
openspec new --auto "Implementar autenticación JWT" \
  --from 01-refined-user-story.md \
  --ticket app-tienda-23 \
  --priority high
```

**Output:** `CHANGE-SAMPLE-001-user-authentication/`
- `proposal.md` — Propuesta con contexto, problema, solución, alcance
- `design.md` — Template vacío para diseño técnico
- `tasks.md` — Template vacío para tareas
- `README.md` — Guía de próximos pasos

---

### Fase 3: FF — Fast-Forward (Generar con AI)

**Comando:**
```bash
openspec ff CHANGE-SAMPLE-001
```

**Output:**
- `design.md` completado con AI:
  - Arquitectura de componentes
  - Modelo de datos
  - API contracts
  - Decisiones técnicas (ADRs)
  - Testing strategy
  
- `tasks.md` completado con AI:
  - Desglose de tareas (TASK-001, TASK-002, ...)
  - Estimaciones (story points)
  - Dependencias entre tareas
  - Template de Testing Report

**IMPORTANTE:** Revisar y ajustar outputs del AI antes de aplicar.

---

### Fase 4: APPLY — Implementar Propuesta

**Comando:**
```bash
openspec apply CHANGE-SAMPLE-001
```

**Acciones:**
1. Crea branch Git: `feat/CHANGE-SAMPLE-001-user-authentication`
2. Aplica delta specs a `openspec/specs/`
3. Actualiza estado a `in_progress`
4. Commit inicial del setup

**Próximo paso:** Implementar código según design.md y tasks.md usando AI assistant (Continue, Copilot, Cursor).

---

### Fase 5: VERIFY — Verificar Tests y Specs

**Durante el desarrollo, ejecutar:**
```bash
openspec verify CHANGE-SAMPLE-001
```

**Verifica:**
- Tests unitarios + integración pasan
- Cobertura mínima alcanzada (>80%)
- Specs aplicadas correctamente
- Sin placeholders en archivos

**Output:** Testing Report actualizado en `tasks.md`

---

### Fase 6: CODE-REVIEW — Solicitar Review

**Comando:**
```bash
openspec code-review CHANGE-SAMPLE-001 --create-pr
```

**Acciones:**
1. Ejecuta `openspec verify` primero
2. Pushea branch a remoto
3. Crea Pull Request en GitHub
4. CodeRabbit hace review automático
5. Actualiza estado a `testing`

**Revisar comentarios de CodeRabbit y aplicar cambios sugeridos.**

---

### Fase 7: ARCHIVE — Archivar al Completar

**Tras mergear PR:**
```bash
openspec archive CHANGE-SAMPLE-001
```

**Acciones:**
1. Verifica que PR esté mergeado
2. Actualiza estado a `completed`
3. Marca specs como `implemented`
4. Elimina branch feature
5. Genera `COMPLETION_REPORT.md`

---

## 📊 Ejemplo de Testing Report

Ver `tasks.md` para el reporte completo. Resumen:

| Suite | Tests | Passed | Failed | Coverage |
|-------|-------|--------|--------|----------|
| Unit | 45 | 45 | 0 | 91% |
| Integration | 12 | 12 | 0 | N/A |
| E2E | 3 | 3 | 0 | N/A |

**CodeRabbit:** ✅ Aprobado (8 issues encontrados, 8 resueltos)

---

## 🎯 Especificaciones Generadas

### Functional Spec: F001-authentication.spec.md

Especificación funcional completa con:
- 12 escenarios (GIVEN/WHEN/THEN)
- Reglas de negocio
- Dependencias
- Métricas y KPIs

### Technical Spec: T001-jwt-implementation.spec.md

Especificación técnica detallada:
- Arquitectura de componentes
- Interfaces de clases
- Modelo de datos
- Endpoints API
- Configuración de seguridad
- Benchmarks de performance

---

## 💡 Lecciones Aprendidas

### Lo que Funcionó Bien

1. **Refinar user story ANTES de diseñar:** Ahorró re-trabajo al tener requisitos claros desde el inicio.

2. **Fast-forward con AI:** Generó 80% del diseño técnico correcto. El 20% restante fue ajuste manual.

3. **Testing Report automático:** Actualización automática desde results de PHPUnit/Jest evitó errores manuales.

4. **CodeRabbit integration:** Detectó 8 issues que hubieran pasado code review manual.

5. **Delta specs:** Mantener specs separadas en `changes/` permitió review sin contaminar source of truth.

### Problemas Encontrados

1. **Rate limiting en DB lento:** Solución temporal. Migrar a Redis en CHANGE-002.

2. **AI generó placeholders:** Template de tasks.md tenía "TODO" que requirió limpieza manual.

3. **Bloqueo de IPs compartidas:** Rate limiting solo por IP bloqueó usuarios legítimos en NAT corporativo. Ajustado a IP+email.

---

## 📚 Referencias

### Documentación

- [OpenSpec CLI](../cli/README.md)
- [Metodología SDD](../../.continue/rules/01-sdd-methodology.md)
- [Templates](../templates/)

### Specs Relacionadas

- `openspec/specs/functional/F001-authentication.spec.md` (aplicada desde delta)
- `openspec/specs/technical/T001-jwt-implementation.spec.md` (aplicada desde delta)

### PRs y Commits

- **PR #45:** feat: Implementar autenticación JWT (merged)
- **Commits:** 12 commits en branch feature
- **Deploy:** Production v1.1.0

---

## 🚀 Cómo Usar Este Ejemplo

### Para Aprender el Flujo

1. Lee los archivos en orden:
   - `00-original-user-story.md`
   - `01-refined-user-story.md`
   - `proposal.md`
   - `design.md`
   - `tasks.md`
   - `specs/`

2. Observa la evolución desde user story simple hasta propuesta completa.

3. Nota los detalles:
   - Criterios de aceptación específicos
   - Arquitectura de componentes
   - ADRs (decisiones técnicas justificadas)
   - Testing strategy completo

### Para Replicar en Tu Proyecto

1. **Copia la estructura:**
   ```bash
   cp -r openspec/examples/CHANGE-SAMPLE-001-* openspec/changes/
   ```

2. **Adapta a tu stack:**
   - Reemplaza referencias de Laravel/PHP por tu framework
   - Ajusta nombres de componentes
   - Modifica testing frameworks

3. **Ejecuta el workflow completo:**
   - Empieza con tu user story
   - Sigue los comandos documentados arriba
   - Ajusta outputs del AI según tu contexto

---

## ❓ FAQ

### ¿Qué es un "delta spec"?

Un spec que vive en `changes/CHANGE-XXX/specs/` temporalmente, y se aplica al source of truth en `openspec/specs/` tras aprobación. Permite revisar cambios sin contaminar specs existentes.

### ¿Por qué `proposal.md` + `design.md` separados?

- **proposal.md:** QUÉ y POR QUÉ (para Product Owner, stakeholders)
- **design.md:** CÓMO técnico (para desarrolladores, arquitectos)

Separarlos permite reviews independientes.

### ¿Puedo omitir `/ff` y escribir manualmente?

Sí. `/ff` es opcional. Genera propuesta rápida con AI, pero siempre requiere revisión manual. Puedes escribir design.md y tasks.md directamente.

### ¿Qué pasa si no uso CodeRabbit?

El flujo funciona sin CodeRabbit, pero pierdes:
- Review automático de código
- Detección de issues de seguridad/performance
- Sugerencias de mejora

Puedes sustituir con:
- Review manual más exhaustivo
- Herramientas SAST (Semgrep, SonarQube)
- Linters configurados

### ¿Cómo escalo esto a equipos grandes?

1. **Prefijos por equipo:**
   - `CHANGE-FE-001` (Frontend)
   - `CHANGE-BE-001` (Backend)
   - `CHANGE-INFRA-001` (Infraestructura)

2. **Ticket integration:**
   - Vincular `CHANGE-XXX` con Epics/Stories
   - Sincronizar estados

3. **Templates personalizados:**
   - Crear templates específicos por tipo de proyecto
   - Ejemplo: `template-microservice.md`, `template-feature.md`

4. **CI/CD checks:**
   - Validar que PRs incluyan Testing Report
   - Verificar cobertura mínima
   - Requerir aprobación de CodeRabbit

---

**Creado:** 2026-02-12  
**Última actualización:** 2026-02-12  
**Estado:** Ejemplo completado y archivado
