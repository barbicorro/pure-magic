# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

pure-magic is a spec-driven PM system that runs entirely inside Claude Code. There is no application code, no build system, and no dependencies. Everything is markdown: commands, rules, templates, and outputs.

## Architecture

The system has three parts:

- `commands/pm/` - Claude slash command definitions. Each file is a markdown prompt with YAML frontmatter declaring its model and allowed tools.
- `.claude/rules/` - Shared standards. Commands reference these inline (e.g., `Follow /rules/task-quality.md`). Claude loads them from the `.claude/` context hierarchy automatically.
- `templates/` - The single source of truth for file structure. Commands read these templates and use them as output structure rather than defining structure inline. Do not duplicate structure inside commands.

`install.sh` copies all three into a target PM workspace's `.claude/` directory so Claude Code picks them up.

### Commands

| Command | Purpose |
|---|---|
| `/pm:spec` | Interview + write a spec |
| `/pm:parse` | Convert spec to tasks |
| `/pm:ticket` | Create a standalone ticket |
| `/pm:interview` | Co-create a customer interview guide (Mom Test) |
| `/pm:sync` | Push to GitHub Issues |
| `/pm:status` | Dashboard with PR delivery status |
| `/pm:validate` | Validate files against quality and frontmatter standards |

`/pm:validate` is called by other commands before syncing and after file creation. A PM can also run it directly to check files at any time.

### Templates

| File | Used for |
|---|---|
| `templates/spec.md` | Spec documents |
| `templates/task.md` | Task files |
| `templates/ticket.md` | Improvement and request tickets |
| `templates/ticket-bug.md` | Bug tickets |
| `templates/pm-config.md` | Project config |
| `templates/interview.md` | Customer interview guides |

## Key conventions

- All state lives in YAML frontmatter. The schemas are defined in `.claude/rules/frontmatter.md`.
- Quality gates in `.claude/rules/task-quality.md` block `/pm:sync` if not met. They are not advisory.
- Every task must have a `spec_section` field linking it to the spec it came from.
- `github_url` and `github_id` are always blank until `/pm:sync` runs and fills them in.
- When modifying a command, do not change the allowed tools list without also verifying the command logic uses only those tools.

## Task filename convention

Task files live in `tasks/<feature>/` and use a zero-padded sequence number followed by the task title in kebab-case:

```
tasks/onboarding/001-build-onboarding-wizard.md
tasks/onboarding/002-add-skip-option.md
```

After `/pm:sync` creates the GitHub issue, the file is renamed using the issue number as prefix:

```
tasks/onboarding/44-build-onboarding-wizard.md
tasks/onboarding/45-add-skip-option.md
```

The `depends_on` field in frontmatter references sibling task filenames (e.g., `[001-build-onboarding-wizard.md]`).
