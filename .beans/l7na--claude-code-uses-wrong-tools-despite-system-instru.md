---
# l7na
title: Claude Code uses wrong tools despite system instructions
status: todo
type: bug
priority: normal
created_at: 2025-12-26T14:05:58Z
updated_at: 2025-12-26T14:24:31Z
parent: mqhw
---

Pattern where Claude Code uses bash commands instead of specialized tools, despite system instructions explicitly preferring them.

Examples:

- Using `bash grep` or `bash rg` instead of the Grep tool
- Using `bash cat` instead of the Read tool
- Using `bash find` instead of the Glob tool

System instructions state: 'Use specialized tools instead of bash commands when possible' and 'Reserve bash tools exclusively for actual system commands and terminal operations that require shell execution.'
