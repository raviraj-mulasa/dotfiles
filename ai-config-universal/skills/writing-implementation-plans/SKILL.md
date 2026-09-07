---
name: writing-implementation-plans
description: MANDATORY before implementing multi-file features, creating task files, or invoking agents for implementation. Creates backbone-only plans that serve BOTH human review AND agent execution. The plan you create IS your execution guide - create once, use for both.
---

# Writing Implementation Plans

**⚠️ CRITICAL: Read this skill BEFORE:**
- Creating any task files (`./tasks/...`)
- Invoking agents for implementation work
- Beginning multi-file implementation

**This skill teaches you to create plans that serve TWO purposes:**
1. **Human review** — What you're building, why these decisions
2. **Your execution guide** — Your map during implementation

## When to Use This Skill

**MANDATORY for:**
- Features requiring 2+ new files
- Changes modifying 3+ existing files
- New models, pipelines, or API endpoints
- Architectural changes or refactoring
- BEFORE creating task files for agents
- BEFORE invoking agents for implementation work

**NOT needed for:**
- Single-file changes
- Debugging tasks
- Investigation/exploration work

## Document Hierarchy

This is the **EXECUTION** document — it defines HOW to build.

**Workflow position:**
- `*.spec.md` (requirements) → `*.design.md` (architecture) → `*.plan.md` (execution)

Scale to complexity:
- **Simple features:** Just `*.plan.md` (most common)
- **Medium features:** `*.design.md` → `*.plan.md`
- **Complex features:** `*.spec.md` → `*.design.md` → `*.plan.md`

## Core Principle: Backbone vs Leaves

The plan defines **what** and **why**. You decide **how** during implementation.

### BACKBONE (Specify in Plan)

- **Data model schemas** — Fields, types, validation rules, relationships
- **Public API contracts** — Method signatures, return types, exceptions raised
- **Orchestration flow** — Which component calls which (A → B → C)
- **Integration points** — Where this connects to existing code
- **Error handling strategy** — Fail fast vs graceful degradation
- **Testing strategy** — Unit vs integration, what to mock, test approach
- **Key decisions** — WHY you chose approach X over Y

**Example (GOOD — backbone only):**
```python
class PipelineConfig(BaseModel):
    """Configuration for processing pipeline."""
    repository: Repository
    persist: bool = False

def run(req: Request) -> Result:
    """Execute pipeline."""
    # 1. Fetch data from repository via metadata hash
    # 2. Analyze with LLM
    # 3. Persist if enabled
    # Pre-decision: Fail fast on missing metadata (no graceful fallback)
```

### LEAVES (Let Yourself Decide During Implementation)

- Variable names and local variables
- Loop implementations (`for`, `while`, `if/else` logic)
- Specific error messages and log statements
- Helper method internals
- Code formatting and style choices

---

## The Box: Defining Boundaries

Every plan MUST define these boundaries:

### IN SCOPE
Explicit list of what you WILL implement.

### OUT OF SCOPE
Explicit list of what you WILL NOT do.

### MUST NOT CHANGE
Existing code that's off-limits.

### MUST FOLLOW
Patterns/conventions that are mandatory.

### BOUNDARY SANITY CHECK
Before finalizing the plan, ask:

- **Am I solving a symptom or the root cause?** If you're adding a lookup/workaround to connect things, is that because an abstraction is missing upstream?
- **Would this plan make the code cleaner or messier?** If messier, consider whether refactoring is the real solution.
- **Does the plan cut around concepts or through them?** Data that belongs together should stay together. Components should have single responsibilities.

If the answer is "messier" or "through" — pause. Ask: *"I'm planning to add X here, but I notice it's working around existing structure. Should we refactor Y instead?"*

---

## PRE-DECISIONS

Resolve ambiguities NOW, not during implementation.

**Template for each decision:**
```
Decision: [What needs deciding]
Options: [A, B, C]
Choice: [X]
Rationale: [Why X over others]
```

**Common decisions to make:**
- **Error handling:** Fail fast vs graceful degradation?
- **Null handling:** Raise exception vs return empty?
- **Data persistence:** Transactional vs eventual?
- **Merge strategy:** Append vs replace vs merge?
- **Backwards compatibility:** Break old clients or support both?

---

## Plan Structure (Required Sections)

### 1. Purpose
2-3 sentences. What problem does this solve?

### 2. File Tree
List the ~3-7 key new or modified files.

```
src/package/module/
  models.py
  pipeline.py
test/package/module/
  test_pipeline.py
```

### 3. Data Models
Schemas only. Fields, types, validation. No method implementations.

### 4. Orchestration
Method signatures + 3-10 line pseudocode. Show flow, not implementation.

### 5. Boundaries
IN SCOPE, OUT OF SCOPE, MUST NOT CHANGE, MUST FOLLOW

### 6. Pre-Decisions
Resolved ambiguities with rationale.

### 7. Testing Strategy

**⚠️ CRITICAL: Feature Verification Tests Are MANDATORY**

Every feature MUST have at least one test that proves the happy path works. This is not optional.

Include:
1. **Feature verification test (REQUIRED)** — The test that proves the core feature works. It did not exist before your feature. It would FAIL if you removed your implementation.
2. **Unit vs integration** — Test type for each major component
3. **What will be mocked vs real**

**GOOD:**
```
Testing Strategy:
- FEATURE TEST: test_synonyms_in_prompt() — create schema with synonyms,
  build prompt, assert "Also known as" appears. THIS PROVES THE FEATURE WORKS.
- Unit tests for Persister (mock Repository)
- Integration test for endpoint (verify 200 OK + side effects)
```

**BAD (stats padding):**
```
Testing Strategy:
- Unit tests for models
- Run existing test suite
- Check for regressions
```
"Run existing test suite" does NOT verify new code works.

### 8. Verification Checkpoints

| After Step | Verify By | Fail Action |
|------------|-----------|-------------|
| Data models created | Unit test instantiation | Fix before proceeding |
| Repository implemented | Integration test with real DB | Don't build dependent code |
| Endpoint wired | curl returns expected shape | Debug routing before logic |
| Full flow complete | End-to-end test passes | Root cause before shipping |

Don't build floor 3 until floor 2 is solid.

### 9. Migration Notes (When Changing Existing Systems)

If modifying existing code/data, plan the transition:

```
Data migration:
- [ ] Existing records need field X backfilled
- [ ] Rollback: field is nullable, old code ignores it

Rollback plan:
- Feature flag: NEW_FEATURE_ENABLED
- If issues: set flag false, old behavior restored
```

Key question: If we deploy and it's broken, how do we get back to working state?

### 10. Acceptance Criteria
Testable statements. How do we know it works?

```
- [ ] POST /api/feature returns 200 with expected shape
- [ ] Field updated after persist=true
- [ ] ValueError raised if required field missing
- [ ] Existing tests still pass (no regressions)
```

### 11. Task Breakdown (For Agent Execution)

Break the plan into independent executable tasks. Each task should be:
- **2-5 minutes of work** — small enough to verify quickly
- **Independent where possible** — can run in parallel
- **Self-contained** — has everything needed to execute

**Task template:**
```markdown
### Task 1: [Short descriptive name]
- **What:** [1-2 sentences]
- **Files:** [Exact paths to create/modify]
- **Depends on:** [Task numbers, or "none"]
- **Tier:** [fast-worker / engineer / you]
- **Verify:** [How to know it's done]
```

**How to break down:**
1. Start with the orchestration flow — each numbered step often becomes a task
2. Data models first — usually independent, can parallelize
3. Group by file — don't have multiple tasks editing the same file
4. Mark dependencies explicitly
5. Tests are tasks too — don't forget feature verification tests

**Tier assignment:**
- **fast-worker** — Bounded, mechanical work: create model from schema, write test from spec, apply pattern
- **engineer** — Requires judgment: complex logic, integration, non-obvious decisions
- **you** — Architectural decisions, orchestration, things requiring full context

---

## Output Location

**ALWAYS save plan to:** `./tasks/YYYY-MM-DD-<title>.plan.md`

---

## Mandatory Assumption Check (Before Presenting Plan)

**STOP. Answer these out loud before saving:**

1. **What am I assuming?**
   - About the user's requirements?
   - About existing code I haven't fully read?
   - About why the current system is structured this way?

2. **What did I decide unilaterally?**
   - List decisions you made without asking
   - For each: should the user have been consulted?

3. **What inconsistencies or questions emerged?**

**If you have questions → ASK THEM NOW, before presenting the plan.**

---

## Self-Check Before Saving

- [ ] Data models and API contracts fully specified (all fields, types, method signatures)?
- [ ] Plan shows orchestration flow (A calls B calls C)?
- [ ] Boundaries defined (in/out/must-not/must-follow)?
- [ ] Boundary sanity check run (symptom vs root cause)?
- [ ] Pre-decisions made with rationale?
- [ ] Testing strategy includes feature verification test?
- [ ] Verification checkpoints defined?
- [ ] If changing existing system: migration and rollback planned?
- [ ] Testable acceptance criteria present?
- [ ] Task breakdown included with dependencies and tier assignments?
- [ ] Plan free of leaf implementations (no loops, variables, try/except)?

If ANY is NO → Fix before saving.
