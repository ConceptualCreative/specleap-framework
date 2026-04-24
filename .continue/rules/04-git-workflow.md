---
name: Git Workflow & Commits
globs: ["**/.git/**", "**/CHANGELOG*", "**/COMMIT*"]
alwaysApply: false
description: Formato de commits y flujo de Git
---

# Git Workflow

## Formato de Commit

```
tipo(alcance): descripción corta en español

## Qué se hizo
- Descripción detallada del cambio

## Por qué
- Justificación del cambio

## Archivos modificados
- ruta/archivo.ts — qué se cambió

## Tests
- Tests añadidos/modificados

## Refs
- Asana: [proyecto]-XXX
- Spec: openspec/specs/functional/FXXX-nombre.spec.md
```

## Tipos de Commit

| Tipo | Uso |
|------|-----|
| `feat` | Nueva funcionalidad |
| `fix` | Corrección de bug |
| `refactor` | Reestructuración sin cambio funcional |
| `docs` | Documentación |
| `test` | Tests |
| `chore` | Mantenimiento, dependencias |
| `style` | Formato, linting |
| `perf` | Mejoras de rendimiento |

## Branch Naming

```
tipo/[proyecto]-XXX-descripcion-corta
```

Ejemplos:
- `feat/app-tienda-23-user-authentication`
- `fix/app-tienda-24-login-redirect`
- `refactor/app-tienda-25-cleanup-utils`

## Reglas

1. **Un commit = un cambio lógico** (no mezclar features)
2. **Mensajes en español** (tipo en inglés)
3. **Nunca push directo a main** — siempre PR
4. **Squash merge** para historial limpio
5. **Code review obligatorio** antes de merge

## Testing Report en PR

Cada PR debe incluir:

```markdown
## Testing Report

| Suite | Tests | Passed | Failed | Coverage |
|-------|-------|--------|--------|----------|
| Unit | XX | XX | 0 | XX% |
| Integration | XX | XX | 0 | N/A |

### Review Status
- [ ] Code review aprobado
- [ ] Tests pasan
- [ ] Coverage mínimo alcanzado
```
