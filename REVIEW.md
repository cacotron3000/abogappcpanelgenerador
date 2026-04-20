# Revisión general de la app e integración del generador

## Estado actual del repositorio

Al revisar el repositorio en la rama actual, no hay código fuente de la aplicación para auditar (frontend, backend, config o infraestructura). El árbol versionado contiene únicamente un archivo marcador (`.gitkeep`).

Esto impide validar en este momento:

- Flujos funcionales (login, navegación, guardado, etc.).
- Rendimiento (carga inicial, TTI, uso de red).
- Seguridad (headers, CSP, XSS, auth entre módulos).
- Calidad de integración actual del generador (si hoy usa iframe, cómo está aislado y qué contratos expone).

## Evaluación: alternativas mejores que `iframe` para integrar el generador

Sí, en general existen enfoques mejores que `iframe`, dependiendo del nivel de desacoplamiento que necesiten.

### Opción A (recomendada): Microfrontend por módulo federado

- **Cómo**: exponer el generador como microfrontend (ej. Module Federation) y cargarlo en runtime como un módulo JS.
- **Ventajas**:
  - Integración nativa de UI/UX (routing, theming, i18n compartidos).
  - Comunicación directa por contratos tipados (props/event bus/store), sin `postMessage`.
  - Mejor observabilidad y analítica unificada.
- **Riesgos**:
  - Acoplamiento de versiones (React/Vue/libs compartidas).
  - Requiere gobierno técnico (versionado semántico y contratos estables).

### Opción B: Web Component (Custom Element)

- **Cómo**: empaquetar el generador como `<app-generador></app-generador>`.
- **Ventajas**:
  - Menor acoplamiento de framework (host y generador pueden usar stacks distintos).
  - API explícita por atributos/propiedades/eventos.
  - Embebible en varias apps con mínimo esfuerzo.
- **Riesgos**:
  - Necesita diseño cuidadoso de estilos (Shadow DOM, tokens de diseño).
  - Estado global compartido no es tan directo.

### Opción C: BFF + renderización en misma app (sin microfrontend)

- **Cómo**: mover la lógica del generador a APIs/BFF y construir la UI directamente dentro de la app principal.
- **Ventajas**:
  - Máxima consistencia de UX y seguridad.
  - Menor complejidad operativa en runtime.
- **Riesgos**:
  - Menor independencia de despliegue del equipo del generador.

### Cuándo mantener `iframe`

Mantener `iframe` puede seguir siendo correcto si existe al menos una de estas condiciones:

- Aislamiento fuerte por cumplimiento/legal/seguridad.
- Integración rápida temporal mientras se migra.
- Equipos totalmente independientes con ciclos de release incompatibles.

## Recomendación práctica

Si su objetivo es mejorar experiencia y mantenimiento sin perder desacoplamiento, la ruta con mejor balance suele ser:

1. **Corto plazo**: mantener `iframe` pero estandarizar contrato `postMessage` (eventos, errores, timeouts, versionado).
2. **Mediano plazo**: migrar a **Web Component** si quieren independencia tecnológica.
3. **Escala enterprise**: evolucionar a **microfrontend federado** si comparten stack y necesitan integración profunda.

## Siguiente paso para una auditoría real

Para hacer una revisión completa y accionable del funcionamiento general necesito que este repo incluya, como mínimo:

- Código frontend/backend.
- Configuración de despliegue (Docker, CI, env vars).
- Implementación actual del generador y su integración (hoy `iframe`).

Con eso puedo devolver:

- Mapa de arquitectura actual.
- Lista priorizada de riesgos.
- Plan de migración del `iframe` a alternativa recomendada con esfuerzo estimado.

## Actualización aplicada: Opción C

Se aterrizó la Opción C con artefactos de implementación en este repositorio:

- Plan técnico y arquitectura objetivo: `docs/generator-option-c-plan.md`.
- Contrato API interno del generador: `contracts/generator-api.openapi.yaml`.
- Infra de DB separada para app y generador: `infra/docker-compose.yml`.
- Esquema inicial de `generator_db`: `infra/sql/generator_init.sql`.
