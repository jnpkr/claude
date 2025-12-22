#!/bin/bash
# Claude Code statusline - shows model name + context usage with visual bar

input=$(cat)

# Extract model name
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# Extract lines added/removed
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Extract context window data
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
USAGE=$(echo "$input" | jq '.context_window.current_usage // null')

if [ "$USAGE" != "null" ]; then
    # Calculate current context from current_usage fields
    INPUT_TOKENS=$(echo "$USAGE" | jq '.input_tokens // 0')
    CACHE_CREATE=$(echo "$USAGE" | jq '.cache_creation_input_tokens // 0')
    CACHE_READ=$(echo "$USAGE" | jq '.cache_read_input_tokens // 0')
    CURRENT_TOKENS=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))
else
    CURRENT_TOKENS=0
fi

# Autocompact buffer is ~22.5% of context (45k for 200k window)
AUTOCOMPACT_BUFFER=$((CONTEXT_SIZE * 225 / 1000))
USABLE_CONTEXT=$((CONTEXT_SIZE - AUTOCOMPACT_BUFFER))

# Calculate percentage of usable context consumed
if [ "$USABLE_CONTEXT" -gt 0 ]; then
    PERCENT=$((CURRENT_TOKENS * 100 / USABLE_CONTEXT))
    # Cap at 100% for display
    [ "$PERCENT" -gt 100 ] && PERCENT=100
else
    PERCENT=0
fi

# Build progress bar (10 chars)
FILLED=$((PERCENT / 10))
EMPTY=$((10 - FILLED))
BAR=""
for ((i=0; i<FILLED; i++)); do BAR+="█"; done
for ((i=0; i<EMPTY; i++)); do BAR+="░"; done

# Color based on thresholds: green <50%, yellow 50-75%, red >75%
if [ "$PERCENT" -lt 50 ]; then
    COLOR="\033[32m"  # Green
elif [ "$PERCENT" -lt 75 ]; then
    COLOR="\033[33m"  # Yellow
else
    COLOR="\033[31m"  # Red
fi
RESET="\033[0m"

# Colors for lines
GREEN="\033[32m"
RED="\033[31m"

# Output
SEP="${RESET} · "
printf "🤖 ${MODEL}${SEP}🧠 ${COLOR}[${BAR}] ${PERCENT}%%${SEP}${GREEN}+${LINES_ADDED}${RESET} ${RED}-${LINES_REMOVED}${RESET}"
