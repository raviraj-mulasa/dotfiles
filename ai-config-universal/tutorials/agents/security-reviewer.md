# Security Reviewer Agent — Tutorial

**Tier:** 🟡 Use Weekly (before shipping anything touching auth, input, or data)
**Type:** Agent (hands off the task completely)
**Full agent:** `agents/security-reviewer.md`

---

## What It Does

Reviews your code for **OWASP Top 10 vulnerabilities** and common security mistakes — injection, broken auth, sensitive data exposure, SSRF, hardcoded secrets, and more.

It thinks like an attacker. Its job is to find what's wrong before shipping.

---

## When to Use It

**Always use it before shipping:**
- Anything that handles user input
- Authentication or authorization changes
- File upload or download features
- External API integrations
- Anything that queries a database with user-supplied data
- Env var or config changes (secrets)

**Less important for:** Pure UI changes, internal tools with no external exposure, refactoring with no logic changes.

---

## How to Invoke

**Copilot Chat:**
```
@workspace Read agents/security-reviewer.md and review 
src/auth/ and src/api/endpoints.py for security vulnerabilities.
```

**Claude Code:**
```
Use the security-reviewer agent on the file upload 
feature I just implemented in src/uploads/
```

**AGY:** "Security review...", "check for vulnerabilities in..." triggers it.

---

## What It Checks (OWASP Top 10 + More)

| Category | What it looks for |
|---|---|
| **Injection** | SQL built by string concat, `eval()`, template injection |
| **Broken Auth** | Weak tokens, sessions not invalidated on logout |
| **Sensitive Data** | Passwords in logs, HTTP instead of HTTPS, MD5 for passwords |
| **Access Control** | Missing auth checks, IDOR (user accesses other users' data by changing ID) |
| **Misconfiguration** | Debug mode in prod, default credentials, verbose error messages |
| **Injection (input)** | Path traversal (`../../etc/passwd`), unvalidated file uploads |
| **SSRF** | User-controlled URLs fetched server-side |
| **Secrets** | Hardcoded API keys, tokens in committed config files |
| **Rate limiting** | No brute-force protection on login/OTP/password reset |

---

## Sample Output

```
## Security Review — src/auth/login.py

### Summary
Critical: 0 | High: 1 | Medium: 2 | Low: 1 | Info: 1
Verdict: CONDITIONAL — fix HIGH before shipping

---

### [HIGH] Broken Access Control — Missing rate limiting on login
Location: src/auth/login.py:L34
Description: POST /auth/login has no rate limiting. An attacker can 
try unlimited password combinations with no throttling.
Remediation: Add rate limiting (5 attempts per IP per 15 min).
See src/auth/middleware.py for existing middleware pattern.

### [MEDIUM] Cryptographic Failure — Password reset token entropy
Location: src/auth/reset.py:L67
Description: reset_token = str(user.id) + str(int(time.time()))
This is predictable — attacker can guess tokens for any user if they
know the user ID and approximate time of request.
Remediation: Use secrets.token_urlsafe(32) instead.

### [MEDIUM] Sensitive Data — Email in URL query param  
Location: src/auth/reset.py:L89
Description: Redirect to /reset?email=user@example.com — email address
appears in server logs, browser history, and referrer headers.
Remediation: Pass email in the session or POST body, not the URL.

### [LOW] Security Logging — Failed login attempts not logged
Location: src/auth/login.py:L45
Description: Failed login attempts silently return 401 with no logging.
Remediation: Log failed attempts with IP and timestamp for alerting.

### Not Checked (Manual Steps Needed)
- [ ] Run `pip-audit` for dependency CVEs
- [ ] Verify SESSION_SECRET is not in .env committed to git:
      git log --all -S "SESSION_SECRET"
```

---

## Acting on the Report

| Severity | Action |
|---|---|
| **CRITICAL** | Fix immediately, do not ship |
| **HIGH** | Fix before shipping |
| **MEDIUM** | Fix soon — schedule in next sprint |
| **LOW** | Track as tech debt |
| **INFO** | Your judgment |

---

## Time Investment

- Review runs: 3-5 minutes
- Fixes: depends on findings
- Saves: security incidents, data breaches, reputation damage
