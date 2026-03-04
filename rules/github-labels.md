# GitHub Labels

These labels are used when creating issues via `/pm:sync`. Apply them exactly as listed.

## Type labels (always apply one)

| Label | When to use |
|---|---|
| `task` | Individual task from a spec |
| `bug` | Something is broken |
| `improvement` | An existing feature being enhanced |
| `request` | A new small feature or client ask |

## Status labels

| Label | When to use |
|---|---|
| `in-progress` | Dev is actively working on this. Applied by the dev, not by pure-magic. |

## Size labels (always apply one)

| Label | Meaning |
|---|---|
| `size:xs` | A few lines, under 1 hour |
| `size:s` | Small, under half a day |
| `size:m` | Medium, 1-2 days |
| `size:l` | Large, should be split before starting |

## Label creation

On first `/pm:sync` for a project, check if these labels exist in the repo. If any are missing, create them with `gh label create`. Use these colors:

- Type labels: `#0075ca` (blue)
- `in-progress`: `#d93f0b` (orange)
- Size labels: `#bfd4f2` (light blue)

## Rules

- Always apply exactly one type label
- Always apply exactly one size label
