# Git Workflow — SpecLeap

> Protocolo completo de control de versiones. Todas las reglas son obligatorias.

## Reglas Críticas

### 1. NUNCA push sin autorización

```
🚫 PROHIBIDO hacer push directamente sin aprobación explícita del responsable.
```

Flujo obligatorio:
1. Desarrollar en rama local
2. Verificar que tests pasan
3. Solicitar aprobación
4. Solo después de "aprobado" → push

### 2. Reglas de Ramas Protegidas

| Rama | Protección | Quién puede mergear |
|------|-----------|---------------------|
| `main` | 🔴 Máxima — solo releases | Lead/CTO |
| `stage` | 🟡 Alta — solo PRs aprobados | Lead + reviewer |
| `feature/*` | 🟢 Normal — desarrollo activo | Desarrollador asignado |
| `fix/*` | 🟢 Normal — correcciones | Desarrollador asignado |

**NUNCA:**
- Hacer commit directo a `main`
- Hacer commit directo a `stage`
- Forzar push (`--force`) a ramas protegidas
- Eliminar ramas protegidas

### 3. Crear Ramas desde Stage

**Toda rama nueva DEBE crearse desde `stage`:**

```bash
git checkout stage
git pull origin stage
git checkout -b feature/SCRUM-XX-descripcion
```

**Verificar** que la rama parte de stage:
```bash
git log --oneline stage..HEAD  # Debe mostrar solo tus commits
```

### 4. Convención de Nombres de Ramas

```
tipo/TICKET-ID-descripcion-corta
```

| Tipo | Uso |
|------|-----|
| `feature/` | Nueva funcionalidad |
| `fix/` | Corrección de bug |
| `refactor/` | Reestructuración sin cambio funcional |
| `docs/` | Solo documentación |
| `test/` | Solo tests |

**Ejemplos:**
```
feature/app-tienda-23-integracion-tracker
fix/app-tienda-45-error-login-timeout
refactor/app-tienda-12-optimizar-queries
```

### 5. Formato de Commits

```
TICKET-ID: tipo(alcance): descripción

Cuerpo opcional con más detalle.

Refs: SPEC-XXX
```

**Ejemplos:**
```
SCRUM-23: feat(auth): implementar login con 2FA
SCRUM-45: fix(api): corregir timeout en endpoint /users
SCRUM-12: refactor(db): optimizar queries de dashboard
```

**Tipos:** `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `style`

### 6. Protocolo Antes de Operaciones Git

Antes de cualquier operación Git significativa (merge, rebase, push):

```
1. VERIFICAR  → git status, git log, rama correcta
2. PREGUNTAR  → ¿Es seguro? ¿Afecta a otros?
3. GUARDAR    → Stash o commit de trabajo en progreso
4. EJECUTAR   → La operación Git
5. VERIFICAR  → Confirmar que todo está correcto
```

### 7. Acciones Post-Pull (Laravel)

Después de un `git pull` en proyectos Laravel:

```bash
composer install          # Dependencias PHP
npm install               # Dependencias JS
php artisan migrate       # Migraciones pendientes
php artisan cache:clear   # Limpiar cache
php artisan config:clear  # Limpiar config cache
php artisan view:clear    # Limpiar vistas compiladas
```

### 8. Pull Requests

**Todo PR debe incluir:**

- Referencia al ticket: `SCRUM-XX`
- Referencia a la spec: `SPEC-XXX`
- Descripción de cambios
- Checklist de verificación:

```markdown
## Checklist
- [ ] Tests pasan localmente
- [ ] Spec actualizada si hubo cambios
- [ ] Sin archivos hardcodeados
- [ ] Code review solicitado
- [ ] Documentación actualizada
```

### 9. Merge Strategy

| Situación | Estrategia |
|-----------|-----------|
| Feature → stage | Squash merge (1 commit limpio) |
| Stage → main | Merge commit (preservar historial) |
| Hotfix → main | Cherry-pick + merge a stage |

---

*Estas reglas son obligatorias para todos los contribuidores del proyecto.*
