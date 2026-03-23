# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

pure-magic is a spec-driven PM system distributed as a Claude Code plugin. There is no application code, no build system, and no dependencies. Everything is markdown: skills, rules, templates, and outputs.

## Architecture

The system has five parts:

- `skills/*/` - Claude skill definitions. Each skill is a directory with a `SKILL.md` file containing a markdown prompt with YAML frontmatter declaring its name, model, allowed tools, and invocation settings.
- `agents/` - Subagent definitions. Each file has YAML frontmatter (name, description, tools, model) and a markdown body that serves as the system prompt. Skills launch subagents by name via the Task tool.
- `rules/` - Shared standards copied into workspaces by the SessionStart hook. Once in `.claude/rules/`, Claude loads them automatically.
- `templates/` - The single source of truth for file structure. Skills read these templates and use them as output structure rather than defining structure inline. Do not duplicate structure inside skills.
- `.claude-plugin/plugin.json` - Plugin manifest. Declares the plugin name (`pm`), version, description, and author.

A SessionStart hook (`hooks/hooks.json`) runs `scripts/ensure-workspace.sh` at the start of each session. That script copies `rules/` and `templates/` into the workspace's `.claude/rules/` and `.claude/templates/` directories, skipping files that already exist (which preserves overrides).

### Skills

| Skill | Purpose |
|---|---|
| `/pm:spec` | Interview + write a spec |
| `/pm:parse` | Convert spec to tasks |
| `/pm:ticket` | Create a standalone ticket |
| `/pm:interview` | Co-create a customer interview guide (Mom Test) |
| `/pm:outcome-brief` | Pressure-test a feature idea before committing to build |
| `/pm:sync` | Push to GitHub Issues or Jira Cloud |
| `/pm:validate` | Validate files against quality and frontmatter standards |

`/pm:validate` is called by other skills before syncing and after file creation. A PM can also run it directly to check files at any time.

### Agents

| File | Launched by | Model | Purpose |
|---|---|---|---|
| `agents/spec-reviewer.md` | `/pm:spec` | sonnet | Review a spec for clarity, completeness, consistency, and readiness |

Agents are subagent definitions with their own system prompt, tool restrictions, and model config. They run in isolated subprocesses with no access to the calling skill's conversation. Skills launch them by name and pass task-specific details in the prompt parameter.

### Templates

| File | Used for |
|---|---|
| `templates/spec.md` | Spec documents |
| `templates/task.md` | Task files |
| `templates/ticket.md` | Improvement and request tickets |
| `templates/ticket-bug.md` | Bug tickets |
| `templates/pm-config.md` | Project config |
| `templates/interview.md` | Customer interview guides |
| `templates/outcome-brief.md` | Outcome brief documents |

### Overrides

PMs can customize rules or templates per project without losing updates. Place a modified file in:

- `.claude/overrides/rules/<name>.md` - overrides `.claude/rules/<name>.md`
- `.claude/overrides/rules/providers/<name>.md` - overrides `.claude/rules/providers/<name>.md`
- `.claude/overrides/templates/<name>.md` - overrides `.claude/templates/<name>.md`

Skills check the override path first. If the file exists, they Read and follow it instead of the copied default. Override directories are created empty by the SessionStart hook and are never touched by it on subsequent runs. The source repo does not track them.

## Conventions for modifying this repo

- Frontmatter schemas live in `rules/frontmatter.md`. Do not duplicate field definitions inside skills.
- Quality gate logic lives in `rules/task-quality.md`. Do not duplicate gate rules inside skills.
- Templates are the single source of truth for file structure. Skills read them; they do not define structure inline.
- When modifying a skill, do not change the allowed tools list without verifying the skill logic only uses those tools.
- Override files in `.claude/overrides/` are per-project and must not be committed to this repo.
