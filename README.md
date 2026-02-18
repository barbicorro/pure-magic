# pure-magic

Spec-driven project management for Claude Code. Write specs with AI, generate GitHub Issues, track delivery, all from your PM workspace.

## How it works

1. **Write a spec** with AI as partner (`/pm:spec`)
2. **Break it into tasks** with quality gates enforced (`/pm:parse`)
3. **Create standalone tickets** for bugs and small requests (`/pm:ticket`)
4. **Review locally** before anything goes to GitHub
5. **Sync to GitHub Issues** with one command (`/pm:sync`)
6. **Track delivery** including PR status (`/pm:status`)

Then the dev team picks up the GitHub Issue, plans with Claude Code (optional), implements, opens a PR. Everything connects through GitHub Issues, no shared files needed.

## Install

```bash
git clone https://github.com/barbicorro/pure-magic
bash pure-magic/install.sh /path/to/your/pm-workspace
```

The installer copies commands and rules into `.claude/` in your target directory. It does not overwrite existing files without asking.

## Setup per project

After installing, create a `pm-config.md` in each project folder:

```bash
cp .claude/templates/pm-config.md <your-project>/pm-config.md
```

Edit the frontmatter to set your `github_repo`, team, and preferences.

## Commands

| Command | What it does |
|---|---|
| `/pm:spec <project> <feature>` | Interview + write a spec |
| `/pm:parse <project> <feature>` | Convert spec to epic + tasks |
| `/pm:ticket <project> <title>` | Create a standalone ticket |
| `/pm:sync <project> <target>` | Push to GitHub Issues |
| `/pm:status [project]` | Dashboard with PR delivery status |

## File structure

```
your-workspace/
  .claude/
    commands/pm/     # pure-magic commands
    rules/           # quality and format rules
    templates/       # file templates
  project-name/
    CLAUDE.md        # your product context (you write this)
    pm-config.md     # project config (github repo, team, labels)
    specs/           # spec documents
    epics/           # epic + task breakdowns
    tickets/         # standalone tickets
```

## Customizing for your team

- **pm-config.md**: set your GitHub repo, team names, label preferences, branch prefix
- **Templates**: replace files in `.claude/templates/` with your own format
- **Rules**: add project-specific rules in `.claude/rules/` (e.g., "all tickets must link to a Figma frame")
- **CLAUDE.md**: your product context flows in automatically through Claude Code's context hierarchy

No code changes needed. Everything is markdown.

## Requirements

- [Claude Code](https://claude.ai/claude-code)
- [GitHub CLI](https://cli.github.com/) (`gh auth login`)
