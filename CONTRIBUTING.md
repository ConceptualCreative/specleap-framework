# Contributing to SpecLeap Framework

Thanks for your interest in contributing to SpecLeap. This document describes the branch flow, how to set up local guardrails, and what to expect during review.

## Branch flow

SpecLeap uses a three-tier branch model:

```
feature/<project>-<ticket>-<short-description>
        │
        ▼
      stage              ← integration / pre-release
        │
        ▼
       main              ← released / production
```

### Rules

- **`main`** is the production branch. Every commit on `main` is reachable via a published tag (`v2.x.y`) and the npm registry.
- **`stage`** is the integration branch. Features land here first, get smoke tested together, and only then graduate to `main` as a release.
- **`feature/*`** is where all work happens. One feature branch per ticket. Branch names follow the `feature/<project>-<ticket>-<desc>` pattern, e.g. `feature/app-tienda-23-cart-ui`.

### Direct pushes to `main` and `stage` are forbidden

All changes must arrive via pull request:

- `feature/*` → `stage` (PR, fast-forward when possible)
- `stage` → `main` (PR at release time, fast-forward when possible)

## Local guardrails (recommended for every clone)

After cloning the repo, install the local git hooks:

```bash
bash scripts/install-git-hooks.sh
```

This installs two hooks under `.git/hooks/`:

- **`pre-commit`** — runs on every `git commit` to validate syntax (PHP, JS/TS), linters (ESLint, PHPStan), formatters (Prettier, PHP-CS-Fixer), CONTRACT immutability, and presence of debug code (`console.log`, `var_dump`, `dd(`).
- **`pre-push`** — blocks pushes directly to `main` or `stage` from a local clone. Forces you to use a feature branch + pull request.

The hooks live in your local `.git/hooks/` (not committed to the repo). Each contributor has to install them once after cloning.

### Bypassing the hooks (NOT recommended)

If you really need to bypass:

```bash
git commit --no-verify -m "..."   # skip pre-commit
git push --no-verify              # skip pre-push (and direct-push protection)
```

Use only for emergencies. The hooks exist to catch mistakes before they reach the shared repo.

## Server-side protection

GitHub-side branch protection (Rulesets) is reserved for when the repo moves to GitHub Pro or becomes public. Until then the local hooks above plus discipline from each contributor are what we have.

If you have admin access on GitHub and need to bypass the hook, you can still push (after `--no-verify`), but you'll be flagged in `git log` as the source of any direct-push incident on `main`.

## Workflow example

```bash
# 1. Create feature branch from latest stage
git checkout stage
git pull origin stage
git checkout -b feature/app-tienda-23-cart-ui

# 2. Work, commit, push your feature branch
git add .
git commit -m "feat(cart): add quantity selector"
git push -u origin feature/app-tienda-23-cart-ui

# 3. Open PR feature/* → stage on GitHub
# 4. Once merged, feature branch can be deleted
git checkout stage
git pull origin stage
git branch -d feature/app-tienda-23-cart-ui

# 5. At release time, PR stage → main, then tag
```

## Commit messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): short imperative summary

Optional longer body explaining the why and any non-obvious constraints.

Optional footer with refs (Closes #123) or breaking-change notice.
```

Types we use most: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`.

## Code review

- All PRs go through CodeRabbit (`.coderabbit.yaml` is configured) before human review.
- Specs and CONTRACT compliance are verified by `scripts/compliance-audit.sh`.

## Questions

Open an issue in the GitHub repo or reach out at `info@specleap.com`.
