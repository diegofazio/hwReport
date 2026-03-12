#include "inkey.ch"

#ifndef __XHARBOUR__
   #include "hbwin.ch"
#endif

/*
   EXAMPLE 01: INVOICING WITH JSON DATA
   Demonstrates how to send a complex dataset (a table with line items)
   from Harbour to FastReport without the need for intermediate DBF files.
*/

FUNCTION Main()
    LOCAL oFR
    LOCAL cJson, lSuccess

    ? "SAMPLES: JSON Invoicing"

    oFR := win_oleCreateObject( "hwReport.FastReport" )

    IF .NOT. oFR:LoadReport( "01_json_invoice.frx" )
        ? "Error loading report: " + oFR:GetLastError()
        RETURN NIL
    ENDIF

    // Create a JSON string simulating invoice line items
    // FastReport will treat this as a table named 'Items'
    cJson := '[' + ;
        '{"ITEM": "1", "DESC": "Consultancy Services", "TOTAL": 1500.00},' + ;
        '{"ITEM": "2", "DESC": "Software License", "TOTAL": 250.00},' + ;
        '{"ITEM": "3", "DESC": "COM/OLE Implementation", "TOTAL": 500.00}' + ;
    ']'

    // Registering the data
    ? "Registering JSON data..."
    IF .NOT. oFR:RegisterJsonData( "Items", cJson )
        ? "JSON Error: " + oFR:GetLastError()
    ENDIF

    // Set global parameters for the report
    oFR:SetParameter( "Cliente", "TEST CUSTOMER LTD." )
    oFR:SetParameter( "NumFac", "INV-2026-00000123" )

    ? "Launching Viewer..."
    IF oFR:ShowPreview()
       ? "Success! PDF generated at: " + oFR:GetLastError()
    ELSE
       ? "Viewer Error: " + oFR:GetLastError()
    ENDIF

    oFR := NIL
RETURN NIL
