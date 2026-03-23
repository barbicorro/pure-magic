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

## Task files (`tasks/<feature>/task-title.md`)

```yaml
---
title: Task title
type: task
status: local         # local | synced | in-progress | done
size: S               # XS | S | M | L
created: 2026-01-01
updated: 2026-01-01
depends_on: []        # list of sibling task filenames, e.g. [build-onboarding-wizard.md]
spec_section: "Main Features > Session Creation"
priority:             # optional: high | medium | low
sync_url:             # filled after /pm:sync
sync_id:              # filled after /pm:sync
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
priority:             # optional: high | medium | low
sync_url:             # filled after /pm:sync
sync_id:              # filled after /pm:sync
---
```

## Interview files (`interviews/`)

```yaml
---
title: Interview Title
type: interview
goal: ""
customer_segment: ""
status: draft         # draft | complete
created: 2026-01-01
updated: 2026-01-01
spec: ""              # path to linked spec, or blank
---
```

## Outcome brief files (`<project>/outcome-briefs/`)

```yaml
---
title: "Outcome Brief: Feature Name"
type: outcome-brief
status: draft         # draft | final
created: 2026-01-01
updated: 2026-01-01
---
```

## Rules

- Dates are always ISO 8601 format: `YYYY-MM-DD`
- `updated` must be set to today's date any time a file is modified
- `sync_url` and `sync_id` are left blank until `/pm:sync` runs
- `status` values are lowercase, use the exact values listed above
- `size` values are uppercase: XS, S, M, L
- `priority` is optional. Values are lowercase: high, medium, low. Leave blank if not set.
- Never use placeholder text like "TBD" or "TODO" in frontmatter
