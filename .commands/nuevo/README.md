# Sistema de Cuestionario Adaptativo — SpecLeap

Este directorio contiene el sistema de preguntas adaptativas para generar CONTRATOs completos y personalizados según el tipo de proyecto.

## 📁 Estructura

```
.commands/nuevo/
├── README.md                      ← Este archivo
├── questions-base.yaml            ← Preguntas obligatorias (todos los proyectos)
├── questions-ecommerce.yaml       ← Preguntas específicas e-commerce
├── questions-saas.yaml            ← Preguntas específicas SaaS
├── questions-api.yaml             ← Preguntas específicas API/Backend
├── questions-cms.yaml             ← Preguntas específicas CMS/Blog
├── questions-auth.yaml            ← Preguntas específicas autenticación
├── questions-admin.yaml           ← Preguntas específicas panel admin
├── questions-storage.yaml         ← Preguntas específicas almacenamiento
├── questions-oauth.yaml           ← Preguntas específicas OAuth
├── questions-aws.yaml             ← Preguntas específicas AWS
├── responses-example.yaml         ← Ejemplo de archivo de respuestas
└── responses-schema.json          ← JSON Schema para validación
```

## 🔄 Flujo de Funcionamiento

### 1. Inicio del Cuestionario

```bash
# Usuario ejecuta
/nuevo

# Claude carga questions-base.yaml
# Realiza 18-20 preguntas obligatorias
```

### 2. Detección de Tipo de Proyecto

```bash
# Analiza respuestas con detect-project-type.sh
./scripts/detect-project-type.sh responses.yaml

# Output: ecommerce auth admin storage
```

### 3. Carga de Preguntas Condicionales

```bash
# Según tipos detectados, carga archivos adicionales:
# - questions-ecommerce.yaml
# - questions-auth.yaml
# - questions-admin.yaml
# - questions-storage.yaml

# Total: 18 base + 30-40 condicionales = 48-58 preguntas
```

### 4. Generación del CONTRATO

```bash
# Genera CONTRATO.md con frontmatter YAML
./scripts/generate-contract.sh responses.yaml

# Output: proyectos/<nombre>/CONTRATO.md
```

## 📋 Formato questions-*.yaml

```yaml
version: "1.0"
category: <nombre>
description: "Descripción del conjunto de preguntas"

questions:
  - id: unique_id
    section: <identity|stack|features|deployment|etc>
    text: "¿Pregunta?"
    type: <text|textarea|select|boolean|multiline>
    required: true|false
    options:                    # Solo para type=select
      - value: valor
        label: "Etiqueta"
        triggers: [questions-oauth]  # Activa otros archivos
    follow_up:                  # Pregunta de seguimiento
      - condition: "valor"
        question: "¿Pregunta adicional?"
        type: text
    depends_on:                 # Solo mostrar si...
      - other_question_id: [valor1, valor2]
    validation: "regex"         # Validación opcional
    help: "Texto de ayuda"
    default: valor_por_defecto
```

## 🎯 Tipos de Pregunta

### `text`
Respuesta corta (1 línea)

```yaml
- id: project_name
  type: text
  validation: "^[a-z0-9-]+$"
```

### `textarea`
Respuesta larga (múltiples líneas)

```yaml
- id: project_objective
  type: textarea
```

### `select`
Opción única de una lista

```yaml
- id: backend_framework
  type: select
  options:
    - value: laravel
      label: "Laravel (PHP)"
    - value: nodejs
      label: "Node.js"
```

### `boolean`
Sí/No

```yaml
- id: needs_ssl
  type: boolean
  default: true
```

### `multiline`
Lista de items (uno por línea)

```yaml
- id: core_features
  type: multiline
  help: |
    Una funcionalidad por línea:
    - Login de usuarios
    - CRUD de productos
```

## 🔍 Detectores de Tipo

El sistema analiza las respuestas en busca de patrones (keywords) para determinar qué preguntas condicionales cargar.

### Patrones Detectados

| Tipo | Keywords | Archivo Cargado |
|------|----------|-----------------|
| **E-commerce** | pago, compra, carrito, stripe, paypal, producto | `questions-ecommerce.yaml` |
| **SaaS** | suscripción, plan, billing, mensualidad, trial | `questions-saas.yaml` |
| **API** | api, endpoint, rest, graphql, webhook | `questions-api.yaml` |
| **CMS** | blog, post, artículo, contenido, cms | `questions-cms.yaml` |
| **Realtime** | chat, mensaje, notificación, websocket | `questions-realtime.yaml` |
| **Auth** | login, usuario, registro, perfil | `questions-auth.yaml` |

### Configuración en questions-base.yaml

```yaml
analyzers:
  detect_project_type:
    triggers:
      - keywords: [pago, compra, carrito]
        activate: questions-ecommerce
      - keywords: [blog, post, artículo]
        activate: questions-cms
```

## 📝 Archivo de Respuestas (responses.yaml)

Las respuestas se guardan en formato YAML plano:

```yaml
# Respuestas básicas
project_name: mi-proyecto
project_objective: Descripción del proyecto
backend_framework: laravel
frontend_framework: react

# Listas
core_features:
  - Funcionalidad 1
  - Funcionalidad 2

# Booleanos
use_typescript: true
needs_ssl: true

# Opciones
target_audience: public
visual_style: modern
```

## 🏗️ Generación del CONTRATO

El script `generate-contract.sh`:

1. Lee `responses.yaml`
2. Carga template `proyectos/_template/CONTRATO.md`
3. Reemplaza placeholders con valores reales
4. Genera frontmatter YAML con metadata
5. Crea archivos `context/*.md`
6. Guarda todo en `proyectos/<nombre>/`

### Frontmatter Generado

```yaml
---
project:
  name: "mi-proyecto"
  display_name: "Mi Proyecto"
  created_at: "2026-02-24"
  status: draft
  version: "1.0"

stack:
  backend:
    framework: "laravel"
  frontend:
    framework: "react"
  database:
    engine: "postgresql"

features:
  core: [...]
  auth:
    enabled: true
    methods: [email_password]
---
```

## 🧪 Testing

### Probar el Sistema Completo

```bash
# 1. Analizar respuestas de ejemplo
cd /path/to/specleap
./scripts/detect-project-type.sh .commands/nuevo/responses-example.yaml

# Output esperado:
# ✓ Detectado: Autenticación de usuarios
# ✓ Detectado: Panel de administración
# ✓ Detectado: Almacenamiento en la nube
# ✓ Detectado: Stack PHP/Laravel
# ✓ Detectado: Frontend React

# 2. Generar CONTRATO
./scripts/generate-contract.sh .commands/nuevo/responses-example.yaml

# Output esperado:
# ✅ CONTRATO.md generado exitosamente
# 📁 Archivos creados:
#   - proyectos/task-manager/CONTRATO.md
#   - proyectos/task-manager/context/brief.md
#   - ...
```

### Validar CONTRATO Generado

```bash
# Ver frontmatter
head -n 100 proyectos/task-manager/CONTRATO.md

# Ver estructura completa
cat proyectos/task-manager/CONTRATO.md
```

## 🔧 Próximos Pasos (Fase 2)

- [ ] Crear archivos `questions-*.yaml` para cada tipo
- [ ] Implementar orquestador `ask-questions.sh`
- [ ] Integrar con comando `/nuevo` en Claude
- [ ] Testing con proyecto real

## 🔧 Próximos Pasos (Fase 3)

- [ ] Parser CONTRATO → Asana (`parse-contract-to-asana.sh`)
- [ ] Integración con `planificar`
- [ ] Sincronización bidireccional Asana ↔ CONTRATO

## 📚 Referencias

- Template CONTRATO: `proyectos/_template/CONTRATO.md`
- Script detector: `scripts/detect-project-type.sh`
- Script generador: `scripts/generate-contract.sh`
- Ejemplo respuestas: `.commands/nuevo/responses-example.yaml`
