# implement-phase

Implement one phase of a project bootstrapped with /new-project.

Detect the user's language from their messages and conduct the entire session in that language.

Loads the minimum context needed, works through the plan checklist in dependency order,
and updates plan/index/CLAUDE.md status when done.

Praise the Omnissiah.

---

## Step 0 — Git status check

Run `git status` before doing anything else.

**If the working tree is clean:** proceed silently to Step 1.

**If there are uncommitted changes**, stop and present them:

```
⚠ Uncommitted changes detected:

  modified:  src/AppName.Logic/Domain/Product.cs
  modified:  src/AppName.Web/Controllers/ProductsController.cs
  untracked: src/AppName.App/src/stores/products.ts

Starting implementation on a dirty tree risks mixing in-progress work
with changes from this phase, making it harder to review or roll back.

Options:
  C — Commit the current changes now (I will help you write the message)
  S — Stash them: git stash (restore later with git stash pop)
  X — Continue anyway (your call — changes will be mixed in this phase's diff)
```

Wait for the user to choose before proceeding.

- **C:** Help the user write a commit message, run `git add` on the relevant files,
  commit, confirm clean status, then continue to Step 1.
- **S:** Run `git stash`, confirm clean status, remind the user to run `git stash pop`
  after the phase is complete, then continue to Step 1.
- **X:** Warn once more — "Continuing with uncommitted changes. The phase diff will
  include pre-existing work." — then continue to Step 1.

**If the directory is not a git repository:** warn that no version control is active,
but do not block — continue to Step 1.

---

## Step 1 — Load project context

Read these two files. Nothing else yet.

1. `CLAUDE.md` — project rules, naming conventions, current state
2. `docs/index.md` — document navigator and phase status table

If either is missing, stop:
"This does not look like a project bootstrapped with /new-project.
Navigate to the project root and try again."

---

## Step 2 — Select phase

Parse the Implementation Plans table from `docs/index.md`.
Display the phase list with status:

    Available phases:
    [ ] Phase 0  — Setup       not-started
    [ ] Phase 1  — Auth        not-started
    [ ] Phase 2  — Products    not-started
    [x] Phase 3  — Sales       done

Default to the first `not-started` phase. Ask:
"Which phase should we implement? (Enter to start with Phase {N} — {Module})"

If a phase has unmet prerequisites (its `depends-on` phase is not `done`), warn the user
and ask if they want to continue anyway.

**If the user selects a `done` phase or describes a change to a completed module:**
Direct them to `/change-module` — it classifies the change, updates docs, and either
implements directly (fix) or creates the patch plan to run here.

---

## Step 3 — Load phase context

Read only these files:

- `docs/plans/phase-{N}-{module}.md` — checklist and goal
- `docs/specs/{module}.md` — contracts, entities, business rules

Extract only the **Active Conventions** section from `docs/architecture.md` — not the full file.

---

## Step 4 — Confirm scope

Present:
- Phase {N} — {Module}: {goal from plan file}
- Prerequisites: {from plan file} — confirm done or warn
- Backend tasks: {count}
- Frontend tasks: {count}
- Test tasks: {count}

Ask: "Ready to review the spec for questions? YES to continue, REVIEW to read the full spec first."

---

## Step 4b — Clarification pass (before any code)

Read the spec and plan carefully. Identify every point that would require a guess to implement.
Do not start coding until all blockers are resolved.

**Check for ambiguity in each of these categories:**

- **Entity fields** — unclear type, nullable vs required, max length, format constraints
- **Business rules** — edge cases the spec does not cover
  (e.g. "what if the same item is submitted twice?", "what if quantity is 0?")
- **API contracts** — request fields with multiple interpretations, response shape not fully defined
- **UI behaviour** — what happens after submit? inline error or toast? redirect or stay?
  confirmation dialog before destructive action? empty-state copy?
- **Authorization** — which roles can call this use case? spec may list endpoints but not roles
- **Error cases** — what should the system do when a related entity doesn't exist?
  when a unique constraint is violated? when a required external resource is unavailable?

**How to ask:**

- Ask one question at a time. Do not batch them.
- After each answer, restate the decision in one sentence, then ask the next question.
- If an answer eliminates a later question, say so and skip it.
- When all questions are resolved, say "All clear. Starting implementation."
- If there are no ambiguities, say "Spec is clear. No questions. Starting implementation."

---

## Step 5 — Implement

Work through tasks in this dependency order. After completing each file, tick its
checkbox in the plan file immediately.

**Implementation order:**

1. **DB migration** — ask before creating (`db/scripts/{NNN}_{description}.sql`)
2. **Domain entity** — `src/{AppName}.Logic/Domain/{Entity}.cs`
3. **DTOs** — `src/{AppName}.Logic/DTOs/{Module}/`
   One file per use case pair: `{UseCase}Request.cs` and `{UseCase}Response.cs`
4. **Use cases** — `src/{AppName}.Logic/Application/{Module}/`
   One class per operation. Verb+noun: `CreateProduct`, `ListProducts`, `UpdateProduct`.
5. **Repository interface** — `src/{AppName}.Logic/Repositories/I{Entity}Repository.cs`
6. **Repository implementation** — `src/{AppName}.Web/Infrastructure/Persistence/Repositories/`
7. **DI registration** — add to `ServiceCollectionExtensions.cs`
8. **Controller** — `src/{AppName}.Web/Controllers/{Module}Controller.cs`
   Thin: inject use case → `ExecuteAsync` → `FromResult`. No logic.
9. **TypeScript types** — `src/{AppName}.App/src/types/{module}.ts`
   Mirror backend DTOs exactly.
10. **Store** — `src/{AppName}.App/src/stores/{module}.ts`
    Only if this module needs shared state across components.
    If the store already exists (prior phase created it), open and read it before modifying.
11. **Composables** — `src/{AppName}.App/src/composables/use{Feature}.ts`
    Any multi-step logic or reusable behaviour extracted from components goes here.
12. **Page components** — `src/{AppName}.App/src/pages/{module}/`
    Thin templates: bind to store state, call store actions, render results.
    No conditional calculations, data transformation, or validation in `.vue` files.
13. **Routes** — add to `src/{AppName}.App/src/router/index.ts`
14. **Backend tests** — mandatory for every use case created or modified this phase.
    `tests/{AppName}.Logic.Tests/Application/{Module}/{UseCaseName}Tests.cs`
    If modifying an existing use case: read its test file first and update the affected cases —
    do not only append new ones. Apply the test conventions below without exception.
15. **Frontend store tests** — mandatory if step 10 created or modified a store.
    `src/{AppName}.App/src/stores/__tests__/{module}.test.ts`
    If the store file already existed: read the test file first, update tests for any changed
    actions, and add tests for new actions. Apply the test conventions below without exception.

**Rules while implementing:**
- Apply test conventions below without exception
- Ask before creating or modifying any file in `db/` or `docs/`
- If you find logic in a component during step 12, extract it first, then write the component

**Discovered gap protocol:**
If during implementation you find something the spec does not cover — a missing field, an
implicit business rule, an unclear error case — stop immediately. Do not guess.

State what was found:
```
Gap discovered: while implementing {UseCase}, I found that the spec does not cover
{specific gap}. This affects {which files/decisions}.

Options:
  A — {concrete option with implication}
  B — {concrete option with implication}
  C — Defer: add a TODO and skip for now
```

Wait for the user to choose. After they answer, update `docs/specs/{module}.md` to record
the decision before continuing. Ask before modifying the spec file.

---

## Test conventions

### Backend — xUnit + NSubstitute

**Location:** `tests/{AppName}.Logic.Tests/Application/{Module}/{UseCaseName}Tests.cs`
**Namespace:** `{AppName}.Logic.Tests.Application.{Module}`

One test class per use case. Standard structure:

```csharp
public class {UseCaseName}Tests
{
    private readonly I{Entity}Repository _repository = Substitute.For<I{Entity}Repository>();
    private readonly IRequestContext _context = Substitute.For<IRequestContext>();
    private readonly {UseCaseName} _sut;

    public {UseCaseName}Tests()
    {
        _context.UserId.Returns("user-1");
        _context.Role.Returns("Admin");
        _sut = new {UseCaseName}(_repository, _context);
    }

    private static {UseCaseName}Request ValidRequest() =>
        new("field1-valid-value", "field2-valid-value" /* all required fields */);

    // --- success path ---

    [Fact]
    public async Task Execute_WithValidRequest_ReturnsSuccess()
    {
        _repository.SomeMethod(Arg.Any<SomeType>()).Returns(expectedValue);

        var result = await _sut.ExecuteAsync(ValidRequest());

        Assert.True(result.IsSuccess);
        Assert.Equal(expectedValue, result.Data!.SomeField);
    }

    // --- validation ---

    [Theory]
    [InlineData("")]
    [InlineData("   ")]
    [InlineData(null)]
    public async Task Execute_WithInvalidName_ReturnsValidationFailure(string? name)
    {
        var result = await _sut.ExecuteAsync(ValidRequest() with { Name = name });

        Assert.False(result.IsSuccess);
        Assert.Equal(400, result.ErrorCode);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    [InlineData(-9999)]
    public async Task Execute_WithNonPositiveAmount_ReturnsValidationFailure(int cents)
    {
        var result = await _sut.ExecuteAsync(ValidRequest() with { AmountCents = cents });

        Assert.False(result.IsSuccess);
        Assert.Equal(400, result.ErrorCode);
    }

    // --- business rules ---

    [Fact]
    public async Task Execute_WhenEntityNotFound_ReturnsNotFound()
    {
        _repository.GetByIdAsync(Arg.Any<int>()).Returns((Entity?)null);

        var result = await _sut.ExecuteAsync(ValidRequest() with { Id = 99 });

        Assert.False(result.IsSuccess);
        Assert.Equal(404, result.ErrorCode);
    }

    // --- repository failures ---

    [Fact]
    public async Task Execute_WhenRepositoryThrows_ReturnsInternalError()
    {
        _repository.SomeMethod(Arg.Any<SomeType>()).Throws(new Exception("db error"));

        var result = await _sut.ExecuteAsync(ValidRequest());

        Assert.False(result.IsSuccess);
        Assert.Equal(500, result.ErrorCode);
    }

    // --- zero-call verification ---

    [Fact]
    public async Task Execute_WhenValidationFails_DoesNotCallRepository()
    {
        await _sut.ExecuteAsync(ValidRequest() with { Name = "" });

        await _repository.DidNotReceive().SomeMethod(Arg.Any<SomeType>());
    }
}
```

**Rules:**

- `[Theory]` + `[InlineData]` for 3+ variants of the same rule. Never duplicate `[Fact]` methods for the same scenario. Use `[MemberData]` for complex inputs.
- Naming: `Execute_{Scenario}_{ExpectedOutcome}` — no filler words.
- Coverage: happy path · each validation rule · each business rule · repository exception · zero-call check.
- Assert on `Result` state, not mock call counts.

### Frontend — Vitest + jsdom

**Tests only for stores. No component tests.**

All logic must live in `.ts` files — stores, composables, utility functions.
Vue components are thin templates: they bind to store state and call store actions.
Before writing any test, verify the logic is not in a component. If it is, extract it first.

**Location:** `src/{AppName}.App/src/stores/__tests__/{storeName}.test.ts`

**`vitest.setup.ts`** (wired in `vitest.config.ts` via `setupFiles`):

```typescript
import { vi } from 'vitest'

global.fetch = vi.fn()

afterEach(() => {
    vi.clearAllMocks()
})
```

**Store test structure:**

```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest'
import { setActivePinia, createPinia } from 'pinia'
import { use{StoreName}Store } from '../{storeName}'

describe('{StoreName} store', () => {

    beforeEach(() => {
        setActivePinia(createPinia())
    })

    const ok = (data: unknown) =>
        Promise.resolve(new Response(JSON.stringify(data), { status: 200 }))

    const fail = (status: number, detail: string) =>
        Promise.resolve(new Response(
            JSON.stringify({ status, detail, title: 'Error', type: 'error', instance: '/' }),
            { status }
        ))

    // --- fetch ---

    describe('fetchAll', () => {
        it('loads items and clears error', async () => {
            vi.mocked(fetch).mockResolvedValueOnce(ok([{ id: 1, name: 'A' }]))
            const store = use{StoreName}Store()
            await store.fetchAll()
            expect(store.items).toHaveLength(1)
            expect(store.error).toBeNull()
        })

        it('sets error when API fails', async () => {
            vi.mocked(fetch).mockResolvedValueOnce(fail(500, 'Server error'))
            const store = use{StoreName}Store()
            await store.fetchAll()
            expect(store.error).toBeTruthy()
        })
    })

    // --- create ---

    describe('create', () => {
        it.each([
            ['empty name',     { name: '' }],
            ['blank name',     { name: '   ' }],
            ['zero amount',    { name: 'ok', amountCents: 0 }],
            ['negative amount',{ name: 'ok', amountCents: -1 }],
        ])('rejects %s without calling API', async (_label, overrides) => {
            const store = use{StoreName}Store()
            const result = await store.create({ name: 'valid', amountCents: 100, ...overrides })
            expect(result.success).toBe(false)
            expect(fetch).not.toHaveBeenCalled()
        })

        it('adds item to store on success', async () => {
            vi.mocked(fetch).mockResolvedValueOnce(ok({ id: 2, name: 'B', amountCents: 500 }))
            const store = use{StoreName}Store()
            await store.create({ name: 'B', amountCents: 500 })
            expect(store.items).toHaveLength(1)
            expect(store.items[0].name).toBe('B')
        })

        it('surfaces conflict error from API', async () => {
            vi.mocked(fetch).mockResolvedValueOnce(fail(409, 'Already exists'))
            const store = use{StoreName}Store()
            const result = await store.create({ name: 'dup', amountCents: 100 })
            expect(result.success).toBe(false)
            expect(store.error).toContain('Already exists')
        })
    })

})
```

**Rules:**

- `it.each` for 3+ variants of the same rule. Never copy-paste tests.
- Mock only `fetch` — never store internals or Pinia getters.
- Assert on store state (`.items`, `.error`, `.loading`), not fetch call arguments.
- Always verify `fetch` was NOT called when client-side validation rejects early.

---

## Step 6 — Sync and close

Work through this checklist before reporting the phase complete. Do not skip any item.

### Docs sync

- [ ] **Spec in sync?**
  Every business rule, entity field, endpoint shape, UI behaviour, or authorization rule that
  was decided during Step 4b or discovered during Step 5 must be reflected in
  `docs/specs/{module}.md`. If any decision is missing, add it now. Ask before modifying.

- [ ] **Architecture in sync?**
  If any Active Convention was bent by necessity, or a new cross-cutting convention emerged
  (e.g. a new helper, a pattern reused across use cases), update `docs/architecture.md`.
  Ask before modifying.

- [ ] **Plan tasks all ticked?**
  Every checkbox in `docs/plans/phase-{N}-{module}.md` should be ticked.
  If any task was intentionally skipped or deferred, add a note next to it explaining why.

### Tests

- [ ] **Backend tests written or updated** for every use case touched this phase.
  Run `dotnet test` — all tests must pass before continuing.

- [ ] **Frontend store tests written or updated** if any store was created or modified.
  Run `npm run test:run` from `src/{AppName}.App` — all tests must pass before continuing.

If any test fails: fix it before moving on. Do not mark the phase done with failing tests.

### Status update

- [ ] Set frontmatter `status: done` in `docs/plans/phase-{N}-{module}.md`
- [ ] Update this phase's status to `done` in `docs/index.md`
- [ ] Tick the phase checkbox in `CLAUDE.md` → Current State
- [ ] Update "Next:" line to the next `not-started` phase, or
      "All phases complete — ready for QA" if none remain

Report when every box above is ticked:
```
Phase {N} — {Module} complete.
  Spec:    in sync
  Tests:   {N} backend · {M} frontend — all passing
  Docs:    plan ticked · index updated · CLAUDE.md updated
  Next:    Phase {N+1} — {NextModule}  (run /implement-phase to continue)
```
