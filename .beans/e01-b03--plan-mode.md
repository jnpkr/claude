---
# uvpj
title: Claude Code doesn't trigger Plan mode when appropriate
status: todo
type: bug
created_at: 2025-12-26T14:56:19Z
updated_at: 2025-12-26T14:56:19Z
parent: mqhw
---

Pattern where Claude Code starts implementation or research without entering Plan mode, despite having the EnterPlanMode tool available and criteria being met.

## Criteria for Plan mode (from tool description)

- New Feature Implementation
- Multiple Valid Approaches
- Code Modifications affecting existing behavior
- Architectural Decisions
- Multi-File Changes
- Unclear Requirements
- User Preferences Matter

## Example from this session

Asked to 'create a single skill for all types' - this met multiple criteria (new feature, unclear requirements, multiple approaches) but instead of triggering Plan mode, started silently looking at internal code.

## Checklist

- [ ] Research why Plan mode isn't being triggered automatically
- [ ] Determine if this is covered by existing research task (3fvz)
- [ ] Identify prompt patterns that might improve Plan mode usage