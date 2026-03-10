# /pm:spec

Interviews you about a feature and writes a structured spec.

## Why this exists

Most specs fail for the same reasons. Either they are written too quickly - a few bullet points that leave developers guessing - or they are written in isolation, without anyone asking the uncomfortable questions about what success actually looks like or what happens when things go wrong.

The `/pm:spec` skill treats spec writing as a conversation. It interviews you, adapts based on what your project context already makes clear, and actively looks for the things you have not thought about yet: missing user roles, error states that are implied but not written down, conflicting requirements, decisions that will block development if left open.

The goal is a spec that a developer can read and start an implementation plan from, without needing to schedule a clarification meeting.

## Usage

```
/pm:spec <project> <feature-name>
```

Example:

```
/pm:spec acme session-notes
```

## What you get out of the interview

The skill does not ask generic questions. It adapts to what your project already says and focuses on what is not yet clear. Expect questions around:

- Who the users are and what they are trying to accomplish - not your assumptions, their actual goals
- What a concrete win looks like 3 months after launch, not just "users can do X"
- Whether the core problem is lack of visibility, scattered data, or inability to act on what users already have - because these lead to very different solutions
- The user flow, step by step
- What is explicitly out of scope - just as important as what is in scope
- Open questions or blockers you already know about

It also flags blindspots: scenarios you did not mention, what happens when the happy path fails, assumptions that are buried in the requirements but not stated.

## Automatic spec review

After the spec is written, a `spec-reviewer` subagent reads it and returns a structured report. The report flags:

- Sections that are thin or missing
- Acceptance criteria that are vague or untestable
- Open questions that will need answers before development can start
- Whether the spec is ready for `/pm:parse` or needs revision first

This catches the gaps that are easy to miss when you wrote the document yourself.

## Output

A spec file at `<project>/specs/<feature-name>.md`.

## Next step

```
/pm:parse <project> <feature-name>
```
