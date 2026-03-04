---
name: sync
description: Push local tasks and tickets to GitHub Issues
argument-hint: <project> <feature-name|ticket-name|--all>
model: sonnet
allowed-tools: Read, Write, Bash, AskUserQuestion
disable-model-invocation: true
---

# /pm:sync

Arguments: $ARGUMENTS
Expected format:
- `/pm:sync <project> <feature-name>`: sync one feature's tasks
- `/pm:sync <project> <ticket-name>`: sync one standalone ticket
- `/pm:sync <project> --all`: sync everything not yet synced

## Setup

Parse $ARGUMENTS to extract `project` and `target`. If either is missing:
"Usage: /pm:sync <project> <feature-name|ticket-name|--all>"

Read `<project>/pm-config.md` (required). Extract `github_repo`. If pm-config.md is not found, stop:
"No pm-config.md found for <project>. Create one first."

If `.claude/overrides/rules/frontmatter.md` exists, Read and follow it instead of the auto-loaded `/rules/frontmatter.md`.
If `.claude/overrides/rules/github-labels.md` exists, Read and follow it instead of the auto-loaded `/rules/github-labels.md`.
If `.claude/overrides/rules/task-quality.md` exists, Read and follow it instead of the auto-loaded `/rules/task-quality.md`.

## Step 1: Collect what will be synced

Depending on the target:

**Single feature** (`feature-name`):
- Read all task files in `<project>/tasks/<feature-name>/` (all .md files)
- Skip any tasks that already have a `github_id` set (already synced)

**Single ticket** (`ticket-name`):
- Read `<project>/tickets/<ticket-name>.md`
- If it already has a `github_id`, stop: "This ticket is already synced at <github_url>"

**All** (`--all`):
- Scan `<project>/tasks/` for any task file with `status: local`
- Scan `<project>/tickets/` for any ticket with `status: local`
- Collect all of them

## Step 2: Quality check

Run `/pm:validate` on all files collected in Step 1. If any file fails validation, list the failures clearly and stop. Do not create any GitHub issues.
"These items have quality issues and cannot be synced. Fix them and try again:"

## Step 3: Milestone

Fetch existing milestones from the repo:
```bash
gh api repos/<owner>/<repo>/milestones --jq '.[].title'
```

Use AskUserQuestion to ask: "Assign a milestone to all items in this sync?" with options:
- Each existing milestone by name
- "Create new milestone"
- "No milestone"

If "Create new milestone": ask for the name and optional due date, then create it:
```bash
gh api repos/<owner>/<repo>/milestones -f title="<name>" -f due_on="<date>"
```
If no due date, omit the `-f due_on` flag.

Store the chosen milestone name for use in Step 6. If "No milestone", skip adding `--milestone` to issue creation commands.

## Step 4: Preview

Show the PM a clear preview of what will be created:

```
Ready to sync to [github_repo]:

feature-name:
  #  001-task-title.md  [S]  Task title 1
  #  002-task-title.md  [M]  Task title 2  (depends on: 001-task-title.md)

TICKETS:
  #  fix-login-redirect.md  [bug, XS]  Fix login redirect

Milestone: <chosen milestone or "none">
Total: 2 tasks, 1 ticket = 3 GitHub issues

Proceed? (yes/no)
```

Use AskUserQuestion to get confirmation. If the PM says no, stop cleanly.

## Step 5: Ensure labels exist

For each label defined in the labels rule loaded in setup, check if it exists in the repo:
```bash
gh label list --repo <github_repo> --json name
```

Create any missing labels:
```bash
gh label create "<label>" --repo <github_repo> --color "<color>" --description "<desc>"
```

## Step 6: Create GitHub issues

The body of each GitHub issue is the markdown content of the local file, with the YAML frontmatter stripped. Do not reformat or restructure the content. The file is already the issue. Skip any section whose body is empty (e.g., an empty `## Notes` section).

For tasks only, append a footer after the last section:
```
---
_Spec section: <spec_section value>_
```

### For tasks

Process in order, respecting `depends_on` (create dependencies first).

```bash
gh issue create \
  --repo <github_repo> \
  --title "<title from task frontmatter>" \
  --body "<task file content with frontmatter stripped + footer>" \
  --label "task,<size-label>" \
  --milestone "<milestone name>"   # omit if no milestone chosen
```

After creating each issue:
- Rename the file: `001-task-title.md` -> `<issue-number>-task-title.md`
- Update frontmatter: `status: synced`, `github_url`, `github_id`, `updated`

If any issue creation fails: report it clearly but continue with the rest. At the end, list what succeeded and what failed.

### For standalone tickets

```bash
gh issue create \
  --repo <github_repo> \
  --title "<title from ticket frontmatter>" \
  --body "<ticket file content with frontmatter stripped>" \
  --label "<type>,<size-label>" \
  --milestone "<milestone name>"   # omit if no milestone chosen
```

Update ticket frontmatter: `status: synced`, `github_url`, `github_id`, `updated`.

## Step 7: Summary

Print a summary of what was created:

```
Synced to [github_repo]:

  Task  #43:  Task title 1   [S]  -> <url>
  Task  #44:  Task title 2   [M]  -> <url>
  Bug   #45:  Fix login redirect  -> <url>

3 issues created.
```

If there were failures, list them at the end.
