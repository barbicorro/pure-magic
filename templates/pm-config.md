---
project: your-project-name
provider: github
github_repo: owner/repo-name
# jira:
#   host: yourcompany.atlassian.net
#   project_key: ACME
#   issue_type: Story
# asana:
#   project_gid: "1234567890123456"
#   workspace_gid: "9876543210987654"
team:
  pm: Your Name
  devs: []
labels:
  task: "task"
  bug: "bug"
  improvement: "improvement"
  request: "request"
  in_progress: "in-progress"
branch_prefix: "feature/"
---

# PM Config: your-project-name

This file configures pure-magic for this project. Edit the frontmatter above.

## Fields

- **project**: Short name used in command arguments (e.g., `acme`)
- **provider**: Sync target. `github` (default), `jira`, or `asana`. If omitted, defaults to `github`.
- **github_repo**: The GitHub repo where issues will be created (e.g., `myorg/acme`). Used when provider is `github`.
- **jira**: Jira Cloud connection config. Used when provider is `jira`. Auth is handled via OAuth through the Atlassian MCP server - no API tokens or env vars required.
  - **host**: Your Atlassian domain (e.g., `yourcompany.atlassian.net`)
  - **project_key**: Jira project key (e.g., `ACME`)
  - **issue_type**: Issue type to create (e.g., `Story`, `Task`)
- **asana**: Asana connection config. Used when provider is `asana`. Auth via `ASANA_PAT` env var - not stored here.
  - **project_gid**: GID from the project URL (`app.asana.com/0/<project_gid>/...`)
  - **workspace_gid**: GID for the workspace. Required for tag operations. Find via `GET /workspaces`.
- **team.pm**: Your name
- **team.devs**: List of dev names on this project
- **labels**: Label names, only change if your repo uses different names (GitHub only)
- **branch_prefix**: Prefix for feature branches. Use `fix/` for bug-heavy projects.
