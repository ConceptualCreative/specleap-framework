# Frequently Asked Questions — SpecLeap

> If your question isn't covered here, open an issue on [GitHub](https://github.com/ConceptualCreative/specleap-framework/issues) or email `info@specleap.com`.

---

## 1. Am I locked into Anthropic / OpenAI / Google?

No. SpecLeap is **provider-agnostic by construction**, not as a later add-on.

The framework makes no calls to any model API. Zero traffic to `api.anthropic.com`, `api.openai.com`, `googleapis.com` or any other provider. All the project's "knowledge" lives in `.md` and `.sh` files inside your repository: the immutable CONTRACT, conversational commands, specialized agents, global standards and the context memory-bank.

Each AI assistant reads its own instruction file:

| Assistant | File it reads |
|---|---|
| Claude (Anthropic) | `CLAUDE.md` |
| Cursor | `.cursorrules` |
| Continue.dev | `.continuerules` + `.continue/rules/*.md` |
| Cline | `.clinerules` |
| GitHub Copilot | `.github/copilot-instructions.md` |
| Gemini Code Assist | `GEMINI.md` |
| OpenAI Codex | `codex.md` |
| Any generic assistant | `AGENTS.md` |

If Anthropic shuts down tomorrow, you open your project in Cursor with GPT-5 (or VSCode + Continue.dev + Llama-4) and the project context is fully intact. **The specification is the asset, not the model that processes it.**

---

## 2. Why SDD if "vibe coding" with AI is faster?

Vibe coding (asking AI for one-off changes and accepting whatever comes back) is **fast at the start and expensive at the end**. After 50-100 iterations, the AI loses track of what the project is, what technical decisions were made and why, what's out of scope, what standards apply. It starts improvising, contradicts existing patterns, reinvents utilities you already had. You become the long-term memory system, reading every PR to catch inconsistencies.

SDD captures the project's intent **once**, in an immutable CONTRACT. The AI can iterate 100 times, 1000 times, but always returns to the same north: CONTRACT + specs + memory-bank. No improvising. No reinventing. No drift.

**Vibe coding scales linearly with developer time.** SDD scales with spec quality (once the spec is right) and becomes nearly free from there on.

---

## 3. Is it for small projects or only enterprise?

There's a minimum where SpecLeap starts paying off. Roughly **one week of real work**.

- **Weekend side-project:** probably not — the 58-question survey (~20 min) is overhead you won't recover if the project is going to be 200 lines of code.
- **1-4 week project:** yes, clearly. A single "no, this isn't what I meant, start over" cycle already costs more than the 20-minute survey.
- **Multi-month project with several contributors:** yes, fundamental. Without SDD, every new dev takes days to ramp up on context. With CONTRACT + memory-bank, 30 minutes.
- **Enterprise / regulated projects:** yes, especially. The traceability of "this was decided this way because…" in versioned specs is exactly what security / compliance / GDPR audits ask for.

If in doubt, run this test: will the project have at least one PR merged from someone other than you? If yes, SDD pays off. If only you'll touch it for an afternoon, vibe coding is more efficient.

---

## 4. Does it work without Claude Code? What do I lose?

Yes, it works without Claude Code. SpecLeap supports 9+ assistants and they all read the same repo files (see question 1).

**What you lose specifically without Claude Code:**

- **Native integration with the 34 Agent Skills.** Agent Skills are a concrete Claude Code runtime feature that loads specialized knowledge (OWASP/STRIDE security, Vercel-style design, TDD, Laravel/React best practices, etc.) when the prompt context warrants it. In other assistants the skill `.md` files are still accessible, but they don't auto-load — you have to reference them by hand when needed.
- **Local validation hooks** (`spec-guard.sh`) that hook into the Claude Code runtime to block writes on protected branches. In other assistants that protection is covered by the SpecLeap `pre-push` git hook, which is independent.

**What you DO NOT lose:**

- The immutable CONTRACT, agents (`.agents/*.md`), commands (`.commands/*.md`), memory-bank, specs, Asana/CodeRabbit integration, the survey, the openspec CLI — everything works the same.

If your priority is the 34 Agent Skills, Claude Code is the best option today. If your priority is flexibility and multi-model, Cursor + Continue.dev cover the rest.

---

## 5. What if I want to switch AI provider mid-project?

You do it without losing anything from the project. But the "how" depends on your current setup, because **AI provider, assistant and IDE are three distinct layers**:

| Layer | Examples |
|---|---|
| **AI Provider** (model + API) | Anthropic (Claude), OpenAI (GPT), Google (Gemini), Meta (Llama) |
| **Assistant / extension** | Claude Code, Cursor's Cmd-K, Continue.dev, Cline, GitHub Copilot |
| **IDE** | VSCode, Cursor (a VSCode fork), JetBrains, Vim, Zed |

**Practical cases:**

- **If you use Cursor or Continue.dev:** switching provider is one click in their settings panel. The SpecLeap project doesn't even notice.
- **If you use Claude Code and want to switch to OpenAI:** swap the extension (install Continue.dev or Copilot instead). You can keep the same IDE (VSCode), or take the chance to switch IDE too if you prefer.
- **If you switch IDE entirely:** open the repo in the new IDE, install its assistant, and the entire context is still there. CONTRACT, specs, agents, decisions, memory-bank — all in `.md` files in the repo, portable to any bilingual assistant.

**What stays intact no matter what:** the `.md` and `.sh` files in the repo. That's SpecLeap's value. Provider, assistant and IDE are replaceable layers on top.

---

## 6. Do I need Asana mandatorily?

For some commands yes, for the bulk of the framework no.

**Commands that DO require Asana:**

- `crear-tickets` (generates the backlog from the CONTRACT)
- `planificar` (refines user stories and creates tasks)
- `implementar` (updates ticket states during implementation: To Do → In Progress → In Review → Done)

**What works WITHOUT Asana:**

- 58-question survey + CONTRACT.md generation
- Specialized agents (`.agents/backend.md`, `frontend.md`, `producto.md`)
- Commands `refinar`, `documentar`, `explicar`, `compliance`, `adoptar`
- 34 Agent Skills
- Full openspec CLI (proposals, deltas, verify, archive)
- Memory-bank in `context/`
- Global standards in `rules/`
- 3-layer validation pipeline (git hooks + `implementar` + CodeRabbit)

If your team uses Linear, Jira, Notion or GitHub Issues instead of Asana, you can use SpecLeap anyway and manage the backlog manually. Contributions adding adapters for other trackers are welcome — the Asana-specific code is isolated in `scripts/lib/asana-utils.sh` and `scripts/create-asana-tasks.sh`.

---

## 7. How does it scale with a team? Conflicts on CONTRACT?

The CONTRACT is **immutable by design**, so the classic "who touches what?" conflicts don't happen on that file.

**How changes are managed:**

1. **Changes to the original scope** → go to `ANEXOS.md` (versioned, append-only). The CONTRACT stays as it was at signing time.
2. **Technical changes / new decisions** → go to `context/decisions.md` with date and rationale.
3. **New features** → each in its own branch `feature/<project>-<ticket>-<desc>` with its spec under `proyectos/<name>/specs/`. PR against `stage`, then PR against `main`.

**Branch flow (documented in `CONTRIBUTING.md`):**

```
feature/<project>-<ticket>-<desc>  →  stage  →  main
        (work)                    PR         PR (release)
```

Each feature carries its spec, its tests and its validation evidence. CodeRabbit reviews the PR against CONTRACT + standards. Merging to `main` only happens after passing the 3-layer pipeline.

**What this prevents:**

- "Why does this endpoint work this way?" → answer in CONTRACT or ANEXO with date and author.
- "Was this part of the original project?" → clear YES/NO in CONTRACT vs ANEXOS.
- "Different developers solved the same problem differently" → global standards + agents with domain rules avoid divergence.

---

## 8. Does it replace TDD / Agile / Scrum?

No, it **complements** them. Each operates at a different layer:

| Methodology | What it solves | When |
|---|---|---|
| **SDD (SpecLeap)** | Project's long-term memory: what's being built and why | Before the first commit, lives the whole project |
| **TDD** | How you write code (test first) | During each iteration |
| **Agile / Scrum** | How you organize work over time | Sprint by sprint |

SpecLeap is the missing layer in the methodology stack now that AI writes the code. Without SDD, Scrum's sprint planning still works the same, but the AI keeps improvising inside each sprint. With SDD, sprint planning fills with tickets already aligned with the CONTRACT, the AI works with context, and code review focuses on business logic instead of "this isn't what I asked for".

**They coexist without friction:**

- Your CONTRACT.md doesn't clash with your sprint board.
- Your TDD tests don't clash with your specs.
- Your Scrum Definition of Done is enriched by SpecLeap's 3-layer validation pipeline.

If you already use Agile + TDD, SpecLeap is the piece that brings consistency across sprints without touching your current methodology.

---

## 9. Does it cost anything? What license is it?

SpecLeap is **free and open source (MIT)**. No account, no paid plan, no card. Clone the repo or install it with npm and the code is yours.

The only cost is the assistant you already use — Claude, Cursor, Copilot or another. SpecLeap does not sit in the middle of that subscription or add one of its own.

---

## 10. What do I need installed? Does it work on Windows?

You need **Node.js 18 or newer, Git and Bash**. Full setup takes 10-15 minutes. PHP, Composer, PostgreSQL or Docker only matter if the project you are about to build uses them.

On Windows, install **Git for Windows**: it includes Git Bash and the installer finds it on its own. If Windows has the folder locked while renaming, setup continues with the current name. The reliable path is to clone with the final name (`git clone <url> my-project`). macOS and Linux already ship Bash.

---

## 11. Can I use it on a project that is already underway?

Yes. The `adoptar` command reads the code you already have and writes a **retroactive CONTRACT**: what exists, what is out of scope, and which rules apply from now on.

It does not rewrite the application. It documents what is already built so later changes stop drifting in silence.

---

## 12. What if I answer the survey wrong, or the scope changes?

The survey saves progress **every 10 questions**. When you finish you can expand from MVP to Serious Project — adding governance, SLAs and compliance without repeating what you already said — or attach a free paragraph in Creative mode.

Once the CONTRACT is approved, it is not edited. A scope change is recorded in `ANEXOS.md` with the `refinar` command. That keeps the original ask separate from what was added later.

---

## 13. Do I have to use Laravel, React and PostgreSQL?

No. The standards and part of the skills are tuned for **Laravel, React, TypeScript, PostgreSQL and shadcn**, and the survey lets you declare a different stack. From then on the CONTRACT is what counts.

Quality, process, security and design skills still apply. The Laravel or React skills help less if your project does not use that stack.

---

## 14. Does SpecLeap upload my code or my CONTRACT anywhere?

It has no server and no account. The CONTRACT and the code **stay in your repository**. The framework does not call model APIs. During setup, the installer clones the 34 skills from public GitHub repos into `~/.claude/skills/`.

What leaves your machine afterwards is what you connect: the AI assistant you already pay for, GitHub if you push, Asana if you paste the token, CodeRabbit if you install the app. Running the installer again only updates the catalog skills. A skill of yours, under another name, is left alone.

---

Have a question that's not covered here? Open an issue on [GitHub](https://github.com/ConceptualCreative/specleap-framework/issues) or email `info@specleap.com`.
