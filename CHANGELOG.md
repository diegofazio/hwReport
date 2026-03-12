# Changelog

Todos los cambios notables de este proyecto serán documentados en este archivo.

## [2026-03-12] - Hash: a910e11
### Características
- **core**: Implementación inicial del wrapper OLE/COM para FastReport OpenSource.
- **core**: Soporte para inyección de datos vía JSON nativo de Harbour.
- **core**: Sistema de resolución quirúrgica de ensamblados para entornos OLE restrictivos.
- **core**: Integración con Costura.Fody para despliegue de DLL única sin dependencias.
- **samples**: Galería de 5 ejemplos Harbour con mapeo 1:1 a plantillas FRX.
- **samples**: Rediseño premium de facturas y etiquetas con códigos QR y de barras.
- **tools**: Script `check_com.bat` para verificación de registro OLE.
- **tools**: Script `Build.bat` mejorado con registro automático.
- **docs**: Documentación completa en `README.md`, `AGENTS.md` y guía paso a paso.
- **skills**: Implementación de skills para automatización de commits y documentación.

### Correcciones
- **script**: Eliminación de funciones `Sum()` en scripts internos para usar Totales del Motor, evitando errores de metadatos.
- **layout**: Corrección de solapamientos visuales en el reporte de Showcase.

---
