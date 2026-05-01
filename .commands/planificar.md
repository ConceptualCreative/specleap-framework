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

### 0. Cargar credenciales desde .env

**ANTES de cualquier comando que necesite Asana**, cargar las variables de entorno desde el `.env` del proyecto SpecLeap. `setup.sh` guarda allí `ASANA_ACCESS_TOKEN` y `ASANA_WORKSPACE_GID`, pero la shell de Claude Code no las carga automáticamente.

```bash
# Cargar .env si existe (no fallar si no existe)
if [ -f .env ]; then
  set -a
  source .env
  set +a
fi

# Verificar que el token quedó cargado
if [ -z "${ASANA_ACCESS_TOKEN:-}" ]; then
  echo "❌ ASANA_ACCESS_TOKEN no está configurado en .env ni en la shell"
  echo "   Re-ejecuta bash setup.sh para configurar Asana, o exporta manualmente."
  exit 1
fi
```

**Importante:** los scripts `scripts/generate-asana-structure.sh` y `scripts/create-asana-tasks.sh` también cargan `.env` por su cuenta como red de seguridad. Pero comprobar aquí permite dar un mensaje claro al usuario antes de invocar el script.

---

### 1. Identificar Proyecto

Si no se especifica ruta:
```markdown
¿Para qué proyecto quieres crear el backlog?

**Proyectos disponibles:**
1. task-manager
2. inventory-app
3. crm-suite

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
2. **ASANA_ACCESS_TOKEN** y **ASANA_WORKSPACE_GID** en `.env` del proyecto SpecLeap (`setup.sh` lo crea al instalar)

Los scripts cargan `.env` automáticamente. Si necesitas verificar manualmente:

```bash
cd <ruta-proyecto-specleap>
cat .env | grep ASANA
```

---

## Troubleshooting

### "Script no encontrado"

```bash
ls scripts/generate-asana-structure.sh
# Si no existe, verifica instalación o re-ejecuta setup.sh
```

### "ASANA_ACCESS_TOKEN no configurado"

El `.env` del proyecto SpecLeap no existe o no contiene el token. Soluciones:

```bash
# Verificar que existe el .env y tiene el token
ls -la .env && grep ASANA .env

# Si falta o está vacío, re-ejecutar el paso de configuración Asana del setup
bash setup.sh
```

Si por alguna razón prefieres exportar manualmente (sin pasar por `.env`):

```bash
export ASANA_ACCESS_TOKEN="tu-token-aqui"
export ASANA_WORKSPACE_GID="tu-workspace-gid"
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
