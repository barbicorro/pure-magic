---
description: Interview about a feature, then write a structured spec
argument-hint: <project> <feature-name>
model: opus
allowed-tools: Read, Write, AskUserQuestion
---

# /pm:spec

Arguments: $ARGUMENTS
Expected format: `<project> <feature-name>` (e.g., `acme session-notes`)

## Setup

Parse $ARGUMENTS to extract `project` and `feature-name`. If either is missing, stop and tell the user:
"Usage: /pm:spec <project> <feature-name>"

Read the following for context (if they exist):
- `<project>/CLAUDE.md` -- product context, users, tech stack
- `<project>/pm-config.md` -- project settings
- Any input passed in $ARGUMENTS beyond the two required args (a rough plan, idea, or notes file path)

Check if `<project>/specs/<feature-name>.md` already exists. If it does, ask the PM if she wants to overwrite it before continuing.

## Interview

Interview the PM using the AskUserQuestion tool. Do two things at once: gather what she knows, and surface what she has not considered yet. Only ask what is not already clear from the input or the project context. Ask non-obvious questions -- skip anything self-evident.

Cover the following (adapt based on what is already known):
- Who are the users involved and what are their goals?
- What does success look like -- how will we know this worked?
- What must the feature do? What are the core requirements?
- How does a user move through this? What is the flow?
- Any design decisions or Figma references already made?
- What is explicitly out of scope?
- Any open questions or blockers already known?

Also actively look for blindspots -- things the PM likely has not thought about yet:
- User roles or scenarios not covered
- What happens when things go wrong (from the user's perspective, not the system's)
- Conflicting requirements or assumptions
- Missing requirements that are implied but not stated
- Decisions that will be needed before development starts

Do not go into technical implementation detail -- the developer will plan that from the spec. The goal is a document clear enough that a developer can start their own implementation plan without needing to ask basic questions.

Keep interviewing until you have enough to write a thorough spec. Use multiple rounds of AskUserQuestion if needed.

## Write the spec

Create the directory `<project>/specs/` if it does not exist.

Write the spec to `<project>/specs/<feature-name>.md` using this format:

```
---
title: <Feature Name>
type: spec
status: draft
created: <today's date>
updated: <today's date>
---

# <Feature Name>

## Overview
[2-3 sentence summary]

## Problem Statement
[What problem is being solved and why it matters]

## Goals
[Bullet points -- desired outcomes and success criteria]

## User Roles / Target Audience
[Each role with a one-line description of how they are affected]

## Main Features

### [Feature Area 1]
**Requirements:**
- [Requirement]

**Design:**
- [Figma link or description, or "TBD"]

### [Feature Area 2]
[Repeat for each feature area]

## Out of Scope
[What is explicitly not included]

## Open Questions
- [Unresolved decisions or blockers]
```

After writing, tell the PM:
- The file path where the spec was saved
- How many open questions remain
- Next step: `/pm:parse <project> <feature-name>` to break it into tasks
