---
name: writing-unit-tests
description: Write valuable unit tests that catch real bugs. Test uncertainty, not certainty. Delete tests that don't provide unique value.
---

# Unit Testing: Essential Guide

## Core Principle

**Test uncertainty, not certainty.**

If you're confident code works, don't test it. Test where bugs hide.

---

## Every Mock Is a Bet

Every test double encodes an assumption about the real thing it replaces.

If the real thing behaves differently, your test gives false confidence. The cheaper the double, the wider the assumption gap. A silent stub that erases a side effect doesn't just simplify — it hides whether the behavior happened at all.

**Every mock is a bet against reality. Keep the bet small.**

---

## The 5 Laws

1. **Test behavior, not implementation**
   - Test what users observe (outputs, side effects, errors)
   - Don't test how code achieves it (internal methods, private state)

2. **Test YOUR code, not frameworks**
   - Don't test: language builtins, library behavior, framework mechanics
   - Do test: Your business logic, algorithms, integrations

3. **Mock at boundaries only**
   - Mock: External APIs, databases, expensive/non-deterministic operations
   - Don't mock: Your own code, fast pure functions, config objects
   - When you must use a double, prefer fakes with observable side effects over silent stubs.

4. **One test, one thing**
   - Each test validates one behavior
   - If test is complex, code is probably bad

5. **Delete bad tests**
   - Bad tests are worse than no tests (maintenance burden, false confidence)
   - If test doesn't catch bugs or enable refactoring, delete it

---

## Decision Tree

```
Should I write this test?

Is it testing language/framework mechanics?
├─ YES → ❌ Delete it
└─ NO → Continue

Would a user notice if this broke?
├─ NO → ❌ Don't write it
└─ YES → Continue

Does another test already cover this?
├─ YES → ❌ Don't write it
└─ NO → ✅ Write it
```

```
Before adding a test double:

Am I replacing an external system (network, disk, clock)?
├─ NO → Don't mock. Use the real thing.
└─ YES → Continue

Can I use the real thing in a controlled environment (tmpdir, in-memory DB)?
├─ YES → Use that. No double needed.
└─ NO → Continue

Can I make the side effect observable (counter, log, channel)?
├─ YES → Build an observable fake.
└─ NO → Use a stub, but document the assumption you're encoding.
```

---

## ⚠️ Stats Padding: The Real Failure Mode

An agent declared a feature done because "25/25 tests pass ✓".

None of those tests verified the feature worked. They were existing tests — API structure, model validation, extraction logic. They proved "nothing broke." They did NOT prove "the new feature works."

**This is stats padding.** Running existing tests, seeing green, reporting success. It feels like verification. It's not.

### The Two Types of Tests After Implementation

| Type | Purpose | Example |
|------|---------|---------| 
| **Regression tests** | Prove you didn't break existing code | Run existing test suite |
| **Feature verification tests** | Prove new code works | New test that exercises new code path |

**You need BOTH. But only feature verification lets you declare the feature done.**

### How to Spot Stats Padding

❌ **Stats padding:**
- "Ran existing tests, 24/24 pass"
- "No regressions detected"
- "All API tests green"

✅ **Real verification:**
- "New test_synonyms_in_prompt() passes - proves feature works"
- "Feature test exercises the new code path and asserts expected output"

### The Rule

**Before declaring ANY feature complete, you MUST:**

1. Identify the test that proves the happy path works
2. Verify that test exercises YOUR NEW CODE (not existing code)
3. Verify that test would FAIL if you removed your implementation

If you can't point to such a test, you haven't verified the feature.

---

## Anti-Patterns (Delete Immediately)

```
// ❌ Testing framework mechanics
test "list get returns null":
    assert [].get("key") == null

// ❌ Testing construction
test "creates object":
    obj = MyClass(x: 1)
    assert obj.x == 1

// ❌ Testing getters
test "property roundtrip":
    obj.value = 10
    assert obj.value == 10

// ❌ Mocking your own code
test "process":
    obj._internal = Stub()   // DON'T mock internals
    obj.process()

// ❌ Testing the mock (circular)
test "api call":
    stub.get.returns("x")
    assert func(stub) == "x"  // Only proves stub works

// ❌ STATS PADDING — existing test results don't verify new features
// "25/25 existing tests pass" does NOT prove new code works

// ❌ The Invisible Side Effect
agent = FakeAgent.idle()          // stop() is a no-op on idle agents
handler.cleanup(agents)
assert agents.is_empty()          // proves drain happened, NOT that stop was called
// Delete every stop() call from cleanup — this test still passes.
```

**The rule for silent fakes:** If deleting the code under test doesn't break the test, the test is worthless.

```
// ✅ Observable fake — proves behavior
runtime = FakeRuntime.new()       // tracks stop calls with a counter
handler.cleanup(handles, runtime)
assert runtime.stop_count == 3    // proves stop was called 3 times
assert handles.is_empty()         // AND proves drain happened
```

---

## What to Test

### 1. Behavior Contracts
Config/flags control behavior as specified.

```
// When enabled=false, processing skipped
test "disabled flag skips processing":
    config = Config(enabled: false)
    result = pipeline.run(data, config)
    assert result.processed == false
```

### 2. Integration Assumptions
Your assumptions about external systems.

```
// Assumes external service returns parseable structure
test "service returns valid response":
    extractor = TextExtractor(config)
    features = extractor.extract(text)
    assert features is a map
```

### 3. Business Logic
Algorithms produce correct results.

```
// High weight on matching field → higher score
test "weighted score favors matching fields":
    score = scorer.calculate(
        features: {a: "match", b: "diff"},
        template: {a: "match", b: "other"},
        weights: {a: 0.9, b: 0.1}
    )
    assert 0.85 < score < 0.95
```

### 4. Error Handling
System handles failures correctly.

```
// Invalid input rejected with clear error
test "negative amount raises error":
    expect_error matching "cannot be negative":
        process(amount: -100)
```

### 5. Thread Safety
Concurrent access doesn't corrupt state.

```
// Singleton cache safe under concurrent access
test "cache returns same instance across threads":
    results = []
    run 100 goroutines/threads: results.append(get_cache())
    wait all
    assert all results are the same instance
```

---

## Mocking Rules

### When to Mock

```
Is it expensive (network API, database)?        → Mock
Is it non-deterministic (system clock, random)? → Mock
Is it YOUR code?                                → DON'T mock
Is it fast and deterministic?                   → DON'T mock
```

### Test Double Ladder

Use the highest-confidence option available. Each step down widens the assumption gap.

```
Preference (highest confidence → lowest):

1. Real thing                    — no assumption gap
2. Controlled real thing         — real DB in container, real file in tmpdir
3. Fake with observable effects  — counter tracks calls, channel captures messages
4. Fake with real logic          — in-memory store with real read/write behavior
5. Stub (canned returns)         — always returns success, no tracking
6. Mock (configured expectations)— return X when called with Y
```

### Mocking Anti-Patterns

```
// ❌ Mocking internal methods
obj._internal = Stub()

// ❌ Over-mocking (tests nothing real)
a = Stub(); b = Stub(); c = Stub()
call(a, b, c)

// ❌ Unrealistic stub
stub_api.get.returns("string")    // real API returns a map — this hides the mismatch

// ❌ Testing the stub (circular)
stub.returns(X)
assert func() == X

// ❌ Over-specified verification
stub.log.assert_called_exactly(3)  // fragile — breaks on unrelated changes
```

---

## Test Organization

```
// Naming: test_<behavior>_<condition>_<expected>
test "score_perfect_match_returns_one":
    // When all fields match, score is 1.0
    ...

// Group by behavior, not by class
group "Error Handling":
    test "missing data raises error": ...
    test "invalid type raises error": ...

group "Config Propagation":
    test "disabled flag skips feature": ...
    test "custom threshold is used": ...
```

---

## Design Feedback

**If tests are hard to write, fix the code first.**

| Test Difficulty | Code Problem | Fix |
|----------------|--------------|-----|
| Needs many mocks | Too many dependencies | Reduce coupling, add interfaces |
| Complex setup | Constructor too complex | Dependency injection, builder |
| Can't isolate | Tight coupling | Extract abstraction |
| Testing internals | Poor encapsulation | Only test public API |
| Side effects invisible in test | No observation point | Add counters, channels, or recording fakes |

```
// ✅ Easy to test — dependency injected
service = Service(api: injected_api)

// ❌ Hard to test — global dependencies
service.fetch():
    api = global_registry.get_api()   // can't substitute
    config = read_env("CONFIG")       // non-deterministic
```

---

## Coverage

**Coverage ≠ Quality**

Don't test just for coverage. Delete:
- Trivial getters/setters
- Framework boilerplate
- Logging calls
- Object construction

Target coverage by code type:
- Business logic: 80-95%
- Integration points: 60-80%
- Pure utilities: 90-100%
- Framework wiring: 30-50%

---

## Quick Reference

### Test Review Checklist
```
□ Tests user-facing behavior (not implementation)?
□ Would users notice if this broke?
□ Tests OUR code (not framework)?
□ Clear name describing behavior?
□ Tests one thing?
□ Not duplicating other tests?
□ Mocks only at boundaries?
□ Side effects observable (not hidden by silent fakes)?
□ Test would fail if implementation code were deleted?
```

### Should I Mock?
| Dependency | Mock? | Why |
|------------|-------|-----|
| External API | ✅ | Expensive, external |
| Database | ✅ | Expensive, setup required |
| Your class | ❌ | Test your own code |
| Pure function | ❌ | Fast, deterministic |
| System clock, random | ✅ | Non-deterministic |
| Config object | ❌ | Just create it |
| Side-effectful operation (stop, send, emit) | Observable fake | Silent stubs hide whether it happened |

### Red Flags
- Mocking 5+ things → Function does too much
- stub.returns(X), assert == X → Testing nothing
- Patching internal methods → Testing implementation
- Complex mock setup → Bad design, refactor first
- Fake makes side effect a no-op → Test can't prove behavior
- Deleting implementation doesn't break test → Test proves nothing

---

## Summary

**DO:**
- Test where behavior is uncertain
- Test what users observe
- Mock external/expensive deps only
- Write clear test names
- Delete bad tests
- Make side effects observable in test doubles

**DON'T:**
- Test framework mechanics
- Test implementation details
- Mock your own code
- Test for coverage only
- Use fakes that make side effects invisible

**Remember:** Small suite of valuable tests > large suite of worthless tests.
