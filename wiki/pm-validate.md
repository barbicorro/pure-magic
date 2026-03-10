# /pm:validate

Checks one or more PM files against quality and frontmatter standards.

## Why this exists

Underspecified tickets are one of the most common sources of wasted time in product development. A ticket without clear acceptance criteria leaves the developer guessing what done looks like. A task title that starts with a noun ("Onboarding wizard") does not tell anyone what action to take. Placeholder text that never got filled in ("TBD - to confirm with design") reaches the sprint as if it were real content.

These are not edge cases. They happen on every team, in every sprint, and they slow things down in ways that are hard to trace back to the source.

`/pm:validate` catches these gaps before the work leaves your hands. It is a fast, explicit check you can run at any point - and it runs automatically when you use `/pm:parse`, `/pm:ticket`, and `/pm:sync`, so most of the time you do not need to think about it.

## Usage

```
/pm:validate <file-path> [file-path ...]
```

Examples:

```
/pm:validate acme/tasks/onboarding/build-wizard.md
/pm:validate acme/tickets/fix-login.md
```

## What it checks

For tasks and tickets:

- The title starts with an action verb - so the work is immediately clear
- The description exists and has real content, not placeholder text
- There are at least 2 acceptance criteria - so done is defined, not assumed
- Size is set - so the team can plan
- Priority, if set, uses the standard values (P1-P4)

For tasks specifically:

- `spec_section` is set - this is the traceability link back to the spec, which matters when someone asks why this task exists

For interview guides:

- Goal and customer segment are defined
- At least 5 core questions are present
- Each question has a stated intention
- Mom Test anti-patterns are flagged as warnings (they do not block saving, since interviews are never synced)

## When to run it yourself

`/pm:validate` runs automatically during other skills, so you will rarely need to call it directly. The main reason to run it manually is when you have edited a file by hand after it was created, or when you are working on a batch of files and want to check them before syncing.

## Output

Pass:
```
Validation passed: 3 file(s) checked, all OK.
```

Fail:
```
Validation failed:

acme/tasks/onboarding/build-wizard.md
  - Title does not start with a verb: "Onboarding wizard setup"
  - Missing acceptance criteria (found 1, need at least 2)

1 file(s) checked. 0 passed, 1 failed.
```

The output is specific enough to fix without guessing.

## Customizing the rules

If your team uses different standards, you can override the default rules per project. Place a modified rule file at `.claude/overrides/rules/task-quality.md` and the validator will follow it instead of the default.
