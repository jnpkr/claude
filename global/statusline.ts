#!/usr/bin/env bun
import { readFileSync, existsSync } from "node:fs";

interface StatusJSON {
  model: { display_name: string };
  cost: { total_lines_added: number; total_lines_removed: number };
  context_window: { context_window_size: number };
  transcript_path: string;
}

interface TranscriptEntry {
  isSidechain?: boolean;
  message?: {
    usage?: {
      input_tokens: number;
      cache_read_input_tokens: number;
      cache_creation_input_tokens: number;
    };
  };
}

const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const RED = "\x1b[31m";
const RESET = "\x1b[0m";

const FILLED = "██████████";
const EMPTY = "░░░░░░░░░░";

const THRESHOLD_YELLOW = 70;
const THRESHOLD_RED = 90;

interface ContextInfo {
  baseline: number; // Pre-cached system overhead from first message
  current: number; // Current total context
}

function getContextInfo(transcriptPath: string): ContextInfo {
  if (!existsSync(transcriptPath)) return { baseline: 0, current: 0 };

  const lines = readFileSync(transcriptPath, "utf-8").trim().split("\n");

  let baseline = 0;
  let current = 0;
  let foundFirst = false;

  // Find first usage entry for baseline, and last for current
  for (let i = 0; i < lines.length; i++) {
    try {
      const entry: TranscriptEntry = JSON.parse(lines[i]);
      if (entry.isSidechain !== true && entry.message?.usage) {
        const u = entry.message.usage;
        const total =
          (u.input_tokens ?? 0) +
          (u.cache_read_input_tokens ?? 0) +
          (u.cache_creation_input_tokens ?? 0);

        if (!foundFirst) {
          // Baseline is total tokens from first message (session overhead)
          baseline = total;
          foundFirst = true;
        }
        current = total;
      }
    } catch {
      // Skip invalid JSON lines
    }
  }

  return { baseline, current };
}

function getColor(percent: number): string {
  if (percent < THRESHOLD_YELLOW) return GREEN;
  if (percent < THRESHOLD_RED) return YELLOW;
  return RED;
}

function buildProgressBar(percent: number): string {
  const filled = Math.floor(percent / 10);
  const empty = 10 - filled;
  return FILLED.slice(0, filled) + EMPTY.slice(0, empty);
}

// Read JSON from stdin
const input: StatusJSON = JSON.parse(readFileSync(0, "utf-8"));

// Extract values
const model = input.model?.display_name ?? "Claude";
const linesAdded = input.cost?.total_lines_added ?? 0;
const linesRemoved = input.cost?.total_lines_removed ?? 0;
const contextSize = input.context_window?.context_window_size ?? 200000;
const transcriptPath = input.transcript_path ?? "";

// Calculate context percentage relative to usable user capacity
const { baseline, current } = getContextInfo(transcriptPath);
const autoCompactThreshold = contextSize * 0.8;
const usableForUser = autoCompactThreshold - baseline;
const userUsage = current - baseline;
const percent =
  usableForUser > 0
    ? Math.min(100, Math.max(0, Math.floor((userUsage / usableForUser) * 100)))
    : 0;

// Build output
const bar = buildProgressBar(percent);
const color = getColor(percent);
const sep = `${RESET} · `;

process.stdout.write(
  `🤖 ${model}${sep}🧠 ${color}[${bar}] ${percent}%${sep}${GREEN}+${linesAdded}${RESET} ${RED}-${linesRemoved}${RESET}`
);
