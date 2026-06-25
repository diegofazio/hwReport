---
name: changelog-generator
description: Reads recent changes from the repository and updates the CHANGELOG.md file by adding a new entry with the current commit.
---
# Skill: Changelog Generator

## When to use this skill
- Primarily: immediately **after** a successful commit (e.g., after using the `committer` skill).
- When the user explicitly requests to update the CHANGELOG or record the most recent changes.

## Workflow

1. **Get the latest commit**:
   Use the command `git log -1 --pretty=format:"%h|%s|%b|%ad" --date=short` to get the latest commit data.
   - `%h`: Short hash
   - `%s`: Title (Subject)
   - `%b`: Body
   - `%ad`: Date

2. **Verify CHANGELOG.md existence**:
   Check if `CHANGELOG.md` exists in the project root. If it doesn't, create it with a basic initial header:
   ```markdown
   # Changelog

   All notable changes to this project will be documented in this file.
   ```

3. **Format the new entry**:
   Analyze the commit title (which should follow Conventional Commits) to categorize the change.
   Extract the type (e.g., `feat`, `fix`, `refactor`) and format the markdown entry.

   Expected format for adding to the file:
   ```markdown
   ## [Commit Date] - Hash: <hash>

   ### <Capitalized Change Type> (e.g., Features, Fixes, Refactor)
   - **<scope if exists>**: <Short title description>

   <Commit body if it exists, appropriately formatted or summarized if very long>

   ---
   ```

4. **Update CHANGELOG.md**:
   - Read current `CHANGELOG.md` content.
   - The change description must be in **English**.
   - Insert the new formatted entry directly **below** the main header (`# Changelog` and its description) so that the most recent entries are at the top (reverse chronological order).
   - Overwrite `CHANGELOG.md` with the new content.

5. **Commit the Changelog (Optional but recommended)**:
   - If `CHANGELOG.md` was modified, stage the file: `git add CHANGELOG.md`.
   - Create a new chore-type commit: `git commit -m "chore: update changelog"`.

## Expected Output
Upon completion, confirm to the user that `CHANGELOG.md` has been successfully updated with the latest change. Show a brief excerpt of the added entry.
