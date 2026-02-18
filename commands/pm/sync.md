---
description: Push local specs/epics/tickets to GitHub Issues after review
argument-hint: <project> <feature-name|ticket-name|--all>
model: opus
allowed-tools: Read, Write, Bash, AskUserQuestion
---

# /pm:sync

Arguments: $ARGUMENTS
Expected format:
- `/pm:sync <project> <feature-name>`: sync one epic and its tasks
- `/pm:sync <project> <ticket-name>`: sync one standalone ticket
- `/pm:sync <project> --all`: sync everything not yet synced

## Setup

Parse $ARGUMENTS to extract `project` and `target`. If either is missing:
"Usage: /pm:sync <project> <feature-name|ticket-name|--all>"

Read `<project>/pm-config.md` (required). Extract `github_repo`. If pm-config.md is not found, stop:
"No pm-config.md found for <project>. Create one first."

Follow `/rules/frontmatter.md` for reading and updating frontmatter.
Follow `/rules/github-labels.md` for label names and creation rules.
Follow `/rules/task-quality.md` for quality gates.

## Step 1: Collect what will be synced

Depending on the target:

**Single epic** (`feature-name`):
- Read `<project>/epics/<feature-name>/epic.md`
- Read all task files in `<project>/epics/<feature-name>/` (all .md files except epic.md)
- Skip any tasks that already have a `github_id` set (already synced)

**Single ticket** (`ticket-name`):
- Read `<project>/tickets/<ticket-name>.md`
- If it already has a `github_id`, stop: "This ticket is already synced at <github_url>"

**All** (`--all`):
- Scan `<project>/epics/` for any epic.md with `status: local`
- Scan `<project>/tickets/` for any ticket with `status: local`
- Collect all of them

## Step 2: Quality check

Run `/pm:validate` on all files collected in Step 1. If any file fails validation, list the failures clearly and stop. Do not create any GitHub issues.
"These items have quality issues and cannot be synced. Fix them and try again:"

## Step 3: Preview

Show the PM a clear preview of what will be created:

```
Ready to sync to [github_repo]:

EPIC: Feature Name
  #  001-task-title.md  [S]  Task title 1
  #  002-task-title.md  [M]  Task title 2  (depends on: 001-task-title.md)

TICKETS:
  #  fix-login-redirect.md  [bug, XS]  Fix login redirect

Total: 1 epic, 2 tasks, 1 ticket = 4 GitHub issues

Proceed? (yes/no)
```

Use AskUserQuestion to get confirmation. If the PM says no, stop cleanly.

## Step 4: Ensure labels exist

For each label in `/rules/github-labels.md`, check if it exists in the repo:
```bash
gh label list --repo <github_repo> --json name
```

Create any missing labels:
```bash
gh label create "<label>" --repo <github_repo> --color "<color>" --description "<desc>"
```

## Step 5: Create GitHub issues

The body of each GitHub issue is the markdown content of the local file, with the YAML frontmatter stripped. Do not reformat or restructure the content. The file is already the issue. Skip any section whose body is empty (e.g., an empty `## Notes` section).

For tasks only, append a footer after the last section:
```
---
_Part of epic: #<epic-issue-number>_
_Spec section: <spec_section value>_
```

### For epics

```bash
gh issue create \
  --repo <github_repo> \
  --title "<title from epic.md frontmatter>" \
  --body "<epic.md content with frontmatter stripped>" \
  --label "epic"
```

Capture the issue number and URL. Update `epic.md` frontmatter:
- `status: synced`
- `github_url: <url>`
- `github_id: <number>`
- `updated: <today>`

### For tasks

Process in order, respecting `depends_on` (create dependencies first).

```bash
gh issue create \
  --repo <github_repo> \
  --title "<title from task frontmatter>" \
  --body "<task file content with frontmatter stripped + footer>" \
  --label "task,<size-label>"
```

After creating each issue:
- Rename the file: `001-task-title.md` -> `<issue-number>-task-title.md`
- Update frontmatter: `status: synced`, `github_url`, `github_id`, `updated`
- Update the epic.md task breakdown table with the issue number

If any issue creation fails: report it clearly but continue with the rest. At the end, list what succeeded and what failed.

### For standalone tickets

```bash
gh issue create \
  --repo <github_repo> \
  --title "<title from ticket frontmatter>" \
  --body "<ticket file content with frontmatter stripped>" \
  --label "<type>,<size-label>"
```

Update ticket frontmatter: `status: synced`, `github_url`, `github_id`, `updated`.

## Step 6: Summary

Print a summary of what was created:

```
Synced to [github_repo]:

  Epic #42:   Feature Name        -> <url>
  Task  #43:  Task title 1   [S]  -> <url>
  Task  #44:  Task title 2   [M]  -> <url>
  Bug   #45:  Fix login redirect  -> <url>

4 issues created.
```

If there were failures, list them at the end.
