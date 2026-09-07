# Commit Curator Agent — Tutorial

**Tier:** 🟢 Use Every Day (before every push)
**Type:** Agent (hands off the task completely)
**Full agent:** `agents/commit-curator.md`

---

## What It Does

Takes your messy staged/unstaged changes and organizes them into **clean, atomic commits** — each one doing one thing, with a clear conventional commit message.

Atomic commits make git history readable, make `git bisect` work, and make PRs reviewable.

---

## When to Use It

- You've been coding for hours and have a pile of changes
- You know your commits are going to be "WIP" and "fix" and "more stuff"
- Before opening a PR
- Before pushing to a shared branch

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read agents/commit-curator.md and organize 
my current changes into clean atomic commits.
```

**Claude Code:**
```
Use the commit-curator agent on my current changes.
```

**AGY:** "Organize my commits" or "clean up my git history" triggers it.

---

## What Happens

The agent first reads your diff:
```bash
git diff HEAD  # or git diff --staged
git status
```

Then it proposes a grouping:

```
Here's how I'd organize these changes into atomic commits:

Commit 1: feat(auth): add rate limiting to login endpoint
  Files: src/auth/middleware.py, src/auth/login.py
  Why: Complete, self-contained feature addition

Commit 2: test(auth): add rate limiting test coverage  
  Files: tests/test_login.py
  Why: Tests for commit 1 should travel with it

Commit 3: chore(deps): add redis-py dependency
  Files: requirements.txt, requirements-lock.txt
  Why: Separate dependency change for easy rollback

Commit 4: fix(auth): handle Redis connection timeout gracefully
  Files: src/auth/middleware.py
  Why: Bug fix is a separate concern from the feature

Does this grouping make sense? I'll generate the git commands once you confirm.
```

Then it produces the exact `git add -p` / `git commit` commands to run.

---

## Conventional Commit Format

The curator uses standard conventional commits:

| Prefix | When |
|---|---|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `test:` | Adding/updating tests |
| `refactor:` | Code restructure, no behavior change |
| `chore:` | Dependencies, config, tooling |
| `docs:` | Documentation only |
| `perf:` | Performance improvement |

Add scope in parentheses: `feat(auth):`, `fix(payments):`, `test(api):`

---

## Real Commit Message Examples

❌ Bad:
```
WIP
fixed stuff  
update login
more changes
```

✅ Good:
```
feat(auth): add Redis-backed rate limiting to login endpoint

Limits to 5 attempts per IP per 15 minutes.
Returns 429 with Retry-After header when exceeded.
```

---

## Time Investment

- Agent runs: 2-3 minutes
- You confirm and run commands: 2-5 minutes
- Saves: messy git history you'll regret in 3 months
