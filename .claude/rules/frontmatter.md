# Frontmatter Standards

All markdown files managed by pure-magic use YAML frontmatter. Always read and write frontmatter exactly as defined here. Never add extra fields. Never omit required fields.

## Spec files (`specs/`)

```yaml
---
title: Feature Name
type: spec
status: draft         # draft | parsed | synced
created: 2026-01-01
updated: 2026-01-01
---
```

## Epic files (`epics/<feature>/epic.md`)

```yaml
---
title: Feature Name
type: epic
status: local         # local | synced
created: 2026-01-01
updated: 2026-01-01
github_url:           # filled after /pm:sync
github_id:            # filled after /pm:sync
spec: specs/feature-name.md
---
```

## Task files (`epics/<feature>/001-task-title.md`)

```yaml
---
title: Task title
type: task
status: local         # local | synced | in-progress | done
size: S               # XS | S | M | L
created: 2026-01-01
updated: 2026-01-01
depends_on: []        # list of sibling task filenames, e.g. [001-task-title.md]
spec_section: "Main Features > Session Creation"
github_url:           # filled after /pm:sync
github_id:            # filled after /pm:sync
---
```

## Ticket files (`tickets/`)

```yaml
---
title: Ticket title
type: bug             # bug | improvement | request
status: local         # local | synced
size: S               # XS | S | M | L
created: 2026-01-01
updated: 2026-01-01
github_url:           # filled after /pm:sync
github_id:            # filled after /pm:sync
---
```

## Rules

- Dates are always ISO 8601 format: `YYYY-MM-DD`
- `updated` must be set to today's date any time a file is modified
- `github_url` and `github_id` are left blank until `/pm:sync` runs
- `status` values are lowercase, use the exact values listed above
- `size` values are uppercase: XS, S, M, L
- Never use placeholder text like "TBD" or "TODO" in frontmatter
