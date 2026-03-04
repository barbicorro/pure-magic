# Interview Quality Standards

Every interview guide created by `/pm:interview` must meet these standards. These gates are enforced by `/pm:validate`.

## Required fields (frontmatter)

- **title**: Non-empty, describes the interview
- **goal**: Non-empty, describes what we want to learn
- **customer_segment**: Non-empty, describes who is being interviewed
- **status**: One of `draft`, `complete`

## Required sections (body)

- **Interview context**: Must exist and be filled in
- **Ground rules**: Must be present (can be the default set)
- **Opening script**: Must be present
- **Core questions**: Must have at least 5 questions across all themes
- **Wrap-up questions**: Must be present
- **Debrief notes**: Must be present

## Question quality gates

Each question in `## Core questions` must have:
- The question itself (non-empty)
- An **Intention** field (non-empty)
- At least one follow-up probe

## Anti-pattern detection

Flag any question that matches these patterns - they violate Mom Test principles:

- **Hypothetical future intent**: "Would you use...", "Would you pay...", "Do you think you would..."
- **Leading questions**: "Don't you think...", "Isn't it frustrating that...", "Would it be better if..."
- **Pitching disguised as a question**: "What do you think of a product that..."
- **Opinion-seeking with no story**: "Do you like...", "How important is..."

Flag these but do not auto-replace them. Report them as warnings and ask the PM to revise.

## Quality gates enforced by /pm:validate

1. `goal` is not empty or placeholder text
2. `customer_segment` is not empty or placeholder text
3. At least 5 core questions exist in the body
4. Every core question has an `Intention` field
5. No question matches anti-pattern list above
6. No field contains "TBD", "TODO", or "placeholder" (case-insensitive)

If any gate fails, report which checks failed. Do not block the file from being saved - interviews are not synced to GitHub, so these are advisory quality checks only.
