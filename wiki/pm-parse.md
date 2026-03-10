# /pm:parse

Reads a spec and breaks it into individual task files.

## Why this exists

The gap between a spec and a sprint is where a lot of PM work disappears. A spec can look complete and still generate a dozen clarification questions in sprint planning - because the tasks were not specific enough, or they bundled things that should have been separate, or a developer had to interpret what "show a chart" meant without any detail about what that chart actually contains.

`/pm:parse` closes that gap. It reads your spec and produces one task file per unit of work, each sized and described clearly enough that a developer can pick it up without guessing. Every task traces back to the spec section it came from, so there is always a line back to the original reasoning.

It also acts as a quality gate on the spec itself: if a feature in the spec does not map to a stated goal, or if a computed value is mentioned without a formula, the skill stops and asks before writing anything. This catches the spec gaps that are easier to fix now than after tasks are in the sprint.

## Usage

```
/pm:parse <project> <feature-name>
```

Example:

```
/pm:parse acme session-notes
```

The spec must already exist at `<project>/specs/<feature-name>.md`. If it does not, the skill will tell you to run `/pm:spec` first.

## What makes a good task

Each task file represents something a developer can pick up independently. Tasks that depend on each other say so explicitly. No task is a catch-all for "the rest of the feature."

Tasks also need to be specific enough to act on without guessing. If the spec mentions a computed value - a score, a ratio, a total - the skill asks for the exact formula before writing the task. If it mentions a chart, it asks for the full visual spec: chart type, axes, tooltip, legend. This prevents the classic back-and-forth where a developer builds something technically correct but visually wrong.

## Output

A folder of task files at `<project>/tasks/<feature-name>/`.

Each file has a title, description, acceptance criteria, size, priority (if known), and a `spec_section` field that links it back to the part of the spec it came from.

## Next step

```
/pm:sync <project> <feature-name>
```

Or run `/pm:validate <project>/tasks/<feature-name>/*.md` to check the files before syncing.
