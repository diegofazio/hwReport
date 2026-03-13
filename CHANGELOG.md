# Changelog

All notable changes to this project will be documented in this file.

## [2026-03-13] - Hash: c68f3b0

### Features
- **tools**: Added `unregister.bat` script to cleanly remove both x86 and x64 COM registrations from the system.
- **docs**: Updated `README.md` to include unregistration steps for all installation methods.

---

## [2026-03-13] - Hash: c86de78

### Features
- **build**: Implemented a multi-architecture build system with dedicated `build32.bat` and `build64.bat` scripts.
- **build**: Updated `hwReport.csproj` to target `AnyCPU`, enabling the DLL to operate in both 32-bit and 64-bit processes.
- **build**: Restored and updated the main `build.bat` as a unified wrapper for full-platform builds.
- **core**: Added `Bitness` property to the OLE interface for runtime identification of the hosting process architecture.
- **tools**: Substantially enhanced `check_com.bat` and `test_com.vbs` to independently verify and report the registration status of both x86 and x64 architectures.
- **dist**: Restructured distribution folders to `dist/x86/` and `dist/x64/` for improved clarity and deployment.

---

## [2026-03-13] - Hash: ff545e5

### Features
- **core**: Added `AddHyperlinkObject`, `SetHyperlink`, and `SetUnderline` methods for hyperlink support.
- **samples**: Added `10_hyperlinks.prg` and `10_hyperlinks.frx` demonstrating hyperlink creation and manipulation.
- **docs**: Updated `README.md` with hyperlink API documentation.

*Note: FPX support was attempted but reverted due to persistent COM registration issues.*

---

## [2026-03-12] - Hash: 82dbe9e

### Features
- **core**: Implemented `IReportEvents` and synchronous OLE events for dynamic callback execution.
- **core**: Added `RegisterUserFunction` with C# script injection for native Harbour function calls within FRX.
- **core**: Added `SetDiagnostics(bool)` method to control internal C# console logging globally.
- **samples**: Added `09_callbacks.prg` and `09_callbacks.frx` demonstrating event-driven communication and dynamic script injection.
- **build**: Integrated automatic Strong Name Key (`.snk`) generation and assembly signing into `hwReport.csproj` and `Build.bat` to eliminate RegAsm `RA0000` warnings.
- **samples**: Improved syntax and error handling across multiple sample programs.

---

## [2026-03-12] - Hash: e331721

### Features
- **core**: Added `AddTextObject` and `AddPictureObject` for runtime report creation.
- **core**: Added `SetUnits` to support mm, cm, in, and 1/100in.
- **core**: Added `SetCodePage` and smart string processing with UTF-8 detection.
- **core**: Added `SetFont`, `SetAlignment`, `SetColor`, and `SetTextColor` for runtime object styling.
- **samples**: Added `07_runtime_creation.prg` and `08_properties.prg` (English version).

### Fixes
- **core**: Fixed visibility issue where dynamically added objects did not appear in PDF exports.
- **build**: Fixed missing DataTable declaration error.

---

## [2026-03-12] - Hash: 1b44171

### Documentation
- **skills**: Translated all project skills to technical English and renamed directories for consistency.
- **skills**: Updated 'committer' skill rules to strictly require English commit messages.

The project skills were previously documented in Spanish. This commit translates all SKILL.md files to technical English and renames the skill directories to follow a consistent English naming convention. Additionally, it updates the 'committer' skill policy to strictly require English for both commit titles and bodies.

---

## [2026-03-12] - Hash: e189a58
### Features
- **core**: Initial OLE/COM wrapper implementation for FastReport OpenSource.
- **core**: Native Harbour JSON data injection support.
- **core**: Surgical Assembly Scanning for restricted OLE environments.
- **core**: Costura.Fody integration for zero-dependency single-DLL deployment.
- **core**: New `ExportToHtml` method for generating self-contained web reports with embedded images.
- **samples**: Gallery of 6 Harbour examples with 1:1 mapping to optimized FRX templates.
- **samples**: Professional redesign of invoice and label templates with QR and Barcode support.
- **tools**: `check_com.bat` utility for OLE registration verification.
- **tools**: Enhanced `Build.bat` with automatic administrative registration.
- **docs**: Comprehensive documentation in `README.md`, `AGENTS.md`, and step-by-step guides.
- **docs**: Professional technical English translation for all Harbour samples and report templates.
- **skills**: Implementation of automated commit and documentation skills.

### Bug Fixes
- **script**: Removed `Sum()` functions in internal scripts in favor of native Engine Totals to bypass metadata resolution errors.
- **layout**: Resolved visual overlaps in the Showcase report header.

---
