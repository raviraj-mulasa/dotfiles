# Fast-Worker Agent — Tutorial

**Tier:** 🟢 Core / Lightweight (Fast & Cheap)
**Type:** Agent (hands off bounded tasks)
**Full agent:** `agents/fast-worker.md`

---

## What It Does

A lightweight, fast, and token-efficient agent for **bounded, mechanical tasks** that do not require multi-step reasoning or architectural synthesis.

---

## When to Use It

- Searching the codebase for patterns, error codes, or function usages
- Running test suites and extracting pass/fail summaries
- Parsing large log files for specific traces
- Performing mechanical file formatting or straight file renaming

**Don't use it for:** design decisions, complex refactors, or debugging root causes — delegate those to `engineer`.

---

## How to Invoke

**Copilot Chat:**
```
@workspace Act as the fast-worker defined in agents/fast-worker.md. 
Find all occurrences of 'API_V1_TIMEOUT' across the src/ directory.
```

**Claude Code:**
```
Use the fast-worker agent to search for all deprecated database queries in models/.
```

**AGY:** Automatically selected for bounded mechanical operations.

---

## Operating Rules

1. **Execute strictly as instructed**: No tangents or extra refactoring.
2. **Stop on unexpected results**: If files are missing or tests crash unexpectedly, report immediately to the caller rather than guessing a workaround.
3. **Concise reporting**: High signal, zero fluff.
