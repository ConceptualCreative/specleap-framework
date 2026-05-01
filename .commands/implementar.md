# Comando: implementar

**Sintaxis:** `implementar @plan.md` o `implementar @[TICKET-ID]_backend.md`

**Objetivo:** Ejecutar el plan de implementación: crear branch, escribir código, tests, commit, push, PR.

**Motor:** Usa `openspec verify` (CLI) para validación de tests.

---

## 🌐 Idioma

**TODOS los mensajes de feedback deben estar en ESPAÑOL.**

Esto incluye:
- Mensajes de progreso ("Creando branch...", "Ejecutando tests...")
- Mensajes de error ("❌ Tests fallaron")
- Mensajes de éxito ("✅ PR creado exitosamente")
- Preguntas al usuario ("¿Qué prefieres? (A/B/C)")

---

## ⚠️ ADVERTENCIA

Este comando **IMPLEMENTA CÓDIGO REAL**. Antes de ejecutar:
1. Plan revisado y aprobado
2. Directorio correcto del proyecto
3. Git configurado
4. Tests funcionando

---

## Flujo

### 1. Leer el Plan

Lee el archivo de plan:
```
proyectos/[proyecto]/specs/[TICKET-ID]_backend.md
```

O usa el nombre corto:
```
implementar @plan.md
```

---

### 2. Verificar Alcance del CONTRATO

**ANTES de implementar**, verificar si está dentro del CONTRATO.md.

**A) Leer CONTRATO.md:**
```bash
cat proyectos/[proyecto]/CONTRATO.md
```

**B) Analizar:**
- ¿Qué funcionalidad implementa?
- ¿Está en Módulos/Funcionalidades del CONTRATO?
- ¿Es mejora o NUEVO?

**C) Decisión:**

**SI está en CONTRATO:** ✅ Continuar

**SI NO está en CONTRATO:**
```markdown
⚠️ **ALERTA: Funcionalidad fuera de alcance**

Este tarea implementa: [Nombre funcionalidad]

NO aparece en CONTRATO.md sección "Módulos" ni "Funcionalidades".

**Opciones:**
A) **Agregar a ANEXOS.md** — Funcionalidad nueva fuera del MVP original
B) **Rechazar** — Está explícitamente en "Fuera de Alcance"
C) **Cancelar** — No implementar por ahora

¿Qué prefieres? (A/B/C)
```

**Si elige A:** Agregar a ANEXOS.md y continuar  
**Si elige B o C:** Detener implementación

---

### 3. Sistema de Validación en 3 Capas

**SpecLeap usa 3 capas de validación para garantizar calidad:**

**🔹 Capa 1: Git Hook Pre-Commit (Automático)**
- Se ejecuta ANTES de cada commit
- Valida: Linters, formatters, syntax
- Rápido (<5 segundos)
- Previene commits obviamente malos

**🔹 Capa 2: Comando `implementar` (Completo)**
- Se ejecuta al terminar feature
- Valida: Tests unitarios + integración + specs
- Completo (~1-5 minutos)
- Si pasa: hace commit + push + crea PR

**🔹 Capa 3: CodeRabbit en PR (Revisión profunda)**
- Se ejecuta automáticamente al crear PR
- Valida: Arquitectura, seguridad, lógica de negocio
- Profundo (~5-10 minutos)
- Comenta en el PR con mejoras

---

### 4. Identificar Directorio del Proyecto

Pregunta dónde está el código:
```markdown
¿En qué directorio está el código del proyecto?

Ejemplo:
- `/path/to/task-manager-backend`
- `/path/to/task-manager-frontend`
```

---

### 4. Verificar Estado de Git

```bash
cd [directorio-proyecto]
git status
```

**Si hay cambios sin commitear:**
```markdown
⚠️ Hay cambios sin commitear:

[Listar archivos modificados]

**Opciones:**
A) **Commit** — Commitearlo antes de continuar
B) **Stash** — Guardarlos temporalmente
C) **Cancelar** — No continuar

¿Qué prefieres? (A/B/C)
```

---

### 5. Crear Branch

```bash
# Determinar nombre
TICKET_ID="[TASK_GID]"
BRANCH_TYPE="feat"  # o "fix" según el plan
BRANCH_NAME="$BRANCH_TYPE/$TICKET_ID-[nombre-corto]"

# Crear branch
git checkout -b $BRANCH_NAME

echo "✅ Branch creado: $BRANCH_NAME"
```

---

### 6. Implementar Paso a Paso

El plan tiene tareas numeradas. Ejecutar una por una:

**Para cada tarea:**

```markdown
📌 **Tarea [X/N]:** [Descripción]

**Archivos a modificar:**
- [archivo1]
- [archivo2]

**Implementando...**
```

**Generar código** según el plan (usando contexto del proyecto + standards).

**Mostrar diff:**
```bash
git diff [archivo]
```

```markdown
**Cambios realizados en [archivo]:**

[Mostrar diff con colores]

✅ Tarea [X/N] completada.
```

---

### 7. Verificar Tests (Usar CLI)

Después de implementar todas las tareas, validar con CLI:

```bash
openspec verify --type unit
openspec verify --type integration
```

Esto ejecuta:
- Tests unitarios
- Tests de integración
- Linters
- Type checking

**Si los tests PASAN:**
```markdown
✅ **Tests: PASS**

[Mostrar resumen]

Continuando...
```

**Si los tests FALLAN:**
```markdown
❌ **Tests: FAIL**

[Mostrar errores]

**Opciones:**
A) **Corregir** — Arreglar los errores y volver a verificar
B) **Commit de todas formas** — (NO recomendado)
C) **Cancelar** — Deshacer cambios

¿Qué prefieres? (A/B/C)
```

Si elige A, corregir y ejecutar `openspec verify` de nuevo.

---

### 8. Commit

```bash
# Determinar mensaje
COMMIT_MSG="$BRANCH_TYPE: [descripción corta del tarea]

Implementa: $TICKET_ID

- [Tarea 1]
- [Tarea 2]
- [Tarea 3]

Tests: pass"

# Commit
git add .
git commit -m "$COMMIT_MSG"

echo "✅ Commit realizado"
```

---

### 9. Push

```bash
git push origin $BRANCH_NAME

echo "✅ Pusheado a origin/$BRANCH_NAME"
```

---

### 10. Crear Pull Request (Opcional)

**Con GitHub CLI (`gh`):**

```bash
gh pr create \
  --title "[$TICKET_ID] [Título del tarea]" \
  --body "[Descripción del plan + link a Asana]" \
  --base develop \
  --head $BRANCH_NAME

echo "✅ PR creado: [URL]"
```

**Si NO está disponible:**

```markdown
✅ **Cambios pusheados**

**Crear PR manualmente:**

1. Ve a: https://github.com/[owner]/[repo]/compare/develop...$BRANCH_NAME
2. Título: [$TICKET_ID] [Título]
3. Descripción:
   ```
   Implementa: $TICKET_ID
   
   **Cambios:**
   - [Tarea 1]
   - [Tarea 2]
   - [Tarea 3]
   
   **Link Asana:** [URL del tarea]
   
   **Tests:** ✅ Pass
   ```
4. Asigna reviewers
5. Crea PR
```

---

### 11. Actualizar Asana

**Si MCP Asana disponible:**

```bash
# Agregar comentario con link al PR
openspec asana comment $TICKET_ID "PR creado: [URL]"

# Mover a Code Review
openspec asana transition $TICKET_ID "Code Review"
```

**Si NO disponible:**

```markdown
**Actualiza Asana manualmente:**

1. Abre tarea $TICKET_ID
2. Agrega comentario: "PR creado: [URL]"
3. Mueve a estado "Code Review"
```

---

### 12. Confirmar Completado

```markdown
✅ **Implementación completada**

**Resumen:**
- Branch: $BRANCH_NAME
- Commits: 1
- Tests: ✅ Pass
- PR: [URL]
- Asana: $TICKET_ID → Code Review

**Próximos pasos:**
1. Esperar code review
2. Hacer ajustes si se requieren
3. Merge cuando aprueben

**Comandos útiles:**
- Ver PR: `gh pr view`
- Ver status checks: `gh pr checks`
- Mergear (cuando aprueben): `gh pr merge`
```

---

## Comandos CLI Usados

| Comando | Propósito |
|---------|-----------|
| `openspec verify --type unit` | Ejecutar tests unitarios |
| `openspec verify --type integration` | Ejecutar tests de integración |
| `openspec asana comment <ID> <text>` | Agregar comentario a tarea |
| `openspec asana transition <ID> <state>` | Cambiar estado de tarea |

---

## Agentes Relacionados

- `.agents/backend.md` — Para implementación backend
- `.agents/frontend.md` — Para implementación frontend

---

## Próximo Comando

- `/code-review` — Solicitar code review del PR creado (cuando esté listo)
