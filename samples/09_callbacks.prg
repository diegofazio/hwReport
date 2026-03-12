#include "hbclass.ch"

PROCEDURE Main()
   LOCAL oFR, oHandler, cFile
   LOCAL cMethod, aArgs, xResult

   ? "Starting hwReport.FastReport (Callback Demo)..."

   oFR := win_oleCreateObject( "hwReport.FastReport" )
   if Empty( oFR )
      ? "Error: Could not create hwReport.FastReport object."
      return
   endif

   oFR:SetDiagnostics( .F. )  // Mute C# internal diagnostics logs. For debugging set to .T.

   oHandler := THbHandler():New()

   // Load the report template
   cFile := "09_callbacks.frx"
   if !oFR:LoadReport( cFile )
      ? "Error loading report:", oFR:GetLastError()
      return
   endif

   // Register Harbour functions dynamically so they can be called NATIVELY in FastReport
   // Syntax: RegisterUserFunction( cName, cParameters, cCategory, cDescription )
   // 'cParameters' follows C# syntax. 'object' is used to accept any Harbour type (String, Numeric, etc.)
   oFR:RegisterUserFunction("GetSystemStatus", "", "Harbour", "Returns the system status")
   oFR:RegisterUserFunction("HarbourFormatCurrency", "object p1", "Harbour", "Formats a number as currency")

   // Create a new text element AT RUNTIME that uses our registered Harbour function
   // Format: AddTextObject( bandName, objectName, text, left, top, width, height )
   // Note: Default units in hwReport are Centimeters
   oFR:AddTextObject("Data1", "RuntimeFuncCall", "Element created at runtime: [HarbourFormatCurrency(9999.99)]", 0.5, 3.5, 15.0, 1.0)
   oFR:SetFont("RuntimeFuncCall", "Arial", 12, .T., .F.)
   oFR:SetTextColor("RuntimeFuncCall", "#FF00FF") // Magenta

   ? "Registering OLE Event Sink..."
   oHandler:Register( oFR, .t. )  // .F. = Show logs

   ? "Showing preview..."
   ? "During report generation, FastReport will call back into Harbour synchronously."

   if !oFR:ShowPreview()
      ? "Error showing report:", oFR:GetLastError()
   endif

return

// --- CALLBACK HANDLER CLASS ---
CREATE CLASS THbHandler
   METHOD New()
   METHOD Register( oFR, lSilent )
   METHOD OnUserFunctionCall( cMethod, aArgs )
ENDCLASS

METHOD New() CLASS THbHandler
return Self

METHOD Register( oFR, lSilent ) CLASS THbHandler
   hb_default( @lSilent, .F. )  // By default, not silent (shows logs)

   oFR:__hSink := __axRegisterHandler( oFR:__hObj, {||
      LOCAL cMethod := oFR:EventMethodName
      LOCAL aArgs   := oFR:EventArgs
      LOCAL xResult

      if !Empty( cMethod )
         if !lSilent
            ? "[HB] Sync Callback Request:", cMethod
         endif

         xResult := ::OnUserFunctionCall( cMethod, aArgs )

         if !lSilent
            ? "[HB] Returning Result:", hb_ValToStr( xResult )
         endif

         oFR:EventResult := xResult
      endif

      RETURN NIL
   } )
return NIL

METHOD OnUserFunctionCall( cMethod, aArgs ) CLASS THbHandler
   LOCAL xRet := NIL

   if cMethod == "GetSystemStatus"
      xRet := "Harbour System ONLINE"
   elseif cMethod == "HarbourFormatCurrency"
      xRet := "$" + AllTrim( Transform( aArgs[1], "999,999.99" ) )
   else
      xRet := "Unknown method: " + cMethod
   endif

return xRet
