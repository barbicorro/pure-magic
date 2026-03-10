# /pm:interview

Co-creates a customer interview guide using Mom Test principles.

## Why this exists

Customer interviews are one of the most valuable PM activities and one of the most commonly done wrong. The problem is not effort - it is that most interview questions accidentally coach the user toward the answer you want to hear.

"Would you use a feature that let you do X?" - Yes, of course, it sounds useful.
"How often do you deal with this problem?" - All the time! (They never will.)
"What do you think of this idea?" - Sounds great! (They are being polite.)

These questions feel productive in the moment but give you false confidence. You walk away thinking you validated something when you just confirmed your own assumptions.

The Mom Test - developed by Rob Fitzpatrick - is a set of rules for asking questions that are hard to lie to. Ask about what people actually did in the past, not what they might do in the future. Ask about their real life and real problems, not your solution. Every question should be almost impossible to answer wrong, because it is grounded in reality.

`/pm:interview` builds these rules into the guide automatically. You describe who you are interviewing and what you are trying to learn, and the skill writes questions that follow the principles - past behavior, specific stories, no leading, no hypotheticals.

## Usage

```
/pm:interview <project> <interview-name>
```

Example:

```
/pm:interview acme discovery-coaches
```

## Interview stages

The guide is shaped by what stage you are at:

- **Discovery** - you are exploring a problem space and do not have a product yet. The goal is to understand how people work, what hurts, and whether the problem is real.
- **Validation** - you have an idea or a direction and want to stress-test it against reality before investing in building it.
- **Post-launch** - you have a product and want to learn from people who are using it (or not using it).

Each stage calls for different kinds of questions, and the skill adjusts accordingly.

## Linking to a spec

If you have already written a spec, you can link the interview to it. The skill reads the spec and uses the problem statement, goals, and open questions to shape the hypotheses and core questions. This is useful when you want to validate assumptions that are baked into an existing spec before committing to the work.

## Output

An interview guide at `<project>/interviews/<interview-name>.md`, with:
- Context section: goal, customer segment, stage, and hypotheses
- Opening script to start the conversation neutrally
- Core questions organized into 2-4 themes, each with a stated intention
- Wrap-up questions
- Debrief section to capture patterns after multiple interviews

## After the interviews

- If you ran discovery interviews and found something worth building, write a spec: `/pm:spec <project> <feature-name>`
- If the interviews were linked to an existing spec, update it with what you learned: `/pm:spec <project> <feature-name>`
- If the interviews surfaced a specific fix or improvement, create a ticket: `/pm:ticket <project> <ticket-title>`

## Notes

Interview files are never pushed to GitHub Issues or Jira. They are for your discovery work, not the issue tracker.
