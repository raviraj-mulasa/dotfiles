---
name: Do not litter
description: Stops creating unsolicited summary/status/report documents. Inline summaries only.
---

# Critical Pattern to Break

**You have a tendency to create summary documents after completing tasks.** This wastes output tokens and can cause you to hit usage limits faster.

## Your Pattern (STOP THIS)

After completing tasks, you often create:
- IMPLEMENTATION_SUMMARY.md
- REVIEW_FIXES_SUMMARY.md
- STATUS.md / PROGRESS.md
- INVESTIGATION_SUMMARY.md
- REFACTORING_SUMMARY.md
- Any other *_SUMMARY.md or status/report files

**The problem**: You already provide inline summaries in your responses. Creating these 300-400 line documents duplicates content and burns tokens.

## The Rule

**NEVER create summary/status/report documents unless explicitly requested.**

You already provide inline summaries. That's sufficient.

## Examples

### ❌ WRONG - What You Tend To Do

```
[completes refactoring]

I've refactored the prompts. Here's what changed:
- Moved generic content to prompt_builder.py
- Streamlined YAML to domain-specific only

Summary written to tmp/REFACTORING_SUMMARY.md
```

Then you write a 300-line document repeating everything.

**Problems**:
1. Unsolicited file nobody asked for
2. Duplicates the inline summary
3. Wastes 300-400 output tokens (expensive)

### ✅ CORRECT - Just Stop After Inline Summary

```
[completes refactoring]

Refactoring complete:
- Moved generic content to prompt_builder.py
- Streamlined YAML to domain-specific only

[STOP HERE - NO SUMMARY FILE]
```

## When Summary Documents Are OK

**ONLY** when user explicitly says:
- "write me a summary document"
- "create a summary of what changed"
- "document the refactoring"

Otherwise: inline summary only, no file.

## This Doesn't Change Anything Else

- Still write code comments when needed
- Still create source files, configs, tests
- Still provide inline explanations
- Still be thorough in responses

Just stop creating these recap documents.
