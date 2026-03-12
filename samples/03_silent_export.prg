#include "inkey.ch"

#ifndef __XHARBOUR__
   #include "hbwin.ch"
#endif

/*
   EJEMPLO 03: EXPORTACION SILENCIOSA (BACKGROUND)
   Genera un PDF sin mostrar ventana alguna al usuario.
   Util para procesos batch o envio de correos automaticos.
*/

FUNCTION Main()
    LOCAL oFR
    LOCAL cPath := "C:\harbour\contrib\hwReport\samples\Reporte_Generado.pdf"

    ? "SAMPLES: Exportando PDF en segundo plano..."

    oFR := win_oleCreateObject( "hwReport.FastReport" )
    
    IF .NOT. oFR:LoadReport( "03_silent_export.frx" )
        ? "Error cargando reporte: " + oFR:GetLastError()
        RETURN NIL
    ENDIF

    // Registramos datos para que el reporte tenga contenido y no falle el motor de script
    oFR:RegisterJsonData( "Items", '[{"DESC": "Item Exportacion 1", "TOTAL": 100.00}]' )
    oFR:SetParameter( "Cliente", "EXPORTADOR SILENCIOSO" )

    // ExportToPdf( RutaFile, AbrirDespues )
    // Pasamos .F. para que NO se abra el visor al finalizar
    IF oFR:ExportToPdf( cPath, .F. )
        ? "EXITO: El archivo se ha creado silenciosamente en:"
        ? cPath
    ELSE
        ? "ERROR: " + oFR:GetLastError()
    ENDIF

    oFR := NIL
RETURN NIL
