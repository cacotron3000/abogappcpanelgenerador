# Implementación Opción C: Generador renderizado en la misma app con base de datos propia

## Objetivo

Integrar el generador **sin iframe**, renderizado dentro de la aplicación principal (mismo frontend), manteniendo una **base de datos aislada del generador** para preservar límites de dominio, seguridad y gobernanza de datos.

## Arquitectura objetivo

- **Frontend único (App principal)**
  - Nueva ruta interna: `/generador`.
  - Componentes nativos de la app (mismo layout, auth, tema y navegación).
- **Backend/BFF de la app**
  - Expone endpoints para UI y orquesta llamadas al servicio del generador.
  - Aplica authN/authZ, rate limiting y trazabilidad.
- **Servicio de dominio del generador**
  - Responsable exclusivo de reglas del generador.
  - API interna (REST) consumida por el BFF.
- **Base de datos propia del generador**
  - Conexión y credenciales separadas de la DB principal.
  - Esquema propio y migraciones independientes.

## Fronteras de datos

1. La app principal **no escribe directamente** en la DB del generador.
2. Toda escritura/lectura del dominio generador pasa por `generator-service`.
3. La correlación con usuarios de la app se hace con `tenant_id` y `created_by_user_id` en tablas del generador.

## Flujo funcional

1. Usuario autenticado entra a `/generador`.
2. Frontend pide configuración y catálogos al BFF (`/api/generador/*`).
3. BFF valida permisos y llama a `generator-service`.
4. `generator-service` persiste/consulta en `generator_db`.
5. BFF devuelve DTOs para pintar UI en la app principal.

## Contrato mínimo (BFF)

- `GET /api/generador/templates`
- `POST /api/generador/documentos`
- `GET /api/generador/documentos/{id}`
- `POST /api/generador/documentos/{id}/render`

## Seguridad

- JWT de la app validado en BFF.
- BFF propaga claims mínimas al servicio generador (`user_id`, `tenant_id`, `roles`).
- `generator_db` con usuario propio (`generator_rw`) y privilegios limitados.
- Auditoría obligatoria de acciones de generación/descarga.

## Observabilidad

- `x-correlation-id` obligatorio en frontend → BFF → generator-service.
- Métricas mínimas:
  - latencia de render,
  - tasa de errores por endpoint,
  - volumen de documentos generados por tenant.

## Plan de implementación por fases

### Fase 1 — Habilitación backend

- Crear `generator-service` y contrato REST interno.
- Crear DB propia del generador y migración inicial.
- Publicar endpoints BFF `/api/generador/*`.

### Fase 2 — UI integrada

- Crear vista `/generador` en la app principal.
- Reutilizar sistema de diseño y sesión actual.
- Reemplazar llamadas iframe/postMessage por llamadas HTTP al BFF.

### Fase 3 — Endurecimiento

- Hardening de permisos por rol.
- Trazas distribuidas y dashboards.
- Pruebas de carga para render.

## Criterios de aceptación

1. No existe `iframe` para el generador en producción.
2. El usuario navega y genera documentos dentro de la misma app.
3. Los datos del generador residen sólo en `generator_db`.
4. Auditoría y correlación de trazas activas de punta a punta.
