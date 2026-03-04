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

pure-magic is a Claude Code plugin. Add it to your PM workspace's `settings.json`:

```json
{
  "plugins": [
    { "path": "/path/to/pure-magic" }
  ]
}
```

On the next session start, the plugin's SessionStart hook copies `rules/` and `templates/` into your workspace's `.claude/` directory automatically.

For development (testing the plugin locally):

```bash
claude --plugin-dir /path/to/pure-magic
```

## Setup per project

Create a `pm-config.md` in each project folder:

```bash
cp .claude/templates/pm-config.md <your-project>/pm-config.md
```

Edit the frontmatter to set your `github_repo`, team, and preferences.

## Skills

| Skill | What it does |
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
pure-magic/                     # plugin source repo
  .claude-plugin/
    plugin.json                 # plugin manifest (name: pm)
  skills/
    spec/SKILL.md
    parse/SKILL.md
    ticket/SKILL.md
    interview/SKILL.md
    sync/SKILL.md
    status/SKILL.md
    validate/SKILL.md
  agents/
    spec-reviewer.md
  rules/                        # copied to workspace .claude/rules/ on session start
  templates/                    # copied to workspace .claude/templates/ on session start
  hooks/
    hooks.json                  # SessionStart hook
  scripts/
    ensure-workspace.sh         # copies rules + templates, creates override dirs

your-workspace/
  .claude/
    rules/                      # auto-populated by SessionStart hook
    templates/                  # auto-populated by SessionStart hook
    overrides/
      rules/                    # project-specific rule overrides (you edit these)
      templates/                # project-specific template overrides (you edit these)
  project-name/
    CLAUDE.md                   # your product context (you write this)
    pm-config.md                # project config (github repo, team, labels)
    specs/                      # spec documents
    tasks/                      # task breakdowns
    tickets/                    # standalone tickets
```

## Customizing for your team

- **pm-config.md**: set your GitHub repo, team names, label preferences, branch prefix
- **CLAUDE.md**: your product context flows in automatically through Claude Code's context hierarchy

No code changes needed. Everything is markdown.

## Overriding rules and templates per project

Files in `rules/` and `templates/` are copied into your workspace on first use. To customize for one project without losing updates, use the overrides directories:

```bash
# Override a rule for this project only
cp .claude/rules/task-quality.md .claude/overrides/rules/task-quality.md

# Override a template for this project only
cp .claude/templates/task.md .claude/overrides/templates/task.md
```

Skills check `.claude/overrides/` first. If an override file exists, it is used instead of the default. Delete the override file to go back to the default.

The `ensure-workspace.sh` script skips files that already exist, so it never overwrites overrides.

## Requirements

- [Claude Code](https://claude.ai/claude-code)
- [GitHub CLI](https://cli.github.com/) (`gh auth login`)
