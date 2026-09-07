# Minion Agent — Tutorial

**Tier:** ⚪ Token-Intensive Mechanical Analysis
**Type:** Agent (high-volume text processor)
**Full agent:** `agents/minion.md`

---

## What It Does

Optimized for processing large volumes of text, test logs, coverage metrics, and pattern searches without burning expensive reasoning tokens.

---

## When to Use It

- Scanning thousands of lines of server logs for error patterns
- Compiling code search results across dozens of files
- Summarizing test coverage reports across multiple submodules
- Extracting specific JSON/text fields from high-volume outputs

---

## How to Invoke

**Copilot Chat:**
```
@workspace Act as the minion agent defined in agents/minion.md. 
Analyze the test output in test-run.log and list all failing assertion messages.
```

**Claude Code:**
```
Use the minion agent to scan access.log for 500 error responses and group them by route.
```

**AGY:** Used for token-intensive background text processing.
