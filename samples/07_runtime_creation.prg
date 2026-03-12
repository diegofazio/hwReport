#include "hbclass.ch"
REQUEST HB_CODEPAGE_UTF8EX

procedure Main()
   local oFR, cPath

   hb_cdpSelect( "UTF8EX" )

   ? "Starting hwReport.FastReport..."
   oFR := win_oleCreateObject( "hwReport.FastReport" )

   if Empty( oFR )
      ? "Error: Could not create OLE object hwReport.FastReport"
      return
   endif

   cPath := hb_dirBase() + "07_runtime_creation.frx"
   if !File( cPath )
      cPath := "07_runtime_creation.frx"
   endif

   if !oFR:LoadReport( cPath )
      ? "Error loading report:", oFR:GetLastError(), "Path:", cPath
      return
   endif

   // Set units (1 = Centimeters)
   oFR:SetUnits( 1 )

   // Set codepage (65001 = UTF-8)
   oFR:SetCodePage( 65001 )

   ? "Adding elements at runtime..."

   // Add a text object with special characters (UTF-8)
   oFR:AddTextObject( "Data1", "txtRuntime", "Text with accents: áéíóú ñ Ñ ¿?!", 0.5, 0.5, 10, 1 )

   // Change properties of the newly created object using existing methods
   oFR:SetText( "txtRuntime", "This text was modified after being created!" )

   // Add an image (if img0.jpg exists in base directory)
   if File( "img0.jpg" )
      oFR:AddPictureObject( "Data1", "picRuntime", "img0.jpg", 11, 0.5, 3, 3 )
   endif

   ? "Showing preview..."
   oFR:ShowPreview()

return
