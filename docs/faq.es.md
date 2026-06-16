# Preguntas frecuentes — SpecLeap

> Si tu pregunta no está aquí, abre un issue en [GitHub](https://github.com/ConceptualCreative/specleap-framework/issues) o escribe a `info@specleap.com`.

---

## 1. ¿Soy cautivo de Anthropic / OpenAI / Google?

No. SpecLeap es **agnóstico de proveedor por construcción**, no como añadido posterior.

El framework no llama a ningún API de modelo. Cero tráfico hacia `api.anthropic.com`, `api.openai.com`, `googleapis.com` o cualquier otro proveedor. Todo el "conocimiento" del proyecto vive en archivos `.md` y `.sh` dentro de tu repositorio: el CONTRATO inmutable, los comandos conversacionales, los agentes especializados, los standards globales y el memory-bank de contexto.

Cada asistente IA lee su archivo de instrucciones específico:

| Asistente | Archivo que lee |
|---|---|
| Claude (Anthropic) | `CLAUDE.md` |
| Cursor | `.cursorrules` |
| Continue.dev | `.continuerules` + `.continue/rules/*.md` |
| Cline | `.clinerules` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Gemini Code Assist | `GEMINI.md` |
| OpenAI Codex | `codex.md` |
| Cualquier asistente genérico | `AGENTS.md` |

Si mañana Anthropic cierra, abres tu proyecto en Cursor con GPT-5 (o en VSCode con Continue.dev + Llama-4) y todo el contexto del proyecto sigue intacto. **La especificación es el activo, no el modelo que la procesa.**

---

## 2. ¿Por qué SDD si "vibe coding" con IA es más rápido?

Vibe coding (pedirle a la IA cosas sueltas y aceptar lo que salga) es **rápido al principio y caro al final**. Después de 50-100 iteraciones, la IA pierde el contexto de qué es el proyecto, qué decisiones técnicas se tomaron y por qué, qué está fuera de alcance, qué standards usa. Empieza a improvisar, contradice patrones existentes, reinventa utilidades que ya tenías. Tú te conviertes en el sistema de memoria a largo plazo, leyendo cada PR para detectar inconsistencias.

SDD captura **una sola vez** la intención del proyecto en un CONTRATO inmutable. La IA puede iterar 100 veces, 1000 veces, pero siempre vuelve al mismo norte: el CONTRATO + las specs + el memory-bank. No improvisa. No reinventa. No se desvía.

**Vibe coding escala linealmente con el tiempo del developer.** SDD escala con la calidad de la spec (una vez bien hecha) y se vuelve casi gratis a partir de ahí.

---

## 3. ¿Sirve para proyectos pequeños o solo enterprise?

Hay un mínimo a partir del cual SpecLeap se rentabiliza. Aproximadamente **1 semana de trabajo real**.

- **Side-project de un fin de semana:** probablemente no — el cuestionario de 58 preguntas (~20 min) es overhead que no recuperas si el proyecto va a tener 200 líneas de código.
- **Proyecto de 1-4 semanas:** sí, claramente. Un solo ciclo de "ah, no, no era esto, vuelve a empezar" ya cuesta más que las 20 min del cuestionario inicial.
- **Proyecto multi-mes con varios contributors:** sí, fundamental. Sin SDD, cada nuevo dev tarda días en entender el contexto. Con CONTRATO + memory-bank, 30 minutos.
- **Proyectos enterprise / regulados:** sí, especialmente. La trazabilidad de "esto se decidió así porque..." en specs versionadas es exactamente lo que piden auditorías de seguridad / compliance / GDPR.

Si dudas, hazte la prueba: ¿el proyecto va a tener al menos un PR mergeado de otra persona? Si sí, SDD vale la inversión. Si solo lo tocas tú una tarde, vibe coding es más eficiente.

---

## 4. ¿Funciona sin Claude Code? ¿Qué pierdo?

Sí, funciona sin Claude Code. SpecLeap soporta 9+ asistentes y todos leen los mismos archivos del repo (ver pregunta 1).

**Lo que pierdes sin Claude Code específicamente:**

- **Integración nativa con los 20 Agent Skills.** Los Agent Skills son una feature concreta del runtime de Claude Code que carga conocimiento especializado (seguridad OWASP/STRIDE, diseño Vercel-style, TDD, Laravel/React best practices, etc.) cuando el contexto del prompt lo justifica. En otros asistentes los `.md` de las skills siguen siendo accesibles, pero no se cargan automáticamente — tienes que referenciarlos a mano cuando los necesites.
- **Hooks de validación local** (`spec-guard.sh`) que se enganchan al runtime de Claude Code para bloquear escrituras en ramas protegidas. En otros asistentes esa protección la cubre el `pre-push` git hook de SpecLeap, que es independiente.

**Lo que NO pierdes:**

- El CONTRATO inmutable, los agentes (`.agents/*.md`), los comandos (`.commands/*.md`), el memory-bank, las specs, la integración con Asana/CodeRabbit, el cuestionario, el CLI openspec — todo funciona igual.

Si tu prioridad son los 20 Agent Skills, Claude Code es la mejor opción hoy. Si tu prioridad es flexibilidad y multi-modelo, Cursor + Continue.dev cubren el resto.

---

## 5. ¿Y si quiero cambiar de proveedor IA en medio del proyecto?

Lo haces sin perder nada del proyecto. Pero el "cómo" depende de tu setup actual, porque **proveedor IA, asistente y IDE son tres capas distintas**:

| Capa | Ejemplos |
|---|---|
| **Proveedor IA** (modelo + API) | Anthropic (Claude), OpenAI (GPT), Google (Gemini), Meta (Llama) |
| **Asistente / extensión** | Claude Code, Cursor's Cmd-K, Continue.dev, Cline, GitHub Copilot |
| **IDE** | VSCode, Cursor (es un fork de VSCode), JetBrains, Vim, Zed |

**Casos prácticos:**

- **Si usas Cursor o Continue.dev:** cambiar de proveedor es un click en su panel de settings. El proyecto SpecLeap ni se entera.
- **Si usas Claude Code y quieres pasarte a OpenAI:** cambias de extensión (instalas Continue.dev o Copilot en su lugar). Puedes mantener el mismo IDE (VSCode), o aprovechar para cambiar también de IDE si prefieres.
- **Si cambias de IDE entero:** abres el repo en el nuevo IDE, instalas su asistente, y todo el contexto sigue ahí. CONTRATO, specs, agentes, decisiones, memory-bank — todo en archivos `.md` del repo, portables a cualquier asistente bilingüe.

**Lo que se queda intacto pase lo que pase:** los `.md` y `.sh` del repo. Eso es el valor de SpecLeap. El proveedor, el asistente y el IDE son piezas reemplazables encima.

---

## 6. ¿Necesito Asana obligatoriamente?

Para algunos comandos sí, para el grueso del framework no.

**Comandos que SÍ requieren Asana:**

- `crear-tickets` (genera el backlog desde el CONTRATO)
- `planificar` (refina user stories y crea tareas)
- `implementar` (actualiza estados durante la implementación: To Do → In Progress → In Review → Done)

**Lo que funciona SIN Asana:**

- Cuestionario de 58 preguntas + generación de CONTRATO.md
- Agentes especializados (`.agents/backend.md`, `frontend.md`, `producto.md`)
- Comandos `refinar`, `documentar`, `explicar`, `compliance`, `adoptar`
- 20 Agent Skills
- CLI openspec completo (proposals, deltas, verify, archive)
- Memory-bank en `context/`
- Standards globales en `rules/`
- Pipeline de validación 3 capas (git hooks + `implementar` + CodeRabbit)

Si tu equipo usa Linear, Jira, Notion o GitHub Issues en lugar de Asana, puedes usar SpecLeap igualmente y gestionar el backlog manualmente. Las contribuciones que añadan adapters para otros trackers son bienvenidas — el código que habla con Asana está aislado en `scripts/lib/asana-utils.sh` y `scripts/create-asana-tasks.sh`.

---

## 7. ¿Cómo escala con un equipo? ¿Hay conflictos en CONTRATO?

El CONTRATO es **inmutable por diseño**, así que los conflictos clásicos de "¿quién toca qué?" no existen sobre ese archivo.

**Cómo se gestionan los cambios:**

1. **Cambios al alcance original** → van a `ANEXOS.md` (versionado, append-only). El CONTRATO se queda como estaba en el momento de la firma.
2. **Cambios técnicos / decisiones nuevas** → van a `context/decisions.md` con fecha y razonamiento.
3. **Features nuevas** → cada una en su propia rama `feature/<proyecto>-<ticket>-<desc>` con su spec en `proyectos/<name>/specs/`. PR contra `stage`, después PR contra `main`.

**Flujo de ramas (documentado en `CONTRIBUTING.md`):**

```
feature/<proyecto>-<ticket>-<desc>  →  stage  →  main
        (trabajo)                 PR         PR (release)
```

Cada feature lleva su spec, sus tests y su evidencia de validación. CodeRabbit revisa el PR contra el CONTRATO + standards. La merge a `main` solo ocurre tras pasar la pipeline de 3 capas.

**Lo que esto previene:**

- "¿Por qué este endpoint funciona así?" → respuesta en CONTRATO o ANEXO con fecha y autor.
- "¿Esto era parte del proyecto original?" → SÍ/NO claro en CONTRATO vs ANEXOS.
- "Diferentes desarrolladores resolvieron el mismo problema de formas diferentes" → standards globales + agentes con reglas específicas evitan divergencia.

---

## 8. ¿Reemplaza a TDD / Agile / Scrum?

No, los **complementa**. Cada uno opera en una capa distinta:

| Metodología | Qué resuelve | Cuándo |
|---|---|---|
| **SDD (SpecLeap)** | Memoria a largo plazo del proyecto: qué se construye y por qué | Antes del primer commit, vive todo el proyecto |
| **TDD** | Cómo escribes el código (test first) | Durante cada iteración |
| **Agile / Scrum** | Cómo organizas el trabajo en el tiempo | Sprint a sprint |

SpecLeap es la capa que faltaba en el stack metodológico ahora que la IA escribe el código. Sin SDD, el sprint planning de Scrum sigue funcionando igual, pero la IA sigue improvisando dentro de cada sprint. Con SDD, el sprint planning se llena de tickets ya alineados con el CONTRATO, la IA trabaja con contexto, y el code review se enfoca en lógica de negocio en lugar de "esto no era lo que pedí".

**Conviven sin fricción:**

- Tu CONTRATO.md no choca con tu sprint board.
- Tus tests TDD no chocan con tus specs.
- Tu Definition of Done de Scrum se enriquece con la pipeline de validación 3 capas de SpecLeap.

Si ya usas Agile + TDD, SpecLeap es la pieza que aporta consistencia entre sprints sin tocar tu metodología actual.

---

¿Tienes una pregunta que no está aquí? Abre un issue en [GitHub](https://github.com/ConceptualCreative/specleap-framework/issues) o escribe a `info@specleap.com`.
