#include "inkey.ch"

#ifndef __XHARBOUR__
   #include "hbwin.ch"
#endif

/*
   EJEMPLO 06: EXPORTACION A HTML
   Muestra como generar un archivo HTML independiente que puede ser visualizado
   en cualquier navegador, ideal para reportes web o dashboards.
*/

FUNCTION Main()
    LOCAL oFR
    LOCAL cPath := "C:\harbour\contrib\hwReport\samples\Reporte_Web.html"
    LOCAL cJson := '[{"ITEM": "WEB-1", "DESC": "Despliegue en Servidor", "TOTAL": 1200.00},' + ;
                   '{"ITEM": "WEB-2", "DESC": "Configuracion IIS/Apache", "TOTAL": 450.00}]'

    ? "SAMPLES: Exportando a HTML..."

    oFR := win_oleCreateObject( "hwReport.FastReport" )
    
    // Usamos la misma plantilla de factura para demostrar la versatilidad
    IF .NOT. oFR:LoadReport( "06_html_export.frx" )
        ? "Error cargando reporte: " + oFR:GetLastError()
        RETURN NIL
    ENDIF

    // Registramos datos y parametros
    oFR:RegisterJsonData( "Items", cJson )
    oFR:SetParameter( "Cliente", "CLIENTE WEB E-COMMERCE" )
    oFR:SetParameter( "NumFac", "W-2026-001" )

    ? "Generando archivo HTML..."
    IF oFR:ExportToHtml( cPath, .T. )
        ? "EXITO: El archivo HTML se ha creado y abierto en tu navegador."
        ? "Ruta: " + cPath
    ELSE
        ? "ERROR: " + oFR:GetLastError()
    ENDIF

    oFR := NIL
RETURN NIL
