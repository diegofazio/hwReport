# hwReport API Documentation

## 🚀 Overview
`hwReport.FastReport` is a professional OLE/COM wrapper for FastReport, designed for Harbour applications.
- **Engine**: FastReport OpenSource.
- **Runtime**: .NET Framework 4.8 (Included in Windows 10/11).
- **Features**: Zero-dependency runtime (via Costura), JSON data support, and advanced object manipulation.

## 🛠️ Getting Started
The library supports both **32-bit (x86)** and **64-bit (x64)** architectures.

### Option A: Pre-compiled Binaries (Quickest)
1. **DLLs**: Binaries are located in `dist/x86/` and `dist/x64/`.
2. **Register**: Run `dist/x86/register.bat` or `dist/x64/register.bat` (based on your Harbour architecture) as **Administrator**.

### Option B: Build from Source
1. **Requirements**: .NET SDK (6.0+ or Framework 4.8 targeting pack).
2. **Build**: Run `build32.bat` (x86) or `build64.bat` (x64) as **Administrator**. This will:
   - Compile the DLL and copy it to the `dist/` folder.
   - Automatically register the COM component.
   - Run `build.bat` to build and register **both** architectures at once.

### Verification
- **Check Status**: Run `check_com.bat` to see which architectures are currently registered.
- **Unregister**: Run `unregister.bat` as **Administrator**.

## 🚀 Deployment & Runtime Requirements
To run an application that uses `hwReport` on a client PC, ensure the following:

1. **.NET Framework 4.8**: Required for COM compatibility. (Standard on Windows 10/11).
2. **Register the DLL**:
   - The compiled `hwReport.dll` must be registered on the client machine.
   - Copy the `dist/x86/` or `dist/x64/` folder to the PC.
   - Run `register.bat` as **Administrator**.
   - **Note on `.tlb`**: The `hwReport.tlb` file is used for early-binding and events metadata. It is **not strictly required** to distribute it, as the `register.bat` will generate it automatically if it is missing.
3. **Bitness Match**: Your Harbour application bitness (32 or 64) must match the registered version of the DLL.
4. **Standalone**: No extra DLLs are needed (FastReport and JSON libs are embedded).

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
- **`AddHyperlinkObject(band, name, text, url, left, top, w, h)`**: Creates a hyperlink object (Blue/Underlined) at runtime.
- **`SetFont(name, font, size, bold, italic)`**: Sets font properties for a text object.
- **`SetAlignment(name, horz, vert)`**: Sets text alignment (0=Left, 1=Center, 2=Right).
- **`SetColor(name, color)`**: Sets background color (Hex or named).
- **`SetTextColor(name, color)`**: Sets text font color.
- **`SetHyperlink(name, url)`**: Sets or updates the hyperlink of an object.
- **`SetUnderline(name, bool)`**: Sets the underline style of an object.

### Callbacks & Diagnostics
- **`RegisterUserFunction(name, parameters, category, description)`**: Registers a Harbour function to be called natively inside the FastReport template (`[FunctionName()]`).
- **`SetDiagnostics(bool)`**: Enables or disables internal C# console logging.
- **`Bitness`**: Returns the architecture of the current instance (`32` or `64`).

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
- `samples/10_hyperlinks.prg` ↔️ `10_hyperlinks.frx`
## 🎨 Report Design
To create or modify `.frx` report templates, you can use the **FastReport Designer Community Edition**. It is a free, stand-alone report designer.
- **Download**: [FastReport Designer Community Edition](https://fastreports.github.io/FastReport.Documentation/FastReportDesignerCommunityEdition.html)

---

> [!NOTE]
> **AI Built**: This entire project, including the C# binary bridge, complex XML report redesigns, and the Harbour sample gallery, was developed by **AI (Antigravity)** using **Vibe Coding** workflows.
