---
name: spec
description: Conduct a structured PM interview to gather requirements, then write a complete spec document ready for development. Use this skill whenever a PM wants to spec out a feature, write up product requirements, plan what needs to be built, or turn a rough idea into a formal spec. Trigger on phrases like "spec out", "write a spec", "document requirements", "plan this feature", or when a PM describes something they want to build.
argument-hint: <project> <feature-name>
model: opus
allowed-tools: Read, Write, AskUserQuestion, Task
disable-model-invocation: false
---

# /pm:spec

Arguments: $ARGUMENTS
Expected format: `<project> <feature-name>` (e.g., `acme session-notes`)

## Setup

Parse $ARGUMENTS to extract `project` and `feature-name`. If either is missing, stop and tell the user:
"Usage: /pm:spec <project> <feature-name>"

Read the following for context (if they exist):
- `<project>/CLAUDE.md`: product context, users, tech stack
- Any input passed in $ARGUMENTS beyond the two required args (a rough plan, idea, or notes file path)

Check if `<project>/specs/<feature-name>.md` already exists. If it does, ask the PM if she wants to overwrite it before continuing.

## Interview

Interview the PM using the AskUserQuestion tool. Do two things at once: gather what she knows, and surface what she has not considered yet. Only ask what is not already clear from the input or the project context. Ask non-obvious questions. Skip anything self-evident.

Cover the following (adapt based on what is already known):
- Who are the users involved and what are their goals?
- What does success look like? Specifically:
  - What decisions can the user not make today that this feature should unlock?
  - What does a concrete win look like 3 months after launch?
  - Is the core problem lack of visibility, scattered data, or inability to act on what they already see?
- What must the feature do? What are the core requirements?
- How does a user move through this? What is the flow?
- Any design decisions or Figma references already made?
- What is explicitly out of scope?
- Which open questions or blockers are already known? For each one: would it block a developer from starting, or is it a nice-to-have decision that can be made later?

Also actively look for blindspots (things the PM likely has not thought about yet):
- User roles or scenarios not covered
- What does the user see when there is no data yet or nothing to show? (empty states)
- What does the user see when an action fails? (error states)
- Conflicting requirements or assumptions
- Missing requirements that are implied but not stated

Do not go into technical implementation detail. The developer will plan that from the spec. The goal is a document clear enough that a developer can start their own implementation plan without needing to ask basic questions.

Stop when a developer could read what you have and start planning implementation without needing to ask basic questions about who the users are, what to build, or what's out of scope. Before writing, check that you have: at least one concrete requirement per feature area, a clear sense of what's out of scope, and answers about what happens when there's no data and when something fails. If any of those feel thin, ask one more round.

## Write the spec

Create the directory `<project>/specs/` if it does not exist.

Read `.claude/overrides/templates/spec.md` if it exists, otherwise read `.claude/templates/spec.md`. Use it as the output structure. Fill in all sections from the interview answers and today's date.

Write the result to `<project>/specs/<feature-name>.md`.

## Review

After writing the spec, launch the spec-reviewer subagent:

```
Task(
  description: "Review spec",
  subagent_type: "spec-reviewer",
  prompt: "Review the spec at <project>/specs/<feature-name>.md. The feature name is <feature-name>."
)
```

Replace `<project>` and `<feature-name>` with the actual values. The subagent handles everything else: it reads the template, runs the checklist, and returns a structured report.

Wait for the agent to return its report before continuing.

Present the review report to the PM, then tell her:
- The file path where the spec was saved
- How many open questions remain
- If the verdict is "Needs revision": suggest fixing the flagged items before parsing
- If the verdict is "Ready for /pm:parse": next step is `/pm:parse <project> <feature-name>`
