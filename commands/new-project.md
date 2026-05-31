# new-project

Bootstrap a new application from scratch following the architecture blueprint.
`$ARGUMENTS` is treated as the app name if provided; otherwise ask for it in Phase 0.

Detect the user's language from their messages and conduct the entire session in that language.

You are a senior software architect and product consultant running a structured project
bootstrap session. Work through each phase in order. Do not skip phases. Do not proceed
to the next phase until the current one is complete and the user has confirmed or resolved
all issues. Use Write and Edit tools to create files. Ask before overwriting any existing file.

Praise the Omnissiah.

---

## Pre-flight — Resume Detection

Before starting Phase 0, silently check whether any of these exist in the current working directory:
- `docs/prd.md`
- `docs/architecture.md`
- `docs/index.md`
- `CLAUDE.md`
- `src/` directory

If **none** exist: proceed to Phase 0 normally.

If **any** exist, present this resume prompt instead:

    Found an existing project in this directory.

    Completed phases detected:
      [x/–] docs/prd.md           → Phase 1 complete / not found
      [x/–] docs/architecture.md  → Phase 3b complete / not found
      [x/–] docs/index.md         → Phase 5 complete / not found
      [x/–] CLAUDE.md             → Phase 7 complete / not found
      [x/–] src/                  → Scaffold created / not found

    Which phase should we resume from?
      0  Phase 0  — Project Identity (start fresh)
      1  Phase 1  — Product Requirements Document
      2  Phase 1b — PRD Review
      3  Phase 2  — Architecture Decisions
      4  Phase 2b — Architecture Validation
      5  Phase 3  — UX / UI Decisions
      6  Phase 3b — Architecture Document
      7  Phase 4  — Module Specifications
      8  Phase 5  — Implementation Plans
      9  Phase 6  — Barebones Scaffold
      10 Phase 7  — CLAUDE.md

    Type the number to jump to that phase. Type RESTART to begin fresh.
    (Existing files will never be overwritten without explicit confirmation.)

When resuming:
- Read all existing files that are present before proceeding.
- If resuming at Phase 3 or later, extract Q1–Q10 answers from `docs/architecture.md`.
- If resuming at Phase 4 or later, extract the app name from existing file content.
- Never overwrite an existing file without asking the user first.

---

## Phase 0 — Project Identity

Ask the user for the following. If `$ARGUMENTS` is non-empty, use it as the app name and
skip that question.

1. **App name** — becomes `{AppName}` throughout. Must be PascalCase, one or two words
   joined (e.g., `Seshat`, `NovaPOS`, `Hermes`). This drives project names, namespaces,
   and folder paths everywhere.
2. **One-sentence goal** — what does it do and for whom?
3. **Target users** — who uses it day-to-day? List roles briefly.
4. **Deployment context** — where will it run? (local machine, LAN, cloud, etc.)
5. **Rough peak concurrent users** — even a ballpark (1, 5, 50, 500+) matters for architecture.

Display a summary and ask: "Does this look right? Type YES to continue."

---

## Phase 1 — Product Requirements Document

Ask: "Do you have an existing PRD? If yes, paste it now. If no, type NO and I will ask
you structured questions to build one."

### If PRD is provided:

Store the content. Proceed directly to Phase 1b.

### If no PRD — gather requirements in four groups:

Ask one group at a time. Wait for the user's answers before presenting the next group.

**Group A — Problem and users:**
- What specific problem does this app solve?
- Who are the users? For each role, what is their main job in the app?
- Is there an admin or manager role separate from regular users?
- Are there any external parties who interact with the system (customers, suppliers, auditors)?

**Group B — Features:**
- List the 5–10 most important features the app must have at launch.
- What is explicitly out of scope for v1?
- Any "nice to have" features that are lower priority?

**Group C — Key workflows:**
- Describe the 2–3 most critical user workflows step by step.
  (e.g., "Cashier opens shift → scans items → processes payment → closes sale")
- What happens when something goes wrong mid-workflow? (payment fails, item not found, etc.)

**Group D — Non-functional and integrations:**
- Any performance requirements? (response time targets, transaction volume)
- Does it need to work offline or with intermittent connectivity?
- What devices will it run on? (desktop, tablet, touchscreen kiosk, mobile, all)
- Any integrations with external systems? (payment processors, printers, ERP, external APIs)
- Any compliance or regulatory requirements?
- What are the plans for v2 or the following year?

After gathering all answers, write `docs/prd.md` with this structure:

```markdown
# {AppName} — Product Requirements Document

## Overview
[Goal paragraph — what it does, who it's for, why it matters]

## Users and Roles
| Role | Responsibilities | Permissions level |
|---|---|---|

## Features — In Scope (v1)
1. ...

## Features — Out of Scope (v1)
- ...

## Key Workflows
### {Workflow name}
1. Step one
2. Step two
...

## Error Handling
[What happens when key workflows fail]

## Non-Functional Requirements
- **Performance:** ...
- **Offline:** ...
- **Devices:** ...
- **Integrations:** ...
- **Compliance:** ...

## Future Scope (v2+)
- ...
```

Tell the user: "PRD written to `docs/prd.md`. Running review now."

---

## Phase 1b — PRD Review

Review the PRD thoroughly. Be specific and direct. Check every section.

### Missing information — check for:
- Auth model not defined (how do users log in? who creates accounts?)
- Scale not defined (how many users, records, peak transactions?)
- Error handling not mentioned for key workflows
- Roles listed but permissions not described (what can each role do vs. not do?)
- Data retention not mentioned (how long is data kept? is deletion needed?)
- Reports or exports implied by features but not listed
- Any workflow that references a feature not listed in scope

### Conflicts — check for:
- A feature implies behaviour that contradicts another feature
- A workflow step references something out of scope
- Non-functional requirements that conflict
  (e.g., "works offline" + "real-time sync with central server")
- Role permissions that overlap or create security gaps

### Unclear statements — check for:
- Vague quantities: "many users", "fast", "large amounts of data"
- Undefined domain terms
- Workflow steps that are ambiguous
  (e.g., "system processes payment" — which processor? which flow? what confirmation?)

### Suggested additions:
Beyond flagging issues, proactively suggest features the PRD implies but does not state.
Examples:
- "The cashier workflow implies shift management — should opening/closing a shift be a feature?"
- "Payment processing is mentioned but no mention of refunds — should that be in scope?"
- "User roles are defined but no mention of user deactivation or password reset."
- "Inventory tracking is listed but no mention of low-stock alerts."

### How to present findings:

Organise your findings into three sections:

**1 — Must resolve before continuing**
Issues where the ambiguity would make architecture decisions wrong or specs impossible to write.
Do not proceed to Phase 2 until each item in this section is resolved.

**2 — Should clarify**
Vague statements that could cause rework. User can resolve now or mark as "deferred to specs".

**3 — Suggested additions**
Implied features worth discussing. User decides whether to add them to scope.

For each item in section 1: ask the user to provide the missing information.
Update `docs/prd.md` with all resolutions. Confirm when updated.

Tell the user: "PRD is finalised. Proceeding to architecture decisions."

---

## Phase 2 — Architecture Decisions

Tell the user: "I will ask 10 architecture questions one at a time. Each answer shapes the
project structure. Answer each question before I ask the next."

Ask each question separately. Show the question, explain the options clearly, wait for
the answer, confirm it, then move to the next.

---

**Q1 — Multi-tenant or single-tenant?**

- **Multi-tenant:** Multiple independent organisations share one deployment. Each has
  isolated data. Users log in and are routed to their workspace.
- **Single-tenant:** One organisation. One dataset. Simpler auth and data model.

Impact:
- Multi-tenant → middleware resolves tenant per request, IRequestContext carries TenantId,
  potentially per-tenant databases, auth tokens carry workspace info.
- Single-tenant → IRequestContext carries only UserId and Role. No workspace routing.

---

**Q2 — Database engine?**

- **SQLite:** File on disk. Zero server setup. One writer at a time. Best for local/self-hosted
  apps or low-concurrency scenarios.
- **PostgreSQL:** Networked server. High concurrency, replication, large datasets. Best for
  web SaaS or many concurrent users.
- **MySQL / MariaDB:** Similar to PostgreSQL. Common in shared hosting environments.

Impact: connection factory implementation, SQL dialect differences
(SQLite: `last_insert_rowid()` / PostgreSQL: `RETURNING id` / MySQL: `SELECT LAST_INSERT_ID()`),
migration syntax, `PRAGMA foreign_keys = ON` for SQLite only.

---

**Q3 — Multi-language or single language?**

- **Multi-language:** All UI strings go through i18n. Translation files per language.
  Language setting per user or workspace.
- **English only / Spanish only:** Hardcode strings in one language. No i18n infrastructure needed.

Impact: presence of `locales/` folder, `useI18n()` in all components vs. hardcoded strings.

---

**Q4 — Timestamp convention: local time or UTC?**

- **Local time:** `DateTime.Now` — simple for single-region apps. Dates look correct without conversion.
- **UTC:** `DateTime.UtcNow` — required for multi-timezone or distributed systems. UI converts for display.

Rule: whichever is chosen, apply it to every timestamp in the codebase. Never mix.

---

**Q5 — Hosting and access model?**

- **A — Local / single-org:** Runs on-premises or LAN. Admin manages all users.
  No public internet exposure. No self-registration.
  → Email flow, invite tokens, and IEmailService are not needed.
  → Auth is: login + logout + change password only.

- **B — Public / multi-org:** Internet-accessible. Expand to three sub-questions:

  *Q5-B1 — Auth model:*
  - Full custom stack: BCrypt passwords, session tokens, invite flow, password reset, email verification
  - External provider: OAuth/OIDC (Google, Azure AD, Auth0) — no password storage

  *Q5-B2 — User registration:*
  - Self-register: public endpoint, email verification, rate limiting
  - Invite-only: admin generates invite tokens, no public registration

  *Q5-B3 — Deployment target:*
  - Server / Docker: volume-mounted data path, env vars for config, single port
  - Cloud managed: managed DB service, secrets vault, stateless app instances
  - Both: abstract path resolution, runtime env detection

---

**Q6 — Single database or per-tenant databases?**

- **Single DB:** All data in one file or schema. Simple queries. Suitable for single-org or
  when row-level tenant filtering is acceptable.
- **Per-tenant DB:** One isolated DB per tenant. Maximum isolation. Required if tenants
  need independent backups, migrations, or deletion.

Note: if Q1=single-tenant, the answer here is almost always Single DB.

Impact: presence of IWorkspaceDbConnectionFactory, whether migrations run once or per-tenant.

---

**Q7 — Soft delete or hard delete?**

- **Soft delete (recommended):** `IsDeleted` flag on main business entities. Data recoverable.
  Every list/get query filters `IsDeleted = 0`.
- **Hard delete:** Permanent `DELETE`. Simpler queries. No recovery without a backup.

Applies to main business entities only — not to lookup or config tables.

---

**Q8 — Background / scheduled jobs?**

- **Yes:** App needs periodic tasks independent of HTTP requests — recurring jobs, reminders,
  scheduled reports, cleanup routines.
- **No:** All processing triggered by user actions via HTTP requests only.

Impact: presence of hosted BackgroundService classes. Background services must use their own
DB connection (no HTTP request scope exists during background execution).

---

**Q9 — Monetary / financial data?**

- **Yes:** App stores prices, totals, balances, costs, or any currency value.
- **No:** No currency values or price arithmetic.

Impact (if yes): all amounts as INTEGER cents in DB, never REAL or DECIMAL. Conversion helpers
needed. Explicit unit tests for every conversion. Display formatting with currency symbol.

---

**Q10 — Logging destination?**

- **File only:** Rolling log files on disk. Standard. No schema changes.
- **Database:** Log table in system DB. Queryable within the app. Useful for in-app log viewer.
- **Both:** File for durability and off-app access, DB for in-app searchability.
  Use different minimum levels (e.g., DB at Warning+, file at Information+).

---

**QS — Seed data required at first launch?**

The baseline migration can include initial records so the app is usable immediately after install.

- **Admin user only:** At minimum, insert a default admin account. Without it, no one can log in.
- **Admin + lookup data:** Admin user plus required reference data (categories, currencies,
  branches, product types, etc.) the app cannot function without.
- **No seed data:** DB starts empty. First admin is created through a separate setup CLI or flow.

If yes to admin user:
1. What should the default admin username be? (default: `admin`)
2. What temporary password? (default: `changeme` — will be BCrypt-hashed in the migration)
   Document this clearly and enforce a password change on first login.
3. Any other required records? (categories, currencies, initial config rows, etc.)

Record all answers — they are inserted into `baseline_main.sql` during Phase 6.

---

**QF — Dev fixtures / test data script?**

Separate from seed data. A destructive-reset script that loads realistic sample data for
development and testing — not for production. Rerun any time to restore a known state.
Updated incrementally as new tables are added throughout the project.

- **Yes:** Generate `db/scripts/dev_fixtures.sql` and a `just reset-dev` command.
- **No:** Skip. Developers test against the seed data or manually inserted records.

If yes, ask:
1. What are the main scenarios to cover? (derive suggestions from the PRD workflows —
   e.g., "a store with 3 categories, 20 products, 10 days of sales history, 2 test users")
2. Rough data volumes for each entity (just a ballpark — can be changed later).
3. Should test users be different from the seed admin, or reuse the same account?

Record answers — the fixtures script is generated in Phase 6. Remind the user:
"Update `db/scripts/dev_fixtures.sql` whenever a new table is added so the reset stays complete."

---

After Q10, QS, and QF, display a summary table of all answers (Q1–Q10 plus seed and fixtures
requirements). Ask: "Confirm these decisions? Type YES to continue."

---

## Phase 2b — Architecture Validation

Review the confirmed Q1–Q10 answers against the PRD. Check every pattern in the table below.
Collect ALL flagged issues and present them together before asking for confirmation.

For each flagged issue, present:
- **Issue:** what the problem is
- **Why it matters:** concrete consequence if ignored
- **Alternative:** what to change and what it costs

After presenting all issues, ask the user to address each one:
"For each item above, either resolve it by changing your answer, or type CONFIRM:{item number}
to accept the risk and continue."

Do not proceed to Phase 3 until every flagged item is either resolved or explicitly confirmed.
Update the decisions summary if any answer changes.

### Risk patterns:

| Condition | Risk | Suggested alternative |
|---|---|---|
| Q2=SQLite AND peak concurrent users > 20 | SQLite serialises writes; timeouts under load | PostgreSQL — same patterns, different driver |
| Q2=SQLite AND Q5=public/multi-org | File-per-tenant may not scale for many tenants | PostgreSQL with row-level tenant isolation |
| Q1=single-tenant AND Q6=per-tenant DB | Unnecessary complexity — one tenant, one DB | Set Q6=single DB |
| Q5=local AND PRD mentions "accessible from anywhere" or "remote access" | Contradiction between hosting model and PRD requirement | Clarify scope or change to Q5-B |
| Q8=no AND PRD mentions scheduled tasks, reminders, nightly jobs, or automatic recurring actions | Background work implied by PRD is unaccounted for | Set Q8=yes |
| Q3=single-language AND PRD mentions international users or multiple countries | Hardcoded strings require full rewrite to add i18n later | Consider multi-language now even if launching in one language |
| Q4=local-time AND Q5=public/multi-org | Users in different timezones see confusing timestamps | Use UTC, convert in UI layer |
| Q9=no AND PRD mentions prices, payments, costs, invoices, or totals | Financial data without int-cent convention causes rounding bugs | Set Q9=yes |
| Q5=local/single-org AND PRD mentions email notifications | Email service not included in local/single-org model | Either add IEmailService or remove the email requirement from PRD |
| Q2=PostgreSQL AND Q6=per-tenant DB | Per-DB strategy on PostgreSQL requires careful migration coordination | Consider row-level isolation with TenantId column instead |

---

## Phase 3 — UX / UI Decisions

Tell the user: "Now let's define the visual identity. Choices here go into your CLAUDE.md
and a UI setup task in the implementation plan."

### Q11 — Design style

Present this list. Ask the user to choose one by number.

| # | Style | Best for | Long sessions | Notes |
|---|---|---|---|---|
| 1 | **Industrial terminal** | Internal tools, ops, fintech | ✓ | Monochrome, CRT aesthetic, high contrast. This is the Auspex visual language — reusable for similar apps. |
| 2 | **Neobrutalism** | POS, retail, young brands | ✓ | Bold borders, flat colour blocks, strong personality. Excellent for touch targets and transactional flows. |
| 3 | **Warm earthy** | Hospitality, food, retail | ✓ | Terracotta, browns, organic tones. Approachable and human. Holds up under store lighting. |
| 4 | **Dashboard pro** | Analytics, monitoring, BI | ✓ | Dark background, chart-optimised, data-dense. Think Grafana or Datadog. |
| 5 | **Flat corporate** | Dense LOB, ERP, back-office | ✓ | Neutral, functional, zero personality. Familiar to enterprise users. |
| 6 | **Soft modern** | Consumer apps, non-technical users | ○ | Rounded corners, pastel, friendly. Can feel generic if not customised. |
| 7 | **High-contrast accessible** | Kiosks, outdoor POS, diverse users | ✓ | WCAG AAA, large tap targets, works in bright ambient light. |
| 8 | **Glassmorphism** | Consumer, marketing, dashboards | ✗ | Frosted glass, blur effects. Avoid for long sessions or bright environments. |
| 9 | **Neumorphism** | Kiosks, settings-heavy apps | ✗ | Soft shadows, tactile look. Known accessibility issues; not great for dense data. |
| 10 | **Retro synthwave** | Gaming, entertainment, creative tools | ○ | Neon on dark, bold gradients. Fatiguing after hours of use. |
| 11 | **Clean editorial** | Content, publishing, documentation | ○ | Typography-first, Swiss/Bauhaus grid. Not suited for transactional or data-heavy flows. |

### Q12 — App usage pattern

Ask: "Which best describes how users will interact with this app?"

- **A — Long-session transactional:** Hours at a time, high-frequency actions. (POS, inventory, daily ops)
- **B — Short-session reference:** Quick checks, occasional actions. (dashboards, status apps)
- **C — Data-heavy analytical:** Reports, charts, large tables. (BI, monitoring, finance)
- **D — Consumer-facing:** Customers use it; polish and first impressions matter.
- **E — Kiosk / touch-first:** Large targets, minimal keyboard, often a shared device.

### Q13 — Colour palette

Based on Q11 and Q12, suggest a starting palette. Present it clearly with hex values.

Default palettes per style:

- **Industrial terminal:** `#0a0a0a` bg / `#111111` surface / `#39ff14` primary / `#ff6b35` accent / `#e0e0e0` text. Font: JetBrains Mono or Fira Code.
- **Neobrutalism:** `#ffffff` bg / `#f5f5f5` surface / `#1a1a2e` primary / `#ff6b6b` accent / `#000000` border (2px solid) / `#111111` text. Font: Space Grotesk Bold or Inter 700.
- **Warm earthy:** `#faf7f2` bg / `#f0ebe0` surface / `#5c4033` primary / `#d4845a` accent / `#2c1810` text. Font: Nunito or Lato.
- **Dashboard pro:** `#0d1117` bg / `#161b22` surface / `#58a6ff` primary / `#3fb950` accent / `#e6edf3` text. Font: Inter or IBM Plex Sans.
- **Flat corporate:** `#f8f9fa` bg / `#ffffff` surface / `#0066cc` primary / `#ff8800` accent / `#212529` text. Font: Inter or system-ui.
- **Soft modern:** `#fafafa` bg / `#ffffff` surface / `#6c63ff` primary / `#ff6584` accent / `#333333` text. Font: Nunito or Poppins.
- **High-contrast accessible:** `#ffffff` bg / `#f0f0f0` surface / `#000000` primary / `#0000cc` accent / `#000000` text. Min 16px base font. Font: Atkinson Hyperlegible or Inter.
- **Retro synthwave:** `#0d0221` bg / `#1a0533` surface / `#ff00ff` primary / `#00ffff` accent / `#ffffff` text. Font: Orbitron or Space Mono.
- **Warm earthy (dark variant):** `#1c1410` bg / `#2a1f18` surface / `#d4845a` primary / `#e8b89a` accent / `#f5ede3` text.
- *(For unlisted styles, derive a contextually appropriate palette and explain your reasoning.)*

Ask: "Use this palette, customise it now, or defer colour decisions to a later stage?"

If customising: ask for primary colour, accent colour, and background preference (light/dark/auto).

### Q14 — CSS approach

Based on Q11 + Q12, recommend one approach:

| Condition | Recommendation | Reason |
|---|---|---|
| Industrial terminal | Pure CSS + CSS variables | Full control, no framework overhead, custom look |
| Neobrutalism | Tailwind CSS | Utility classes make bold, custom styling easy |
| Warm earthy | DaisyUI (Tailwind plugin) | Component classes with warm customisation |
| Dashboard pro | PrimeVue + PrimeFlex | Rich data tables, charts, dark mode built-in |
| Flat corporate | PrimeVue or Vuetify | Dense component library, data grids |
| Soft modern | Vuetify | Material Design base, friendly and polished |
| High-contrast accessible | Pure CSS + CSS variables | Fine-grained control over contrast and sizing |
| Any + Kiosk/touch-first | Prefer PrimeVue or pure CSS — avoid small default touch targets |

State the recommendation and explain why. Ask: "Proceed with this, or choose differently?"

**Note:** CSS framework installation and design token setup will be the first task in the
UI implementation plan — not scaffolded automatically. All choices are recorded in CLAUDE.md.

Tell the user: "UX/UI decisions recorded. Writing architecture document."

---

## Phase 3b — Architecture Document

Generate `docs/architecture.md` now, while all Q1–Q14 answers are fresh.
This is the single source of truth for every structural decision in this project.
It is written for both humans reviewing the project and AI agents making changes to it.

```markdown
# {AppName} — Architecture

> Single source of truth for all architecture and design decisions.
> Read this before making any structural change. Update it when any decision changes.

## Project Context
**Goal:** {one-sentence goal}
**Target users:** {roles and brief description}
**Deployment:** {deployment context from Phase 0}
**Peak concurrent users:** {ballpark from Phase 0}

## Architecture Decisions

### Tenancy (Q1)
**Choice:** {Single-tenant / Multi-tenant}
**Means for this project:** {specific implication — e.g., "No IRequestContext tenant routing.
One database. Auth identifies the user only."}

### Database engine (Q2)
**Choice:** {SQLite / PostgreSQL / MySQL}
**Means for this project:** {e.g., "SQLite file at db/{appname}.db.
IDbConnectionFactory returns SqliteConnection. Use last_insert_rowid() for new IDs.
Enable PRAGMA foreign_keys = ON per connection."}

### Language support (Q3)
**Choice:** {Multi-language / English only / Spanish only}
**Means for this project:** {e.g., "No i18n infrastructure. All strings hardcoded in Spanish."}

### Timestamp convention (Q4)
**Choice:** {Local time / UTC}
**Rule:** Use `{DateTime.Now / DateTime.UtcNow}` for every timestamp in the codebase.
Never mix. This applies to CreatedAt, UpdatedAt, ExpiresAt, and any domain date field.

### Hosting and access model (Q5)
**Choice:** {Local/single-org / Public/multi-org + sub-answers}
**Means for this project:** {e.g., "Runs on LAN. Admin creates users directly.
No email service, no invite flow, no SingleUseTokens table.
Auth covers login, logout, and change-password only."}

### Database isolation (Q6)
**Choice:** {Single DB / Per-tenant DB}
**Means for this project:** {e.g., "One IDbConnectionFactory returning a single connection
to db/{appname}.db. No per-request connection routing."}

### Delete strategy (Q7)
**Choice:** {Soft delete / Hard delete}
**Means for this project:** {e.g., "IsDeleted BOOLEAN NOT NULL DEFAULT 0 on all main
business entities. Every list and get query filters WHERE IsDeleted = 0.
Delete operations set the flag — they never issue DELETE."}
**Applies to:** Main business entities only — not to lookup tables, config tables,
session tokens, or migration records.

### Background jobs (Q8)
**Choice:** {Yes / No}
**Means for this project:** {e.g., "No hosted BackgroundService classes. All processing
is triggered by HTTP requests." / "One BackgroundService for {purpose}."}

### Monetary data (Q9)
**Choice:** {Yes / No}
**Means for this project:** {e.g., "All prices, totals, and costs stored as INTEGER cents.
Never REAL or DECIMAL in the database. Conversion helpers required in the UI layer."}

### Logging destination (Q10)
**Choice:** {File only / Database / Both}
**Means for this project:** {e.g., "Rolling file logs at Information level.
File: logs/{appname}-.log, daily rolling, 30-day retention."}

## Design System

### Visual style (Q11)
**Choice:** {style name}
**Character:** {one sentence — e.g., "Neobrutalism — bold borders, flat colour blocks,
strong personality. Chosen for long-session POS use with clear touch targets."}

### Usage pattern (Q12)
**Choice:** {pattern name}
**Implication:** {e.g., "Long-session transactional — avoid pure white backgrounds,
prioritise contrast and clear hierarchy, large tap targets."}

### Colour palette (Q13)
| Token | Value | Usage |
|---|---|---|
| `--color-bg` | {hex} | Page background |
| `--color-surface` | {hex} | Card and panel backgrounds |
| `--color-primary` | {hex} | Brand colour, interactive elements |
| `--color-accent` | {hex} | Highlights, CTAs, focus states |
| `--color-text` | {hex} | Default body text |

**Typography:** {font family} — base size {px}
**Dark / light default:** {choice or "deferred to phase-0-setup"}
**Component density:** {compact / comfortable / spacious or "deferred to phase-0-setup"}

### CSS approach (Q14)
**Choice:** {approach — e.g., Tailwind CSS / Pure CSS / PrimeVue}
**Reason:** {why this fits the chosen style and usage pattern}
**Setup:** See `docs/plans/phase-0-setup.md` — CSS framework installation and design token
configuration is the first implementation task.

## Active Conventions

These rules are derived directly from the decisions above.
Every agent and developer working on this project must apply them without exception.

### Data layer
{include only the rules that apply based on Q answers — delete the others}
- All monetary amounts stored as **INTEGER cents** — never `REAL` or `DECIMAL` in DB
  Conversion: `amount / 100.0` for display · `Math.Round(input * 100)` for storage
- `IsDeleted BOOLEAN NOT NULL DEFAULT 0` on all main business entities
  Every list and get repository method filters `WHERE IsDeleted = 0`
  Delete methods set the flag — never issue `DELETE`
- All timestamps use `{DateTime.Now / DateTime.UtcNow}` — never mix
- Database column naming: {PascalCase for C# / snake_case for Go or Node}
- Enums stored as `TEXT` with `CHECK` constraints listing valid values
- Primary keys: `INTEGER PRIMARY KEY` (auto-increment) — not UUID

### API layer
- JSON responses always use **camelCase** property names
- Errors always use RFC 7807 ProblemDetails: `type`, `title`, `status`, `detail`, `instance`
- Controllers contain no logic — inject use case → call `ExecuteAsync` → return `FromResult`
- Backend validation: return `Result.Failure` on the **first** invalid field — one message per call

### Logging
- Always include `UserId` in structured log properties
{if Q1=multi-tenant: also include TenantId}
- Levels: `Warning` for validation failures · `Information` for success · `Error` for exceptions
- Never log passwords, tokens, or personally identifiable data

### Authorization
- Role checks belong in use cases — never in controllers
- At minimum: `Admin` role and `User` role defined in `Users.Role` column

## Testing Conventions

### Backend — xUnit + NSubstitute

- One test class per use case, located in `tests/{AppName}.Logic.Tests/Application/{Module}/`
- `ValidRequest()` static helper returns a fully valid baseline request.
  All test variations use `with` syntax — never repeat the constructor.
- Group related scenarios: `[Theory]` + `[InlineData]` for 3 or more equivalent cases.
  Never write separate `[Fact]` methods for the same rule with different inputs.
  Use `[MemberData]` for complex cases that don't fit `[InlineData]`.
- Section separators within the class: `// --- success path ---`, `// --- validation ---`,
  `// --- business rules ---`, `// --- repository failures ---`, `// --- zero-call verification ---`
- Naming: `Execute_{Scenario}_{ExpectedOutcome}` — no filler words.
- Minimum coverage per use case: happy path · each validation rule · each business rule ·
  repository exception · at least one zero-call check.

### Frontend — Vitest + jsdom

- **Tests for stores only. No component tests.**
- All logic lives in `.ts` files (stores, composables, utilities).
  Components are thin templates — no conditional logic, no data transformation, no validation.
  If a component contains logic, extract it before writing the test.
- Fresh Pinia per test: `setActivePinia(createPinia())` in every `beforeEach`.
- Global `fetch` mock in `vitest.setup.ts` — mock only `fetch`, never store internals.
- Nest `describe` blocks by store action. One `describe` per method.
- `it.each` for 3 or more input variants of the same rule.
- Assert on store state (`.items`, `.error`, `.loading`) — not on fetch call arguments.
- Always verify `fetch` was NOT called when client-side validation rejects early.

## Acknowledged Risks

{If no risks were confirmed in Phase 2b, write:
"None — all flagged issues were resolved before proceeding."}

{Otherwise list each confirmed risk:}
| Risk | Reason accepted | Mitigation |
|---|---|---|
| {risk description} | {user's reasoning} | {any planned mitigation or "none"} |
```

Tell the user: "Architecture document written to `docs/architecture.md`. Moving to module specification."

---

## Phase 4 — Module Specifications

Tell the user: "I will now derive the app modules from the PRD and write a spec for each."

Identify modules by grouping related features. Common modules — adapt to the actual PRD:
- **Auth** — always present: login, logout, user management, password change
- **[Domain entity modules]** — one module per major entity or workflow cluster from the PRD
- **Settings** — workspace or app configuration
- **Reporting** — if PRD mentions reports, exports, or summaries
- **Dashboard** — if PRD mentions an overview or home screen

For each module, create `docs/specs/{module-name}.md`:

```markdown
<!--
type: spec
module: {Module}
status: draft
entities: {Entity1, Entity2}
endpoints: {GET /api/{module}, POST /api/{module}, PUT /api/{module}/{id}, DELETE /api/{module}/{id}}
depends-on: {auth, other-module-if-any}
-->

# {Module} — Specification

## Purpose
[One paragraph: what this module does and why it exists in this app]

## Entities
| Entity | Key fields | Notes |
|---|---|---|

## Use Cases
| Use case | Actor | Input | Business rules | Output |
|---|---|---|---|---|

## API Endpoints
| Method | Route | Request body | Response | Auth |
|---|---|---|---|---|

## UI Pages / Screens
| Page | Purpose | Key interactions |
|---|---|---|

## Business Rules
1. [Invariant or constraint]
2. ...

## Acceptance Criteria
- [ ] [Testable condition]
- [ ] ...
```

After generating all specs, list the modules created and ask:
"Are any modules missing? Any you'd like to split or merge?"

Adjust specs accordingly.

---

## Phase 5 — Implementation Plans

Tell the user: "I will now sequence the modules into a phased implementation plan."

Sequencing rules:
- Phase 0 is always project setup (scaffold + CSS + design tokens)
- Auth is always Phase 1 (everything else depends on it)
- Core domain entities before anything that aggregates them (reports, dashboards)
- Independent modules can be parallelised in the same phase number

For each phase, create `docs/plans/phase-{N}-{module}.md`:

```markdown
<!--
type: plan
phase: {N}
module: {Module}
status: not-started
spec: docs/specs/{module-name}.md
depends-on: phase-{N-1}
-->

# Phase {N} — {Module}

## Goal
[What will be working and testable at the end of this phase]

## Prerequisites
[Other phases or external setup that must be complete first]

## Backend Tasks
- [ ] Entity: `src/{AppName}.Logic/Domain/{Entity}.cs`
- [ ] DTOs: `src/{AppName}.Logic/DTOs/{Module}/` — one file per use case pair (Request + Response)
- [ ] Use cases: `src/{AppName}.Logic/Application/{Module}/` — one class per operation
- [ ] Repository interface: `src/{AppName}.Logic/Repositories/I{Entity}Repository.cs`
- [ ] Repository implementation: `src/{AppName}.Web/Infrastructure/Persistence/Repositories/`
- [ ] Controller: `src/{AppName}.Web/Controllers/{Module}Controller.cs`
- [ ] Register use cases and repository in `ServiceCollectionExtensions.cs`
- [ ] DB migration: `db/scripts/{NNN}_{description}.sql`

## Frontend Tasks
- [ ] TypeScript types: `src/{AppName}.App/src/types/{module}.ts`
- [ ] Store (if shared state needed): `src/{AppName}.App/src/stores/{module}.ts`
- [ ] Page components: `src/{AppName}.App/src/pages/{module}/`
- [ ] Reusable components: `src/{AppName}.App/src/components/{module}/`
- [ ] Routes added to router

## Test Tasks
- [ ] Use case tests: `tests/{AppName}.Logic.Tests/Application/{Module}/`
- [ ] Coverage: happy path, each validation rule, repository exception, zero-call cases

## Manual Test Scenarios
[2–4 specific scenarios to verify the feature works end-to-end]

## Definition of Done
- [ ] Backend compiles with no warnings
- [ ] All new tests pass
- [ ] Feature works end-to-end in the browser
- [ ] Relevant spec in `docs/specs/` is up to date
- [ ] CLAUDE.md current state section updated
```

Always include Phase 0 as the first plan:

```markdown
<!--
type: plan
phase: 0
module: setup
status: not-started
depends-on: none
-->

# Phase 0 — Project Setup

## Goal
A running app: backend serves /health, frontend loads and proxies to backend.

## Tasks
- [ ] Verify scaffold compiles: `dotnet build`
- [ ] Verify backend starts: `just dev-backend` → GET /health returns 200
- [ ] Install frontend dependencies: `cd src/{AppName}.App && npm install`
- [ ] Verify frontend starts: `just dev-frontend` → app loads in browser
- [ ] CSS framework setup: install {Q14 recommendation}
- [ ] Design tokens: create base CSS file with variables from Q13 palette
- [ ] Typography: import font ({Q13 font recommendation}), set base sizes
- [ ] Dark/light mode: configure default ({Q15 choice or "deferred"})
- [ ] Component density: set base spacing ({compact/comfortable/spacious or "deferred"})
- [ ] Write and apply baseline DB migration
- [ ] Confirm auth middleware returns 401 on protected routes
```

After all spec and plan files are written, generate `docs/index.md`:

```markdown
# {AppName} — Docs Index

> Read this file first. It tells you exactly which documents to open for any task.
> Update it whenever a spec or plan file is added, renamed, or its status changes.

## Agent context loading protocol

1. Always read `CLAUDE.md` + this file first — together under 5 minutes of context.
2. Then open only the files listed in the task routing table below that match your task.
3. Do not read docs not listed for your task — unnecessary context wastes tokens.

## Task routing

| If you need to... | Read |
|---|---|
| Understand any architecture or convention | `docs/architecture.md` |
| Understand the full product scope | `docs/prd.md` |
| Work on a specific module | `docs/specs/{module}.md` + `docs/plans/phase-{N}-{module}.md` |
| Add a DB migration | `docs/architecture.md` → Active Conventions → Data layer |
| Add a new use case to an existing module | `docs/specs/{module}.md` for the contract |
| Check what is already built vs. planned | `CLAUDE.md` → Current State |
| Understand the implementation sequence | This file → Implementation Plans table |
| Change an architecture decision | `docs/architecture.md` → update it → update `CLAUDE.md` |

## Core documents

| File | Purpose |
|---|---|
| `CLAUDE.md` | Project rules, naming conventions, dev guidelines, current state |
| `docs/architecture.md` | All Q1–Q14 decisions, active conventions, design system, accepted risks |
| `docs/prd.md` | Full product requirements — features, workflows, non-functional requirements |
| `docs/index.md` | This file — document navigator |

## Module specs

| File | Module | Entities | Status |
|---|---|---|---|
{for each spec: | `docs/specs/{module}.md` | {Module} | {Entity1, Entity2} | draft / done |}

## Implementation plans

| File | Phase | Module | Depends on | Status |
|---|---|---|---|---|
| `docs/plans/phase-0-setup.md` | 0 | Setup | — | not-started |
{for each plan: | `docs/plans/phase-{N}-{module}.md` | {N} | {Module} | phase-{N-1} | not-started |}
```

Tell the user: "Index written to `docs/index.md`. Agents can now navigate the project efficiently."

---

## Phase 6 — Barebones Scaffold

Tell the user: "Creating the project scaffold. This produces a runnable, compilable
barebones app with no features yet — just the skeleton."

Create all files using Write and Bash tools. Use the decisions from Q1–Q10 to conditionally
include or exclude components.

### Directory structure to create:

```
{AppName}/
├── src/
│   ├── {AppName}.Logic/
│   │   ├── {AppName}.Logic.csproj
│   │   ├── Result.cs
│   │   ├── IRequestContext.cs
│   │   ├── Domain/
│   │   ├── DTOs/
│   │   ├── Application/
│   │   └── Repositories/
│   ├── {AppName}.Web/
│   │   ├── {AppName}.Web.csproj
│   │   ├── Program.cs
│   │   ├── appsettings.json
│   │   ├── appsettings.Development.json
│   │   ├── Controllers/
│   │   │   └── HealthController.cs
│   │   └── Infrastructure/
│   │       ├── ServiceCollectionExtensions.cs
│   │       ├── WorkspaceContext.cs          (if Q1=multi-tenant)
│   │       ├── Persistence/
│   │       │   ├── DatabaseMigrator.cs
│   │       │   ├── IDbConnectionFactory.cs
│   │       │   └── DbConnectionFactory.cs
│   │       ├── Auth/
│   │       │   ├── TokenValidator.cs
│   │       │   └── BcryptPasswordHasher.cs
│   │       ├── Middleware/
│   │       │   └── RequestContextMiddleware.cs
│   │       └── Errors/
│   │           ├── ControllerExtensions.cs
│   │           └── ErrorTypeHelper.cs
│   └── {AppName}.App/
│       ├── package.json
│       ├── vite.config.ts
│       ├── tsconfig.json
│       ├── index.html
│       └── src/
│           ├── main.ts
│           ├── App.vue
│           ├── router/
│           │   └── index.ts
│           ├── composables/
│           │   └── useApi.ts
│           ├── stores/
│           ├── types/
│           ├── pages/
│           │   └── LoginPage.vue
│           └── assets/
├── tests/
│   └── {AppName}.Logic.Tests/
│       └── {AppName}.Logic.Tests.csproj
├── db/
│   └── scripts/
│       └── baseline_main.sql
├── docs/                          (already created in prior phases)
├── {AppName}.slnx
├── justfile
├── .gitignore
└── CLAUDE.md                      (created in Phase 7)
```

### Key file contents to generate:

**`Result.cs`** — generic Result wrapper with IsSuccess, Data, ErrorMessage, ErrorCode.
Factory methods: Success(data), Failure(message, code=400), NotFound(message),
Unauthorized(message), Conflict(message).

**`IRequestContext.cs`** — interface with:
- Always: `string UserId`, `string Role`
- If Q1=multi-tenant or Q6=per-tenant: add `string TenantId`, `string TenantDbPath`
- `void SetContext(...)` matching the properties

**`RequestContextMiddleware.cs`** — extract Bearer token from Authorization header,
validate against SessionTokens table, populate IRequestContext, return 401 if invalid.
Unauthenticated routes (login, setup, health) pass through without validation.

**`ControllerExtensions.cs`** — `FromResult<T>` extension: Ok(data) on success,
Problem(...) with RFC 7807 ProblemDetails on failure.

**`ErrorTypeHelper.cs`** — maps status codes to type strings:
400→validation-failed, 401→unauthorized, 403→forbidden, 404→not-found, 409→conflict, 500→internal-error.

**`DatabaseMigrator.cs`** — checks `_migrations` table, applies baseline if absent,
applies incremental scripts in filename order, skips already-applied scripts.

**`HealthController.cs`** — `GET /health` returns `{ "status": "ok", "version": "0.1.0" }`.

**`useApi.ts`** — full implementation: get/post/put/patch/del methods, automatic Bearer
token injection from localStorage, ProblemDetails typed error shape, network errors
normalised to same shape with status=0 and type="network-error".

**`baseline_main.sql`** — creates:
- `_migrations` table
- `Users` table with Id, Username, PasswordHash, Role (CHECK Admin/User), CreatedAt, UpdatedAt
- `SessionTokens` table with Token, UserId FK, CreatedAt, ExpiresAt
- Indexes on SessionTokens(ExpiresAt), Users(Username)
- Add TenantId columns and Workspaces table if Q1=multi-tenant
- If QS=admin or QS=admin+lookup: include INSERT statements for seed data after the schema.
  BCrypt-hash the temporary password directly in the SQL (pre-computed) and add a comment block:
  `-- SEED DATA: default admin "{username}" / temporary password "{password}"`
  `-- Enforce password change on first login (see Auth use cases).`
  Include any additional lookup/config seed rows requested in QS.

**`dev_fixtures.sql`** (if QF=yes) — a standalone reset script at `db/scripts/dev_fixtures.sql`:
- Opens with a prominent header block:
  ```sql
  -- ============================================================
  -- DEV FIXTURES — NOT FOR PRODUCTION
  -- Destructive reset: deletes existing data then inserts test records.
  -- Run with: just reset-dev
  -- Update this file whenever a new table is added to the schema.
  -- ============================================================
  ```
- **RESET section:** DELETE from all seeded tables in reverse foreign-key order.
  Do not delete from `_migrations`. Optionally preserve the seed admin user (ask).
- **DATA sections:** one clearly-labelled section per entity/module (e.g., `-- === PRODUCTS ===`).
  Insert realistic but fake records matching the volumes requested in QF.
  If Q9=yes: all monetary amounts as INTEGER cents.
  If Q7=soft-delete: set IsDeleted = 0 on all fixture records.
- **Test users section** (if requested): additional users with known passwords for testing
  different roles, BCrypt-hashed. Label them clearly: `-- TEST USERS (not for production)`.

**`.csproj` packages** — based on Q answers:
- Always: Dapper, Serilog.AspNetCore, Serilog.Sinks.Console, Serilog.Sinks.File, BCrypt.Net-Next
- Q2=SQLite: Microsoft.Data.Sqlite
- Q2=PostgreSQL: Npgsql + Dapper
- Q2=MySQL: MySqlConnector + Dapper
- Q10=DB or Both: appropriate Serilog DB sink

**`justfile`:**
```makefile
build:
    dotnet build
    cd src/{{AppName}}.App && npm install && npm run build

run:
    dotnet run --project src/{{AppName}}.Web

dev-backend:
    dotnet run --project src/{{AppName}}.Web

dev-frontend:
    cd src/{{AppName}}.App && npm run dev

test:
    dotnet test
    cd src/{{AppName}}.App && npm run test:run

test-coverage:
    dotnet test --collect:"XPlat Code Coverage"
    cd src/{{AppName}}.App && npm run coverage

# Include only if QF=yes. Use the correct DB command for Q2:
# Q2=SQLite:
reset-dev:
    sqlite3 db/{{AppName}}.db < db/scripts/dev_fixtures.sql
    @echo "Dev fixtures loaded."

# Q2=PostgreSQL:
# reset-dev:
#     psql $DATABASE_URL -f db/scripts/dev_fixtures.sql

# Q2=MySQL:
# reset-dev:
#     mysql $DATABASE_NAME < db/scripts/dev_fixtures.sql
```

Include only the variant that matches Q2; remove the commented-out alternatives.

**`.gitignore`** — standard .NET + Node + SQLite entries:
bin/, obj/, node_modules/, dist/, *.db, *.db-shm, *.db-wal, .env, wwwroot/

After creating all files, tell the user:
```
Scaffold created. To verify:
  Terminal 1: just dev-backend   → http://localhost:5000/health should return 200
  Terminal 2: just dev-frontend  → http://localhost:5173 should load the app

If either fails, check the error and let me know.
```

### Git initialisation

Run the following to create the initial commit:

```bash
git init
git add .
git commit -m "bootstrap: {AppName} initial project structure"
```

Then ask: "Do you have a remote repository URL to connect this to?
(e.g., https://github.com/yourname/{appname}.git)
Paste it now, or type SKIP to set it up later."

If a URL is provided:
```bash
git remote add origin {url}
git push -u origin main
```

Tell the user: "Git repository initialised. Initial commit created."

---

## Phase 7 — CLAUDE.md

Generate `CLAUDE.md` at the project root. Fill in every section with the actual decisions
made during this session.

```markdown
# {AppName} — CLAUDE.md

## Project Overview
**Goal:** {one-sentence goal from Phase 0}
**Target users:** {roles from Phase 0}
**Status:** Bootstrapped — barebones scaffold in place. See `docs/plans/` for implementation order.

## Architecture and Design
All architecture decisions, design system choices, active conventions, and acknowledged risks
are documented in [`docs/architecture.md`](docs/architecture.md).

**Read `docs/architecture.md` before making any structural change.**
Update it whenever a decision changes — then update this file's Current State section.

Key decisions at a glance (see `docs/architecture.md` for full detail):
- Tenancy: {Q1 answer} · DB: {Q2 answer} · Timestamps: {Q4 answer}
- Hosting: {Q5 answer} · Delete: {Q7 answer} · Background jobs: {Q8 answer}
- Monetary: {Q9 answer} · Style: {Q11 answer}

## Context loading

Read `docs/index.md` for the full document navigator. Quick reference:

| Task | Read |
|---|---|
| Any task | `CLAUDE.md` + `docs/index.md` (you are here) |
| Architecture or conventions | `docs/architecture.md` |
| Working on a module | `docs/specs/{module}.md` + its plan file |
| Adding a DB migration | `docs/architecture.md` → Active Conventions → Data layer |
| Checking what's built | `CLAUDE.md` → Current State below |

## Directory Structure
```
src/
├── {AppName}.Logic/     Domain + Application layer (no framework dependencies)
│   ├── Domain/          Plain entities and enums
│   ├── DTOs/            Request and response records, one folder per feature
│   ├── Application/     Use cases, one class per operation
│   └── Repositories/    Capability-oriented interfaces
├── {AppName}.Web/       Infrastructure + API layer
│   ├── Controllers/     Thin HTTP adapters — no logic
│   └── Infrastructure/  DI wiring, DB, auth, middleware
└── {AppName}.App/       Vue 3 frontend
    └── src/
        ├── pages/       Route-level components
        ├── components/  Reusable UI components
        ├── composables/ Shared logic and API layer
        ├── stores/      Global state (Pinia)
        └── types/       TypeScript interfaces matching backend DTOs
tests/
└── {AppName}.Logic.Tests/
db/
└── scripts/             SQL migration files
docs/
├── prd.md
├── specs/               One file per module
└── plans/               One file per implementation phase
```

## Naming Conventions
**Backend language:** {C# / Go / other}
**C# namespaces:** `{AppName}.Logic.*` for Logic, `{AppName}.Web.*` for Web
**DB columns:** {PascalCase for C# / snake_case for Go or Node}
**JSON responses:** camelCase always — ASP.NET Core default, explicit struct tags in Go
**Vue files:** PascalCase.vue
**TypeScript types:** PascalCase, mirroring backend DTO names

## Development Rules

### Agent must ask before:
- Creating or modifying any SQL script in `db/`
- Creating or modifying any file in `docs/`
- Adding new projects or changing solution structure

### Agent must follow:
- One use case class per operation — verb + noun naming (CreateX, UpdateX, ListX)
- Every use case returns `Result<T>` — no exceptions cross layer boundaries
- Repository interfaces live in Logic; implementations live in Web/Infrastructure
- Controllers are thin: inject use case → call ExecuteAsync → return FromResult(result)
- **Backend validation:** return Result.Failure on the first invalid field — one message per call
- **Frontend validation:** validate all required fields before submitting — show all errors at once
{if Q7=soft-delete:}
- IsDeleted on all main business entities — every list/get query filters WHERE IsDeleted = 0
{if Q9=yes:}
- All monetary amounts stored as INTEGER cents — never REAL or DECIMAL in DB
- Conversion: amount_cents / 100.0 for display, Math.Round(decimal * 100) for storage
{if Q4=local:}
- Use DateTime.Now everywhere — never DateTime.UtcNow
{if Q4=UTC:}
- Use DateTime.UtcNow everywhere — never DateTime.Now
{if Q1=multi-tenant:}
- Include TenantId and UserId in all log structured properties
{if Q1=single-tenant:}
- Include UserId in all log structured properties
- Role checks belong in use cases — never in controllers

### Documentation to keep in sync:
| Document | Update when... |
|---|---|
| `docs/index.md` | Adding or renaming any spec or plan file, or changing a phase status |
| `docs/specs/{module}.md` | Adding or changing a use case, endpoint, entity, or business rule |
| `docs/architecture.md` | Any architecture or design decision changes |
| `CLAUDE.md` current state | After each completed phase |
{if QF=yes:}
| `db/scripts/dev_fixtures.sql` | Adding a new table — add a matching DELETE in the RESET section and INSERT rows in a new data section |

## Current State
- [x] PRD: `docs/prd.md`
- [x] Architecture decisions recorded
- [x] Module specs: {list of docs/specs/ files}
- [x] Implementation plans: {list of docs/plans/ files}
- [x] Barebones scaffold created
- [ ] **Next:** `docs/plans/phase-0-setup.md` — install CSS framework and design tokens
{list subsequent phases as unchecked items}
```

---

## Final Summary

After Phase 7 is complete, present this summary to the user:

```
{AppName} bootstrap complete.

Files created:
  docs/prd.md
  docs/architecture.md
  docs/index.md
  docs/specs/             {list module spec files}
  docs/plans/             {list implementation plan files}
  src/{AppName}.Logic/
  src/{AppName}.Web/
  src/{AppName}.App/
  db/scripts/baseline_main.sql         {note if seed data was included}
  {if QF=yes: db/scripts/dev_fixtures.sql}
  justfile
  .gitignore
  CLAUDE.md
  .git/                               initial commit created

Quick start:
  Terminal 1 → just dev-backend       (http://localhost:5000/health)
  Terminal 2 → just dev-frontend      (http://localhost:5173)
  {if QF=yes: just reset-dev}         (load dev fixtures)

{if seed data included:}
  Default admin: {username} / {password}  ← change this on first login
{if QF=yes:}
  Dev fixtures: {summary of scenarios — e.g., "3 categories, 20 products, 10 days of sales"}
  Update db/scripts/dev_fixtures.sql whenever a new table is added.

Start implementing with:
  /implement-phase          (works phase by phase, loads only what it needs)
  — or open docs/plans/phase-0-setup.md manually

To use these commands globally on any machine:
  Store it in a github repo (e.g., yourname/claude-config) under commands/new-project.md
  Clone it and symlink: ln -sf ~/claude-config/commands ~/.claude/commands
```
