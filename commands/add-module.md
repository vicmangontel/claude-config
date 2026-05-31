# add-module

Add a new module to an existing project built with /new-project.

Detect the user's language from their messages and conduct the entire session in that language.
Checks PRD alignment, gathers requirements, writes the spec and plan,
and updates docs/index.md. No implementation — use /implement-phase after.

Praise the Omnissiah.

---

## Step 0 — Git status check

Run `git status` before anything else.

**Clean tree:** proceed silently.

**Uncommitted changes:** stop and present them. Offer:
- **C** — commit now (help write the message)
- **S** — stash (`git stash`, remind to `git stash pop` when done)
- **X** — continue anyway (warn: changes will mix with this session's diff)

---

## Step 1 — Load project context

Read:
1. `CLAUDE.md`
2. `docs/index.md`
3. `docs/prd.md`

Extract only the **Active Conventions** section from `docs/architecture.md`.

---

## Step 2 — Module identity

Ask: "What is the new module called, and what does it do in one sentence?"

**Check for duplicates:**
Scan `docs/index.md` Module Specs table. If a module with the same name or clear
overlap already exists, stop:
"A `{module}` module already exists at `docs/specs/{module}.md`.
To extend it, use /change-module instead."

**Check PRD alignment:**
Review `docs/prd.md` against the module description. Determine which case applies:

| Case | Criteria | Action |
|---|---|---|
| **In scope** | Module was implied or mentioned in the PRD but not extracted as a spec | Proceed — note which PRD section it comes from |
| **New scope** | Module is not in the PRD at all | Warn + confirm before continuing, then update PRD at Step 7 |
| **Contradicts PRD** | Module conflicts with an out-of-scope decision in the PRD | Surface the conflict and ask the user to resolve it first |

Present the alignment assessment. Ask: "Does this match your intent?"

---

## Step 3 — Requirements questions

Ask one group at a time. Wait for complete answers before moving to the next group.

**Group A — Entities:**
- What data does this module manage? For each entity: name and key fields.
- How do these entities relate to existing ones? (foreign keys, ownership)

**Group B — Use cases:**
- List the operations users can perform (list, create, update, delete, plus any domain-specific actions).
- For each use case: who performs it (role), what are the inputs, what are the business rules, what is the output?

**Group C — API and UI:**
- What API endpoints are needed? (method, route, auth required)
- What pages or screens does the UI need?
- Any UI behaviour worth noting? (confirmation dialogs, inline errors, empty states, redirects)

**Group D — Rules and dependencies:**
- What invariants apply? (uniqueness constraints, allowed values, calculated fields, limits)
- Which existing modules does this depend on? (e.g., Sales depends on Products and Auth)
- Which existing modules might depend on this one in the future?
- Any business rules that are non-obvious or could be misunderstood?

---

## Step 4 — Clarification pass

Review the answers for anything that would require a guess to implement.
Ask one clarifying question at a time using the same protocol as /implement-phase Step 4b.
When all gaps are resolved: "All clear. Writing spec now."

---

## Step 5 — Write spec

Ask before creating the file.

Write `docs/specs/{module-name}.md`:

```markdown
<!--
type: spec
module: {Module}
status: draft
entities: {Entity1, Entity2}
endpoints: {GET /api/{module}, POST /api/{module}, ...}
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

---

## Step 6 — Phase sequencing

Ask:
- "What is the last completed or in-progress phase number?" (or derive from `docs/index.md`)
- "Does this module depend on any phase that is not yet done?"

Determine the phase number: next integer after all existing plans in `docs/index.md`.
If the module can run in parallel with an existing not-started phase, note that but still
assign a distinct phase number — let the user decide whether to work them in parallel.

---

## Step 7 — Write plan

Ask before creating the file.

Write `docs/plans/phase-{N}-{module-name}.md`:

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
[Other phases that must be complete first]

## Backend Tasks
- [ ] Entity: `src/{AppName}.Logic/Domain/{Entity}.cs`
- [ ] DTOs: `src/{AppName}.Logic/DTOs/{Module}/`
- [ ] Use cases: `src/{AppName}.Logic/Application/{Module}/`
- [ ] Repository interface: `src/{AppName}.Logic/Repositories/I{Entity}Repository.cs`
- [ ] Repository implementation: `src/{AppName}.Web/Infrastructure/Persistence/Repositories/`
- [ ] Controller: `src/{AppName}.Web/Controllers/{Module}Controller.cs`
- [ ] Register in `ServiceCollectionExtensions.cs`
- [ ] DB migration: `db/scripts/{NNN}_{description}.sql`

## Frontend Tasks
- [ ] TypeScript types: `src/{AppName}.App/src/types/{module}.ts`
- [ ] Store: `src/{AppName}.App/src/stores/{module}.ts`
- [ ] Page components: `src/{AppName}.App/src/pages/{module}/`
- [ ] Routes added to router

## Test Tasks
- [ ] Use case tests: `tests/{AppName}.Logic.Tests/Application/{Module}/`
- [ ] Store tests: `src/{AppName}.App/src/stores/__tests__/{module}.test.ts`
- [ ] Coverage: happy path · each validation rule · each business rule · repository exception

## Manual Test Scenarios
[2–4 specific scenarios to verify end-to-end]

## Definition of Done
- [ ] Backend compiles with no warnings
- [ ] All new tests pass
- [ ] Feature works end-to-end in the browser
- [ ] Spec acceptance criteria met
- [ ] CLAUDE.md current state updated
```

---

## Step 8 — Update docs

Ask before modifying any file.

1. Add the new module to `docs/index.md` → Module Specs table:
   `| docs/specs/{module}.md | {Module} | {Entity1, Entity2} | draft |`

2. Add the new plan to `docs/index.md` → Implementation Plans table:
   `| docs/plans/phase-{N}-{module}.md | {N} | {Module} | phase-{N-1} | not-started |`

3. Add a new unchecked entry to `CLAUDE.md` → Current State:
   `- [ ] Phase {N} — {Module}: docs/plans/phase-{N}-{module}.md`

4. **If the module is new scope** (not in the original PRD): ask the user if they want to
   update `docs/prd.md`. If yes, add a brief section to the relevant area of the PRD
   documenting what was added and why. Ask before modifying.

---

## Step 9 — Summary

Report:
```
Module added.

  Spec:  docs/specs/{module-name}.md       (draft)
  Plan:  docs/plans/phase-{N}-{module}.md  (not-started)
  Index: docs/index.md — updated
  CLAUDE.md: current state updated
  {if new scope: PRD: docs/prd.md — updated}

Run /implement-phase to start Phase {N} — {Module}.
```
