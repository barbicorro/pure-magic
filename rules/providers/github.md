# GitHub Provider Rules

Provider: `github`

Auth: the `gh` CLI is used for all operations. It must already be authenticated (`gh auth status`). No additional env vars are required.

Also read `rules/github-labels.md` (or the project override at `.claude/overrides/rules/github-labels.md`) for label definitions and colors.

## Milestone

Fetch existing milestones:
```bash
gh api repos/<owner>/<repo>/milestones --jq '.[].title'
```

Create a new milestone (omit `due_on` if not provided):
```bash
gh api repos/<owner>/<repo>/milestones -f title="<name>" -f due_on="<YYYY-MM-DDT00:00:00Z>"
```

## Project board

Fetch the owner's projects:
```bash
gh project list --owner <owner> --format json
```

Returns a JSON array. Each project has `number`, `title`, and `id` (GraphQL node ID). Use the `number` with `gh project item-add` and the `id` with `gh project item-edit`.

Add an issue to a project (capture returned `.id` as the item node ID):
```bash
gh project item-add <project-number> --owner <owner> --url <issue-url> --format json
```

Fetch project fields once per sync run (cache the result):
```bash
gh project field-list <project-number> --owner <owner> --format json
```

Returns a JSON array. Each field has `id` (node ID), `name`, and for single-select fields an `options` array where each option has `id` and `name`. Find the field named "Priority".

Set the Priority field on a project item:
```bash
gh project item-edit \
  --project-id <project-node-id> \
  --id <item-node-id> \
  --field-id <priority-field-node-id> \
  --single-select-option-id <option-node-id>
```

If no "Priority" field exists or the task priority does not match any option, skip silently.

## Priority mapping

Map the task/ticket `priority` frontmatter value to the GitHub Project Priority field option name:

| Frontmatter | GitHub option name |
|---|---|
| high | High |
| medium | Medium |
| low | Low |

Find the matching option by `name` in the field's `options` array. Use that option's `id`.

## Labels

See `rules/github-labels.md` for label names, colors, and creation rules.

Check if labels exist:
```bash
gh label list --repo <owner>/<repo> --json name
```

Create a missing label:
```bash
gh label create "<label>" --repo <owner>/<repo> --color "<color>" --description "<desc>"
```

## Issue creation

### Tasks

```bash
gh issue create \
  --repo <owner>/<repo> \
  --title "<title>" \
  --body "<body>" \
  --label "task,<size-label>" \
  --milestone "<milestone name>"
```

Omit `--milestone` if no milestone was chosen.

### Tickets

```bash
gh issue create \
  --repo <owner>/<repo> \
  --title "<title>" \
  --body "<body>" \
  --label "<type>,<size-label>" \
  --milestone "<milestone name>"
```

## Dependencies

For tasks with `depends_on`, append a "Blocked by" section to the issue body after the spec footer:

```
**Blocked by:** #<sync_id>, #<sync_id>
```

Only include dependencies that have a `sync_id`.

## Issue ID format

GitHub issues use numeric IDs prefixed with `#` (e.g., `#42`). The `sync_id` field stores the number only (e.g., `42`). The `sync_url` field stores the full issue URL.

## PR status lookup

```bash
gh pr list --repo <owner>/<repo> --search "linked:<issue-number>" --json number,title,state,url
```
