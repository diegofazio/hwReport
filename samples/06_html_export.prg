#include "inkey.ch"

#ifndef __XHARBOUR__
   #include "hbwin.ch"
#endif

/*
   EXAMPLE 06: HTML EXPORT
   Shows how to generate a standalone HTML file that can be viewed
   in any browser, ideal for web reports or dashboards.
*/

FUNCTION Main()
    LOCAL oFR
    LOCAL cPath := "C:\harbour\contrib\hwReport\samples\Web_Report.html"
    LOCAL cJson := '[{"ITEM": "WEB-1", "DESC": "Server Deployment", "TOTAL": 1200.00},' + ;
                   '{"ITEM": "WEB-2", "DESC": "IIS/Apache Configuration", "TOTAL": 450.00}]'

    ? "SAMPLES: Exporting to HTML..."

    oFR := win_oleCreateObject( "hwReport.FastReport" )
    
    // Using the same invoice template to demonstrate versatility
    IF .NOT. oFR:LoadReport( "06_html_export.frx" )
        ? "Error loading report: " + oFR:GetLastError()
        RETURN NIL
    ENDIF

    // Register data and parameters
    oFR:RegisterJsonData( "Items", cJson )
    oFR:SetParameter( "Cliente", "E-COMMERCE WEB CUSTOMER" )
    oFR:SetParameter( "NumFac", "W-2026-001" )

    ? "Generating HTML file..."
    IF oFR:ExportToHtml( cPath, .T. )
        ? "SUCCESS: The HTML file has been created and opened in your browser."
        ? "Path: " + cPath
    ELSE
        ? "ERROR: " + oFR:GetLastError()
    ENDIF

    oFR := NIL
RETURN NIL
