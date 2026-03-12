#include "inkey.ch"

#ifndef __XHARBOUR__
   #include "hbwin.ch"
#endif

/*
   EJEMPLO 01: FACTURACION CON DATOS JSON
   Demuestra como enviar un set de datos complejo (una tabla con lineas de detalle)
   desde Harbour a FastReport sin necesidad de archivos DBF intermedios.
*/

FUNCTION Main()
    LOCAL oFR
    LOCAL cJson, lSuccess

    ? "SAMPLES: Facturacion con JSON"

    oFR := win_oleCreateObject( "hwReport.FastReport" )

    IF .NOT. oFR:LoadReport( "01_json_invoice.frx" )
        ? "Error cargando reporte: " + oFR:GetLastError()
        RETURN NIL
    ENDIF

    // Creamos un JSON que simula los items de una factura
    // FastReport lo tratara como una tabla llamada 'Items'
    cJson := '[' + ;
        '{"ITEM": "1", "DESC": "Servicios de Consultoria", "TOTAL": 1500.00},' + ;
        '{"ITEM": "2", "DESC": "Licencia de Software", "TOTAL": 250.00},' + ;
        '{"ITEM": "3", "DESC": "Implementacion COM/OLE", "TOTAL": 500.00}' + ;
    ']'

    // Registramos los datos
    ? "Registrando datos JSON..."
    IF .NOT. oFR:RegisterJsonData( "Items", cJson )
        ? "Error en JSON: " + oFR:GetLastError()
    ENDIF

    // Seteamos una variable global para el reporte
    oFR:SetParameter( "Cliente", "CLIENTE DE PRUEBA S.A." )
    oFR:SetParameter( "NumFac", "A-0001-00000123" )

    ? "Iniciando Visualizador..."
    IF oFR:ShowPreview()
       ? "Success! PDF generado en: " + oFR:GetLastError()
    ELSE
       ? "Error en Visualizador: " + oFR:GetLastError()
    ENDIF

    oFR := NIL
RETURN NIL
