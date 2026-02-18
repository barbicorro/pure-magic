---
description: Create a standalone ticket (bug, improvement, or request) without an epic
argument-hint: <project> <ticket-title>
model: opus
allowed-tools: Read, Write, AskUserQuestion
---

# /pm:ticket

Arguments: $ARGUMENTS
Expected format: `<project> <ticket-title>` (e.g., `acme fix-login-redirect`)

## Setup

Parse $ARGUMENTS to extract `project` and `ticket-title`. Convert ticket-title to kebab-case if needed. If either is missing, stop and tell the user:
"Usage: /pm:ticket <project> <ticket-title>"

Read `<project>/pm-config.md` if it exists (for project context).

Check if `<project>/tickets/<ticket-title>.md` already exists. If it does, ask the PM if she wants to overwrite it.

## Interview

Ask the PM the following. Adapt based on what the title already makes clear. Do not ask redundant questions.

Use AskUserQuestion to gather:

1. **Type**: Is this a bug, an improvement to something existing, or a new small request?

2. **Description**: What needs to be done? (If the title is already clear, ask for any additional context.)

3. If bug:
   - What are the steps to reproduce?
   - What is the expected behavior?
   - What is the actual behavior?

4. **Acceptance criteria**: What does "done" look like? Ask for at least 2 verifiable conditions.

5. **Size**: How big is this?
   - XS: a few lines, under 1 hour
   - S: small, under half a day
   - M: medium, 1-2 days
   - L: large, more than 2 days

If size is M or L, ask: "This seems larger than a standalone ticket. Would you like to create a spec instead with `/pm:spec <project> <feature-name>`?"
If the PM confirms M or L and wants to proceed, continue.

## Write the ticket

Create directory `<project>/tickets/` if it does not exist.

For bugs: read `templates/ticket-bug.md` and use it as the output structure. Set `type: bug`.
For improvements: read `templates/ticket.md` and use it as the output structure. Set `type: improvement`.
For requests: read `templates/ticket.md` and use it as the output structure. Set `type: request`.

Follow `/rules/frontmatter.md` for frontmatter format.

Fill in all fields from the interview answers and today's date. Write the result to `<project>/tickets/<ticket-title>.md`.

## Quality check

Run `/pm:validate` on the ticket file. If it fails, fix the issues before saving.

Follow `/rules/task-quality.md` for standards.

## Finish

After writing, tell the PM:
- File saved at: `<project>/tickets/<ticket-title>.md`
- Next step: `/pm:sync <project> <ticket-title>` to push to GitHub Issues
