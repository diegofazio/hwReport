#include "inkey.ch"

#ifndef __XHARBOUR__
   #include "hbwin.ch"
#endif

/*
   EXAMPLE 04: DYNAMIC COMPONENT CONTROL
   Shows how to move, resize, and hide elements based on your 
   Harbour program logic (e.g., hide signature if not authorized).
*/

FUNCTION Main()
    LOCAL oFR
    LOCAL lIsUrgent := .T.

    ? "SAMPLES: Dynamic Component Control"

    oFR := win_oleCreateObject( "hwReport.FastReport" )
    
    IF .NOT. oFR:LoadReport( "04_dynamic_objects.frx" )
        ? "Load Error: " + oFR:GetLastError()
        RETURN NIL
    ENDIF

    // Register minimum data to avoid report compilation errors
    oFR:RegisterJsonData( "Items", '[{"DESC": "Dynamic Object", "TOTAL": 0.00}]' )

    IF lIsUrgent
        // Move a text object to a specific position
        // SetPosition( objectName, leftCM, topCM, widthCM, heightCM )
        oFR:SetPosition( "Text1", 10.5, 0.5, 5.0, 2.0 )
        oFR:SetText( "Text1", "!! URGENT DOCUMENT !!" )
    ELSE
        oFR:SetVisible( "Text1", .F. ) // Hide the object
    ENDIF

    ? "Launching Viewer..."
    IF .NOT. oFR:ShowPreview()
        ? "Error: " + oFR:GetLastError()
    ENDIF

    oFR := NIL
RETURN NIL
