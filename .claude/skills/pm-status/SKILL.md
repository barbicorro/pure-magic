---
name: pm-status
description: Show PM dashboard for one or all projects, including PR delivery status
argument-hint: [project]
model: sonnet
allowed-tools: Read, Bash
disable-model-invocation: true
---

# /pm-status

Arguments: $ARGUMENTS
Expected format:
- `/pm-status <project>`: active items only (default)
- `/pm-status <project> --local`: unsynced drafts only
- `/pm-status <project> --delivered`: items delivered in the last 15 days
- `/pm-status <project> --all`: everything
- `/pm-status`: active items across all projects

## Setup

Parse $ARGUMENTS to extract `project` (optional) and `flag` (optional: `--local`, `--delivered`, `--all`). Default flag is none (active items only).

If a project name is given, scan only that project. If none, scan all projects (any directory in the vault that contains a `pm-config.md`).

If `.claude/overrides/rules/frontmatter.md` exists, Read and follow it instead of the auto-loaded `/rules/frontmatter.md`.

## Step 1: Collect local state

For each project in scope:

**Specs**: read all files in `<project>/specs/`:
- Extract: title, status (draft / parsed / synced)

**Tasks**: read all task files in `<project>/tasks/*/`:
- Extract: title, size, status, github_id, updated
- Group by feature folder name

**Tickets**: read all files in `<project>/tickets/`:
- Extract: title, type, size, status, github_id, updated

## Step 2: Apply filter

Filter items based on the flag before fetching PR status (avoids unnecessary GitHub API calls):

**No flag (default, active only):**
- Include: specs with `status: draft` or `parsed`
- Include: tasks and tickets with `status: local`, `synced`, or `in-progress`
- Exclude: anything with `status: delivered` or `closed`

**`--local`:**
- Include only: items with `status: local` (not yet synced to GitHub)
- Skip GitHub API calls entirely, no `github_id` to look up

**`--delivered`:**
- Include only: items where PR state is `MERGED` and PR merged within the last 15 days
- Requires GitHub API call to check merge date

**`--all`:**
- Include everything, no filter applied

## Step 3: Fetch PR status from GitHub

For each item that has a `github_id`, fetch open PR status:

```bash
gh pr list \
  --repo <github_repo> \
  --search "linked:<github_id>" \
  --json number,title,state,isDraft,url \
  --state all
```

Map each issue to its PR state:
- No PR found: `waiting`
- PR state `OPEN`, `isDraft: false`: `in review`
- PR state `OPEN`, `isDraft: true`: `in progress`
- PR state `MERGED`: `delivered`
- PR state `CLOSED`: `closed`

Note: `gh pr list --search "linked:<id>"` may not always work depending on how PRs are linked. Fall back to searching by branch name pattern `<branch_prefix><github_id>` if needed.

## Step 4: Display dashboard

Always show the active filter at the top so the PM knows what they are looking at.

Format the output clearly:

```
=== PROJECT: acme === (active)   # or (local) / (delivered: last 15d) / (all)

SPECS
  draft    session-notes
  parsed   user-onboarding

TASKS
  user-onboarding  (3 tasks)
    #44  [M]  Build onboarding wizard   in review   PR #71 open
    #45  [S]  Add skip option           waiting     no PR

TICKETS
  req  #39  [S]   Export CSV button      in review   PR #70 open
  bug  #51  [XS]  Mobile nav overlap     waiting     no PR

NEEDS ATTENTION
  - Spec "session-notes" has not been parsed yet. Run /pm-parse acme session-notes
  - Task #44 has no acceptance criteria

Tip: use --delivered to see what shipped in the last 15 days, --all to see everything.
```

**Column order:** issue number, size, title, delivery status, PR info

**Delivery status labels:**
- `local`: not synced to GitHub yet
- `waiting`: synced, no PR yet
- `in progress`: draft PR exists
- `in review`: open PR exists
- `delivered`: PR merged

Only show the "Tip" line on the default view, not when a flag is explicitly passed.

## Needs attention rules

Flag these automatically:
- Specs with `status: draft` that have not been parsed (no `tasks/<feature>/` directory exists for them)
- Tasks or tickets with missing acceptance criteria (check the file)
- Tickets sized L (should probably be a spec)
- Local items (not synced) older than 7 days

If nothing needs attention, print: "Everything looks good."
