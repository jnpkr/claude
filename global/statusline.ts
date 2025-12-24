#!/usr/bin/env bun
import { readFileSync, existsSync } from "node:fs";
import simpleGit from "simple-git";

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
const BLUE = "\x1b[34m";
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

interface GitStatus {
  staged: number;
  modified: number;
  untracked: number;
  deleted: number;
  conflicted: number;
}

async function getGitStatus(): Promise<GitStatus | null> {
  try {
    const status = await simpleGit().status();
    return {
      staged: status.staged.length + status.created.length,
      modified: status.modified.length,
      untracked: status.not_added.length,
      deleted: status.deleted.length,
      conflicted: status.conflicted.length,
    };
  } catch {
    return null;
  }
}

function buildGitStatusString(status: GitStatus | null): string {
  if (status === null) return "";

  const parts: string[] = [];

  if (status.staged > 0) parts.push(`${GREEN}+${status.staged}${RESET}`);
  if (status.modified > 0) parts.push(`${YELLOW}!${status.modified}${RESET}`);
  if (status.untracked > 0) parts.push(`${BLUE}?${status.untracked}${RESET}`);
  if (status.deleted > 0) parts.push(`${RED}✘${status.deleted}${RESET}`);
  if (status.conflicted > 0) parts.push(`${RED}=${status.conflicted}${RESET}`);

  if (parts.length === 0) {
    return `${GREEN}✓${RESET}`;
  }

  return parts.join(" ");
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
const gitStatus = buildGitStatusString(await getGitStatus());
const gitPart = gitStatus ? `${sep}📂 ${gitStatus}` : "";

process.stdout.write(
  `🤖 ${model}${sep}🧠 ${color}[${bar}] ${percent}%${sep}✏️ ${GREEN}+${linesAdded}${RESET} ${RED}-${linesRemoved}${RESET}${gitPart}`
);
