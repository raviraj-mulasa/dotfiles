# Writing Unit Tests Skill — Tutorial

**Tier:** 🟡 Use Weekly (when writing tests)
**Type:** Skill (you stay in the driver's seat)
**Full skill:** `skills/writing-unit-tests/SKILL.md`

---

## What It Does

Teaches you to write tests that **actually catch bugs** — not tests that pad your coverage number and give false confidence.

The core principle: **test uncertainty, not certainty.** If you're confident the code works, don't test it. Test where bugs hide.

---

## When to Use It

- Writing tests for a new feature
- Reviewing tests someone else wrote (including AI-generated tests)
- After a bug ships — to write the test that would have caught it
- When you notice your test suite is big but bugs still slip through

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read skills/writing-unit-tests/SKILL.md and help 
me write tests for the rate limiting middleware in 
src/auth/middleware.py
```

**Claude Code:**
```
Use the writing-unit-tests skill to write tests for 
the payment webhook handler.
```

**AGY:** "Write unit tests for..." or "help me test..." triggers it.

---

## What the Skill Teaches You to Do

### 1. The Decision Tree (run for every proposed test)

```
Is this testing language/framework mechanics?  → Delete it
Would a user notice if this broke?              → Keep it
Does another test already cover this?           → Delete it
```

### 2. What to actually test

| Test type | Example |
|---|---|
| Behavior contracts | Rate limit blocks after 5 attempts |
| Business logic | Discount applies correctly to edge cases |
| Error handling | Invalid input returns 422 with clear message |
| Integration assumptions | External API response matches expected shape |

### 3. The mock ladder (use real things where possible)

```
1. Real thing (best)
2. Real thing in controlled env (tmpdir, in-memory DB)
3. Observable fake (records calls — can be verified)
4. Stub (canned return value — use sparingly)
```

---

## Real Example: Before and After

**❌ Before (AI-generated padding tests):**
```python
def test_rate_limiter_created():
    limiter = RateLimiter(max_attempts=5)
    assert limiter.max_attempts == 5  # Tests a constructor. Useless.

def test_redis_mock_returns_value():
    mock_redis = Mock()
    mock_redis.get.return_value = "3"
    assert mock_redis.get("key") == "3"  # Testing the mock itself. Meaningless.
```

**✅ After (using the skill):**
```python
def test_login_blocked_after_max_attempts():
    """THE feature test — proves rate limiting actually works."""
    client = TestClient(app)
    for _ in range(5):
        client.post("/auth/login", json={"email": "x@x.com", "password": "wrong"})
    
    response = client.post("/auth/login", json={"email": "x@x.com", "password": "wrong"})
    
    assert response.status_code == 429
    assert "Retry-After" in response.headers
    # This test would FAIL if you removed the rate limiting middleware

def test_rate_limit_resets_after_window():
    """Verifies the window behavior — this is uncertain, worth testing."""
    with freeze_time("2025-01-01 12:00:00"):
        exhaust_rate_limit(client, "test@test.com")
    
    with freeze_time("2025-01-01 12:16:00"):  # 16 min later, window expired
        response = client.post("/auth/login", json=valid_credentials)
    
    assert response.status_code == 200
```

---

## The Stats Padding Warning

The skill flags **stats padding** — when an AI declares a feature done because "25/25 tests pass" but none of those tests exercise the new code.

**The rule:** Before declaring any feature done, you must point to a test that:
1. Did not exist before your feature
2. Exercises the new code path
3. Would FAIL if you deleted your implementation

---

## Time Investment

- Reading the skill + writing good tests: adds ~20% to implementation time
- Saves: production bugs, false confidence, debugging sessions
