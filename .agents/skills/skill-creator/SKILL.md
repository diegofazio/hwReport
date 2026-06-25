---
name: skill-creator
description: Generates new skills following the official Antigravity standard (Plan, Validate, Execute).
---
# Skill Creator for Antigravity

## When to use this skill
- When the user asks to create a new skill.
- When the user repeats a process that should be standardized.
- When there is a need to convert a long prompt into a reusable procedure.

## Required Inputs
- Topic or functionality of the skill to be created.
- (Optional) Desired freedom level (High, Medium, Low).

## Workflow
1) **Planning**: Define the name (lowercase, hyphens) and the operational description.
2) **Structure**: Define which folders (`resources`, `scripts`, `examples`) are necessary.
3) **Writing**: Draft the `SKILL.md` with YAML frontmatter and clear sections.
4) **Validation**: Review to ensure there is no filler and that the output is standardized.

## Instructions
- Faithfully follow the standard defined in `resources/base-instructions.md`.
- Do not create unnecessary files.
- Define concrete and easy-to-recognize triggers.

## Output (exact format)
Return:
1. Folder path (`.agent/skills/...`)
2. Full content of `SKILL.md`.
3. Content of additional resources if applicable.

## Optional Resources
- `resources/base-instructions.md`: Reference to the user's original document.
