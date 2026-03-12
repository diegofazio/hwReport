#include "inkey.ch"

#ifndef __XHARBOUR__
   #include "hbwin.ch"
#endif

/*
   EJEMPLO 02: ETIQUETAS Y CODIGOS QR / BARRAS
   Demuestra como manipular especificamente objetos de tipo Barcode o QR
   en tiempo de ejecucion desde Harbour.
*/

FUNCTION Main()
    LOCAL oFR
    LOCAL cQrData := "https://miempresa.com/serial/ABC-123-XYZ"

    ? "SAMPLES: Etiquetas con QR"

    oFR := win_oleCreateObject( "hwReport.FastReport" )

    IF .NOT. oFR:LoadReport( "02_labels_qr.frx" )
        ? "Error: " + oFR:GetLastError()
        RETURN NIL
    ENDIF

    ? "Asignando datos al QR..."
    oFR:SetParameter( "qr", cQrData )
    oFR:SetParameter( "Text1", "SERIAL: ABC-123-XYZ" )

    ? "Iniciando Visualizador..."
    IF .NOT. oFR:ShowPreview()
        ? "Error en Preview: " + oFR:GetLastError()
    ENDIF

    oFR := NIL
RETURN NIL
