#!/bin/bash
# Claude Code statusline - shows model name + context usage with visual bar

# ANSI color codes
readonly GREEN="\033[32m"
readonly YELLOW="\033[33m"
readonly RED="\033[31m"
readonly RESET="\033[0m"
readonly SEP="${RESET} · "

# Character sets for progress bar
readonly FILLED_CHARS="██████████"
readonly EMPTY_CHARS="░░░░░░░░░░"

# Color thresholds (percentage of usable context)
readonly THRESHOLD_YELLOW=70
readonly THRESHOLD_RED=90

# Read JSON input
input=$(cat)

# Extract values from JSON (each field on its own line for clarity)
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')

# Current context = all input tokens in current window (fresh + cached)
INPUT_TOKENS=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
CACHE_CREATE=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
CACHE_READ=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
CURRENT_TOKENS=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))

# Autocompact buffer is 22.5% of context (45k for 200k window)
AUTOCOMPACT_BUFFER=$((CONTEXT_SIZE * 225 / 1000))

# Calculate inverse of free space: 100 - ((context - components - buffer) / context * 100)
# Equivalent to: (components + buffer) / context * 100
if [ "$CONTEXT_SIZE" -gt 0 ]; then
    PERCENT=$(( (CURRENT_TOKENS + AUTOCOMPACT_BUFFER) * 100 / CONTEXT_SIZE ))
    [ "$PERCENT" -gt 100 ] && PERCENT=100
else
    PERCENT=0
fi

# Build progress bar using substring extraction
FILLED=$((PERCENT / 10))
EMPTY=$((10 - FILLED))
BAR="${FILLED_CHARS:0:$FILLED}${EMPTY_CHARS:0:$EMPTY}"

# Color based on thresholds
if [ "$PERCENT" -lt "$THRESHOLD_YELLOW" ]; then
    COLOR="$GREEN"
elif [ "$PERCENT" -lt "$THRESHOLD_RED" ]; then
    COLOR="$YELLOW"
else
    COLOR="$RED"
fi

# Output statusline
printf "🤖 ${MODEL}${SEP}🧠 ${COLOR}[${BAR}] ${PERCENT}%%${SEP}${GREEN}+${LINES_ADDED}${RESET} ${RED}-${LINES_REMOVED}${RESET}"
