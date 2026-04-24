# OpenSpec CLI — Spec-Driven Development

CLI para implementar el workflow completo de SpecLeap.

## Instalación

```bash
# Desde la raíz del proyecto
export PATH="$PATH:$(pwd)/openspec/cli"

# O crear symlink en /usr/local/bin
ln -s $(pwd)/openspec/cli/openspec /usr/local/bin/openspec
```

## Comandos

| Comando | Descripción |
|---------|-------------|
| `openspec enrich` | Refinar user story con AI |
| `openspec new` | Crear nueva propuesta de cambio |
| `openspec ff` | Fast-forward: generar propuesta completa |
| `openspec apply` | Implementar propuesta aprobada |
| `openspec verify` | Verificar tests y specs |
| `openspec code-review` | Solicitar review de CodeRabbit |
| `openspec archive` | Archivar propuesta completada |
| `openspec report` | Generar testing report |
| `openspec status` | Ver estado de propuestas activas |

**📖 Referencia completa:** Ver [COMMAND_REFERENCE.md](./COMMAND_REFERENCE.md) para documentación detallada de cada comando con todas las opciones, ejemplos, y exit codes.

## Ciclo Completo de Desarrollo

```bash
# 1. Refinar user story
openspec enrich "Como usuario quiero hacer login" --output us-refined.md

# 2. Crear propuesta
openspec new --auto "Implementar autenticación JWT" --from us-refined.md --ticket app-tienda-23

# 3. (Opcional) Generar propuesta completa con AI
openspec ff CHANGE-001

# 4. Revisar y ajustar manualmente proposal.md, design.md, tasks.md

# 5. Aplicar propuesta (crear branch, scaffolding)
openspec apply CHANGE-001

# 6. Implementar código (manual o con AI assistant)
# ... usar Continue.dev, Copilot, Cursor según specs ...

# 7. Verificar tests y specs
openspec verify CHANGE-001

# 8. Solicitar code review
openspec code-review CHANGE-001 --create-pr

# 9. (AI review automático por CodeRabbit)
# ... revisar comentarios y aplicar cambios ...

# 10. Archivar al completar
openspec archive CHANGE-001
```

## Ejemplos de Uso

### Crear propuesta rápida con AI

```bash
# Generar todo automáticamente
openspec enrich "Sistema de notificaciones push" | \
openspec new --auto --from - --ticket app-tienda-24
openspec ff CHANGE-002
openspec apply CHANGE-002
```

### Ver estado de propuestas

```bash
openspec status
openspec status --all
openspec status --state in_progress --format json
```

### Generar testing report

```bash
openspec report CHANGE-001
openspec report --format json --output report.json
```

## Prerequisitos

- **Git:** Para branch management
- **AI CLI:** oracle, gh copilot, o ai-cli (para `/enrich` y `/ff`)
- **GitHub CLI (gh):** Para crear PRs y verificar merges
- **Test frameworks:** PHPUnit, Jest, etc. (según proyecto)

## Configuración

Edita `openspec/config.yaml` para personalizar:

- Estados de specs y changes
- Integración con ticket tracker (Asana recomendado en SpecLeap; el CLI es agnóstico al backend)
- Umbrales de testing
- Formato de IDs

## Integración con AI Assistants

Los scripts CLI están diseñados para trabajar con:

- **Continue.dev:** Lee `.continue/rules/*.md` para seguir metodología
- **Copilot:** Usa `codex.md`
- **Cursor:** Sigue `.cursorrules`
- **Cline:** Usa `.clinerules`
- **Claude Code:** Sigue `AGENTS.md`

Todos los AI assistants tienen acceso a las specs en `openspec/specs/` y las propuestas en `openspec/changes/`.

## Testing Report Automation

El comando `openspec report` detecta automáticamente:

- **PHPUnit:** `phpunit.xml` o `phpunit.xml.dist`
- **Jest:** `package.json` con jest configurado
- **Otros:** Puedes extender `report.sh`

## Code Review con CodeRabbit

CodeRabbit se activa automáticamente en PRs si está configurado en el repo.

Configuración en `.coderabbit.yaml`:

```yaml
language: es
early_access: true
enable_free_tier: true
reviews:
  profile: assertive
  request_changes_workflow: true
  high_level_summary: true
  poem: false
  collapse_walkthrough: false
```

## Troubleshooting

### "Comando no encontrado: openspec"

Asegúrate de que `openspec/cli` esté en tu `$PATH`:

```bash
export PATH="$PATH:$(pwd)/openspec/cli"
```

### "No se encontró CLI de AI"

Instala uno de estos:

- **oracle:** https://github.com/djmango/oracle
- **gh copilot:** `gh extension install github/gh-copilot`
- **ai-cli:** https://ai-cli.ai

### "PHPUnit/Jest no encontrado"

Instala las dependencias del proyecto:

```bash
# PHP
composer install

# Node
npm install
```

## Contribuir

Para añadir nuevos comandos o mejorar existentes:

1. Crear `openspec/cli/mi-comando.sh`
2. Seguir estructura de scripts existentes
3. Usar funciones de `common.sh`
4. Documentar en esta README

## Referencias

- Metodología: `../.continue/rules/01-sdd-methodology.md`
- Templates: `../templates/`
- Config: `../config.yaml`
- Docs: `../README.md`
