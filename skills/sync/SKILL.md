---
name: sync
description: Push local tasks and tickets to GitHub Issues or Jira Cloud
argument-hint: <project> <feature-name|ticket-name|--all>
model: sonnet
allowed-tools: Read, Write, Bash, AskUserQuestion, mcp__atlassian__jira_search, mcp__atlassian__jira_create_issue, mcp__atlassian__jira_create_issue_link, mcp__atlassian__jira_get_project_versions, mcp__atlassian__jira_create_version
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

Read `<project>/pm-config.md` (required). If pm-config.md is not found, stop:
"No pm-config.md found for <project>. Create one first."

Extract `provider` from pm-config frontmatter. If the field is missing or blank, default to `github`.

**Load provider rules.** Check for a project override first:
- If `.claude/overrides/rules/providers/<provider>.md` exists, Read and follow it.
- Otherwise Read `.claude/rules/providers/<provider>.md`.

If provider is `github`:
- Extract `github_repo` from pm-config. Split on `/` to get `owner` and `repo`.
- If `.claude/overrides/rules/github-labels.md` exists, Read it; otherwise the auto-loaded `/rules/github-labels.md` is already in context.

If provider is `jira`:
- Extract `jira.host`, `jira.project_key`, and `jira.issue_type` from pm-config.
- Verify the Atlassian MCP server is available as described in the Jira provider rules. Stop with setup instructions if the server is not reachable.

If `.claude/overrides/rules/frontmatter.md` exists, Read and follow it instead of the auto-loaded `/rules/frontmatter.md`.
If `.claude/overrides/rules/task-quality.md` exists, Read and follow it instead of the auto-loaded `/rules/task-quality.md`.

## Step 1: Collect what will be synced

Depending on the target:

**Single feature** (`feature-name`):
- Read all task files in `<project>/tasks/<feature-name>/` (all .md files)
- Skip any tasks that already have a `sync_id` set (already synced)

**Single ticket** (`ticket-name`):
- Read `<project>/tickets/<ticket-name>.md`
- If it already has a `sync_id`, stop: "This ticket is already synced at <sync_url>"

**All** (`--all`):
- Scan `<project>/tasks/` for any task file with `status: local`
- Scan `<project>/tickets/` for any ticket with `status: local`
- Collect all of them

## Step 2: Quality check

Run `/pm:validate` on all files collected in Step 1. If any file fails validation, list the failures clearly and stop. Do not create any issues.
"These items have quality issues and cannot be synced. Fix them and try again:"

## Step 3: Milestone / Fix Version

Use AskUserQuestion to ask: "Assign a milestone to all items in this sync?" with options built from the provider pattern (fetch existing milestones or fix versions, offer to create a new one, and offer "No milestone").

Follow the milestone/version pattern from the provider rules loaded in setup.

Store the chosen milestone or version for use in Step 6. If "No milestone", omit the milestone/version field from issue creation.

## Step 3.5: Project board (GitHub only)

Skip this step entirely for Jira. Jira issues appear on the board automatically when created.

For GitHub: follow the project board pattern from the GitHub provider rules. Use AskUserQuestion to ask whether to add items to a project. If a project is chosen, store both its `number` and its `id` node ID. If "No project", skip the project step.

## Step 4: Preview

Show the PM a clear preview of what will be created:

```
Ready to sync to [provider: github_repo or jira host/project_key]:

feature-name:
  #  task-title.md  [S] [P1]  Task title 1
  #  another-task.md  [M]      Task title 2  (depends on: task-title.md)

TICKETS:
  #  fix-login-redirect.md  [bug, XS] [P2]  Fix login redirect

Milestone: <chosen milestone/version or "none">
Project:   <chosen project or "none">  (GitHub only)
Total: 2 tasks, 1 ticket = 3 issues

Proceed? (yes/no)
```

Use AskUserQuestion to get confirmation. If the PM says no, stop cleanly.

## Step 5: Ensure labels exist

Follow the labels pattern from the provider rules loaded in setup.

For GitHub: check if labels exist in the repo and create any that are missing.
For Jira: labels are global strings. No creation step is needed.

## Step 6: Create issues

The body of each issue is the markdown content of the local file, with YAML frontmatter stripped. Do not reformat or restructure the content. Skip any section whose body is empty.

For tasks only, append a footer after the last section:
```
---
_Spec section: <spec_section value>_
```

Follow the issue creation pattern from the provider rules loaded in setup. After creating each issue:
- Update frontmatter: `status: synced`, `sync_url`, `sync_id`, `updated`
- Do not rename the file.

For GitHub: if a project was chosen, add the issue to it and apply the priority field as described in the GitHub provider rules.

### Dependency handling (tasks only)

Maintain a visited set of filenames already processed in this sync run to prevent infinite loops from circular dependencies.

Before creating a task's issue, check its `depends_on` list. For each dependency filename listed:
- If the filename is already in the visited set, skip it.
- Add it to the visited set, then read the file and check if it has a `sync_id`.
- If it does not, sync that dependency first (create its issue and update its frontmatter) before continuing with the current task.
- Repeat recursively until all dependencies in the chain have a `sync_id`.

If a circular dependency is detected, report it clearly and skip: "Circular dependency detected: <filename> -> <dep> -> ... -> <filename>. Skipping."

After all dependencies have a `sync_id`, follow the dependency linking pattern from the provider rules (append "Blocked by" to issue body for GitHub, create issue links for Jira).

If any issue creation fails: report it clearly but continue with the rest. At the end, list what succeeded and what failed.

## Step 7: Summary

Print a summary of what was created. Use the issue ID format for the active provider (GitHub: `#N`, Jira: `KEY-N`).

```
Synced to [github_repo or jira host/project_key]:

  Task  #43:  Task title 1   [S]  -> <url>
  Task  #44:  Task title 2   [M]  -> <url>
  Bug   #45:  Fix login redirect  -> <url>

3 issues created.
```

If there were failures, list them at the end.
