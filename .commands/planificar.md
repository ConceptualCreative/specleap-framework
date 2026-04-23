# Comando: planificar

**Sintaxis:** `planificar` o `planificar <ruta-proyecto>`

**Objetivo:** Generar secciones y tareas desde el CONTRATO.md y subirlas a Asana.

**Motor:** Usa `scripts/generate-asana-structure.sh` (CLI) para generación de backlog.

---

## 🌐 Idioma

**TODOS los mensajes de feedback deben estar en ESPAÑOL.**

Esto incluye:
- Mensajes de progreso ("Generando backlog...", "Analizando CONTRATO...")
- Vista previa de épicas y stories
- Mensajes de confirmación
- Errores y advertencias

---

## Flujo

### 1. Identificar Proyecto

Si no se especifica ruta:
```markdown
¿Para qué proyecto quieres crear el backlog?

**Proyectos disponibles:**
1. app-tienda
2. api-backend
3. dashboard-analytics

Responde con el número o nombre:
```

---

### 2. Leer CONTRATO.md

```bash
cat proyectos/[proyecto]/CONTRATO.md
```

Extraer:
- Nombre del proyecto
- Features core
- Features secundarias

---

### 3. Generar Backlog (Usar CLI)

```bash
cd specleap
./scripts/generate-asana-structure.sh -p proyectos/[proyecto]
```

Esto genera:
- Proyecto en Asana
- Secciones (Infraestructura, Backend, Frontend, Testing)
- Tareas (3-8 por sección)
- Story points asignados en notas
- Prioridades

---

### 4. Confirmación

Mostrar al usuario:
```markdown
📊 **Backlog Generado — Preview**

**Proyecto:** [Nombre]

🛠️ **Infraestructura** (3 tareas, 11 pts)
  - Setup inicial del proyecto [3 pts]
  - Configurar CI/CD [5 pts]
  - Configurar entornos (dev/staging/prod) [3 pts]

⚙️ **Backend** (5-8 tareas, 25-40 pts)
  - Implementar API REST básica [8 pts]
  - Implementar autenticación [5 pts]
  - Implementar autorización (roles) [5 pts]
  - ...

🎨 **Frontend** (3 tareas, 16 pts)
  - Implementar sistema de diseño base [8 pts]
  - Implementar autenticación UI [5 pts]
  - Implementar navegación principal [3 pts]

🧪 **Testing** (3 tareas, 13 pts)
  - Tests unitarios backend (>=90% coverage) [5 pts]
  - Tests E2E críticos [5 pts]
  - Tests de integración [3 pts]

**Resumen:**
- Secciones: 4
- Tareas: 14-17
- Story Points: 65-80
- Esfuerzo estimado: ~40-50 días

¿Crear este backlog en Asana? (s/n)
```

---

### 5A. Si el usuario acepta: Crear en Asana

```bash
# Crear proyecto y tareas en Asana
./scripts/generate-asana-structure.sh -p proyectos/[proyecto]
```

Esto:
- Crea proyecto en Asana
- Crea secciones (Infraestructura, Backend, Frontend, Testing)
- Crea tareas vinculadas a secciones
- Asigna story points en notas

**Mostrar confirmación:**
```markdown
✅ **Backlog creado en Asana**

**Proyecto:** https://app.asana.com/0/[PROJECT_GID]

**Secciones creadas:**
- 🛠️ Infraestructura (3 tareas)
- ⚙️ Backend (5-8 tareas)
- 🎨 Frontend (3 tareas)
- 🧪 Testing (3 tareas)

**Actualizar CONTRATO.md con metadata:**
```yaml
asana:
  project_gid: "[PROJECT_GID]"
  section_count: 4
  task_count: 14-17
  synced_at: 2026-03-06T20:00:00Z
```

✅ CONTRATO.md actualizado.

**Próximos pasos:**
1. Revisa el proyecto en Asana
2. Prioriza las tareas
3. Asigna tareas a miembros del equipo
4. Ejecuta `implementar` cuando estés listo
```

---

### 5B. Si el usuario NO acepta: Modo Dry-Run

Usuario puede usar modo dry-run para ver preview sin crear nada:

```bash
./scripts/generate-asana-structure.sh -p proyectos/[proyecto] --dry-run
```

```markdown
💾 **Preview generado (sin crear en Asana)**

Ejecuta sin `--dry-run` cuando estés listo para crear el backlog real.
```

Ejecuta sin `--dry-run` cuando estés listo para crear el backlog real.
```

---

## Comandos CLI/Scripts Usados

| Comando | Propósito |
|---------|-----------|
| `scripts/generate-asana-structure.sh` | Generar proyecto y tareas en Asana desde CONTRATO.md |
| `scripts/create-asana-tasks.sh` | Crear tareas individuales en Asana |
| `scripts/lib/asana-utils.sh` | Utilidades de API Asana |

---

## Personalización

### Ajustar generación de tareas

Edita `scripts/generate-asana-structure.sh`:
- Líneas 145-200: Secciones y tareas generadas
- Story points asignados por tipo de tarea
- Nombres de secciones personalizados

### Crear tareas individuales

```bash
# Listar proyectos
./scripts/create-asana-tasks.sh --listar

# Crear tarea
./scripts/create-asana-tasks.sh \
  -p [PROJECT_GID] \
  -t "Nombre de la tarea" \
  -P 5
```

---

## Requisitos

1. **CONTRATO.md** existente
2. **ASANA_ACCESS_TOKEN** configurado en ~/.zshrc
3. **ASANA_WORKSPACE_GID** configurado (o se detecta automáticamente)

---

## Troubleshooting

### "Script no encontrado"

```bash
cd ~/specleap-framework
ls scripts/generate-asana-structure.sh
# Si no existe, verifica instalación
```

### "ASANA_ACCESS_TOKEN no configurado"

```bash
# Verifica que está en tu ~/.zshrc
grep ASANA_ACCESS_TOKEN ~/.zshrc

# Si no está, agrégalo:
echo 'export ASANA_ACCESS_TOKEN="tu-token-aqui"' >> ~/.zshrc
source ~/.zshrc
```

### "Error: Not Authorized"

Tu token de Asana puede haber expirado. Genera uno nuevo en:
https://app.asana.com/0/my-apps

---

## Workflow Típico

1. `/inicio` → genera CONTRATO.md
2. **`planificar`** → crea backlog en Asana ✅ **ESTÁS AQUÍ**
3. Asigna tareas en Asana
4. `implementar` → desarrolla features

---

**Próximo paso:** Revisa el proyecto en Asana y asigna tareas
