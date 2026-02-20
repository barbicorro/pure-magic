---
project: your-project-name
github_repo: owner/repo-name
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
- **github_repo**: The GitHub repo where issues will be created (e.g., `myorg/acme`)
- **team.pm**: Your name
- **team.devs**: List of dev names on this project
- **labels**: Label names, only change if your repo uses different names
- **branch_prefix**: Prefix for feature branches. Use `fix/` for bug-heavy projects.
