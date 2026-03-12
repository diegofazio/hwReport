# AGENTS.md - hwReport Knowledge Base

This document provides a technical overview of the `hwReport` project for AI assistants and developers.

## 🚀 Project Overview
`hwReport` is an OLE/COM wrapper for **FastReport OpenSource**, designed to provide professional reporting capabilities to **Harbour/clippper** applications.

### Key Features:
- **Zero Runtime Dependencies**: Uses Costura.Fody to embed all DLLs inside a single `hwReport.dll`.
- **Signed Assembly**: Automatically generates a Strong Name Key (`.snk`) to ensure clean COM registration without `RA0000` warnings.
- **JSON Data Source**: Native support for converting Harbour JSON strings into FastReport DataTables.
- **Dynamic Manipulation**: Pure OLE methods to create, move, and style objects at runtime.
- **Synchronous Callbacks**: Native OLE Event-driven model allowing FastReport to call Harbour functions during report generation without polling.

---

## 🏗️ Technical Stack
- **Languages**: C# (Wrapper), Harbour (Samples), PowerShell (Build automation).
- **Framework**: .NET Framework 4.8 (required for maximum COM compatibility).
- **External Libs**: FastReport OpenSource, Newtonsoft.Json, Costura.Fody.

---

## 📁 Key File Map
- `/ReportWrapper.cs`: Core logic. Handles OLE registration and FastReport lifecycle.
- `/GenerateKey.ps1`: Generates the Strong Name Key (`hwReport.snk`) for assembly signing.
- `/samples/*.prg`: Harbour example programs.
- `/samples/*.frx`: FastReport templates (1:1 mapping with `.prg`).
- `/Build.bat`: Compiles, signs, and registers the DLL (Administrator required).
- `/check_com.bat`: Verifies the OLE object `hwReport.FastReport` is registered.

---

## 🛠️ Critical Patterns & Gotchas

### 1. Synchronous Event Callbacks (OLE Events)
Instead of polling, use `__axRegisterHandler` in Harbour to listen to `OnUserFunctionCall`.
- **Mechanism**: FastReport calls a native bridge method -> C# fires a COM Event -> Harbour executes codeblock -> Results returned to FastReport.
- **Diagnostics**: Use `oFR:SetDiagnostics(.F.)` to mute internal C# ping/state logs in production.

### 2. Runtime Object Creation
When creating objects via `oFR:AddTextObject()` or `oFR:AddPictureObject()`:
- **Units**: The wrapper uses **Centimeters** by default.
- **Naming**: Ensure `objectName` is unique to avoid overwriting existing layout elements.

### 3. Native Function Registration
Use `oFR:RegisterUserFunction("MyFunc", "object p1", ...)` to inject Harbour functions as native C# methods into the report script.
- **Reserved Names**: Avoid naming your Harbour functions as `FormatCurrency` or `Sum`, as they conflict with FastReport's internal methods (causing `CS0111`). Prefix them (e.g., `HbFormatCurrency`).

### 4. Assembly Resolution (Metadata Errors)
The `ReportWrapper.cs` includes a "Surgical Assembly Scan" that manually injects absolute paths for critical DLLs like `mscorlib.dll` and `Microsoft.CSharp.dll` into the `ReferencedAssemblies` list to bypass `CS0006` errors.

### 5. Data Injections
- **Parameters**: Use `oFR:SetParameter("Name", "Value")`.
- **JSON Tables**: Use `oFR:RegisterJsonData("TableName", cJsonString)`.

---

## 🤖 AI Interaction Guidelines
- **COM Visibility**: When adding methods to `ReportWrapper.cs`, update the `IReportWrapper` interface and ensure `[ComVisible(true)]`.
- **Interface Consistency**: Prefer methods (e.g., `SetDiagnostics(bool)`) over direct property assignments to ensure compatibility with different Harbour OLE versions.
- **Administrator Rights**: Always remind the user to run `Build.bat` as **Administrator** to maintain the COM registry and assembly signature.
