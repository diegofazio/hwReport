---
name: creador-de-skills
description: Genera nuevos skills siguiendo el estándar oficial de Antigravity (Plan, Validar, Ejecurar).
---
# Creador de Skills para Antigravity

## Cuándo usar este skill
- Cuando el usuario pida crear un skill nuevo.
- Cuando el usuario repita un proceso que deba estandarizarse.
- Cuando se necesite convertir un prompt largo en un procedimiento reutilizable.

## Inputs necesarios
- Tema o funcionalidad del skill a crear.
- (Opcional) Nivel de libertad deseado (Alta, Media, Baja).

## Workflow
1) **Planificación**: Definir el nombre (minúsculas, guiones) y la descripción operativa.
2) **Estructura**: Definir qué carpetas (`resources`, `scripts`, `examples`) son necesarias.
3) **Escritura**: Redactar el `SKILL.md` con frontmatter YAML y secciones claras.
4) **Validación**: Revisar que no haya relleno y que el output esté estandarizado.

## Instrucciones
- Sigue fielmente el estándar definido en `resources/instrucciones-base.md`.
- No crees archivos innecesarios.
- Define triggers concretos y fáciles de reconocer.

## Output (formato exacto)
Devolver:
1. Ruta de la carpeta (`.agent/skills/...`)
2. Contenido completo del `SKILL.md`.
3. Contenido de los recursos adicionales si aplican.

## Recursos opcionales
- `resources/instrucciones-base.md`: Referencia al documento original del usuario.
