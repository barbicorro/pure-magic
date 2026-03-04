---
name: pm-parse
description: Convert a spec into a task breakdown (local, for review before syncing)
argument-hint: <project> <feature-name>
model: sonnet
allowed-tools: Read, Write, AskUserQuestion
disable-model-invocation: true
---

# /pm-parse

Arguments: $ARGUMENTS
Expected format: `<project> <feature-name>` (e.g., `acme session-notes`)

## Setup

Parse $ARGUMENTS to extract `project` and `feature-name`. If either is missing, stop and tell the user:
"Usage: /pm-parse <project> <feature-name>"

Read these files:
- `<project>/specs/<feature-name>.md`: the spec to parse (required; stop if not found)
- `<project>/CLAUDE.md`: product and technical context

If the spec does not exist, tell the PM: "No spec found at <project>/specs/<feature-name>.md. Run /pm-spec <project> <feature-name> first."

Check if `<project>/tasks/<feature-name>/` already exists. If it does, ask the PM if she wants to regenerate it before continuing.

## Pre-write checks

Before writing any task file, read the full spec and apply these checks:

**Goal mapping**: For each feature in the spec, check if it maps to a stated goal in the Problem Statement section. If a feature has no clear goal link, add a note in the task description and ask the PM to confirm it belongs in scope before writing that task.

**Duplicate data**: For each metric, total, score, or computed value in the spec, check if the same value already exists elsewhere in the product (as described in the spec or `<project>/pm-config.md`). If it does, flag it and ask the PM to confirm it is intentional before writing the task.

## Create task files

Create directory `<project>/tasks/<feature-name>/`.

Read the spec carefully. Break it into individual tasks. Each task should represent one clear unit of work a dev can pick up independently.

If `.claude/overrides/rules/task-quality.md` exists, Read and follow it instead of the auto-loaded `/rules/task-quality.md`.
If `.claude/overrides/rules/frontmatter.md` exists, Read and follow it instead of the auto-loaded `/rules/frontmatter.md`.

Rules for task breakdown:
- Maximum 10 tasks per feature. If more are needed, ask the PM to split the spec into two features.
- Each task must map to a specific section of the spec. Set `spec_section` to the exact section name.
- Tasks sized L must include a note in the description explaining how to split further.
- Set `depends_on` as a list of filenames for tasks that must come before (e.g., `[001-task-title.md]`).
- All tasks start with `status: local`.
- If a spec section describes any computed value (sum, average, count, subtraction, percentage, ratio, score, or similar), the task must include the explicit formula: what is computed, the inputs used, the denominator if any, and the scope or filters applied. If the spec does not provide this, ask the PM before writing the task.
- If a spec section describes a chart or visualisation, the task must include a full visual spec: chart type, X-axis labels and format, Y-axis unit and starting point, any overlay or comparison behaviour, tooltip fields, and legend. If the spec only says "a chart showing X" without this detail, ask the PM before writing the task.
- If two features in the same spec section have different open questions, or one may be cut while the other proceeds, give them separate tasks.
- If a task depends on a definition (e.g., "active user", "completed session", "at-risk client"), the task must cover: what is included in that definition, what is excluded, whether the categories are mutually exclusive, and the relevant edge cases.

Read `.claude/overrides/templates/task.md` if it exists, otherwise read `.claude/templates/task.md`. Use it as the output structure for each task file.

Name each task file using a zero-padded sequence number and the task title in kebab-case: `001-task-title.md`, `002-another-task.md`, etc.

Write each task to `<project>/tasks/<feature-name>/<filename>.md`.

## Quality check

Run `/pm-validate` on all task files created. If any fail, fix them before finishing.

## Summary

After writing all files, print:

```
Tasks created: [N]

  001-task-title.md  [S]  Task title
  002-another-task.md  [M]  Task title  (depends on: 001-task-title.md)
  ...

Warnings:
  [Any L-sized tasks, missing acceptance criteria, etc.]

Next step: /pm-sync <project> <feature-name>
```
