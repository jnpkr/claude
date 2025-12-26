---
# ffv1
title: ultralytics-dev plugin hooks not firing
status: todo
type: bug
priority: normal
created_at: 2025-12-26T14:22:19Z
updated_at: 2025-12-26T14:36:02Z
---

The ultralytics-dev plugin is installed but its PostToolUse hooks aren't executing after Edit/Write operations.

## What we know
- Plugin is installed at ~/.claude/plugins/cache/fcakyon-claude-plugins/ultralytics-dev/2.0.2/
- hooks/hooks.json is valid and defines PostToolUse hooks for Edit|MultiEdit|Write
- According to Context7 docs, plugin hooks should auto-merge with user hooks
- Not installed mid-session, so restart isn't the issue
- No manual settings.json entry should be required

## What we don't know
- Why hooks aren't being triggered
- Whether there's a loading/registration issue
- Whether other plugins from fcakyon-claude-plugins have the same problem (general-dev, notification-tools)

## To investigate
- Check if other fcakyon plugins work
- Compare with working plugin (superpowers) structure
- Check Claude Code logs for plugin loading errors
- Ask in Claude Code community/issues