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

The installer copies `commands/pm/`, `rules/`, and `templates/` into `.claude/` in your target directory. A `.pure-magic.json` manifest is written so the workspace knows where it came from and which version is installed.

## Updating

When you pull a new version of pure-magic, run `update.sh` to push the changes to any installed workspace:

```bash
bash pure-magic/update.sh /path/to/your/pm-workspace
```

This shows a diff of what changed, asks for confirmation, then copies the updated files. Overrides and `settings.local.json` are never touched.

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
| `/pm:parse <project> <feature>` | Break a spec into tasks |
| `/pm:ticket <project> <title>` | Create a standalone ticket |
| `/pm:interview <project> <segment>` | Create a customer interview guide |
| `/pm:sync <project> <target>` | Push to GitHub Issues |
| `/pm:status [project]` | Dashboard with PR delivery status |
| `/pm:validate <file>` | Validate a file against quality standards |

## File structure

```
your-workspace/
  .claude/
    commands/pm/        # copied from pure-magic/commands/pm/
    rules/              # copied from pure-magic/.claude/rules/
    templates/          # copied from pure-magic/templates/
    overrides/
      rules/            # project-specific rule overrides (you edit these)
      templates/        # project-specific template overrides (you edit these)
    .pure-magic.json    # manifest: version, source path, install timestamp
  project-name/
    CLAUDE.md           # your product context (you write this)
    pm-config.md        # project config (github repo, team, labels)
    specs/              # spec documents
    tasks/              # task breakdowns
    tickets/            # standalone tickets
```

## Customizing for your team

- **pm-config.md**: set your GitHub repo, team names, label preferences, branch prefix
- **CLAUDE.md**: your product context flows in automatically through Claude Code's context hierarchy

No code changes needed. Everything is markdown.

## Overriding rules and templates per project

Files in `commands/pm/`, `rules/`, and `templates/` are copies. If you edit them directly, your changes will be overwritten the next time you run `update.sh`. To customize for one project without losing updates, use the overrides directories instead.

Copy any rule or template file into the overrides directory and edit it there:

```bash
# Override a rule for this project only
cp .claude/rules/task-quality.md .claude/overrides/rules/task-quality.md

# Override a template for this project only
cp .claude/templates/task.md .claude/overrides/templates/task.md
```

Commands check `.claude/overrides/` first. If an override file exists, it is used instead of the copied default. Delete the override file to go back to the default.

The overrides directories (`.claude/overrides/rules/` and `.claude/overrides/templates/`) are created empty by the installer and are never touched by `update.sh`.

## Requirements

- [Claude Code](https://claude.ai/claude-code)
- [GitHub CLI](https://cli.github.com/) (`gh auth login`)
