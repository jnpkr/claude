---
# 63rk
title: Claude Code ignores explicit CLAUDE.md rules
status: in-progress
type: bug
priority: normal
created_at: 2025-12-26T14:03:46Z
updated_at: 2025-12-26T14:24:31Z
parent: mqhw
---

Ongoing pattern where Claude Code violates explicit rules in CLAUDE.md despite having them in context. Examples from this session:

1. **Answering the wrong question**: Asked 'what led to the behaviour' - answered 'which rule was violated' instead of causation
2. **Acting without permission**: Asked 'why @-include?' - immediately jumped to editing instead of just answering
3. **Making assumptions instead of asking**: Invented conventions, assumed symlink structure, assumed statusline purpose - despite explicit rule 'YOU MUST ALWAYS STOP and ask for clarification rather than making assumptions'
4. **Acknowledging rules without following them**: Said 'I should have asked' but then didn't actually ask

This pattern makes Claude Code unusable because explicit instructions aren't followed reliably.