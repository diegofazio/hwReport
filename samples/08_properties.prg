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

   cFile := "08_properties.frx"

   if !oFR:LoadReport( cFile )
      ? "Error loading report:", oFR:GetLastError()
      return
   endif

   // Set units to CM
   oFR:SetUnits( 1 )

   // Set Codepage to UTF-8
   oFR:SetCodePage( 65001 )

   ? "Adding and styling elements..."

   // 1. Regular text
   oFR:AddTextObject( "Data1", "txtRegular", "Regular text (Arial 10)", 0.5, 0.5, 10, 0.6 )

   // 2. Styled text: Bold, Italic, Different Font and Size
   oFR:AddTextObject( "Data1", "txtStyled", "I am a Big Bold Blue text!", 0.5, 1.5, 10, 1 )
   oFR:SetFont( "txtStyled", "Times New Roman", 16, .T., .T. )
   oFR:SetTextColor( "txtStyled", "#0000FF" ) // Blue

   // 3. Alignment Test
   oFR:AddTextObject( "Data1", "txtAligned", "I am centered in a box", 0.5, 3.0, 10, 1.5 )
   oFR:SetColor( "txtAligned", "#FFF0F0" ) // Light Red background
   oFR:SetAlignment( "txtAligned", 1, 1 ) // Center, Center (Horz, Vert)
   oFR:SetFont( "txtAligned", "Verdana", 12, .F., .F. )

   // 4. Multiple styles update
   oFR:AddTextObject( "Data1", "txtMulti", "Multi-style update test", 0.5, 5.0, 10, 1 )
   oFR:SetFont( "txtMulti", "Courier New", 14, .T., .F. )
   oFR:SetTextColor( "txtMulti", "Green" ) // Named color support

   ? "Showing preview..."
   oFR:ShowPreview()

return
