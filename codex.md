# SpecLeap — Context for GitHub Copilot

**Framework:** Spec-Driven Development (SDD). Specification before implementation.

---

## What is SpecLeap?

A development framework combining:
- Conversational AI agents with specialized roles
- Contract-based project management (CONTRATO.md)
- Multi-project support with independent contexts
- Standards-driven code quality

---

## File Structure

```
proyectos/[project]/
├── CONTRATO.md          # Immutable contract
├── ANEXOS.md            # Improvements log
├── context/             # Project memory
│   ├── brief.md
│   ├── architecture.md
│   ├── tech-stack.md
│   ├── conventions.md
│   └── decisions.md
└── specs/               # Feature specs
```

---

## Commands (Spanish)

Use these commands in chat with your AI assistant:

- **`refinar [proyecto]-XXX`** — Refine user story from Asana
- **`planificar [proyecto]-XXX`** — Generate implementation plan
- **`implementar @plan.md`** — Execute implementation
- **`explicar [concept]`** — Explain code or architecture
- **`documentar`** — Update technical docs

**Details:** See `.commands/` directory

---

## Standards to Follow

Before writing code, read:

1. `specs/base-standards.mdc` — Core principles
2. `specs/laravel-standards.mdc` — For Laravel/PHP projects
3. `specs/react-standards.mdc` — For React/TypeScript projects
4. `proyectos/[project]/context/conventions.md` — Project-specific patterns

---

## Workflow

1. Say **"Hola"** to start
2. AI loads project context
3. Use commands to work on tickets
4. Follow generated plans
5. Tests >= 90% coverage
6. Create PR (never push to main)

---

## Key Rules

- ✅ **CONTRATO.md is immutable** — Never modify after accepted
- ✅ **All code in English** — Variables, functions, comments
- ✅ **User text in Spanish** — UI messages, errors
- ✅ **Tests required** — >= 90% coverage
- ✅ **Follow conventions** — Read `context/conventions.md`

---

For full documentation, see: `CLAUDE.md` or `.commands/inicio.md`
