---
name: documentador-readme
description: Analiza cambios recientes y actualiza el README.md antes de realizar un commit para asegurar que la documentación técnica sea precisa.
---
# Documentador de README

## Cuándo usar este skill
- **SIEMPRE antes de realizar un commit** que incluya cambios funcionales.
- Cuando se añadan nuevos métodos a `ReportWrapper.cs`.
- Cuando se modifique la arquitectura o los requisitos del sistema.
- Cuando se añadan nuevos ejemplos en la carpeta `samples/`.

## Inputs necesarios
- Lista de archivos modificados o resumen de los últimos cambios.
- Archivo `README.md` actual para referencia.

## Workflow
1. **Detección**: Identificar cambios significativos (nuevos métodos en `IReportWrapper`, cambios en `Build.bat`, nuevos archivos `.frx`/`.prg`).
2. **Análisis**: Determinar qué sección del `README.md` debe actualizarse (API Reference, Project Structure, Architecture Notes).
3. **Edición**: Aplicar los cambios al `README.md` manteniendo el estilo profesional y conciso.
4. **Verificación**: Asegurarse de que los links a archivos y las descripciones técnicas sean correctas.

## Políticas
- No borrar información histórica relevante, solo añadir o rectificar.
- Mantener el formato de tablas y encabezados existente.
- Usar emojis de forma moderada y profesional (🚀, 📂, 🛠️).
- **CRÍTICO**: Si se añade una nueva funcionalidad en C#, asegurar que se documente el nombre exacto del método OLE.

## Ejemplo de uso
"He añadido un método `SetOrientation` en la DLL. Ejecutando `documentador-readme` para actualizar la sección de 'Component Manipulation' antes del commit."
