# Asana Provider Rules

Provider: `asana`

## Important

Do not use any Asana MCP tools, even if they are available in the session. The MCP only exposes `create_task_preview`, not `create_task`, which does not work in Claude Code. Always use curl via Bash for all Asana API calls.

## Auth

Run this exact command to check the PAT is set. No other auth command is permitted before or after it:
```bash
source ~/.zshrc 2>/dev/null; [ -z "$ASANA_PAT" ] && echo "NOT_SET" || echo "SET"
```

If the output is `NOT_SET`, stop immediately with:
```
ASANA_PAT is not set. See the Asana setup instructions in wiki/pm-sync.md.
```

If the output is `SET`, proceed. Do not run any other command to inspect, verify, or print the PAT value at any point.

`<project_gid>` and `<workspace_gid>` come from the `asana` fields in pm-config.

## curl pattern

All API calls use this pattern:
```bash
curl -s -X <METHOD> \
  "https://app.asana.com/api/1.0/<endpoint>" \
  -H "Authorization: Bearer $ASANA_PAT" \
  -H "Content-Type: application/json" \
  -d '<json>'
```

Parse JSON responses with Python (no jq dependency):
```bash
python3 -c "import sys,json; d=json.load(sys.stdin); print(d['data']['gid'])"
```

## Sections (milestone equivalent)

Fetch existing sections:
```bash
curl -s "https://app.asana.com/api/1.0/projects/<project_gid>/sections" \
  -H "Authorization: Bearer $ASANA_PAT"
```

Create a new section:
```bash
curl -s -X POST \
  "https://app.asana.com/api/1.0/projects/<project_gid>/sections" \
  -H "Authorization: Bearer $ASANA_PAT" \
  -H "Content-Type: application/json" \
  -d '{"data": {"name": "<name>"}}'
```

Use the section GID when creating tasks via `memberships`:
```json
"memberships": [{"project": "<project_gid>", "section": "<section_gid>"}]
```

## Tags (label equivalent)

Fetch existing tags in the workspace:
```bash
curl -s "https://app.asana.com/api/1.0/workspaces/<workspace_gid>/tags" \
  -H "Authorization: Bearer $ASANA_PAT"
```

Create a new tag:
```bash
curl -s -X POST \
  "https://app.asana.com/api/1.0/tags" \
  -H "Authorization: Bearer $ASANA_PAT" \
  -H "Content-Type: application/json" \
  -d '{"data": {"name": "<name>", "workspace": "<workspace_gid>"}}'
```

Apply tags at task creation via the `tags` array (array of tag GIDs).

## Task creation

```bash
curl -s -X POST \
  "https://app.asana.com/api/1.0/tasks?opt_fields=gid,permalink_url" \
  -H "Authorization: Bearer $ASANA_PAT" \
  -H "Content-Type: application/json" \
  -d '<json_body>'
```

JSON body fields:
- `projects`: array containing `<project_gid>` (required)
- `name`: task title (required)
- `notes`: body text with frontmatter stripped (optional)
- `tags`: array of tag GIDs (optional)
- `memberships`: section assignment (optional, see Sections above)

`opt_fields=gid,permalink_url` is required - Asana does not return `permalink_url` by default.

Extract from the response:
- `data.gid` -> store as `sync_id`
- `data.permalink_url` -> store as `sync_url`

## Priority

Asana has no native priority field. If the workspace has a custom field named "Priority":

1. Fetch project custom fields to find the field GID and its option GIDs:
```bash
curl -s "https://app.asana.com/api/1.0/projects/<project_gid>?opt_fields=custom_field_settings.custom_field.gid,custom_field_settings.custom_field.name,custom_field_settings.custom_field.enum_options" \
  -H "Authorization: Bearer $ASANA_PAT"
```

2. Map frontmatter priority to option name:

| Frontmatter | Option name |
|---|---|
| high | High |
| medium | Medium |
| low | Low |

3. After task creation, set the field:
```bash
curl -s -X PUT \
  "https://app.asana.com/api/1.0/tasks/<task_gid>" \
  -H "Authorization: Bearer $ASANA_PAT" \
  -H "Content-Type: application/json" \
  -d '{"data": {"custom_fields": {"<field_gid>": "<option_gid>"}}}'
```

If no "Priority" custom field exists or no option matches, skip silently.

## Dependencies

After both tasks exist, link them:
```bash
curl -s -X POST \
  "https://app.asana.com/api/1.0/tasks/<task_gid>/addDependencies" \
  -H "Authorization: Bearer $ASANA_PAT" \
  -H "Content-Type: application/json" \
  -d '{"data": {"dependencies": ["<dep_gid>"]}}'
```

Fallback: if this fails, update the task notes via PUT to append "Blocked by: <dep_url>":
```bash
curl -s -X PUT \
  "https://app.asana.com/api/1.0/tasks/<task_gid>" \
  -H "Authorization: Bearer $ASANA_PAT" \
  -H "Content-Type: application/json" \
  -d '{"data": {"notes": "<existing_notes>\n\nBlocked by: <dep_url>"}}'
```

## Issue ID format

- `sync_id`: the task GID (numeric string, e.g., `1234567890123456`)
- `sync_url`: `permalink_url` from the API response

## Project board

No project board step is needed. Tasks appear in the Asana project automatically when created with the `projects` field.
