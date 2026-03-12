#include "inkey.ch"

#ifndef __XHARBOUR__
   #include "hbwin.ch"
#endif

/*
   EJEMPLO 04: CONTROL DINAMICO DE OBJETOS
   Muestra como mover, redimensionar y ocultar elementos segun la logica
   de tu programa Harbour (ej: ocultar firma si no esta autorizado).
*/

FUNCTION Main()
    LOCAL oFR
    LOCAL lEsUrgente := .T.

    ? "SAMPLES: Control Dinamico de Objetos"

    oFR := win_oleCreateObject( "hwReport.FastReport" )
    
    IF .NOT. oFR:LoadReport( "04_dynamic_objects.frx" )
        ? "Error al cargar: " + oFR:GetLastError()
        RETURN NIL
    ENDIF

    // Registramos datos minimos para evitar errores de compilacion del reporte
    oFR:RegisterJsonData( "Items", '[{"DESC": "Objeto Dinamico", "TOTAL": 0.00}]' )

    IF lEsUrgente
        // Movemos un objeto de texto a una posicion especifica
        // SetPosition( NombreObjeto, LeftCM, TopCM, WidthCM, HeightCM )
        oFR:SetPosition( "Text1", 10.5, 0.5, 5.0, 2.0 )
        oFR:SetText( "Text1", "¡¡ DOCUMENTO URGENTE !!" )
    ELSE
        oFR:SetVisible( "Text1", .F. ) // Ocultamos el objeto
    ENDIF

    ? "Iniciando Visualizador..."
    IF .NOT. oFR:ShowPreview()
        ? "Error: " + oFR:GetLastError()
    ENDIF

    oFR := NIL
RETURN NIL
