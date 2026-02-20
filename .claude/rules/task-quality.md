# Task Quality Standards

Every task and ticket created by pure-magic must meet these standards before it can be synced to GitHub. These are enforced by `/pm:parse` and `/pm:sync`.

## Required fields (all tasks and tickets)

- **Title**: Clear, action-oriented. Starts with a verb. Example: "Add session notes field to coach session view"
- **Description**: What needs to be done and why. Enough context for a dev to start without asking basic questions.
- **Acceptance criteria**: A checklist of conditions that define "done" from the user's perspective. At least 2 items. No vague criteria like "it works" or "looks good".
- **Size**: XS, S, M, or L, required on every task and ticket

## Required for tasks from `/pm:parse` only

- **`spec_section`**: The section of the spec this task came from. This is the traceability link. If a task cannot be traced back to a spec section, it should not exist.

## Size guidelines

| Size | Meaning | What to do if larger |
|---|---|---|
| XS | A few lines, under 1 hour | Fine as-is |
| S | Small, under half a day | Fine as-is |
| M | Medium, 1-2 days | Fine as-is, but consider splitting |
| L | Large, more than 2 days | Must include a note on how to split. Warn the PM before syncing. |

## Acceptance criteria format

Write as a checklist. Each item must be verifiable:

```
**Acceptance criteria:**
- [ ] Coach can add notes to a session from the session detail view
- [ ] Notes are saved on blur (no save button needed)
- [ ] Notes are visible to the coach on the session history view
- [ ] Notes are not visible to the coachee
```

Bad examples (do not use):
- "Feature works correctly" (not verifiable)
- "UI looks good" (subjective)
- "Tests pass" (assumed, not a product criterion)

## Quality gates enforced before sync

1. Description is not empty and not placeholder text
2. Acceptance criteria has at least 2 items
3. Size is set
4. `spec_section` is set (for tasks created by /pm:parse)
5. Title starts with a verb
6. No field contains "TBD", "TODO", or "placeholder"

If any gate fails, report which fields need attention and stop. Do not create the GitHub issue.
