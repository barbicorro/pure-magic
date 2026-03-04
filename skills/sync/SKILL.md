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

Split `github_repo` on `/` to get `owner` (first segment) and `repo` (second segment). Use these separately in all commands that require them.

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

## Step 3.5: GitHub Project

Fetch the owner's projects:
```bash
gh project list --owner <owner> --format json
```

This returns a JSON array. Each project has `number`, `title`, and `id` (the GraphQL node ID). Build a display list of `title (#number)` for the PM to choose from.

Use AskUserQuestion to ask: "Add all items to a GitHub project?" with options:
- Each project by title
- "No project"

If a project is chosen, store both its `number` (used with `gh project item-add`) and its `id` node ID (used with `gh project item-edit`). If "No project", skip the project step entirely.

## Step 4: Preview

Show the PM a clear preview of what will be created:

```
Ready to sync to [github_repo]:

feature-name:
  #  task-title.md  [S] [P1]  Task title 1
  #  another-task.md  [M]      Task title 2  (depends on: task-title.md)

TICKETS:
  #  fix-login-redirect.md  [bug, XS] [P2]  Fix login redirect

Milestone: <chosen milestone or "none">
Project:   <chosen project or "none">
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

Maintain a visited set of filenames already processed in this sync run to prevent infinite loops from circular dependencies.

Before creating a task's issue, check its `depends_on` list. For each dependency filename listed:
- If the filename is already in the visited set, skip it.
- Add it to the visited set, then read the file and check if it has a `github_id`.
- If it does not, sync that dependency first (create its GitHub issue and update its frontmatter) before continuing with the current task.
- Repeat recursively until all dependencies in the chain have a `github_id`.

If a circular dependency is detected (a file depends on a file that is already mid-sync), report it clearly and skip that dependency: "Circular dependency detected: <filename> -> <dep> -> ... -> <filename>. Skipping."

When creating an issue for a task that has `depends_on`, append a "Blocked by" section to the issue body after the spec footer:
```
**Blocked by:** #<github_id>, #<github_id>
```
Only include dependencies that have a `github_id` (all of them will, after the auto-sync step above).

```bash
gh issue create \
  --repo <github_repo> \
  --title "<title from task frontmatter>" \
  --body "<task file content with frontmatter stripped + footer + blocked-by line if applicable>" \
  --label "task,<size-label>" \
  --milestone "<milestone name>"   # omit if no milestone chosen
```

After creating each issue:
- Update frontmatter: `status: synced`, `github_url`, `github_id`, `updated`
- Do not rename the file.
- If a project was chosen, add the issue to it and capture the returned item ID:
```bash
gh project item-add <project-number> --owner <owner> --url <issue-url> --format json
```
Parse the `.id` field from the output — this is the item's node ID, needed for the next step.

If the task has a `priority` field set, set the Priority field on the project item. Fetch the project's fields once per sync run (cache the result — do not re-fetch for each item):
```bash
gh project field-list <project-number> --owner <owner> --format json
```
The output is a JSON array of field objects. Each has an `id` (node ID), `name`, and for single-select fields, an `options` array where each option has `id` and `name`. Find the field whose `name` is "Priority". From its `options`, find the entry whose `name` matches the task's priority value (P1/P2/P3/P4). Use those IDs to set the field:
```bash
gh project item-edit \
  --project-id <project-node-id> \
  --id <item-node-id> \
  --field-id <priority-field-node-id> \
  --single-select-option-id <option-node-id>
```
`<project-node-id>` is the `id` captured from Step 3.5. `<item-node-id>` is the `.id` from `gh project item-add` above.

If no "Priority" field exists in the project, or the task's priority value does not match any option, skip silently.

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

If a project was chosen, add the ticket to it using `gh project item-add`, capture the item node ID, and apply priority if set — using the same field lookup logic as for tasks.

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
