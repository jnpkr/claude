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

# Extract values from JSON
MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
CONTEXT_SIZE=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
TRANSCRIPT_PATH=$(echo "$input" | jq -r '.transcript_path // ""')

# Get context length from transcript (most recent main-chain entry)
# Each API call includes the full context, so the last entry's input = current context size
CONTEXT_LENGTH=0
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
	# Stream through reversed file, filter for main-chain entries with usage, take first match
	CONTEXT_LENGTH=$(tail -r "$TRANSCRIPT_PATH" |
		jq -r 'select((.isSidechain == false or .isSidechain == null) and .message.usage) | .message.usage | .input_tokens + .cache_read_input_tokens + .cache_creation_input_tokens' |
		head -1)
	[ -z "$CONTEXT_LENGTH" ] || [ "$CONTEXT_LENGTH" = "null" ] && CONTEXT_LENGTH=0
fi

# Usable context = 80% of max (before auto-compact triggers)
USABLE_CONTEXT=$((CONTEXT_SIZE * 80 / 100))

# Percentage of usable context consumed
PERCENT=$((CONTEXT_LENGTH * 100 / USABLE_CONTEXT))
[ "$PERCENT" -gt 100 ] && PERCENT=100

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
