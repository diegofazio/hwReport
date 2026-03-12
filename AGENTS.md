# AGENTS.md - hwReport Knowledge Base

This document provides a technical overview of the `hwReport` project for AI assistants and developers.

## 🚀 Project Overview
`hwReport` is an OLE/COM wrapper for **FastReport OpenSource**, designed to provide professional reporting capabilities to **Harbour/clippper** applications.

### Key Features:
- **Zero Runtime Dependencies**: Uses Costura.Fody to embed all DLLs inside a single `hwReport.dll`.
- **JSON Data Source**: Native support for converting Harbour JSON strings into FastReport DataTables.
- **Dynamic Manipulation**: Pure OLE methods to move objects, change texts/images, and control visibility.

---

## 🏗️ Technical Stack
- **Languages**: C# (Wrapper), Harbour (Samples), VBScript (Testing).
- **Framework**: .NET Framework 4.8 (required for maximum COM compatibility).
- **External Libs**: FastReport OpenSource, Newtonsoft.Json, Costura.Fody.

---

## 📁 Key File Map
- `/ReportWrapper.cs`: Core logic. Handles OLE registration and FastReport lifecycle.
- `/samples/*.prg`: Harbour example programs.
- `/samples/*.frx`: FastReport templates (1:1 mapping with `.prg`).
- `/Build.bat`: Compiles and registers the DLL (Administrator required).
- `/check_com.bat`: Verifies the OLE object `hwReport.FastReport` is registered.
- `/test_com.vbs`: Low-level VBScript to test COM instantiation.

---

## 🛠️ Critical Patterns & Gotchas

### 1. Script Compilation vs. Engine Logic
> [!IMPORTANT]
> **Avoid using `Sum()` or complex C# scripts inside `.frx` templates.**
> FastReport attempts to compile these via `Microsoft.CSharp`, which often fails in OLE/COM environments due to assembly resolution issues.
> **Fix**: Use native **Total Objects** (Dictionary -> Totals) which are handled by the engine without script compilation.

### 2. Assembly Resolution (Metadata Errors)
If you see `CS0006` (Metadata file not found), it refers to the FastReport script compiler being unable to find `.NET` DLLs. 
- **Solution**: The `ReportWrapper.cs` includes a "Surgical Assembly Scan" that manually injects absolute paths for critical DLLs like `mscorlib.dll` and `Microsoft.CSharp.dll` into the `ReferencedAssemblies` list.

### 3. Data Injections
- **Parameters**: Use `oFR:SetParameter("Name", "Value")`. Ideal for simple labels or variables.
- **JSON Tables**: Use `oFR:RegisterJsonData("TableName", cJsonString)`. In the report, use `[TableName.ColumnName]`.

### 4. Naming Conventions
- Maintain the **1:1 mapping**: If a sample is `99_test.prg`, its template must be `99_test.frx`.

---

## 🤖 AI Interaction Guidelines
- When adding methods to `ReportWrapper.cs`, ensure the `IReportWrapper` interface is updated and `[ComVisible(true)]` is maintained.
- Always check `.frx` XML integrity. Malformed XML (like nested bands) will cause cryptic "Missing context" errors.
- If modifying the DLL, remind the user to run `Build.bat` as **Administrator**.
