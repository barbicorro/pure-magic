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
- `<project>/specs/<feature-name>.md` -- the spec to parse (required; stop if not found)
- `<project>/CLAUDE.md` -- product and technical context

If the spec does not exist, tell the PM: "No spec found at <project>/specs/<feature-name>.md. Run /pm:spec <project> <feature-name> first."

Check if `<project>/epics/<feature-name>/` already exists. If it does, ask the PM if she wants to regenerate it before continuing.

## Create the epic

Create directory `<project>/epics/<feature-name>/`.

Write `<project>/epics/<feature-name>/epic.md` using this format:

```
---
title: <Feature Name>
type: epic
status: local
created: <today>
updated: <today>
github_url:
github_id:
spec: specs/<feature-name>.md
---

# <Feature Name> -- Epic

## Overview
[Brief summary of the full scope and technical approach based on the spec]

## Task Breakdown

| # | Title | Size | Depends on |
|---|---|---|---|
| 001 | [task title] | [size] | -- |
| 002 | [task title] | [size] | 001 |

## Notes
[Any implementation notes or decisions made during planning]
```

## Create task files

Read the spec carefully. Break it into individual tasks. Each task should represent one clear unit of work a dev can pick up independently.

Follow `/rules/task-quality.md` for all quality standards.
Follow `/rules/frontmatter.md` for frontmatter format.

Rules for task breakdown:
- Maximum 10 tasks per epic. If more are needed, ask the PM to split the spec into two features.
- Each task must map to a specific section of the spec. Set `spec_section` to the exact section name.
- Tasks sized L must include a note in the description explaining how to split further.
- Set `depends_on` as a list of filenames for tasks that must come before (e.g., `[001.md]`).
- All tasks start with `status: local`.

Write each task as `<project>/epics/<feature-name>/001.md`, `002.md`, etc. using this format:

```
---
title: [Action verb + what]
type: task
status: local
size: [XS|S|M|L]
created: <today>
updated: <today>
depends_on: []
spec_section: "[Section Name > Subsection]"
github_url:
github_id:
---

# [Task title]

## Description
[What needs to be done and why. Enough for a dev to start without asking basic questions.]

## Acceptance criteria
- [ ] [Verifiable criterion]
- [ ] [Verifiable criterion]

## Notes
[Edge cases, implementation hints, or design references]
```

## Quality check

Before finishing, verify every task has:
- A title that starts with a verb
- A non-empty description
- At least 2 acceptance criteria
- A `spec_section` set
- A size set
- No placeholder text ("TBD", "TODO", etc.)

If any task fails these checks, fix it before finishing.

## Summary

After writing all files, print:

```
Epic: <feature-name>
Tasks created: [N]

  001.md  [S]  Task title
  002.md  [M]  Task title  (depends on: 001)
  ...

Warnings:
  [Any L-sized tasks, missing acceptance criteria, etc.]

Next step: /pm:sync <project> <feature-name>
```
