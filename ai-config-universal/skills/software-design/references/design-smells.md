# Design Smells Catalog

Organized by coupling source. Each smell has: what it looks like, why it hurts, how to spot it mechanically.

---

## Boundary Coupling

These are violations of encapsulation — modules knowing things about the outside world they shouldn't.

### Implementation Leaking Upward

A caller imports a type named after its implementation — `SqliteReader`, `RedisCache`, `S3Client`, `HttpTransport`. The name betrays that the caller knows HOW something works, not just WHAT it does.

**How to spot:** Walk the import graph. If you renamed the implementation, how many files outside its module would break? If more than zero, the abstraction is missing.

### Knowledge Flowing Sideways

Component A reaches into Component B's data structures, internal state, or file layout instead of going through B's public interface. Change B's internals and A breaks with no compiler warning.

**How to spot:** Look for imports of another module's internal types, direct field access across module boundaries, or assumptions about another component's data layout.

### Infrastructure in Domain

Domain or business logic importing database drivers, HTTP clients, filesystem APIs, or serialization libraries. The core should express WHAT decisions to make, not HOW to persist or transport them.

**How to spot:** Domain modules importing `sqlite`, `requests`, `fs`, `serde`, `json`. Error handling that catches `SqliteError` or `HttpTimeoutError` instead of domain-level errors.

### The Grow-Only File

A file over 700 lines that keeps getting longer because there's no natural place to put new code. Multiple responsibilities tangled together — nobody noticed because each addition was small.

**How to spot:** Line counts. If a file is over 700 lines, ask: can I state this module's purpose in one sentence? If the answer uses "and," there's a missing boundary.

### Missing Abstraction

Two concerns welded together in the same module. You can tell because you can't state the module's purpose in one sentence without "and." The module does X *and* Y — that "and" is the missing boundary.

**How to spot:** Module purpose requires "and." Functions that take unrelated parameter groups. Classes where method subsets use disjoint fields.

### Shotgun Surgery

One business rule change would touch 5+ files. The rule's logic is scattered instead of owned.

**How to spot:** Ask "if I changed how [X] works, how many files would I touch?" If more than one module, the responsibility is split across boundaries.

---

## Dependency Visibility

Dependencies that exist but aren't declared in the API — hidden coupling that kills testability.

### Ambient Authority

Dependencies obtained through global access — service locators, singletons, static methods, thread-local context — instead of being passed through the API.

```python
# Smell: deps not in API
class InvoiceService:
    def charge(self, invoice_id):
        db = ServiceLocator.get("db")
        gateway = PaymentGateway.instance()
        user = CurrentUser.get()
```

**Why it hurts:** Tests must patch globals. Different tests share state. Refactors are risky because nothing in the signature tells you what the unit needs.

**How to spot:** Flag `ServiceLocator.get()`, `*.instance()`, `*.getInstance()`, `Context.current()`, `CurrentUser.get()`, static mutable fields, module-level mutable globals. If a function uses a dependency it didn't receive via parameter, mark it.

### Constructor Workbench

Constructors that do real work — I/O, network calls, config parsing, object graph construction — instead of just assigning dependencies.

```python
# Smell: constructor does work
class ReportGenerator:
    def __init__(self, config_path):
        self.config = json.load(open(config_path))
        self.db = Database.connect(self.config["db_url"])
        self.templates = load_templates_from_disk()
```

**Why it hurts:** Every test that merely wants an instance must survive disk, config, and network. Instantiation is expensive and effectful.

**How to spot:** Inside constructors, flag I/O calls, network/client construction, DB connections, filesystem reads, environment reads, conditionals/loops, `new ConcreteDependency()`. Allow plain assignments: `self.repo = repo`.

---

## Signature Coupling

Coupling encoded in function signatures — missing types, excessive parameters, passthrough chains.

### Data Clump

The same group of parameters traveling together across multiple functions — a missing value type.

```python
# Smell: same params everywhere
def calculate_shipping(street, city, state, zip, country): ...
def validate_address(street, city, state, zip, country): ...
def format_label(street, city, state, zip, country): ...
```

**Why it hurts:** Every call site assembles the same bundle. New fields touch many signatures. Tests repeat the same construction.

**How to spot:** Same 3+ parameter names appearing together in 3+ functions. Same field groups repeated across DTOs.

### Parameter Conveyor Belt

Parameters passed through intermediate layers that don't use them — just forwarding to the next call.

```python
# Smell: params just passing through
def handle_request(req, user_id, tenant_id, trace_id, locale):
    return validate(req, user_id, tenant_id, trace_id, locale)

def validate(req, user_id, tenant_id, trace_id, locale):
    return price(req.items, user_id, tenant_id, trace_id, locale)
```

**Why it hurts:** Intermediate layers know about data they don't use. Adding/removing a parameter creates a call-chain edit across files.

**How to spot:** For each parameter: declared in function F, not read by F, only passed unchanged to G. Same param appears in 3+ consecutive call levels.

### Flag Argument Maze

Boolean parameters hiding multiple behaviors in one function.

```python
# Smell: booleans controlling branches
def export_report(id, include_drafts=False, redact_pii=True,
                  async_mode=False, use_cache=True, send_email=False): ...
```

**Why it hurts:** One function contains several behaviors. Tests multiply by flag combinations. Call sites become unreadable. Later changes become "just add one more flag."

**How to spot:** 2+ boolean parameters. Parameters named include/exclude/skip/force/enable/disable/dry_run. Booleans used positionally at call sites.

---

## Semantic Coupling

Coupling through shared meaning of values — magic strings, numbers, informal protocols.

### Stringly Domain

Domain rules encoded as strings, numbers, dict keys, and magic values instead of types.

```python
# Smell: domain rules as strings
if user_type == "P": ...
if discount_type == "LOYALTY_2024": ...
order.status = "SENT_TO_WAREHOUSE"
```

**Why it hurts:** Every caller must know the same hidden vocabulary. Typos become bugs. Refactors can't reliably find all usages.

**How to spot:** Same string/number literal in conditionals across files. Parameters named type/status/kind/mode as str/int. Dict/map payloads crossing module boundaries. Large sets of constants used as informal enums.

### Repeated Type Switch

The same discriminant checked with the same branches in 3+ locations.

```python
# pricing.py
if order.kind == "subscription": ...
elif order.kind == "one_time": ...

# fulfillment.py
if order.kind == "subscription": ...
elif order.kind == "one_time": ...

# analytics.py
if order.kind == "subscription": ...
elif order.kind == "one_time": ...
```

**Why it hurts:** Adding a new variant requires hunting every switch. Missing one creates subtle bugs.

**How to spot:** Same field checked in 3+ files with the same set of literal values. Especially bad when branch bodies perform domain behavior.

---

## Interface Design

### Fat Port

An interface with many methods where individual consumers use only a fraction.

```python
# Smell: 20-method interface, consumers use 3
class UserRepository:
    def find_user(self, id): ...
    def save_user(self, user): ...
    def delete_user(self, id): ...
    def list_users(self, filters): ...
    def find_permissions(self, id): ...
    def save_login_attempt(self, id): ...
    def lock_account(self, id): ...
    def export_users_csv(self): ...
```

**Why it hurts:** Clients depend on methods they don't need. Tests must provide huge fakes. Interface changes ripple into unrelated consumers.

**How to spot:** Interfaces with 8+ methods. Consumers using <30% of available methods. Test fakes with "not implemented" stubs.

---

## Temporal Coupling

### Temporal Protocol

APIs where correctness depends on call order, but the order isn't enforced by the type system.

```python
# Smell: must-call-in-order
client = SearchClient()
client.configure(config)
client.connect()
client.authenticate(token)
results = client.query("...")  # fails if you skip any step above
```

**Why it hurts:** Tests need ceremony before actual behavior. Refactors break when someone moves or skips one step.

**How to spot:** Public init/configure/connect/start methods. Methods checking initialized/connected/authenticated flags. Objects constructed invalid and made valid later. Comments saying "must call X before Y."

---

## Test Smell (signals design problems)

### Mock Parade

Tests that need 5+ mocks/fakes to exercise one unit. This is a TEST smell that points back to DESIGN — the unit under test has too many dependencies.

**How to spot:** Test setup creating many mock objects. Constructor with 7+ injected dependencies. If method groups use disjoint dependency clusters, the class contains several roles.

**What to do:** Don't fix the tests — fix the design. The class probably needs splitting.
