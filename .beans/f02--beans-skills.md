---
# g50r
title: Skills for creating beans by type
status: todo
type: feature
created_at: 2025-12-26T14:44:12Z
updated_at: 2025-12-26T14:44:12Z
---

Create Claude Code skills that provide templates and prompts for creating different types of beans.

Each skill would guide issue creation with type-appropriate structure:

- Required fields and sections
- Checklist templates
- Prompts for description quality

## Naming Convention

After creation, rename with `mv` to follow hierarchy pattern:

- `mNN--slug` for milestones
- `mNN-eNN--slug` for epics under milestones
- `mNN-eNN-fNN--slug` for features under epics
- `mNN-eNN-bNN--slug` for bugs under epics
- `mNN-eNN-tNN--slug` for tasks under epics
- `eNN--slug` for standalone epics
- `fNN--slug`, `bNN--slug`, `tNN--slug` for other standalone items

Slug guidelines:

- Keep concise (2-4 words max)
- Use key descriptive terms, not full title
- Check git history before assigning numbers to avoid collisions

Test beans should be deleted directly (`beans delete -f`), not scrapped/archived.

## Checklist

- [ ] Research Claude Code skill structure and best practices
- [ ] Design skill for bug creation
- [ ] Design skill for feature creation
- [ ] Design skill for task creation
- [ ] Design skill for epic/milestone creation
- [ ] Implement and test skills
- [ ] Document usage in repo CLAUDE.md
