#include "hbclass.ch"
REQUEST HB_CODEPAGE_UTF8EX

procedure Main()
   local oFR, cFile

   hb_cdpSelect( "UTF8EX" )

   ? "Starting hwReport.FastReport..."
   oFR := win_oleCreateObject( "hwReport.FastReport" )

   if Empty( oFR )
      ? "Error: Could not create OLE object hwReport.FastReport"
      return
   endif

   cFile := "10_hyperlinks.frx"

   if !oFR:LoadReport( cFile )
      ? "Error loading report:", oFR:GetLastError()
      return
   endif

   // Set units (1 = Centimeters)
   oFR:SetUnits( 1 )

   // Set codepage (65001 = UTF-8)
   oFR:SetCodePage( 65001 )

   ? "Adding hyperlink elements..."

   // 1. Add a hyperlink object at runtime
   // AddHyperlinkObject(bandName, objectName, text, url, left, top, width, height)
   oFR:AddHyperlinkObject( "Data1", "lnkGoogle", "Visit Google", "https://www.google.com", 0.5, 0.5, 5, 1 )

   // 2. Set/Modify a hyperlink on an existing object
   oFR:SetText( "txtStaticLink", "This was a static text, now it's a link to GitHub" )
   oFR:SetHyperlink( "txtStaticLink", "https://github.com/diegofazio/hwReport" )
   
   // Style it manualy if needed (SetHyperlink doesn't style by default to be flexible)
   oFR:SetTextColor( "txtStaticLink", "#0000FF" )
   oFR:SetUnderline( "txtStaticLink", .T. )

   // 3. Add another link with different styling
   oFR:AddHyperlinkObject( "Data1", "lnkWiki", "Wikipedia (Custom Style)", "https://www.wikipedia.org", 0.5, 2.0, 8, 1 )
   oFR:SetTextColor( "lnkWiki", "#800080" ) // Purple
   oFR:SetFont( "lnkWiki", "Verdana", 12, .T., .F. )


   ? "Showing preview..."
   ? "Please click on the links to verify they work."
   if !oFR:ShowPreview()
      ? "Preview Error:", oFR:GetLastError()
   endif

return
