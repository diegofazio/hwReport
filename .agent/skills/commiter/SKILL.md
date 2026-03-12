---
name: commiter
description: Crea commits estructurados usando Conventional Commits, con un título breve y una descripción detallada de los cambios.
---

# Skill: Generador de Commits Estructurados

## Cuándo usar este skill
- Cuando el usuario solicita hacer un commit de los cambios actuales al repositorio.
- Como paso final o punto de control después de completada una tarea importante o refactorización.

## Flujo de Trabajo (Workflow)

1. **Revisar Estado**: Usa el comando `git status` para ver qué archivos han cambiado.
2. **Revisar Cambios**: Usa `git diff` (y `git diff --cached`) para entender la naturaleza exacta de los cambios y el impacto.
3. **Preparar Cambios**: Usa `git add <archivos>` para añadir los archivos al área de stating, o `git add .` según corresponda.
4. **Generar Changelog (Automático)**: antes del commit, auto-ejecuta obligatoriamente el skill `generador-changelog` para que el commit se registre en `CHANGELOG.md` e incluye ese cambio en un sub-commit interno.
5. **Actualizar README (Automático)**:
ejecuta la skill `generador-readme` verificar que el cambio realizado se refleja en el archivo `README.md`. SIEMPRE Y CUANDO el cambio realizado sea relevante para el usuario final.
6. **Crear Commit**: Ejecuta el comando de estructuración del mensaje `git commit` (usualmente `git commit -m "Título" -m "Cuerpo descriptivo"`).
7. **Ejecutar Push (Opcional)**: Si el usuario solicitó hacer "push" (o "subir los cambios"), ejecuta `git push` siempre **después** de haber generado exitosamente el changelog.

## Formato del Commit (Conventional Commits)

El mensaje del commit debe dividirse **obligatoriamente** en dos partes: un **Título** (Header) y un **Cuerpo** (Body) extenso y bien argumentado.

```text
<tipo>[scope opcional]: <título corto estricto>

<cuerpo extenso explicando contexto, qué y por qué>
```

### 1. Reglas para el Título (Header)
- **El título debe estar siempre en español**.
- **Longitud máxima:** 50 caracteres (estricto).
- **Formato:** `<tipo>: <descripción en imperativo>`. No debe terminar en punto.
- Usar minúsculas en el `tipo` y `scope`.
- La descripción de acción debe usar el modo imperativo verbal de idioma inglés (ej. "add", "fix", "update", en vez de "added", "fixed" o "updates").
- **Tipos permitidos:**
  - `feat`: Una nueva característica o funcionalidad.
  - `fix`: Solución de un bug o error de código.
  - `docs`: Cambios en la documentación  (`README.md`, `CONTEXT.md` etc.).
  - `style`: Cambios de formato visual que no afectan el funcionamiento real (espaciado, comillas).
  - `refactor`: Cambio de código que no corrige un bug ni añade funcionalidad pero mejora el diseño.
  - `perf`: Cambio de código enfocado a la mejora del rendimiento general.
  - `test`: Añadir, actualizar o corregir pruebas y tests.
  - `build`: Cambios que afectan dependencias estáticas y el build principal.
  - `ci`: Cambios en la integración continua o scripts de automatización.
  - `chore`: Tareas triviales de mantenimiento, misceláneo, exclusiones menores.

*Ejemplo de título:* `feat(auth): require login for technician system`
*Ejemplo de título:* `fix: resolve task rendering delay on login`

### 2. Reglas para el Cuerpo (Body)
- **El Cuerpo debe estar siempre en español**.
- Debe estar separado del título por **exactamente una línea en blanco**. Si usas terminal ejecuta: `git commit -m "title" -m "body"`.
- **Descripción extensa:** Aquí es obligatorio explicar exhaustivamente **QUÉ** cambiaste y **POR QUÉ** se hizo el cambio, no solo "cómo" se estructuró (pues el diff del código lo describe implícitamente).
- Debe responder:
  - ¿Cuál era el contexto o el problema previo al commit?
  - ¿Qué enfoque tomaste para resolverlo?
  - ¿Existen efectos secundarios (side-effects), o cambiaste tablas o variables globales de base de datos?
- Se sugiere utilizar listas de viñetas o bullet points (`- ` o `* `) si se modifican múltiples componentes.

### Ejemplo de Ejecución Completa

```bash
git commit -m "feat(ui): add visual indicators for overdue tasks" -m "Previously, overdue tasks were not easily distinguishable out-of-the-box in the main Maintenance grid, leading to potential operator oversight.

This commit introduces a new robust color-coding pattern relying directly on the backend 'ui_status' logical state.

- Updated Maintenance.jsx to parse ui_status properly and inject corresponding CSS classes.
- Adjusted index.css to refine the status-red, status-yellow, and status-green visual accents honoring the glassmorphism theme.
- Ensured that the standalone TV Visualization module replicates these color conventions."
```

## Salida (Output)
Al finalizar exitosamente este skill reporta al usuario con un resumen breve: el Título del commit generado y una pequeña confirmación de que los cambios ya están trackeados, omitiendo el output crudo e innecesario de log de la consola.
