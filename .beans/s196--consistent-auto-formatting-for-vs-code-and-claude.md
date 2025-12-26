---
# s196
title: Consistent auto-formatting for VS Code and Claude Code
status: todo
type: feature
created_at: 2025-12-26T14:09:05Z
updated_at: 2025-12-26T14:09:05Z
---

Set up formatting and linting that works automatically and invisibly with both VS Code and Claude Code.

Goals:
- Format on save in VS Code
- Claude Code respects same formatting rules
- No manual intervention required
- Consistent output regardless of which tool makes the edit

Considerations:
- Prettier / ESLint for JS/TS
- markdownlint for markdown (already seeing MD007 warnings)
- EditorConfig for basic settings
- Pre-commit hooks vs editor integration