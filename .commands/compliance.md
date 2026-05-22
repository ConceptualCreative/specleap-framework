# Comando: compliance

**Trigger:** Usuario escribe `compliance`, `auditoria` o `audit` (case-insensitive).

**Objetivo:** Ejecutar una auto-auditoría del framework SpecLeap y reportar al usuario una nota 0-100 en 6 dimensiones, más acciones concretas para subir la nota si hay drift.

---

## Qué dimensiones se auditan

1. **Version** — El `package.json.version` coincide con el último tag de git.
2. **Skills** — El número de carpetas en `~/.claude/skills/` (o `~/.skills/` si es instalación legacy) coincide con los counters declarados en `CLAUDE.md`, `README.md` y `.quality/baselines/baseline.json`.
3. **i18n** — Todas las claves de `.specleap/i18n/es.json` existen en `.specleap/i18n/en.json` y viceversa.
4. **Hooks** — `.claude/hooks/spec-guard.sh` existe, tiene shebang, es ejecutable y está referenciado en `.claude/settings.json.template`.
5. **Baseline** — `.quality/baselines/baseline.json.repo_snapshot` no difiere >20% de los counters reales del repo.
6. **Docs** — Ningún `.md` raíz tiene residuos de marcas pasadas (`iapanderson`, `archspec`, `openclaw`, `pamela`) excluyendo `CHANGELOG.md` (histórico).

---

## Flujo que la IA debe seguir

### Paso 1: Ejecutar el script de auditoría

Desde la raíz del framework:

```bash
bash scripts/compliance-audit.sh
```

El script imprime un resumen a stdout y escribe un JSON detallado en `.quality/evidence/compliance/audit-$(timestamp).json`.

### Paso 2: Mostrar el resultado al usuario

Lee el output del script y preséntalo al usuario con formato markdown. Ejemplo:

```markdown
## SpecLeap Compliance Audit

| Dimensión | Puntuación | Observaciones |
|-----------|------------|---------------|
| Version   | 100/100    | |
| Skills    | 100/100    | |
| i18n      | 95/100     | Falta clave `quality.spec_guard.hint_flow` en `en.json` |
| Hooks     | 100/100    | |
| Baseline  | 85/100     | `repo_snapshot` desactualizado |
| Docs      | 100/100    | |

**Total: 96/100**

Detalle guardado en: `.quality/evidence/compliance/audit-2026-04-23T18:55:12Z.json`
```

### Paso 3: Sugerencias de mejora (solo si hay dimensiones <100)

Si alguna dimensión está por debajo de 100, lista las **acciones concretas** para subirla:

```markdown
### Acciones recomendadas

- **i18n:** Añadir la clave `quality.spec_guard.hint_flow` a `en.json` para alinear con `es.json`.
- **Baseline:** Ejecutar `bash scripts/quality-baseline.sh snapshot` para refrescar `repo_snapshot`.
```

Usa las observaciones del script como base. No inventes acciones; si el script dice "missing key X", di "añadir key X".

### Paso 4: Mensaje final según el total

- **Total = 100/100:** felicitación breve. Una frase, sin exagerar. Ejemplo: *"Framework al día, cero drift detectado."*
- **Total 80-99:** resumen neutral. Ejemplo: *"Hay X dimensiones con drift menor. Las acciones de arriba lo resuelven."*
- **Total 60-79:** advertencia moderada. Ejemplo: *"Drift notable en X dimensiones. Revisa las acciones antes del próximo release."*
- **Total < 60:** advertencia fuerte. Ejemplo: *"Drift significativo. Recomiendo no publicar nueva versión hasta resolver los ítems listados."*

---

## Reglas

1. **El script es la fuente de verdad.** No inventes puntuaciones ni observaciones; solo presenta lo que el script devuelve.
2. **No ejecutes acciones correctivas automáticamente.** Solo presenta las recomendaciones. El usuario decide cuándo aplicarlas.
3. **Si el script falla** (error de bash, falta `jq`, etc.), reporta el error tal cual al usuario sin intentar auditar manualmente.
4. **Sin mencionar otros frameworks.** La auditoría es interna de SpecLeap; no compares con otros sistemas.

---

## Referencias

- **Script:** `scripts/compliance-audit.sh`
- **Evidencia:** `.quality/evidence/compliance/` (gitignored)
- **Baseline de referencia:** `.quality/baselines/baseline.json`
- **Claves i18n:** namespace `quality.compliance` en `.specleap/i18n/{es,en}.json`
