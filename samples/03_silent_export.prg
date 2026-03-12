#include "inkey.ch"

#ifndef __XHARBOUR__
   #include "hbwin.ch"
#endif

/*
   EXAMPLE 03: SILENT EXPORT (BACKGROUND)
   Generates a PDF without showing any window to the user.
   Useful for batch processes or automated email sending.
*/

FUNCTION Main()
    LOCAL oFR
    LOCAL cPath := "C:\harbour\contrib\hwReport\samples\Generated_Report.pdf"

    ? "SAMPLES: Exporting PDF in background..."

    oFR := win_oleCreateObject( "hwReport.FastReport" )
    
    IF .NOT. oFR:LoadReport( "03_silent_export.frx" )
        ? "Error loading report: " + oFR:GetLastError()
        RETURN NIL
    ENDIF

    // Register data so the report has content and doesn't trigger engine errors
    oFR:RegisterJsonData( "Items", '[{"DESC": "Export Item 1", "TOTAL": 100.00}]' )
    oFR:SetParameter( "Cliente", "SILENT EXPORTER" )

    // ExportToPdf( filePath, openAfter )
    // Pass .F. so the viewer does NOT open upon completion
    IF oFR:ExportToPdf( cPath, .F. )
        ? "SUCCESS: File has been created silently at:"
        ? cPath
    ELSE
        ? "ERROR: " + oFR:GetLastError()
    ENDIF

    oFR := NIL
RETURN NIL
