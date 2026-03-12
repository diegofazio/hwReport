#include "inkey.ch"

#ifndef __XHARBOUR__
   #include "hbwin.ch"
#endif

/*
   EXAMPLE 02: LABELS AND QR / BAR CODES
   Demonstrates how to specifically manipulate Barcode or QR objects
   at runtime from Harbour.
*/

FUNCTION Main()
    LOCAL oFR
    LOCAL cQrData := "https://mycompany.com/serial/ABC-123-XYZ"

    ? "SAMPLES: QR Labels"

    oFR := win_oleCreateObject( "hwReport.FastReport" )

    IF .NOT. oFR:LoadReport( "02_labels_qr.frx" )
        ? "Error: " + oFR:GetLastError()
        RETURN NIL
    ENDIF

    ? "Assigning data to QR code..."
    oFR:SetParameter( "qr", cQrData )
    oFR:SetParameter( "Text1", "SERIAL: ABC-123-XYZ" )

    ? "Launching Viewer..."
    IF .NOT. oFR:ShowPreview()
        ? "Preview Error: " + oFR:GetLastError()
    ENDIF

    oFR := NIL
RETURN NIL
