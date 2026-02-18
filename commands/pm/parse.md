---
description: Convert a spec into an epic and task breakdown (local, for review before syncing)
argument-hint: <project> <feature-name>
model: opus
allowed-tools: Read, Write, AskUserQuestion
---

# /pm:parse

Arguments: $ARGUMENTS
Expected format: `<project> <feature-name>` (e.g., `acme session-notes`)

## Setup

Parse $ARGUMENTS to extract `project` and `feature-name`. If either is missing, stop and tell the user:
"Usage: /pm:parse <project> <feature-name>"

Read these files:
- `<project>/specs/<feature-name>.md`: the spec to parse (required; stop if not found)
- `<project>/CLAUDE.md`: product and technical context

If the spec does not exist, tell the PM: "No spec found at <project>/specs/<feature-name>.md. Run /pm:spec <project> <feature-name> first."

Check if `<project>/epics/<feature-name>/` already exists. If it does, ask the PM if she wants to regenerate it before continuing.

## Create the epic

Create directory `<project>/epics/<feature-name>/`.

Read `templates/epic.md` and use it as the output structure. Fill in all fields from the spec and today's date.

Write the result to `<project>/epics/<feature-name>/epic.md`.

## Create task files

Read the spec carefully. Break it into individual tasks. Each task should represent one clear unit of work a dev can pick up independently.

Follow `/rules/task-quality.md` for all quality standards.
Follow `/rules/frontmatter.md` for frontmatter format.

Rules for task breakdown:
- Maximum 10 tasks per epic. If more are needed, ask the PM to split the spec into two features.
- Each task must map to a specific section of the spec. Set `spec_section` to the exact section name.
- Tasks sized L must include a note in the description explaining how to split further.
- Set `depends_on` as a list of filenames for tasks that must come before (e.g., `[001-task-title.md]`).
- All tasks start with `status: local`.

Read `templates/task.md` and use it as the output structure for each task file.

Name each task file using a zero-padded sequence number and the task title in kebab-case: `001-task-title.md`, `002-another-task.md`, etc.

Write each task to `<project>/epics/<feature-name>/<filename>.md`.

## Quality check

Run `/pm:validate` on all task files created. If any fail, fix them before finishing.

## Summary

After writing all files, print:

```
Epic: <feature-name>
Tasks created: [N]

  001-task-title.md  [S]  Task title
  002-another-task.md  [M]  Task title  (depends on: 001-task-title.md)
  ...

Warnings:
  [Any L-sized tasks, missing acceptance criteria, etc.]

Next step: /pm:sync <project> <feature-name>
```
