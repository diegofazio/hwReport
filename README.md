# hwReport API Documentation

## 🚀 Overview
`hwReport.FastReport` is a professional OLE/COM wrapper for FastReport, designed for Harbour applications. It features zero-dependency runtime (via Costura), JSON data support, and advanced object manipulation.

## 🛠️ Installation & Verification
1. **Build & Register**: Run `Build.bat` as **Administrator**. This compiles the DLL and registers the COM object.
2. **Verify Registration**: Run `check_com.bat`. It will confirm if the OLE object `hwReport.FastReport` is correctly registered and ready to use.

## 📂 API Reference

### File Management
- **`LoadReport(filePath)`**: Loads a `.frx` file. Returns `.T.` if success.
- **`GetLastError()`**: Returns the last error message from the C# engine.

### Data Injection
- **`RegisterJsonData(dataName, jsonString)`**: Registers a JSON array or object as a DataSource.
  - If `jsonString` is an array `[{...}]`, it creates a table `dataName` where each key is a column.
  - If `jsonString` is an object `{}`, it creates a key/value table.
- **`SetParameter(name, value)`**: Sets a report parameter/variable (Recommended for macros like `[VarName]`).

### Component Manipulation
- **`SetText(objectName, text)`**: Changes the text of a `TextObject`.
- **`SetImage(objectName, path)`**: Changes the image of a `PictureObject`.
- **`SetBarcode(objectName, data)`**: Changes the data/text of a Barcode/QR object.
- **`SetPosition(objectName, left, top, width, height)`**: Moves/Resizes an object (Units: Centimeters).
- **`SetVisible(objectName, bool)`**: Shows or hides an object.

### Execution & Exports
- **`ShowPreview()`**: Generates a temporary PDF and opens the system's default PDF viewer.
- **`ExportToPdf(exportPath, openAfter)`**: Exports to a specific PDF file.
  - `openAfter`: `.T.` to open the file immediately, `.F.` to just save it.

## 📁 Project Structure (1:1 Mapping)
The library follows a strict **1:1 mapping** between Harbour samples and FastReport templates for clarity:

- `samples/01_json_invoice.prg` ↔️ `01_json_invoice.frx`
- `samples/02_labels_qr.prg` ↔️ `02_labels_qr.frx`
- `samples/03_silent_export.prg` ↔️ `03_silent_export.frx`
- `samples/04_dynamic_objects.prg` ↔️ `04_dynamic_objects.frx`
- `samples/05_full_showcase.prg` ↔️ `05_full_showcase.frx`

## ⚙️ Architecture Notes
- **Architecture**: 64-bit (x64).
- **Runtime**: .NET Framework 4.8 (Included in Windows 10/11).
- **Engine**: FastReport OpenSource (using native Totals for stability).
