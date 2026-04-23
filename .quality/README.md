# Carpeta `.quality/`

Esta carpeta guarda la **huella auditable** de calidad del proyecto: los umbrales mínimos acordados y la evidencia generada por cada feature trabajada.

## Estructura

```
.quality/
├── README.md                    Este archivo
├── baselines/
│   └── baseline.json            Umbrales y snapshot del repositorio
└── evidence/
    └── [feature-slug]/          Una carpeta por feature
        ├── metadata.json        Ticket, fecha, autor, estado
        ├── tests/
        │   ├── unit.txt
        │   ├── integration.txt
        │   └── coverage.json
        ├── security/
        │   └── audit.txt
        └── decisions.md         Decisiones no triviales
```

## Qué se versiona y qué no

| Ruta | ¿Versionada? |
|------|--------------|
| `.quality/README.md` | Sí |
| `.quality/baselines/baseline.json` | Sí |
| `.quality/evidence/.gitkeep` | Sí |
| `.quality/evidence/<feature>/` | No (ignorada en `.gitignore`) |

La razón: los umbrales son contrato compartido del equipo, pero la evidencia son outputs regenerables que ensucian el historial de Git.

## `baselines/baseline.json`

Campo | Propósito
--- | ---
`thresholds.coverage_min` | Cobertura mínima exigida para que `implementar` haga push (por defecto 80%)
`thresholds.coverage_target` | Cobertura objetivo a la que aspirar (por defecto 90%)
`thresholds.complexity_max_per_function` | Complejidad ciclomática máxima por función (por defecto 10)
`thresholds.duplicates_max_pct` | Porcentaje máximo de código duplicado tolerado (por defecto 3%)
`repo_snapshot` | Contadores de LOC, ficheros, agentes, comandos y skills. Se regenera con `snapshot`

Los valores por defecto salen del estándar general del framework. Cada proyecto puede editarlos en su propio `baseline.json` si su CONTRATO lo exige.

## Convención de nombres para `evidence/`

`evidence/[nombre-proyecto]-[numero-ticket]/`

Ejemplos:
- `evidence/app-tienda-23/`
- `evidence/channel-pms-107/`

## Comando `scripts/quality-baseline.sh`

Tres verbos:

```bash
bash scripts/quality-baseline.sh init
# Crea .quality/baselines/baseline.json con los umbrales por defecto
# si aún no existe, y la estructura evidence/ con .gitkeep.

bash scripts/quality-baseline.sh snapshot
# Cuenta LOC, ficheros, agentes, comandos y skills del repositorio
# y actualiza repo_snapshot dentro de baseline.json.

bash scripts/quality-baseline.sh new-evidence app-tienda-23
# Crea evidence/app-tienda-23/ con los stubs (metadata.json,
# tests/, security/, decisions.md).
```

El comando usa el sistema i18n del framework: los mensajes aparecen en el idioma seleccionado durante la instalación.

## Cuándo escribir en `evidence/`

- `planificar [proyecto]-XXX` genera el `metadata.json` inicial del ticket.
- `implementar @plan.md` rellena `tests/` y `coverage.json` al terminar la feature.
- Un security scan manual o automatizado escribe `security/audit.txt`.
- Las decisiones técnicas relevantes se anotan en `decisions.md` a medida que se toman.

## Cuándo purgar `evidence/`

Cuando el ticket se archiva (`openspec archive CHANGE-XXX` o cierre manual en Asana), se puede borrar la carpeta de evidence. El historial queda en el propio ticket y en los commits del PR mergeado.

---

## Healing Log (`evidence/[feature]/healing.jsonl`)

Cada feature mantiene además un log en formato JSONL con las acciones correctivas automáticas que se ejecutan durante su ciclo (reintentos de tests, arreglos de lint, regeneraciones de migraciones, rollbacks, etc.). Útil para observabilidad retrospectiva: permite contestar a *"¿qué ha tenido que auto-corregir este `implementar` antes de pasar?"*

### Formato de cada entrada

Una línea por evento, objeto JSON:

```json
{"ts":"2026-04-23T18:51:00Z","phase":"implementar","severity":"warn","action":"retry_test","detail":"Test falló, reintento 1 de 3","file":"tests/RedisCacheTest.php"}
```

| Campo | Tipo | Obligatorio | Descripción |
|-------|------|-------------|-------------|
| `ts` | string ISO | sí | Marca de tiempo UTC |
| `phase` | string | sí | Comando en el que ocurrió (`planificar`, `implementar`, `verify`, etc.) |
| `severity` | `info` / `warn` / `error` | sí | Gravedad |
| `action` | string | sí | Identificador del tipo de corrección (`retry_test`, `fix_lint`, ...) |
| `detail` | string | no | Descripción humana |
| `file` | string | no | Archivo implicado, si aplica |

### Comando `scripts/quality-healing.sh`

Tres verbos:

```bash
# Añadir una entrada
bash scripts/quality-healing.sh log \
  --feature app-tienda-23 \
  --phase implementar \
  --severity warn \
  --action retry_test \
  --detail "Test redis-cache falló, reintento 1 de 3" \
  --file tests/RedisCacheTest.php

# Mostrar las últimas N entradas (20 por defecto)
bash scripts/quality-healing.sh show --feature app-tienda-23 --last 50

# Ver estadísticas: total + por severity / phase / action
bash scripts/quality-healing.sh stats --feature app-tienda-23
```

El helper usa el mismo sistema i18n: los mensajes de salida aparecen en el idioma configurado en la instalación (es/en).

### Qué comandos lo deberían usar

- `implementar` cuando una validación falla y se reintenta
- `planificar` si tiene que reescribir un plan detectando inconsistencias
- Cualquier script de validación (pre-commit, post-test) que aplique una corrección automática
