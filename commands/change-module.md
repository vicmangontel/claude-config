# change-module

Apply a change to one or more modules in a project built with /new-project.

Detect the user's language from their messages and conduct the entire session in that language.
Classifies the change, asks questions, updates docs, then either implements
directly (fix) or creates a patch plan and hands off to /implement-phase
(enhancement or cross-cutting).

Praise the Omnissiah.

---

## Step 0 — Git status check

Run `git status` before anything else.

**Clean tree:** proceed silently.

**Uncommitted changes:** stop and present them. Offer:
- **C** — commit now (help write the message)
- **S** — stash (`git stash`, remind to `git stash pop` when done)
- **X** — continue anyway (warn: changes will mix with this session's diff)

**Not a git repo:** warn but do not block.

---

## Step 1 — Load project context

Read:
1. `CLAUDE.md`
2. `docs/index.md`

---

## Step 2 — Describe and locate

Ask: "Describe the change you need to make."

Then ask: "Which module(s) does this affect?"
If uncertain, list the modules from `docs/index.md` and ask the user to identify them.

Read the affected spec(s) `docs/specs/{module}.md`. Extract only the **Active Conventions**
section from `docs/architecture.md`.

---

## Step 3 — Classify

Based on the description and spec, determine which class applies:

| Class | Criteria | Outcome |
|---|---|---|
| **Fix** | Modifies only existing files. No new DB migration. No new use case or endpoint. | Implement directly in this session. |
| **Enhancement** | Adds new files (use case, endpoint, store action) or needs a DB migration. Single module. | Update spec → create patch plan → hand to /implement-phase. |
| **Cross-cutting** | Adds or changes things across 2+ modules. | Update all affected specs → create one patch plan → hand to /implement-phase. |

Present the classification and your reasoning. Ask: "Does this match what you intended?"
Accept any correction without argument.

**If the scope expands mid-session** (a Fix turns out to need a migration, for example),
stop, reclassify, and tell the user before continuing.

---

## Step 4 — Clarification questions

Ask one question at a time. After each answer, restate the decision in one sentence,
then ask the next. Skip any question made irrelevant by a previous answer.
When all questions are resolved: "All clear. Updating docs now."

**For a Fix:**
- What is the incorrect behaviour? (specific: inputs, conditions, actual vs. expected output)
- What is the correct behaviour?
- Does this change any business rule in the spec?
- Which existing tests are affected? (validation path, success path, error case)

**For an Enhancement:**
- What is the new use case? (actor, trigger, inputs, expected output)
- Which roles can call it?
- What business rules apply? (uniqueness, constraints, allowed values, limits)
- What happens in error cases? (not found, conflict, validation failure)
- Is this purely additive, or does it change existing behaviour?
- UI: new page, new action on an existing page, or no UI change?

**For a Cross-cutting change:**
- For each affected module: what specifically changes? (field added, rule modified, endpoint changed)
- Is there a dependency order between modules?
- Is the DB migration additive (new column/table) or destructive (rename, drop, type change)?

---

## Step 5 — Update docs

Ask before modifying any file.

**Always — update specs:**
Update `docs/specs/{module}.md` for every module where a business rule, entity field,
endpoint, or UI behaviour changed. Skip only if the change is a purely internal refactor
with zero behaviour change.

**Enhancement and Cross-cutting only — create patch plan:**

Naming: `docs/plans/phase-{N}a-{module}-{slug}.md`
- `{N}` = phase number of the most recently completed plan for this module
- suffix increments alphabetically for multiple patches: `a`, `b`, `c` ...
- `{slug}` = 2–3 words: `phase-2a-products-export`, `phase-1b-auth-role-check`

```markdown
<!--
type: plan
phase: {N}a
module: {Module}
status: not-started
spec: docs/specs/{module}.md
depends-on: phase-{N}
-->

# Phase {N}a — {Module}: {change description}

## Goal
[One sentence: what will work differently or be newly available when this is done]

## Scope
[List only files being created or modified — not the full module checklist]

## Tasks
- [ ] {each specific task}

## Test updates
- [ ] {which test files need updating and what specifically changes}

## Definition of done
- [ ] All tests pass
- [ ] Spec reflects the change
- [ ] No regressions in adjacent modules
```

Add the new plan to `docs/index.md` Implementation Plans table.

---

## Step 6 — Execute or hand off

### If Fix — implement directly

Work through only the files identified in Step 4. Follow the same rules as
/implement-phase Step 5:

- Read existing test files before touching them — update affected cases, do not only append
- Ask before modifying any file in `db/` or `docs/`
- If a gap surfaces mid-fix, stop and apply the gap protocol:
  present the gap, offer options (A / B / Defer), update the spec before continuing

After implementing:
- Run `dotnet test` — must pass before done
- Run `npm run test:run` (from the App project) if any store was touched — must pass
- Confirm the spec reflects what was changed
- Commit: `fix({module}): {what was wrong and what now happens}`

### If Enhancement or Cross-cutting — hand off

Report:
```
Docs updated.

  Spec:       docs/specs/{module}.md — updated
  Patch plan: docs/plans/phase-{N}a-{module}-{slug}.md — created
  Index:      docs/index.md — updated

Run /implement-phase to execute the patch plan.
```
