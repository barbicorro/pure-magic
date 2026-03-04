# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this project is

pure-magic is a spec-driven PM system that runs entirely inside Claude Code. There is no application code, no build system, and no dependencies. Everything is markdown: skills, rules, templates, and outputs.

## Architecture

The system has four parts:

- `.claude/skills/pm-*/` - Claude skill definitions. Each skill is a directory with a `SKILL.md` file containing a markdown prompt with YAML frontmatter declaring its name, model, allowed tools, and invocation settings.
- `.claude/agents/` - Subagent definitions. Each file has YAML frontmatter (name, description, tools, model) and a markdown body that serves as the system prompt. Skills launch subagents by name via the Task tool.
- `.claude/rules/` - Shared standards. Skills reference these inline (e.g., `Follow /rules/task-quality.md`). Claude loads them from the `.claude/` context hierarchy automatically.
- `templates/` - The single source of truth for file structure. Skills read these templates and use them as output structure rather than defining structure inline. Do not duplicate structure inside skills.

`install.sh` copies all four into a target PM workspace's `.claude/` directory. It writes a `.claude/.pure-magic.json` manifest containing the installed version, source path, and timestamp. `update.sh` reads that manifest, diffs managed files against the source repo, and applies changes after confirmation. Overrides and `settings.local.json` are never touched by either script.

### Skills

| Skill | Purpose |
|---|---|
| `/pm-spec` | Interview + write a spec |
| `/pm-parse` | Convert spec to tasks |
| `/pm-ticket` | Create a standalone ticket |
| `/pm-interview` | Co-create a customer interview guide (Mom Test) |
| `/pm-sync` | Push to GitHub Issues |
| `/pm-status` | Dashboard with PR delivery status |
| `/pm-validate` | Validate files against quality and frontmatter standards |

`/pm-validate` is called by other skills before syncing and after file creation. A PM can also run it directly to check files at any time.

### Agents

| File | Launched by | Model | Purpose |
|---|---|---|---|
| `.claude/agents/spec-reviewer.md` | `/pm-spec` | sonnet | Review a spec for clarity, completeness, consistency, and readiness |

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

### Overrides

PMs can customize rules or templates per project without losing updates. Place a modified file in:

- `.claude/overrides/rules/<name>.md` - overrides `.claude/rules/<name>.md`
- `.claude/overrides/templates/<name>.md` - overrides `.claude/templates/<name>.md`

Skills check the override path first. If the file exists, they Read and follow it instead of the copied default. Override directories are created empty by `install.sh` and are never touched by `update.sh`. The source repo does not track them.

## Key conventions

- All state lives in YAML frontmatter. The schemas are defined in `.claude/rules/frontmatter.md`.
- Quality gates in `.claude/rules/task-quality.md` block `/pm-sync` if not met. They are not advisory.
- Every task must have a `spec_section` field linking it to the spec it came from.
- `github_url` and `github_id` are always blank until `/pm-sync` runs and fills them in.
- When modifying a skill, do not change the allowed tools list without also verifying the skill logic uses only those tools.
- Override files in `.claude/overrides/` are per-project and should not be committed to the pure-magic source repo.

## Task filename convention

Task files live in `tasks/<feature>/` and use a zero-padded sequence number followed by the task title in kebab-case:

```
tasks/onboarding/001-build-onboarding-wizard.md
tasks/onboarding/002-add-skip-option.md
```

After `/pm-sync` creates the GitHub issue, the file is renamed using the issue number as prefix:

```
tasks/onboarding/44-build-onboarding-wizard.md
tasks/onboarding/45-add-skip-option.md
```

The `depends_on` field in frontmatter references sibling task filenames (e.g., `[001-build-onboarding-wizard.md]`).
