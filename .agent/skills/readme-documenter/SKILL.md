---
name: readme-documenter
description: Analyzes recent changes and updates README.md before committing to ensure technical documentation is accurate.
---
# README Documenter

## When to use this skill
- **ALWAYS before making a commit** that includes functional changes.
- When adding new methods to `ReportWrapper.cs`.
- When modifying the architecture or system requirements.
- When adding new examples to the `samples/` directory.

## Required Inputs
- List of modified files or a summary of recent changes.
- Current `README.md` file for reference.

## Workflow
1. **Detection**: Identify significant changes (new methods in `IReportWrapper`, changes to `Build.bat`, new `.frx`/`.prg` files).
2. **Analysis**: Determine which section of `README.md` needs to be updated (API Reference, Project Structure, Architecture Notes).
3. **Editing**: Apply changes to `README.md` maintaining a professional and concise style.
4. **Verification**: Ensure that file links and technical descriptions are correct.

## Policies
- Do not delete relevant historical information; only add or correct.
- Maintain the existing table and header format.
- Use emojis moderately and professionally (🚀, 📂, 🛠️).
- **CRÍTICO**: If a new functionality is added in C#, ensure the exact OLE method name is documented.

## Usage Example
"I've added a `SetOrientation` method to the DLL. Running `readme-documenter` to update the 'Component Manipulation' section before committing."
