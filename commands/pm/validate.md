---
description: Validate one or more PM files against quality and frontmatter standards
argument-hint: <file-path> [file-path ...]
model: opus
allowed-tools: Read
---

# /pm:validate

Arguments: $ARGUMENTS
Expected format: one or more file paths to validate (e.g., `acme/epics/onboarding/001-build-wizard.md`)

## Setup

Parse $ARGUMENTS as a list of file paths. If no arguments are given, stop:
"Usage: /pm:validate <file-path> [file-path ...]"

Read `/rules/task-quality.md` and `/rules/frontmatter.md` to load the current standards.

## Validate each file

For each file path provided:

1. Read the file.
2. Determine its type from the `type` field in frontmatter (`task`, `ticket`, `epic`, `spec`).
3. Run all applicable quality gates listed below.

### Quality gates (tasks and tickets)

- **Verb title**: Title must start with a verb (e.g., "Add", "Fix", "Build", "Update"). Reject titles that start with a noun or adjective.
- **Non-empty description**: The `## Description` section must exist and contain real content. Placeholder text ("TBD", "TODO", "placeholder") fails this gate.
- **Acceptance criteria count**: Must have at least 2 items in `## Acceptance criteria`. Unchecked (`- [ ]`) or checked (`- [x]`) both count.
- **Size set**: The `size` field in frontmatter must be one of: XS, S, M, L. Empty or missing fails.
- **No placeholder text**: No field or section body may contain "TBD", "TODO", or "placeholder" (case-insensitive).

### Additional gate (tasks only)

- **spec_section set**: The `spec_section` field must be present and non-empty. This is the traceability link to the spec.

### Frontmatter completeness

- All required fields for the file type must be present (per `/rules/frontmatter.md`).
- `github_url` and `github_id` must be blank (empty value, not missing key) for local files.
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

acme/epics/onboarding/001-build-wizard.md
  - Title does not start with a verb: "Onboarding wizard setup"
  - Missing acceptance criteria (found 1, need at least 2)

acme/tickets/export-csv.md
  - Description contains placeholder text: "TBD"
  - Size is not set

[N] file(s) checked. [M] passed, [K] failed.
```

Stop after reporting. Do not attempt to fix files automatically unless the calling command explicitly asks you to fix them.
