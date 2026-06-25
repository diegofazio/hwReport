---
name: committer
description: Creates structured commits using Conventional Commits, with a brief title and a detailed description of the changes.
---

# Skill: Structured Commit Generator

## When to use this skill
- When the user requests to commit current changes to the repository.
- As a final step or checkpoint after completing a significant task or refactor.

## Workflow

1. **Review Status**: Use the `git status` command to see which files have changed.
2. **Review Changes**: Use `git diff` (and `git diff --cached`) to understand the exact nature of the changes and their impact.
3. **Prepare Changes**: Use `git add <files>` to add files to the staging area, or `git add .` as appropriate.
4. **Generate Changelog (Automatic)**: Before the commit, you must auto-execute the `changelog-generator` skill so the commit is registered in `CHANGELOG.md` and include that change in an internal sub-commit.
5. **Update README (Automatic)**: Execute the `readme-documenter` skill to verify that the changes are reflected in the `README.md` file, provided the changes are relevant to the end user.
6. **Create Commit**: Execute the commit message structuring command `git commit` (usually `git commit -m "Title" -m "Descriptive body"`).
7. **Perform Push (Optional)**: If the user requested to "push" (or "upload changes"), execute `git push` only **after** successfully generating the changelog.

## Commit Format (Conventional Commits)

The commit message must **obligatorily** be divided into two parts: a **Title** (Header) and an extensive, well-reasoned **Body**.

```text
<type>[optional scope]: <strict short title>

<extensive body explaining context, what and why>
```

### 1. Title Rules (Header)
- **The title must always be in English**.
- **Maximum length:** 50 characters (strict).
- **Format:** `<type>: <imperative description>`. It must not end with a period.
- Use lowercase for `type` and `scope`.
- The action description must use the English imperative verb mode (e.g., "add", "fix", "update" instead of "added", "fixed", or "updates").
- **Allowed types:**
  - `feat`: A new feature or functionality.
  - `fix`: Fixing a bug or code error.
  - `docs`: Documentation changes (`README.md`, `CONTEXT.md`, etc.).
  - `style`: Visual formatting changes that do not affect actual functionality (spacing, quotes).
  - `refactor`: A code change that neither fixes a bug nor adds functionality but improves design.
  - `perf`: A code change focused on improving overall performance.
  - `test`: Adding, updating, or fixing tests.
  - `build`: Changes affecting static dependencies and the main build.
  - `ci`: Changes to continuous integration or automation scripts.
  - `chore`: Trivial maintenance tasks, miscellaneous, minor exclusions.

*Example title:* `feat(auth): require login for technician system`
*Example title:* `fix: resolve task rendering delay on login`

### 2. Body Rules (Body)
- **The Body must always be in English**.
- It must be separated from the title by **exactly one blank line**. If using a terminal, execute: `git commit -m "title" -m "body"`.
- **Extensive description:** It is mandatory to exhaustively explain **WHAT** was changed and **WHY** the change was made, not just "how" it was structured (as the code diff implicitly describes this).
- It must answer:
  - What was the context or problem prior to the commit?
  - What approach did you take to resolve it?
  - Are there side effects, or did you change database tables or global variables?
- Using bulleted lists (`- ` or `* `) is suggested if multiple components are modified.

### Full Execution Example

```bash
git commit -m "feat(ui): add visual indicators for overdue tasks" -m "Previously, overdue tasks were not easily distinguishable out-of-the-box in the main Maintenance grid, leading to potential operator oversight.

This commit introduces a new robust color-coding pattern relying directly on the backend 'ui_status' logical state.

- Updated Maintenance.jsx to parse ui_status properly and inject corresponding CSS classes.
- Adjusted index.css to refine the status-red, status-yellow, and status-green visual accents honoring the glassmorphism theme.
- Ensured that the standalone TV Visualization module replicates these color conventions."
```

## Output
Upon successful completion of this skill, report back to the user with a brief summary: the generated commit Title and a small confirmation that the changes are now tracked, omitting unnecessary raw console logs.
