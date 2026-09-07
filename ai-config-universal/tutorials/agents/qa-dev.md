# QA Dev Agent — Tutorial

**Tier:** 🔵 Situational (adversarial tests for critical features)
**Type:** Agent (hands off the task completely)
**Full agent:** `agents/qa-dev.md`

---

## What It Does

Writes **adversarial test cases** — tests designed to find the bugs you didn't think about. It reads your spec (not your implementation) and thinks like someone trying to break the feature.

It is loyal to the spec, not to your code. If the code doesn't match the spec, it writes tests that expose that gap.

---

## When to Use It

- A feature is critical enough that you want tests beyond what you'd write yourself
- Payment, auth, data integrity, or security-sensitive code
- You want "what could go wrong" coverage — race conditions, edge cases, failure modes
- After writing-qa-plan — to generate the actual test code from the plan

**Skip it for:** simple CRUD features, UI-only changes, internal tooling.

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read agents/qa-dev.md and write adversarial tests 
for the rate limiting feature.

Spec: tasks/2025-09-02-rate-limiting.spec.md
Implementation: src/auth/middleware.py
Focus on: edge cases, race conditions, bypass attempts
```

**Claude Code:**
```
Use the qa-dev agent on the payment webhook handler.
Spec is in tasks/webhook.spec.md
I especially want tests for the idempotency logic.
```

---

## What It Does Differently from Code Reviewer Tests

| Your tests | QA Dev agent tests |
|---|---|
| Happy path + obvious errors | Edge cases + adversarial scenarios |
| Written by the implementer | Written by a fresh adversarial reviewer |
| "Does it work?" | "How can it be broken?" |
| What you thought to test | What you didn't think to test |

---

## Sample Output

```python
# Adversarial tests for rate limiting

class TestRateLimitingAdversarial:
    
    def test_rate_limit_not_reset_by_successful_login(self, client, redis):
        """Verify: 3 failed attempts + 1 success + 2 more failures = blocked.
        
        Some implementations reset the counter on success, allowing an attacker
        to use one valid credential to reset the counter for another account.
        """
        for _ in range(3):
            client.post("/auth/login", json={"email": "x@x.com", "password": "wrong"})
        
        # Successful login (attacker uses known valid credentials)
        client.post("/auth/login", json=valid_credentials)
        
        # Continue failing attempts — should still count toward 5 total
        for _ in range(2):
            client.post("/auth/login", json={"email": "x@x.com", "password": "wrong"})
        
        response = client.post("/auth/login", json={"email": "x@x.com", "password": "wrong"})
        assert response.status_code == 429  # Should be blocked at attempt 6

    def test_rate_limit_per_ip_not_per_session(self, client):
        """Verify: clearing cookies doesn't reset the rate limit."""
        for _ in range(5):
            client.post("/auth/login", json={"email": "x@x.com", "password": "wrong"})
        
        client.cookies.clear()  # Attacker clears session
        
        response = client.post("/auth/login", json={"email": "x@x.com", "password": "wrong"})
        assert response.status_code == 429  # Still blocked — key is IP, not session

    def test_concurrent_requests_dont_bypass_limit(self, client):
        """Race condition: simultaneous requests at attempt #5 shouldn't both succeed."""
        import threading
        results = []
        
        # Exhaust to 4 attempts
        for _ in range(4):
            client.post("/auth/login", json={"email": "x@x.com", "password": "wrong"})
        
        # Fire 3 simultaneous requests as attempt #5
        def make_request():
            results.append(client.post("/auth/login", json={"email": "x@x.com", "password": "wrong"}))
        
        threads = [threading.Thread(target=make_request) for _ in range(3)]
        for t in threads: t.start()
        for t in threads: t.join()
        
        # At most 1 should succeed (the one that got in before the limit was hit)
        blocked = [r for r in results if r.status_code == 429]
        assert len(blocked) >= 2  # At least 2 of 3 concurrent requests blocked
```

---

## What to Give the Agent

- **Spec file path** — it reads the spec, not the code (spec = source of truth)
- **Implementation file(s)** — for reference only
- **Focus areas** — where you want adversarial attention
- **Constraints** — test framework, any setup fixtures that exist

---

## Time Investment

- Agent runs: 5-10 minutes
- Saves: security vulnerabilities found in production, race conditions, bypass attacks
