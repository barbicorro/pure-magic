---
description: Co-create a customer interview guide using Mom Test principles
argument-hint: <project> <interview-name>
model: opus
allowed-tools: Read, Write, AskUserQuestion
---

# /pm:interview

Arguments: $ARGUMENTS
Expected format: `<project> <interview-name>` (e.g., `acme discovery-coaches`)

## Setup

Parse $ARGUMENTS to extract `project` and `interview-name`. If either is missing, stop and tell the user:
"Usage: /pm:interview <project> <interview-name>"

Read the following for context (if they exist):
- `<project>/CLAUDE.md`: product context, users, and goals
- `<project>/pm-config.md`: project settings

Check if `<project>/interviews/<interview-name>.md` already exists. If it does, ask the PM if she wants to overwrite it before continuing.

## Intake

Use AskUserQuestion for round 1 with these four questions:

1. What is the goal of this interview? What is the one thing you most want to learn?
2. Who are you interviewing? Describe their role, context, and relationship to the product or problem.
3. What are your main assumptions or hypotheses you want to test?
4. What stage is this interview?
   - **Discovery** - exploring a problem space, no product yet
   - **Validation** - testing a specific idea or solution direction
   - **Post-launch** - learning from users of an existing product

Use a second AskUserQuestion call to ask: Is this interview linked to a spec? If yes, enter the file path (e.g., `acme/specs/session-notes.md`). Leave blank to skip.

If a spec path is given, read the file and extract the problem statement, goals, and any open questions. Use these to enrich or confirm the hypotheses from question 3.

If any answers from round 1 are too vague to write good questions from, use a follow-up AskUserQuestion call to push for specifics before generating the draft.

## Generate draft

Read `templates/interview.md` and use it as the structure for the output.

Build the interview guide using the intake answers. Apply Mom Test principles throughout:

**Question generation rules:**
- Every question asks about past behavior or current reality, not future intent
  - Good: "When did you last have to deal with this?"
  - Bad: "Would you use a feature that..."
- Questions explore their life and problems, not your solution
- No leading questions or hypotheticals
- Every question has a clear intention tied to one of the stated hypotheses
- Probes dig for stories and specifics, not opinions

**Structure the core questions into 2-4 themes** based on the hypotheses. Generate at least 5 questions in total across all themes.

Fill in:
- Frontmatter: title (from `interview-name`), goal, customer_segment, status: draft, today's date, spec path if given
- Interview context: goal, customer segment, stage, and the hypotheses from intake
- Opening script: use the default from the template, but replace `[problem space]` with the relevant problem area from the intake answers
- Core questions: generated from the hypotheses, following the rules above
- Wrap-up questions: use the default set from the template
- Debrief notes: use the default structure from the template

## Iterate

Show the PM the full draft and ask:

> "Here is your interview guide. Does anything need to change? You can ask me to:
> - Add, remove, or reword questions
> - Add a new theme
> - Adjust the opening script
> - Change who this is for or what stage it is
>
> Say 'done' when you are happy with it."

Keep iterating with AskUserQuestion until the PM says done.

## Quality check

Using the standards already loaded from `/rules/interview-quality.md`, check the draft content against all quality gates. Report any issues found, but do not block the save - interview files are advisory only.

## Save

Create the directory `<project>/interviews/` if it does not exist.

Write the final guide to `<project>/interviews/<interview-name>.md`.

## Finish

Tell the PM:
- File saved at: `<project>/interviews/<interview-name>.md`
- Any quality warnings (if none, confirm it passed)
- Next step:
  - If a spec was linked: "After running your interviews, update the spec with new findings: `/pm:spec <project> <feature-name>`"
  - If no spec was linked and this is discovery: "After running a few interviews, create a spec from what you learned: `/pm:spec <project> <feature-name>`"
  - If no spec was linked and this is post-launch: "After running your interviews, create a ticket for any follow-up work: `/pm:ticket <project> <ticket-title>`"
