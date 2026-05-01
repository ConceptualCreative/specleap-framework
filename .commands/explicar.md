# Comando: explicar

**Sintaxis:** 
- `explicar [concepto]`
- `explicar @archivo.php`
- `explicar esta función`

**Objetivo:** Explicar código, arquitectura o decisiones técnicas de forma clara.

**Motor:** Usa lectura directa de archivos + análisis contextual.

---

## Flujo

### 1. Identificar Qué Explicar

Analiza el argumento:

- **Concepto general** — "cómo funciona el carrito"
- **Archivo específico** — "@ProductController.php"
- **Función/método** — "esta función" (contexto previo)
- **Arquitectura** — "por qué usamos services"
- **Decisión técnica** — "por qué PostgreSQL"

---

### 2. Leer Contexto Relevante

**Para Conceptos/Arquitectura:**
```bash
cat proyectos/[proyecto]/CONTRATO.md
cat proyectos/[proyecto]/context/architecture.md
cat proyectos/[proyecto]/context/tech-stack.md
cat proyectos/[proyecto]/context/decisions.md
```

**Para Código Específico:**
```bash
# Encontrar archivo
find [directorio-proyecto] -name "[archivo]"

# Leer archivo
cat [ruta-archivo]

# Ver imports/dependencias
grep -E "^use |^import " [ruta-archivo]
```

**Para Decisiones Técnicas:**
```bash
# Buscar en decisions.md
grep -A 10 "[tecnología/decisión]" context/decisions.md
```

---

### 3. Generar Explicación

**Estructura:**

```markdown
# Explicación: [Concepto/Archivo/Función]

## Resumen
[1-2 párrafos: qué es y para qué sirve]

## ¿Cómo Funciona?
[Explicación paso a paso]

## Código Relevante
[Fragmentos de código con explicación]

## Relaciones
[Qué otros componentes están relacionados]

## Decisiones Técnicas
[Por qué se hizo de esta manera]

## Referencias
[Enlaces a docs, CONTRATO.md, context/]
```

---

### 4. Ejemplo Completo

```
Usuario: "explicar cómo funciona el sistema de autenticación"

IA:
🔍 Leyendo contexto del proyecto...

cat proyectos/task-manager/CONTRATO.md:
  Sistema de Usuarios → Autenticación: Laravel Sanctum (SPA)

cat proyectos/task-manager/context/tech-stack.md:
  Autenticación: Laravel Sanctum 4.x
  Frontend: React 18 con axios

cat proyectos/task-manager/context/architecture.md:
  API stateless, tokens en localStorage

---

# Explicación: Sistema de Autenticación

## Resumen

El proyecto usa **Laravel Sanctum** para autenticación SPA (Single Page Application).

Es un sistema **stateless** basado en tokens: el frontend (React) envía credenciales al backend (Laravel), recibe un token, y lo incluye en cada request posterior.

## ¿Cómo Funciona?

### 1. Login (Frontend → Backend)

Usuario ingresa email + password:

```javascript
// LoginForm.tsx
const response = await axios.post('/api/login', {
  email: 'user@example.com',
  password: 'secreto123'
});

const token = response.data.token;
localStorage.setItem('auth_token', token);
```

### 2. Backend Valida Credenciales

```php
// AuthController.php
public function login(Request $request)
{
    $credentials = $request->validate([
        'email' => 'required|email',
        'password' => 'required',
    ]);

    if (!Auth::attempt($credentials)) {
        return response()->json(['error' => 'Invalid credentials'], 401);
    }

    $user = Auth::user();
    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json(['token' => $token]);
}
```

### 3. Requests Autenticados

Frontend incluye el token en cada request:

```javascript
axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;

// Ahora todas las requests llevan el token
const products = await axios.get('/api/products');
```

### 4. Backend Verifica Token

Laravel Sanctum valida automáticamente el token:

```php
// routes/api.php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/products', [ProductController::class, 'index']);
    Route::post('/products', [ProductController::class, 'store']);
});
```

## Relaciones

- **Frontend:** LoginForm.tsx, ProtectedRoute.tsx, axiosConfig.js
- **Backend:** AuthController.php, User model, Sanctum middleware
- **Base de Datos:** personal_access_tokens table (guarda tokens)

## Decisiones Técnicas

**¿Por qué Sanctum y no JWT/Passport?**

Referencia: context/decisions.md línea 45

**Decisión:** Laravel Sanctum

**Razones:**
1. Más simple que Passport
2. Integrado nativamente en Laravel
3. Perfecto para SPAs
4. No requiere OAuth server

**Alternativas evaluadas:**
- JWT (tymon/jwt-auth) — Más complejo
- Laravel Passport — Overkill para SPA simple

## Referencias

- CONTRATO.md: "Sistema de Usuarios" sección
- context/tech-stack.md: Laravel Sanctum 4.x
- context/decisions.md: Línea 45-60
- Docs oficiales: https://laravel.com/docs/11.x/sanctum
```

---

## Comandos/Herramientas Usados

| Comando | Propósito |
|---------|-----------|
| `cat proyectos/[proyecto]/CONTRATO.md` | Leer contrato |
| `cat context/*.md` | Leer contexto |
| `find . -name "[archivo]"` | Buscar archivo |
| `grep -A 10 "[patrón]" [archivo]` | Buscar en archivo |
| `cat [archivo]` | Leer código |

---

## Reglas

1. **Siempre leer contexto** antes de explicar
2. **Ejemplos de código** cuando ayude
3. **Referencias** a archivos/líneas específicas
4. **No inventar** — Si no hay info, decir "No lo sé"
5. **Claridad** sobre precisión técnica excesiva

---

## Próximo Comando

- `refinar SCRUM-XX` — Refinar user story para implementación
