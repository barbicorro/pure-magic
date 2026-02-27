---
name: pm-validate
description: Validate one or more PM files against quality and frontmatter standards
argument-hint: <file-path> [file-path ...]
model: opus
allowed-tools: Read
---

# /pm-validate

Arguments: $ARGUMENTS
Expected format: one or more file paths to validate (e.g., `acme/tasks/onboarding/001-build-wizard.md`)

## Setup

Parse $ARGUMENTS as a list of file paths. If no arguments are given, stop:
"Usage: /pm-validate <file-path> [file-path ...]"

For each rule, check for a project override first:
- If `.claude/overrides/rules/task-quality.md` exists, Read it; otherwise the auto-loaded `/rules/task-quality.md` is already in context.
- If `.claude/overrides/rules/frontmatter.md` exists, Read it; otherwise the auto-loaded `/rules/frontmatter.md` is already in context.
- If `.claude/overrides/rules/interview-quality.md` exists, Read it; otherwise the auto-loaded `/rules/interview-quality.md` is already in context.

Follow override versions where they exist; fall back to the auto-loaded defaults.

## Validate each file

For each file path provided:

1. Read the file.
2. Determine its type from the `type` field in frontmatter (`task`, `ticket`, `spec`, `interview`).
3. Run all applicable quality gates listed below.

### Quality gates (interview files)

Apply the standards from the interview-quality rule loaded in setup (override if present, default otherwise). Summary of gates:

- **Goal set**: The `goal` frontmatter field must be non-empty and not placeholder text.
- **Customer segment set**: The `customer_segment` field must be non-empty and not placeholder text.
- **Minimum questions**: At least 5 core questions must appear in the `## Core questions` section.
- **Intention on every question**: Every question block must include an `**Intention:**` field.
- **No anti-patterns**: Flag questions matching Mom Test anti-patterns (future hypotheticals, leading questions, pitching). These are warnings, not hard failures.
- **No placeholder text**: No field or section may contain "TBD", "TODO", or "placeholder" (case-insensitive).

Interview validation failures are reported as warnings. They do not block sync (interviews are not synced to GitHub).

### Quality gates (tasks and tickets)

- **Verb title**: Title must start with a verb (e.g., "Add", "Fix", "Build", "Update"). Reject titles that start with a noun or adjective.
- **Non-empty description**: The `## Description` section must exist and contain real content. Placeholder text ("TBD", "TODO", "placeholder") fails this gate.
- **Acceptance criteria count**: Must have at least 2 items in `## Acceptance criteria`. Unchecked (`- [ ]`) or checked (`- [x]`) both count.
- **Size set**: The `size` field in frontmatter must be one of: XS, S, M, L. Empty or missing fails.
- **No placeholder text**: No field or section body may contain "TBD", "TODO", or "placeholder" (case-insensitive).

### Additional gate (tasks only)

- **spec_section set**: The `spec_section` field must be present and non-empty. This is the traceability link to the spec.

### Frontmatter completeness

- All required fields for the file type must be present (per the frontmatter rule loaded in setup).
- For `task` and `ticket` files only: `github_url` and `github_id` must be blank (empty value, not missing key). Interview and spec files do not have these fields.
- Dates must be in ISO 8601 format: YYYY-MM-DD.

## Output

After checking all files, return a structured result.

If all files pass:
```
Validation passed: [N] file(s) checked, all OK.
```

If any file fails, list each failure clearly:
```
Validation failed:

acme/tasks/onboarding/001-build-wizard.md
  - Title does not start with a verb: "Onboarding wizard setup"
  - Missing acceptance criteria (found 1, need at least 2)

acme/tickets/export-csv.md
  - Description contains placeholder text: "TBD"
  - Size is not set

[N] file(s) checked. [M] passed, [K] failed.
```

Stop after reporting. Do not attempt to fix files automatically unless the calling skill explicitly asks you to fix them.
