# /pm:ticket

Creates a standalone ticket for a bug, improvement, or small request.

## Why this exists

Not everything needs a spec. A broken redirect, a label that is wrong, a small UX fix - these things should move fast. But even small tickets fail when they are underspecified. A bug report without reproduction steps. An improvement request with no acceptance criteria. A "quick change" that turns into a two-week thread because nobody wrote down what done looks like.

`/pm:ticket` gives small work the same discipline as a full spec, without the overhead. It asks the right questions for the type of work - reproduction steps for bugs, acceptance criteria for everything, exact formulas if computation is involved - and writes a ticket that a developer can act on without asking for more context.

## Usage

```
/pm:ticket <project> <ticket-title>
```

Example:

```
/pm:ticket acme fix-login-redirect
```

## When to use this vs. /pm:spec

Use `/pm:ticket` when:
- The scope is small and clear (likely XS or S)
- It is a bug with known reproduction steps
- It is an improvement to something that already exists
- It is a self-contained request with no dependencies

Use `/pm:spec` when:
- The feature is new and requires user flow design
- Multiple teams or user roles are involved
- The work is likely M or L and will generate multiple tasks
- You are not yet sure what the right solution is

If you size the ticket as M or L during the interview, the skill will suggest switching to a spec instead.

## Output

A ticket file at `<project>/tickets/<ticket-title>.md`.

Bug tickets use a different template than improvements and requests, with dedicated sections for reproduction steps and expected vs. actual behavior.

## Next step

```
/pm:sync <project> <ticket-title>
```
