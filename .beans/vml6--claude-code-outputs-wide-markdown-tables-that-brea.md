---
# vml6
title: Claude Code outputs wide markdown tables that break terminal display
status: todo
type: bug
priority: normal
created_at: 2025-12-26T14:07:04Z
updated_at: 2025-12-26T14:28:57Z
---

Pattern where Claude Code outputs wide markdown tables that don't render well in terminal output.

Terminal width is limited and wide tables either wrap awkwardly or require horizontal scrolling, making them unreadable. Should prefer alternative formats for terminal output:
- Vertical key/value lists
- Bullet points
- Narrower table designs
- Plain text summaries