# Jira Cloud Provider Rules

Provider: `jira`

## Auth

This provider uses the Atlassian Remote MCP Server (`atlassian`). Auth is handled via OAuth on first use - no env vars required.

At startup, verify the MCP server is available by calling `mcp__atlassian__jira_search` with `jql: "project = <project_key> ORDER BY created DESC"` and `maxResults: 1`.

If the call fails or the tool is not available, stop with:
```
Jira sync requires the Atlassian MCP server. Add it to .mcp.json and restart the session:

{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@atlassian/mcp"]
    }
  }
}

On first use, Claude will prompt you to authenticate via OAuth.
```

`<host>`, `<project_key>`, and `<issue_type>` come from the `jira` fields in pm-config.

## Fix Versions (milestone equivalent)

List existing fix versions using `mcp__atlassian__jira_get_project_versions` with `project_key`.

Create a new fix version using `mcp__atlassian__jira_create_version` with `name`, `project_key`, and optional `releaseDate` (YYYY-MM-DD).

If the MCP server does not expose version tools, skip the fix version step and proceed without one.

## Labels

Jira labels are global strings. No creation step is needed. Use labels from the `labels` section of pm-config as-is. If no label matches a type, use the type value directly (e.g., `bug`, `task`).

## Issue creation

Use `mcp__atlassian__jira_create_issue` with:
- `project_key`: from pm-config
- `summary`: task/ticket title
- `description`: markdown body with frontmatter stripped (MCP server handles format conversion)
- `issue_type`: from pm-config
- `labels`: array of label strings
- `priority_name`: mapped Jira priority name (see priority mapping below)
- `fix_version_id`: version ID if one was chosen (omit otherwise)

The response contains `key` (e.g., `ACME-42`) and a URL. Store `key` in `sync_id` and construct the browser URL as `https://<host>/browse/<key>` for `sync_url`.

## Priority mapping

Map the task/ticket `priority` frontmatter value to the Jira native priority name:

| Frontmatter | Jira priority name |
|---|---|
| high | High |
| medium | Medium |
| low | Low |

## Dependencies

For tasks with `depends_on`, create issue links after both issues exist. Use `mcp__atlassian__jira_create_issue_link` with:
- `link_type`: `Blocks`
- `inward_issue_key`: the dependency (the one that must be done first)
- `outward_issue_key`: the current task

If the MCP server does not expose an issue link tool, append a "Blocked by: KEY-N" line to the issue description as a fallback.

## Issue ID format

Jira issues use a project-key prefix (e.g., `ACME-42`). The `sync_id` field stores the full key (e.g., `ACME-42`). The `sync_url` field stores `https://<host>/browse/<key>`.

## Project board

No project board step is needed. Jira issues appear on the project board automatically when created.
