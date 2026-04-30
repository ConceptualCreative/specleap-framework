# SpecLeap Framework Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.1.9] - 2026-04-30

### Added

- **Interactive base-folder prompt during `npx specleap-framework@latest`.** The installer now asks where to install before copying anything. Previously it dropped the `specleap-framework/` folder silently into the user's current working directory, leaving them unsure of the final location.

#### How it works

- `bin/specleap` (the entry point invoked by `npx`) now accepts an optional CLI argument with the base folder, e.g. `npx specleap-framework@latest ~/Downloads`. If the argument is omitted, an interactive bilingual prompt asks for the base folder, with the current working directory as default.
- The folder name is **always** `specleap-framework` (not configurable). If the user wants a different name, they rename it after install with `mv`.
- The base path supports `~`, `~/relative`, plain relative paths, and absolute paths. The resolved path is shown back to the user before copying.
- If the resolved target already exists, the installer aborts with a clear bilingual message instead of silently overwriting.
- The installer creates the base folder if it does not exist.

### Changed

- **Final summary of `setup.sh` now prints the absolute install path prominently.** Block at the end of the installer reads `📍 SpecLeap instalado en: <ruta>` (or `📍 SpecLeap installed at: <path>` in English). Reported by Styng during v2.1.8 testing — after a long setup, the path was effectively lost in the scrollback.
- **Next-steps list now starts with `cd "<install_path>"`** so the user knows how to reach the project regardless of where they ran `npx` from.

### Notes

- Backwards compatible: existing scripts that depend on `setup.sh` running from the project root still work — the env var `SPECLEAP_INSTALL_PATH` is set by `bin/specleap` but `setup.sh` falls back to `pwd` if absent.
- The folder-name decision (always `specleap-framework`) keeps documentation, generated paths and tutorials consistent across users.

## [2.1.8] - 2026-04-26

### Fixed

- **`setup.sh` token validation no longer aborts on the first wrong input.** Both the GitHub and the Asana token prompts now retry up to 3 times before asking the user whether to retry the round again or cancel the installation. Empty input doesn't consume an attempt (it's almost always a paste/typo, not a real failure). Reported by Styng during a manual test where pasting a partial Asana token killed the installer outright with no recovery path.

#### Behavioural details

- 3 attempts per round, then the installer prints the actual count and asks `[R]eintentar / [C]ancelar` (Spanish) or `[R]etry / [C]ancel` (English) depending on the chosen language.
- Choosing `R` (default) resets the attempt counter and lets the user try 3 more times — useful when they realise mid-prompt that they grabbed the wrong token.
- Choosing `C` exits cleanly with code 1 and the message `Instalación cancelada por el usuario` / `Installation cancelled by user`.
- After every invalid token, a tip is printed reminding the user about required scopes (GitHub: `repo`, `workflow`) or token format (Asana: Personal Access Token).
- Empty token input prints a localised reminder of the expected format and re-prompts without spending an attempt.

No changes to the validation logic itself (still calls `https://api.github.com/user` and `https://app.asana.com/api/1.0/workspaces`), so behaviour with valid tokens is unchanged.

## [2.1.7] - 2026-04-25

### Added

- **Bilingual setup questionnaire** (Phase 1 of i18n rollout) — `scripts/lib/questions.json` was split into `questions.es.json` and `questions.en.json`, both with all 58 questions. `generate-contrato.sh` now resolves the file at runtime from `SPECLEAP_LANG` (set by `setup.sh` from the user's choice or by `.specleap/config.json`), falling back to Spanish if the requested locale file is missing. Question IDs, numbers, options, validations and conditional logic (`skip_if`, `auto_suggest`) are preserved verbatim across both files for behavioural parity.
- **Bilingual openspec CLI `--help` output** (Phase 2 of i18n rollout) — the `usage()` function in all nine subcommands (`apply`, `archive`, `code-review`, `enrich`, `ff`, `new`, `report`, `status`, `verify`) now prints English when `SPECLEAP_LANG=en`. A new `cli_lang()` helper in `openspec/cli/common.sh` resolves the active language from the env var, then `.specleap/config.json`, then falls back to `es`. Spanish output is byte-identical to the previous version, so existing users see no change.
- **Bilingual FAQ** documenting the eight most common questions (vendor lock-in, SDD vs vibe coding, project size threshold, working without Claude Code, switching AI providers mid-project, Asana requirement, team scaling, relation to TDD/Agile/Scrum). Lives at `docs/faq.es.md` and `docs/faq.en.md`, linked from the README. Same content also rendered as a public section on `specleap.com/#faq` and `specleap.com/en/#faq`.
- **Branch protection workflow** — new `pre-push` git hook installed alongside `pre-commit` by `scripts/install-git-hooks.sh`. The hook blocks direct pushes to `main` and `stage`, redirecting contributors to the documented `feature → stage → main` flow. Bypassable with `--no-verify` for emergencies. Companion document `CONTRIBUTING.md` describes the workflow, commit conventions and hook setup.

### Notes

- The `.specleap/i18n/{es,en}.json` runtime catalog and the `t()` helper in `.specleap/i18n.sh` continue to be used for short labels and runtime messages. The bilingual files added in this release (`questions.<lang>.json`) follow the project's separate-files convention for larger localised content.
- The repository now has a `stage` branch as a permanent integration target; release tags are cut from `main` after a `stage → main` merge.
- This release is the first to ship the openspec CLI with English `--help` to npm. Local i18n catalog (`.specleap/i18n/`) was already in the v2.1.5 tarball.

## [2.1.6] - 2026-04-24

### Changed

- **`package.json` `bin` field** — switched from string form `"bin": "bin/specleap"` to object form `"bin": { "specleap": "bin/specleap" }`. This makes `npx specleap` work directly; previously the string form made npm link the executable as `specleap-framework` (the package name), forcing users to type `npx specleap-framework` — longer and counter-intuitive.
- **`package.json` `repository.url`** — added the `git+` prefix (`git+https://github.com/…`) to comply with the canonical [package.json spec](https://docs.npmjs.com/cli/configuring-npm/package-json#repository) and silence the normalization warning npm emitted on every publish.

### Fixed

- **`.gitignore`** — added `**/__pycache__/` and `**/*.pyc` so Python bytecode generated at runtime by the `ui-ux-pro-max` skill never sneaks into the repo. Companion to the `.npmignore` rule already shipping since v2.1.5 that keeps the tarball clean.
- **Removed tracked `.pyc` artifacts** from `.claude/skills/ui-ux-pro-max/scripts/__pycache__/` that had slipped into the repo before the gitignore rule existed.

### Notes

- No behavioral change to scripts, agents, commands, i18n or validation pipeline. Pure maintenance release to polish the packaging.

## [2.1.5] - 2026-04-24

### Fixed

- **npm tarball packaging** — the v2.1.4 tarball was missing critical files. Added `.specleap/i18n/**` (ES/EN translations used by `setup.sh` and runtime scripts), `.specleap/i18n.sh` (loader), `openspec/**` (optional formal CLI + templates + examples), and `CHANGELOG.md` to the `files` whitelist in `package.json`. Without `.specleap/i18n/`, the setup process would fall back to raw keys instead of localized messages. Without `openspec/**`, the documented formal CLI was unreachable from npm-installed copies.
- **`.npmignore`** — the overly broad `.specleap/` exclusion was replaced with a precise `.specleap/config.json` exclusion (only the actual secret). Added `**/__pycache__/` and `**/*.pyc` to prevent Python bytecode leaking into the published package.

### Notes

- Version 2.1.4 was tagged locally and pushed to the private GitHub repo but **never published to npm**, so no user ever received the incomplete tarball. The tag `v2.1.4` remains in GitHub as historical marker of the install-skills.sh fix commit, while `v2.1.5` is the first release published to the npm registry after the ownership transfer to ConceptualCreative.

## [2.1.4] - 2026-04-24

### Fixed

- **`scripts/install-skills.sh`** — replaced four occurrences of `((VAR++))` counter increments with `VAR=$((VAR + 1))` plain assignments. The post-increment form returns exit code 1 when the variable starts at 0 (arithmetic expression evaluates to 0 → bash interprets as false), which under `set -e` killed the installer after the first skill. Installation now completes all 34 skills as expected on bash 3.2+ (macOS default) and newer shells. Reported by a collaborator during smoke testing.

## [2.1.3] - 2026-04-23

### Changed

- **Repository ownership transferred** from `iapanderson/specleap-framework` to `ConceptualCreative/specleap-framework`. Old URLs keep working via GitHub 301 redirect.
- Migrated residual Jira / SCRUM references to Asana / `[proyecto]-XXX` across `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `codex.md`, `README.md`.
- Renamed "Slash Command Detection" section in `CLAUDE.md` to "Command Detection"; added a format note clarifying that commands are plain keywords with no `/` or `.` prefix to avoid collision with Claude Code native slash commands.
- Fixed 11 broken `.commandsXXX.md` paths in `.commands/inicio.md`.
- Updated `package.json` author metadata to `Styng Arias <developers@conceptualcreative.com>` and repository URLs to `ConceptualCreative/specleap-framework`.
- Renamed `generate-jira-structure.sh` reference to `generate-asana-structure.sh` in README tree diagram.
- Fixed TIER 2 comment in `scripts/install-skills.sh` (13 → 14 new skills).
- Redesigned `README.md` from 624 to 248 lines: removed all decorative emojis, added table of contents, consolidated validation pipeline into a single table, flat TIER 1 / TIER 2 skill tables.
- Fixed legacy i18n key typo: `scripts.creating_effort` → `scripts.creating_structure` in `en.json`.
- Updated Agent Skills count message in `setup.sh` (20 → 34).

### Added

#### Quality infrastructure

- **`.quality/` directory** with versioned `baselines/baseline.json` (coverage min 80 / target 90, complexity 10 per function, duplicates max 3%) and per-feature `evidence/[slug]/` folder for audit trail (gitignored).
- **`scripts/quality-baseline.sh`** — helper with three verbs: `init`, `snapshot`, `new-evidence [slug]`. Populates `repo_snapshot` (LOC, files, agents, commands, skills) and creates evidence stubs for each feature.
- **`scripts/quality-healing.sh`** — healing telemetry log with three verbs: `log`, `show`, `stats`. JSONL format per feature at `.quality/evidence/[slug]/healing.jsonl` with fields `ts`, `phase`, `severity`, `action`, `detail`, `file`.

#### Spec-guard hook

- **`.claude/hooks/spec-guard.sh`** — `PreToolUse` hook that blocks `Write` / `Edit` / `NotebookEdit` on files under `src/`, `app/`, `tests/`, `test/`, `lib/` when the current git branch is `main`, `stage` or `develop`. Fail-open on internal errors (no git, no jq, malformed stdin). Pedagogical block message suggests creating a `feature/[proyecto]-[ticket]-[desc]` branch and recalls the `feature → stage → main` flow.
- **`.claude/settings.json.template`** — hook wiring snippet that consumer projects merge into their own `.claude/settings.json`.

#### Compliance audit

- **`compliance` command** (`.commands/compliance.md`) — conversational trigger (`compliance`, `auditoria`, `audit`) that runs the self-audit and reports back.
- **`scripts/compliance-audit.sh`** — six-dimension self-audit with 0–100 score per dimension and averaged total:
  - *Version* — `package.json` version vs last git tag
  - *Skills* — `~/.skills/` count vs README / baseline counters
  - *i18n* — key parity between `es.json` and `en.json`
  - *Hooks* — `spec-guard.sh` present, shebang, executable, referenced in settings template
  - *Baseline* — `repo_snapshot` freshness (≤20% drift)
  - *Docs* — no legacy brand residuals in root `*.md`
- Writes per-run JSON detail to `.quality/evidence/compliance/audit-TS.json` (gitignored).

#### Internationalisation

- New namespaces `quality.baseline`, `quality.healing`, `quality.spec_guard`, `quality.compliance` in `.specleap/i18n/es.json` and `en.json`. All new runtime messages go through the existing `t "key.path"` helper.

### Removed

- **`scripts/setup-mcp.sh`** — obsolete Jira-MCP installer that contradicted the actual Asana-via-API flow handled by `setup.sh`. It claimed to install the Asana client but in practice prompted for Atlassian credentials and wrote a Jira MCP block into IDE config. Removed entirely; Asana is wired through `setup.sh` (direct API + token in `.env`), not through MCP.
- References to `openclaw` in `.commands/planificar.md` (legacy orchestration tool, no longer relevant to the public framework).
- Historical `CHANGELOG.md` entry no longer spells out the concrete personal emails that had been removed in v2.0; rewritten to "Legacy personal emails (removed)".

### Fixed

- **`SETUP.md`** Agent Skills section: updated from "20 Skills" to "34 profesionales" (20 TIER 1 + 14 TIER 2), pointed to `scripts/install-skills.sh` (the real installer), removed decorative emojis and the reference to `docs/SKILLS-REFERENCE.md` (deleted in v2.0).
- **`scripts/README.md`**: removed the obsolete `setup-mcp.sh` section and updated `install-skills.sh` description to 34 skills with full category breakdown.
- **`.gitignore`**: added `.specleap/config.json` (generated per-user by `setup.sh`, contains `github_user` and `asana_workspace`; must never be committed).

### Changed (deep cleanup pass)

A thorough pre-release audit revealed ~60 additional legacy references missed by the first cleanup pass. This round completes the migration:

- **`openspec/` CLI made tracker-agnostic** instead of Jira-coupled. The flag `--jira <key>` becomes `--ticket <id>`, variable `JIRA_KEY` becomes `TICKET_ID`, function `parse_jira_key()` becomes `parse_ticket_id()`. Regex updated from `[A-Z]+-[0-9]+` to `[a-zA-Z0-9-]+-[0-9]+` so it accepts the SpecLeap convention `app-tienda-23`, `channel-pms-107`, etc.
- Templates (`openspec/templates/proposal.md`, `tasks.md`, `.coderabbit.yaml`) now use `TICKET-XXX` as the neutral placeholder (git-friendly for branch names, no brackets).
- Examples in `openspec/examples/CHANGE-SAMPLE-001-user-authentication/` rewritten to use `app-tienda-NN` tickets instead of `PROJ-NNN`.
- `.agents/backend.md`, `.agents/frontend.md`, `.agents/producto.md` updated (13 Jira mentions across the three roles) to use Asana terminology and the real `ASANA_ACCESS_TOKEN` flow instead of a fictional "Jira MCP".
- `.cursorrules`, `.continuerules`, `.clinerules`, `.continue/rules/04-git-workflow.md`, `.github/copilot-instructions.md`, `.coderabbit.yaml` updated with Asana/ticket terminology and `app-tienda-23` example.
- `rules/git-workflow.md`, `rules/session-protocol.md` updated to mention Asana explicitly.
- `scripts/generate-contract.sh` YAML frontmatter block `jira: {...}` replaced with `asana: {...}` (workspace_id, section_count, task_count, synced_at).
- `scripts/lib/render-contrato.py` and `.continuerules` had residual "ArchSpec" branding in headers/titles; now "SpecLeap".
- `.quality/README.md` example `channel-pms-107` (a real internal project name leaked) replaced with neutral `api-backend-45`.

### Removed (deep cleanup pass)

- **`scripts/lib/jira-project-utils.sh`** (222 lines) — Jira project utilities. No caller imported it (`grep -r` returned 0 usages).
- **`scripts/test-cuestionario.sh`** (428 lines) — Jira-oriented test harness that referenced the already-renamed `generate-jira-structure.sh` (now `generate-asana-structure.sh`) and had no invocations anywhere in the repo.

### Fixed (deep cleanup pass)

- `.agents/producto.md` line 374: the word "Transiciona" was split across a blank line ("Transi\n\nciona"); restored as a single word.

---

## [2.1.1] - 2026-04-04

### Added
- **GDPR/DSGVO expert** skill (alirezarezvani/claude-skills) — GDPR compliance validation

### Changed
- Total skills: 33 → **34**

## [2.1.0] - 2026-04-04

### Added

#### 🎯 13 New Agent Skills (Total: 33)

**Design & Frontend (3):**
- `web-design-guidelines` (vercel-labs) — Vercel-style design patterns
- `vercel-composition-patterns` (vercel-labs) — React composition best practices
- `agent-browser` (vercel-labs) — Browser automation for testing

**Brainstorming & Documentation (2):**
- `brainstorming` (obra/superpowers) — Ideation techniques for spec refinement
- `pdf` (anthropics) — PDF analysis and manipulation

**DevOps & Infrastructure (2):**
- `terraform-engineer` (jeffallan) — Infrastructure as Code with Terraform
- `monitoring-expert` (jeffallan) — Performance profiling and monitoring

**Mobile Development (2):**
- `react-native-expert` (jeffallan) — React Native mobile development
- `flutter-expert` (jeffallan) — Flutter cross-platform development

**Documentation (1):**
- `code-documenter` (jeffallan) — Automatic code documentation generation

**Security (1):**
- `security-reviewer` (jeffallan) — Security review and pentesting patterns

**Testing Advanced (2):**
- `playwright-expert` (jeffallan) — E2E testing with Playwright
- `test-master` (jeffallan) — Advanced testing methodologies

**Total:** 20 → **33 skills** (+65% improvement)

### Changed
- Updated `scripts/install-skills.sh` header to reflect 33 total skills
- Updated `README.md` skills section with complete categorization
- Bumped version to `2.1.0` (minor version: new features added)

### Added - 2026-03-20

#### 🛡️ 3-Layer Validation System
- **Git hooks pre-commit** (`scripts/install-git-hooks.sh`) - Automatic validation in <5 seconds
  - Validates syntax, linters, formatters
  - Prevents CONTRATO.md modifications (immutable)
  - Prevents debug code (console.log, var_dump)
  - Rejects commits that fail validation
- **Full validation in `implementar` command** - Exhaustive checks (1-5 min)
  - Unit tests + integration tests
  - Validation vs CONTRATO.md and specs
  - Coverage >= 80% requirement
  - Only pushes if ALL tests pass
- **CodeRabbit integration** - Deep PR review (5-10 min)
  - Architecture, security, business logic validation
  - Automatic comments on PRs
  - Profile "assertive" configured
  - `.coderabbit.yaml` included

#### ❓ Help Command & Discoverability
- Created `.commands/ayuda.md` - Complete command reference
- Lists ALL available commands (conversational + CLI)
- Explains when to use each workflow
- Updated `CLAUDE.md` to auto-detect `ayuda`, `help`, `comandos`

#### 📚 Documentation & Clarity
- **OpenSpec vs Conversational workflows** - Clear distinction when to use each
  - Conversational: Small teams, rapid development
  - OpenSpec CLI: Enterprise, formal proposals, traceability
  - Both can coexist and complement each other
- **CodeRabbit clarification** - Works with BOTH workflows, not just OpenSpec
- **README.md** - Complete system explanation with 3-layer validation
- **SETUP.md** - Git hooks installation as Step 4
- **scripts/README.md** - Scripts reference guide

### Changed - 2026-03-20

#### URLs & Branding
- All repository URLs updated: `specleap` → `specleap-framework`
- "Conceptual Creative" → "SpecLeap Community/Contributors"
- "Pamela Anderson" → "SpecLeap Contributor" (in examples)
- Package.json repository URLs corrected

#### Documentation Links
- Fixed broken `docs/` references (directory was removed)
- Updated to point to actual existing files
- `.commands/`, `openspec/`, `.agents/` references

### Removed - 2026-03-20

#### Security & Privacy
- `openspec/cli/jira.sh` - Private Jira credentials
- `docs/` directory (7 files, 2,630 lines) - Old ArchSpec landing with private references
- All mentions of:
  - conceptualcreative.com domains
  - Private Atlassian URLs
  - Legacy personal emails (removed)
  - Internal project names

### Fixed - 2026-03-20

- Survey count corrected: 58 questions (not 56)
- Git ignore: Added `kofi-images/` to prevent accidental push

---

## Statistics - 2026-03-20

**Files changed:** 24  
**Lines added:** ~2,500  
**Lines removed:** ~2,650 (mostly private data cleanup)  
**Commits:** 4

**Key improvements:**
- ✅ 100% private data removed
- ✅ Quality validation system implemented
- ✅ Complete discoverability (help command)
- ✅ Clear workflow distinction (conversational vs CLI)
- ✅ Professional documentation

---

## Migration Guide

### For Existing Users

#### To enable git hooks:
```bash
cd your-project
bash scripts/install-git-hooks.sh
```

#### To discover all commands:
In chat with your AI assistant:
```
ayuda
```

Or in terminal:
```bash
openspec --help
```

#### To understand when to use CLI vs conversational:
- **Small team (1-3 devs):** Use conversational commands in chat
- **Large team (4+ devs):** Use OpenSpec CLI for formal proposals
- **Both:** Use conversational for daily work, CLI for big changes

---

## Coming Soon

- [ ] Integration tests for git hooks
- [ ] CI/CD templates
- [ ] More Agent Skills (TIER 2)
- [ ] Docker support
- [ ] VS Code extension

---

**Full details:** See individual commit messages and PR descriptions.
