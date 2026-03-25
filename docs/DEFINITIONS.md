# Definitions and naming

**Purpose:** Single place for **canonical product terms** and **workflow** so docs, UI copy, APIs, and the database stay aligned. When you introduce or rename a concept, **update this file** in the same change as [DOMAINS.md](./DOMAINS.md) / [VISION.md](./VISION.md).

**Related:** [VISION.md](./VISION.md) (north star), [DOMAINS.md](./DOMAINS.md) (domains + UI surface), [RULES.md](../RULES.md) (engineering / DB rules).

---

## Documentation and delivery workflow

1. **Explore / decide** — Flesh out behavior in [DOMAINS.md](./DOMAINS.md) (problem, in scope, dependencies). Use the **UI** section for cross-cutting screens.
2. **Stabilize one-liners** — When a concept is stable enough, promote a short formulation into [VISION.md](./VISION.md) (design principles or operating rhythm).
3. **Define terms here** — Add or adjust entries in **Glossary** and **Naming** below so everyone uses the same words.
4. **Data model** — For persistence: agree **MVP ERD** (e.g. `MVP-ERD.md` when created), then **idempotent** SQL per [RULES.md](../RULES.md) §7; **database is source of truth** once objects exist (§1).
5. **Validate** — After schema changes: `npm run validate` (and live DB checks as per project rules).

---

## Naming conventions (canonical terms)

Use these **preferred** forms in new writing and code (identifiers may use `snake_case` or `PascalCase` as your stack requires, but **meaning** should match).

| Preferred term | Also acceptable | Avoid / clarify |
|----------------|-----------------|-----------------|
| **Horizon ladder** | — | “Goal tree” alone (ladder is time-scoped); “nested lists” (ambiguous). |
| **Rung** | Horizon rung, timescale rung | “Level” if confused with goal hierarchy naming; prefer **rung** for the seven time scopes. |
| **Life tag** | — | Generic “tag” without context; ensure reader knows tags are **defined on Life rung** and **unique** there. |
| **Focus** (noun) | Current focus, **Focus element** | “Active task” without tying to short list rules. |
| **Short list** | — | Calling it only “task list” (too broad — backlog and Daily rung are also lists). |
| **Session** | — | **Auth / login session** in code — prefix or namespace (e.g. `WorkSession`) so it does not collide with this product meaning. |
| **Inter-session** | Between sessions | “Break” for the whole gap (confuses with **typed break**); “pause” alone (vague). |
| **Session activity type** | Session kind (TBD) | Pick one term when the enum is defined; align with existing **focus block** / **inbox triage** / **break** concepts. |
| **Work period** | Work block | Legacy pair with **block**; conceptually a **session** whose activity is **work-oriented** (focus or triage). Prefer **session** in new writing where **any** timed activity is meant. |
| **Focus block** | Focus work block, focus session | — |
| **Inbox triage block** | Inbox / capture triage (block), triage session | “Triage mode” without time-box when you mean only the **UI mode**. |
| **Between-blocks assessment** | Between work periods; **inter-session** ritual (work → work) | “Break” (typed **breaks** are separate, often their **own session** later). |
| **Between-blocks ritual** | — | “Assessment” alone when you mean the **ordered steps** specifically. |
| **Pre-break assessment** | — | — |
| **Capture** (domain) | — | “Inbox” as the **domain** name — **inbox** is the Capture **surface**. |
| **Inbox** | Inbox row, inbox item | — |
| **Daily life maintenance** | Daily maintenance list, life maintenance checklist | “Chores” in product copy if you want friendlier UX, but **specs** use **daily life maintenance**. |
| **Exercise snack** | — | “Micro-break” (confuses with typed **breaks**). |
| **Break** | Typed break | “Break” without type when you mean the three archetypes. |
| **Mental focus demand** | — | “Difficulty” or “priority” alone (different concepts). |
| **Deep focus** / **Flexible focus** | (values of mental focus demand) | — |
| **Day-part fit** | — | — |
| **Vision board** | — | “Mood board” only if you mean the same thing. |
| **Goal progress look-back** | — | — |
| **Planning** (domain) | — | “Lists” as domain name (too vague). |
| **Reflection** (domain) | — | — |
| **Ritual** | — | “Routine” in casual copy OK; spec prefers **ritual** for named, ordered sequences in-app. |
| **Horizon item** / **ladder item** | (data model TBD) | Mixing “task” for non-Daily rungs if it misleads — **item** is safer until ERD names entities. |

---

## Sessions and inter-session time

**Session** — Any **time-limited** period of activity in the app. You might be in **deep focus**, **inbox triage**, a **typed break**, a future **ritual** block, etc. — all are **sessions** once modeled. Duration is flexible per session; each session will eventually have a **session activity type** (or equivalent name — **TBD**, see naming table).

**Inter-session** — The **interval between** one **session** and the next: you are not inside a timed activity blob. This is usually where **assessment** surfaces run (triage, energy, choosing the **next** session).

**What we use today for “between sessions” (before the word *session* was canonical):**

| Term | Meaning |
|------|--------|
| **Between-blocks assessment** | The main **inter-session** flow **after** a **focus** or **inbox triage** **work period** and **before** the next one: **daily life maintenance**, Capture flush, **exercise snack**, **energy**, choice of next work block (type, focus, duration). **Block** = those **work** sessions in older wording. |
| **Between work periods** | Same idea in [VISION.md](./VISION.md) user-facing copy. |
| **Between-blocks ritual** | Ordered **steps** inside **between-blocks assessment** (not the whole gap by itself). |
| **Pre-break assessment** | **Inter-session** flow **before** a **break** session: pick **break type** from state / exhaustion. |
| **Assessment** (generic) | Any deliberate pause to triage or read state; **inter-session** is the **temporal** framing, **assessment** is the **purpose**. |

**Optional friendlier labels (UI copy):** **Transition** or **bridge** can label the inter-session screen; specs should still say **between-blocks assessment** / **pre-break assessment** / **inter-session** for precision.

**Session activity type** — Future first-class field or enum: which kind of **session** this is. Likely values will map to today’s **focus block**, **inbox triage block**, and **break** (and more later). Reuse an existing phrase (**work block type** extended) or introduce **session kind** — decide when modeling; document the chosen term here.

---

## Glossary

### A–E

**Assessment** — Deliberate pause to triage, read state, or choose what’s next. See **between-blocks assessment** and **pre-break assessment**.

**Between-blocks assessment** — Primary **inter-session** flow **after** a **work** session (focus or inbox triage **block**) and **before** the next. Hosts **daily life maintenance**, capture flush, **exercise snack**, **energy** check, and choice of **next work block** (type, focus, duration). Not a long **break**.

**Between-blocks ritual** — Recommended **ordered steps** during **between-blocks assessment** (maintenance → flush → snack → energy → next block).

**Break** — Longer recovery period, one of **three break types**, chosen from **pre-break assessment** (and energy), distinct from **exercise snack**.

**Capture** — Domain for **fast, minimal-structure** intake. Primary surface: **inbox**.

**Day-part fit (soft)** — Product encouragement to align **deep-focus** work earlier in the day and **flexible-focus** later; never hard-enforced.

**Deep focus** — A value of **mental focus demand**: work that needs sustained attention; suffers when distracted.

**Emotional reward** — One of **three break types**: restores positive affect / meaning / pleasure.

**Energy (domain)** — Lightweight check-in on physical / mental / emotional dimensions; informs next block length (optional) and **break** choice.

**Exercise snack** — Under **one minute** of movement during **between-blocks** ritual; **not** a full **break**. Often logged (what + how well).

**Exercise logging** — Recording which exercise and quality/effort for trends and motivation.

**Flexible block length** — User chooses duration per **work period**; shorter blocks when tired are expected.

**Flexible focus** — A value of **mental focus demand**: work that still works with a more scattered mind.

**Focus** / **Focus element** — The **single** task receiving attention during a **focus block**; must sit on the **short list** (almost always **Daily** rung).

**Focus block** — **Work period** type: timer tied to one **Focus** on the short list.

### G–L

**Goal hierarchy (domain)** — Formal name of domain §5 in [DOMAINS.md](./DOMAINS.md); product language centers on **horizon ladder**.

**Goal progress look-back** — Periodic review of progress toward ladder / life commitments; entry from **Reflection** and optionally **vision board**.

**Horizon ladder** — Seven **rungs** from **Life** → **Multi-year** → **Yearly** → **Quarterly** → **Monthly** → **Weekly** → **Daily**; **one list per rung** (v1); spine of navigation and meaning.

**Inbox** — Capture surface: large text + keys + optional **attachments**; **no** “when arrived” timestamp by product intent.

**Inbox triage block** — **Work period** / **session** type: dedicated UI to parse **Capture** onto **horizon ladder**, **Daily** tasks, **Life tags**, **vision board**.

**Inter-session** — Time **between** two **sessions**; see **Sessions and inter-session time** above.

**Life (rung)** — Top of **horizon ladder**; open-ended commitments; defines **Life tags**.

**Life tag** — User-defined label on a **Life** rung item, **unique** across Life items (v1); **attached** to items on **Daily** through **Multi-year** to show which north star they serve.

### M–Z

**Mental focus demand** — Classification of how much uninterrupted attention a task needs: **deep focus** vs **flexible focus**.

**Mental rest** — One of **three break types**: cognitive downshift.

**Physical rest / rejuvenation** — One of **three break types**: body and sensory recovery.

**Planning** — Domain for structured work: **horizon ladder**, **short list**, **daily life maintenance**, **mental focus demand**, triage from Capture.

**Pomodoro-like** — Time-boxed work periods plus assessment and breaks; spiritual cousin to Pomodoro, with our **flexible** lengths and rituals.

**Pre-break assessment** — Choosing **break type** from exhaustion and state before entering a **break**.

**Priority rank** — Ordering of items **within** a single **rung** list.

**Reflection** — Domain for closing the loop: prompts, trends, **look-backs**, exercise/work-block history; later **achievements** / gamification.

**Ritual** — Named **ordered** group of steps (tasks); can be morning flow, or embedded in **between-blocks ritual**.

**Session** — Any **time-limited** activity period in the product; see **Sessions and inter-session time**. **Session activity type** (or chosen synonym) will classify kind — **TBD**.

**Session activity type** — What kind of **session** (focus, triage, break, …); enum / model **TBD** — align with **focus block**, **inbox triage block**, **break**.

**Rung** — One of the seven timescales on the **horizon ladder** (Life … Daily).

**Short list** — At most **three** tasks: **one** highlighted **Focus**, up to **two** others; primary execution surface; usually sourced from **Daily** rung.

**Three break types** — **Mental rest**, **physical rest / rejuvenation**, **emotional reward**.

**Trust during work** — During a **focus block**, new inputs go to **Capture** / queue; full triage waits for **assessment**.

**Vision board** — Inspiration surface: media linked to **Life** / long-horizon items; optional **look-back** entry.

**Work block** — See **work period**; may be **focus block** or **inbox triage block**.

**Work block tracking (optional)** — Logging planned/actual duration and counts for motivation (non-punitive).

**Work period** — Bounded stretch of **work**: either **focus block** or **inbox triage block**, with flexible duration. A **session** in the **work** category (contrast **break** session when modeled).

**Daily life maintenance** — User-edited **basic upkeep** items resetting each **calendar day** (or user day boundary); shown on **between-blocks** UI; **not** on **short list** by default.

---

## Domain quick reference

| Domain | One-line role |
|--------|----------------|
| **Capture** | Fast inbox; unstructured text + attachments. |
| **Planning** | Ladder, short list, daily maintenance, triage outcomes. |
| **Rituals and habits** | Ordered sequences; **between-blocks ritual** template. |
| **Focus** | Single **Focus** on short list; hero UI. |
| **Goal hierarchy (horizon ladder)** | Seven rungs, one list each, **Life tags**. |
| **Time and focus** | Work periods, assessment, transitions to **breaks**. |
| **Energy and wellbeing** | Check-ins; informs blocks and breaks. |
| **Breaks** | Three typed recovery archetypes. |
| **Inspiration** | Vision board; ladder-linked media. |
| **Reflection** | Look-backs, trends, later achievements. |
| **UI (product surface)** | Cross-cutting layout and behavior (not a data domain). |

---

## Changelog

| Date | Change |
|------|--------|
| *today* | Initial **DEFINITIONS.md**: naming table, glossary, workflow, domain quick reference. |
| *today* | **Session** (time-limited activity); **inter-session**; mapping to **between-blocks assessment** / **between work periods** / **pre-break assessment**; **session activity type** TBD. |
