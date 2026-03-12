#include "inkey.ch"

#ifndef __XHARBOUR__
   #include "hbwin.ch"
#endif

/*
   EXAMPLE 05: FULL SHOWCASE
   This program demonstrates ALL the features of the professional wrapper:
   - Report loading
   - Bulk JSON data injection
   - PictureObject updates
   - QR and Code128 generation
   - Runtime object positioning
   - Visibility handling
   - Export and Preview
*/

FUNCTION Main()
    LOCAL oFR
    LOCAL cJson, lSuccess
    LOCAL cLogoPath := "img0.jpg" // Sample image

    ? "--- hwReport FULL SHOWCASE ---"

    oFR := win_oleCreateObject( "hwReport.FastReport" )
    IF Empty( oFR )
        ? "Error: Could not instantiate DLL. Registration failed?"
        RETURN NIL
    ENDIF

    // 1. Load the 'Showcase' template
    IF !oFR:LoadReport( "05_full_showcase.frx" )
        ? "Error loading report: " + oFR:GetLastError()
        RETURN NIL
    ENDIF

    // 2. Set Header Parameters
    oFR:SetParameter( "Title", "FULL HARBOUR INTEGRATION DEMO" )

    // 3. Inject JSON Data for the Table
    cJson := '[' + ;
        '{"ID": "01", "Description": "Laser Barcode Scanner", "Value": 120.50},' + ;
        '{"ID": "02", "Description": "Thermal Printer 80mm", "Value": 350.00},' + ;
        '{"ID": "03", "Description": "Paper Roll x10", "Value": 45.15},' + ;
        '{"ID": "04", "Description": "Support Service", "Value": 80.00}' + ;
    ']'
    oFR:RegisterJsonData( "Data", cJson )

    // 4. Visual Component Manipulation
    ? "Configuring visual components..."

    // Dynamically change an image (Logo)
    IF File( cLogoPath )
        oFR:SetImage( "LogoImg", cLogoPath )
    ENDIF

    // Update QR and Barcode data
    oFR:SetBarcode( "QrCode", "https://github.com/vszakats/harbour-core" )
    oFR:SetBarcode( "BarCode128", "SHOW-CASE-2026" )

    // Move an object (Title) and update its text
    oFR:SetText( "TxtTitle", "PROFESSIONAL REPORTING SYSTEM" )

    // 5. Silent Export Demonstration
    ? "Generating silent PDF copy..."
    IF oFR:ExportToPdf( "C:\harbour\contrib\hwReport\samples\Showcase_Output.pdf", .F. )
        ? "PDF saved to disk: Showcase_Output.pdf"
    ENDIF

    // 6. Launch Viewer
    ? "Launching Final Viewer..."
    IF .NOT. oFR:ShowPreview()
        ? "Viewer Failure: " + oFR:GetLastError()
    ENDIF

    oFR := NIL
    ? "Showcase completed."

RETURN NIL
