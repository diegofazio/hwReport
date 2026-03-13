# hwReport API Documentation

## 🚀 Overview
`hwReport.FastReport` is a professional OLE/COM wrapper for FastReport, designed for Harbour applications. It features zero-dependency runtime (via Costura), JSON data support, and advanced object manipulation.

## 🛠️ Installation & Verification
You can choose between building the library from source or using the pre-compiled **x64** binary provided in the repository.

### Option A: Use Pre-compiled Binary (Quickest)
1. **Register**: Run `dist/register.bat` as **Administrator**.
2. **Verify**: Run `check_com.bat`.

### Option B: Build from Source
1. **Build & Register**: Run `build.bat` as **Administrator**. This compiles and registers the DLL automatically.
2. **Verify**: Run `check_com.bat`.

## 📂 API Reference

### File Management
- **`LoadReport(filePath)`**: Loads a `.frx` file. Returns `.T.` if success.
- **`GetLastError()`**: Returns the last error message from the C# engine.

### Data Injection
- **`RegisterJsonData(dataName, jsonString)`**: Registers a JSON array or object as a DataSource.
  - If `jsonString` is an array `[{...}]`, it creates a table `dataName` where each key is a column.
  - If `jsonString` is an object `{}`, it creates a key/value table.
- **`SetParameter(name, value)`**: Sets a report parameter/variable (Recommended for macros like `[VarName]`).
- **`SetCodePage(int codePage)`**: Sets the encoding for incoming strings (Default: 65001 / UTF-8).

### Component Manipulation
- **`SetText(objectName, text)`**: Changes the text of a `TextObject`.
- **`SetImage(objectName, path)`**: Changes the image of a `PictureObject`.
- **`SetBarcode(objectName, data)`**: Changes the data/text of a Barcode/QR object.
- **`SetPosition(objectName, left, top, width, height)`**: Moves/Resizes an object. (Units set via `SetUnits`).
- **`SetVisible(objectName, bool)`**: Shows or hides an object.
- **`SetUnits(int unitType)`**: Sets measurement units (0=mm, 1=cm, 2=in, 3=1/100in).
- **`AddTextObject(band, name, text, left, top, w, h)`**: Creates a text object at runtime.
- **`AddPictureObject(band, name, path, left, top, w, h)`**: Creates a picture object at runtime.
- **`SetFont(name, font, size, bold, italic)`**: Sets font properties for a text object.
- **`SetAlignment(name, horz, vert)`**: Sets text alignment (0=Left, 1=Center, 2=Right).
- **`SetColor(name, color)`**: Sets background color (Hex or named).
- **`SetTextColor(name, color)`**: Sets text font color.

### Callbacks & Diagnostics
- **`RegisterUserFunction(name, parameters, category, description)`**: Registers a Harbour function to be called natively inside the FastReport template (`[FunctionName()]`).
- **`SetDiagnostics(bool)`**: Enables or disables internal C# console logging.

### Execution & Exports
- **`ShowPreview()`**: Generates a temporary PDF and opens the system's default PDF viewer.
- **`ExportToPdf(exportPath, openAfter)`**: Exports to a specific PDF file.
- **`ExportToHtml(exportPath, openAfter)`**: Exports to a standalone HTML file.
  - `openAfter`: `.T.` to open the file immediately, `.F.` to just save it.

## 📁 Project Structure (1:1 Mapping)
The library follows a strict **1:1 mapping** between Harbour samples and FastReport templates for clarity:

- `samples/01_json_invoice.prg` ↔️ `01_json_invoice.frx`
- `samples/02_labels_qr.prg` ↔️ `02_labels_qr.frx`
- `samples/03_silent_export.prg` ↔️ `03_silent_export.frx`
- `samples/04_dynamic_objects.prg` ↔️ `04_dynamic_objects.frx`
- `samples/05_full_showcase.prg` ↔️ `05_full_showcase.frx`
- `samples/06_html_export.prg` ↔️ `06_html_export.frx`
- `samples/07_runtime_creation.prg` ↔️ `07_runtime_creation.frx`
- `samples/08_properties.prg` ↔️ `08_properties.frx`
- `samples/09_callbacks.prg` ↔️ `09_callbacks.frx`
## 📂 Project Structure & Distribution

### 📦 Pre-compiled Binary (Quick Start)
If you do not want to compile the source code, you can use the pre-compiled binary provided in the repository:
1. **Download/Clone** this repository.
2. **Register**: Run `dist/register.bat` as **Administrator**.
3. **Architecture**: The provided DLL is **x64**.

### 🏗️ Build from Source
1. **Requirements**: .NET SDK (6.0+ or Framework 4.8 targeting pack).
2. **Build**: Run `build.bat` as **Administrator**. This will:
   - Compile the DLL in Release mode.
   - Copy the binaries to the `dist` folder.
   - Register the COM component automatically.

## 🎨 Report Design
To create or modify `.frx` report templates, you can use the **FastReport Designer Community Edition**. It is a free, stand-alone report designer.
- **Download**: [FastReport Designer Community Edition](https://fastreports.github.io/FastReport.Documentation/FastReportDesignerCommunityEdition.html)

## ⚙️ Architecture Notes
- **Architecture**: 64-bit (x64).
- **Runtime**: .NET Framework 4.8 (Included in Windows 10/11).
- **Engine**: FastReport OpenSource (using native Totals for stability).
- **Distribution**: Binaries are kept in the `dist/` folder for immediate OLE registration.

---

> [!NOTE]
> **AI Built**: This entire project, including the C# binary bridge, complex XML report redesigns, and the Harbour sample gallery, was developed by **AI (Antigravity)** using **Vibe Coding** workflows.
