# /pm:sync

Pushes local tasks and tickets to GitHub Issues, Jira Cloud, or Asana.

## Why this exists

Creating issues in GitHub, Jira, or Asana by hand is slow. For every task, you open the tracker, fill in the title, description, labels, and priority, then go back to your notes to copy the context across. With ten tasks and dependencies between them, you also have to figure out the creation order manually so linked issues exist before you reference them.

`/pm:sync` handles that in one command. It reads your local files, validates them, resolves dependency order, and creates everything in the tracker. Each local file is updated with the issue URL and ID so the link is permanent.

## Usage

```
/pm:sync <project> <feature-name>       # sync one feature's tasks
/pm:sync <project> <ticket-name>        # sync one standalone ticket
/pm:sync <project> --all                # sync everything not yet synced
```

## Before it creates anything

The skill runs validation on every file before touching your issue tracker. If a file has quality issues - missing acceptance criteria, a title that does not start with a verb, placeholder text - it stops and tells you what to fix. Nothing is created until everything passes.

You also get a preview of exactly what will be created, with sizes, priorities, and dependency relationships, before you confirm.

## Milestone and project board support

For each sync, you can assign a milestone (GitHub) or fix version (Jira) to all items at once. For GitHub, you can also assign items to a project board and apply a priority field - useful if your team uses GitHub Projects for sprint planning.

## Dependency handling

If task A depends on task B, the skill creates task B first and links task A to it. You do not need to manage the order manually. If there is a circular dependency in the task files, it is caught and reported before anything is created.

## Output

A summary of every issue created:

```
Synced to owner/repo:

  Task  #43:  Build session summary panel   [S]  -> https://github.com/...
  Task  #44:  Add export to CSV             [M]  -> https://github.com/...
  Bug   #45:  Fix login redirect            [XS] -> https://github.com/...

3 issues created.
```

Each local file is updated with `status: synced`, the issue URL, and the issue ID.

## Setup

**1. Find or create a `pm-config.md` in your project folder.**

**2. Set your provider** in the frontmatter:

For GitHub:
```yaml
provider: github
github_repo: owner/repo-name
```

For Jira:
```yaml
provider: jira
jira:
  host: yourcompany.atlassian.net
  project_key: ACME
  issue_type: Story
```

For Asana:
```yaml
provider: asana
asana:
  project_gid: "1234567890123456"
  workspace_gid: "9876543210987654"
```

**3. Configure authentication** for your provider.

For GitHub: uses your existing `gh` CLI authentication - no extra setup needed. If you have not installed the GitHub CLI yet, follow the official guide: https://cli.github.com/manual/installation

For Asana:

1. Go to Asana > your profile photo > My Settings > Apps > Personal Access Tokens.
2. Create a new token and copy it.
3. Set it as an env var in your terminal session:
   ```bash
   export ASANA_PAT=your_token_here
   ```
4. To persist it, add the export line to your shell profile (`~/.zshrc` or `~/.bashrc`).

Where to find your GIDs in Asana:
- `project_gid`: open the project in Asana, copy the number from the URL: `app.asana.com/0/<project_gid>/...`
- `workspace_gid`: call `GET https://app.asana.com/api/1.0/workspaces` with your PAT and copy the `gid` from the response.

**Do not put your PAT in pm-config.md.** That file is committed to git. The PAT must stay in your environment only.

**4. Add the Atlassian MCP server** if using Jira. Add this to `.mcp.json` in your project root (create the file if it does not exist):

```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@atlassian/mcp"]
    }
  }
}
```

Then restart the Claude Code session. On first use, Claude will prompt you to authenticate with Atlassian via OAuth - no API tokens or env vars needed.
