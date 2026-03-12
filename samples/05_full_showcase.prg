#include "inkey.ch"

#ifndef __XHARBOUR__
   #include "hbwin.ch"
#endif

/*
   EJEMPLO 05: SHOWCASE COMPLETO
   Este programa demuestra TODAS las funcionalidades del wrapper profesional:
   - Carga de reporte
   - Inyeccion de JSON masivo
   - Cambio de Imagenes (PictureObject)
   - Generacion de QR y Code128
   - Movimiento de objetos en tiempo de ejecucion
   - Manejo de visibilidad
   - Exportacion y Preview
*/

FUNCTION Main()
    LOCAL oFR
    LOCAL cJson, lSuccess
    LOCAL cLogoPath := "C:\Windows\Web\Wallpaper\Windows\img0.jpg" // Imagen por defecto de Windows

    ? "--- hwReport FULL SHOWCASE ---"

    oFR := win_oleCreateObject( "hwReport.FastReport" )
    IF Empty( oFR )
        ? "Error: No se pudo instanciar la DLL. Registro fallido?"
        RETURN NIL
    ENDIF

    // 1. Cargar la plantilla 'Showcase'
    IF .NOT. oFR:LoadReport( "05_full_showcase.frx" )
        ? "Error al cargar reporte: " + oFR:GetLastError()
        RETURN NIL
    ENDIF

    // 2. Setear Variables de Cabecera
    oFR:SetParameter( "Title", "DEMOSTRACION INTEGRAL HARBOUR" )

    // 3. Inyectar Datos JSON para la Tabla
    cJson := '[' + ;
        '{"ID": "01", "Description": "Lector de Barras Laser", "Value": 120.50},' + ;
        '{"ID": "02", "Description": "Impresora Termica 80mm", "Value": 350.00},' + ;
        '{"ID": "03", "Description": "Bobina de Papel x10", "Value": 45.15},' + ;
        '{"ID": "04", "Description": "Servicio de Soporte", "Value": 80.00}' + ;
    ']'
    oFR:RegisterJsonData( "Data", cJson )

    // 4. Manipulacion de Objetos Visuales
    ? "Configurando componentes visuales..."

    // Cambiar una imagen dinamica (Logo)
    IF File( cLogoPath )
        oFR:SetImage( "LogoImg", cLogoPath )
    ENDIF

    // Cambiar QR y Codigo de Barras
    oFR:SetBarcode( "QrCode", "https://github.com/vszakats/harbour-core" )
    oFR:SetBarcode( "BarCode128", "SHOW-CASE-2026" )

    // Mover un objeto (Título) y cambiarle el color/texto
    oFR:SetText( "TxtTitle", "SISTEMA DE REPORTES PROFESIONAL" )
    
    // 5. Demostracion de Exportacion Silenciosa
    ? "Generando copia PDF silenciosa..."
    IF oFR:ExportToPdf( "C:\harbour\contrib\hwReport\samples\Showcase_Output.pdf", .F. )
        ? "PDF guardado en disco: Showcase_Output.pdf"
    ENDIF

    // 6. Lanzar Visualizador
    ? "Lanzando Visualizador Final..."
    IF .NOT. oFR:ShowPreview()
        ? "Fallo en Visualizador: " + oFR:GetLastError()
    ENDIF

    oFR := NIL
    ? "Showcase completado."

RETURN NIL
