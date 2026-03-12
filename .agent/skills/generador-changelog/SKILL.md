---
name: generador-changelog
description: Lee los cambios recientes del repositorio y actualiza el archivo CHANGELOG.md agregando una nueva entrada con el commit actual.
---
# Skill: Generador de Changelog

## Cuándo usar este skill
- Principalmente: inmediatamente **después** de haber realizado un commit exitoso (ej. después de usar la skill `commiter`).
- Cuando el usuario solicita explícitamente actualizar el CHANGELOG o registrar los cambios más recientes.

## Flujo de Trabajo (Workflow)

1. **Obtener el último commit**:
   Usa el comando `git log -1 --pretty=format:"%h|%s|%b|%ad" --date=short` para obtener los datos del último commit.
   - `%h`: Hash corto
   - `%s`: Título (Subject)
   - `%b`: Cuerpo (Body)
   - `%ad`: Fecha

2. **Verificar existencia de CHANGELOG.md**:
   Verifica si el archivo `CHANGELOG.md` existe en la raíz del proyecto. Si no existe, debes crearlo con un encabezado inicial básico:
   ```markdown
   # Changelog

   Todos los cambios notables de este proyecto serán documentados en este archivo.
   ```

3. **Formatear la nueva entrada**:
   Analiza el título del commit (que debería seguir Conventional Commits) para categorizar el cambio.
   Extrae el tipo (ej. `feat`, `fix`, `refactor`) y formatea la entrada en markdown.

   Ejemplo de formato esperado para añadir al archivo:
   ```markdown
   ## [Fecha del commit] - Hash: <hash>

   ### <Tipo de Cambio Capitalizado> (ej. Características, Correcciones, Refactorización)
   - **<scope si existe>**: <Descripción corta del título>

   <Cuerpo del commit si existe, formateado apropiadamente o resumido si es muy largo>

   ---
   ```

4. **Actualizar CHANGELOG.md**:
   - Lee el contenido actual de `CHANGELOG.md`.
   - La descripcion del cambio de estar en **español**.
   - Inserta la nueva entrada formateada justo **debajo** del encabezado principal (`# Changelog` y su descripción), de modo que las entradas más recientes queden arriba (orden cronológico inverso).
   - Sobrescribe el archivo `CHANGELOG.md` con el nuevo contenido.

5. **Commit del Changelog (Opcional pero recomendado)**:
   - Si se ha modificado el `CHANGELOG.md`, haz un stage del archivo: `git add CHANGELOG.md`.
   - Crea un nuevo commit tipo chore: `git commit -m "chore: update changelog"`.

## Salida (Output) esperado
Al finalizar, contesta al usuario confirmando que el `CHANGELOG.md` ha sido actualizado exitosamente con el último cambio. Muestra un brevísimo extracto de cómo quedó la entrada añadida.
