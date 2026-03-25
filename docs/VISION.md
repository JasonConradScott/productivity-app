# Product vision (product anchor)

This document is the **north star** for the personal productivity app. It will **grow** as we refine [DOMAINS.md](./DOMAINS.md)—when a domain clarifies scope or intent, fold the key points back here so this page stays the single summary.

---

## Who it is for

- **Personal use only** — one person, not teams or shared workspaces.
- Built for someone who wants **today’s work to stay connected to what matters long-term**, including **life-level aspirations**.
- A core outcome is **building better life habits over time** — not only logging tasks, but **repeating meaningful sequences** until they become easier and more automatic (ideas compatible with *Atomic Habits*–style thinking: small steps, stacking, consistency).

---

## What “a productive day” means (working definition)

A productive day is one where you:

1. **Move meaningful work forward** along the **horizon ladder** — from **daily** execution up through **life** — not only clear a random list. The **short list** (**at most three** tasks) stays the **primary execution** UI: **current focus** **highlighted**, **at most two** others, so attention is not split. **Life-level priorities** stay visible through **Life tags**: **unique user-defined** labels on **Life** rung items that you **add** to work on lower rungs (see [DOMAINS.md](./DOMAINS.md) §5), not duplicate lists per theme. Tasks carry **mental focus demand**; the product **encourages** **deep-focus** work **earlier** in the day and **flexible-focus** **later** — guidance, not a hard rule.
2. **Sustain physical, mental, and emotional energy** through the day — productivity includes **recovery**, not endless grinding.
3. **Reduce drain from worry** by capturing commitments and seeing them **in context** on the **horizon ladder** (time scope + **Life tags** linking execution to north stars).
4. **Strengthen habits** by running **rituals** — repeatable, ordered sequences (e.g. morning routine) that compound when tracked and reflected on.
5. **Feel momentum** over time — through visible progress (exercise, focus blocks, ladder wins) and, **eventually**, light **achievements** and **gamification**-style rewards tied to **your** goals — not a generic scoreboard (see design principles).

*Refine this paragraph as domains (especially Energy, Breaks, **horizon ladder**, and Rituals) get sharper.*

---

## Operating rhythm: trust, work periods, assessment, breaks

We use **session** for any **time-limited** stretch of activity (focus, triage, break, etc.); the **gap between sessions** is **inter-session** time, where **assessment** usually runs — see [DEFINITIONS.md](./DEFINITIONS.md) (**Sessions and inter-session time**). Older docs still say **work period** / **work block** for work-oriented timed stretches; those align with **work sessions** once **session activity types** are enumerated.

The app centers on a **Focus element**: **one task** you concentrate on **without distraction**, similar in spirit to the **Pomodoro technique** — **work periods are time-limited** so you do not run until exhaustion. **Block length is flexible:** as you **tire**, you can choose **shorter** upcoming blocks (and longer ones when you have bandwidth) — not a single rigid timer for every day. Optionally, the app **records how long each block ran** (planned vs actual if useful) so you can **see progress**: over time, many users will want to **grow** both the **number** of blocks and their **size** per day; **tracking** supports **motivation** and a **sense of achievement**, in the same spirit as logging exercise improvement.

**Trust during focus:** While you are in a work period on the current focus, you **trust the system** that **interruptions and new tasks will be addressed later** — during **assessment / reflection periods** between blocks — not by derailing the block you are in. **Capturing** something incoming should take **only a moment** (brief text, optional **drop** of a file); **parsing** it into lists, goals, and milestones happens in **reassessment** or in a dedicated **inbox triage work block** (see [DOMAINS.md](./DOMAINS.md) **UI** and **Time and focus**).

**Between work blocks** — when deciding **what to do in the next work period** — the app supports a **ritual** (ordered steps), typically:

0. **Daily life maintenance** — a **fixed** list of basic upkeep (meds, meals, household minima, etc.) **resets each day** and appears **here** (not on the **short list** during focus) so it stays in view during transitions — see [DOMAINS.md](./DOMAINS.md) **Planning** and **Rituals**.
1. **Assess interruptions** that arrived during the last work period → ensure they live in **Capture** (or quick merge from queue) — **heavy triage** into lists / goals can wait for the next **inbox triage block** or continue in assessment if you prefer.
2. **Exercise snack** — a **very short** (&lt; 1 minute) burst of movement to support **mental focus** and **physical health** (not a full break).
3. **Assess energy** — quick read of physical / mental / emotional state (and type of depletion).
4. **Choose the next work block** — pick the **next focus** / task and **how long** the next bounded work period should be (shorter when depleted; flexible presets or custom — see design principles).

After that (or on a separate cadence), you still **choose a typed break** when it is time for deeper rest — see below.

**Assessment periods** (also used before longer breaks) are where you:

- Finish **triage** if not already done in the between-blocks ritual.
- **Read your current state** — including **what kind of tired you are** (mental, physical, emotional) — to **choose the next break type** when you are transitioning to a **break**, not only to the next work block.

**Breaks** are one of **three basic types** (see [DOMAINS.md](./DOMAINS.md)):

1. **Mental rest** — recovery for cognitive load.  
2. **Physical rest / rejuvenation** — body and energy restoration.  
3. **Emotional reward** — positive affect, meaning, or pleasure that restores the emotional side.

The **type of break** is determined during **pre-break assessment** from **current state** and **type of exhaustion**, not at random.

**Exercise snacks vs breaks:** **Exercise snacks** are **under one minute**, happen **during assessment between work blocks**, and aim to **prime focus and health**. They are **not** the same as the three **break** archetypes (which are longer, deeper recovery).

**Exercise logging and improvement:** The user can **record which exercises they did** and **how well they did** (e.g. reps, duration, effort / difficulty, or a simple “felt strong → weak” scale). Over time, **trends and personal bests** support **motivation** — seeing improvement reinforces the habit loop alongside work and ritual completion.

---

## Habits and rituals (alongside Pomodoro-style rhythm)

**Pomodoro-like** structure (time-boxed work, assessment, typed breaks) addresses **attention and exhaustion** during focused work. Separately, the app supports **habit formation** through **rituals**.

**Rituals** are **named groups of ordered tasks** — for example a **morning ritual**: get up → brush teeth → take pills → walk the dog. They make **repeating the same sequence** easy to follow and track, which supports **better life habits** when combined with reflection and gentle consistency (conceptually aligned with *Atomic Habits*: clear steps, stacking small behaviors, identity-linked routines over time).

A **between-blocks ritual** is a first-class example: **daily maintenance checklist → triage interruptions → exercise snack → energy check → choose next work block** — so the transition between Pomodoro-style periods is **habitual** and **health-aware**, not ad hoc.

Rituals may run **outside** a single Pomodoro **Focus** block (e.g. a whole morning flow) or **between** work blocks as above — see [DOMAINS.md](./DOMAINS.md) **Rituals and habits**.

---

## Design principles

| Principle | Meaning |
|-----------|---------|
| **Goal context** | Executable work and commitments are placeable on the **horizon ladder** from **Daily → … → Life**; **Life tags** (defined on **Life** rung items, **unique** per item) are **reused** on lower rungs so **why** stays visible without theme-silo lists. |
| **Horizon ladder** | The **spine** of the product: **seven fixed rungs** (**Life** through **Daily**), **one ranked list per rung**, **evocative board titles**, and **Life tags** — user-defined on **Life** items, **attachable** on **Daily** through **Multi-year**. See [DOMAINS.md](./DOMAINS.md) §5. |
| **Minimal inbox** | **Incoming** items live in **Capture** as **almost unstructured** text (plus **identifiers** only as needed for storage). **No** “when it arrived.” **Entry must be fast** — minimal time away from deep work; **files/images** may be **dropped** onto the record. Content may be **tiny or huge**; later triage may **split** one capture into **many** tasks, a **goal**, or **vision board** material — see [DOMAINS.md](./DOMAINS.md) **Capture** and **UI**. |
| **One focus at a time** | Only **one** task is the **current focus** at any moment. |
| **Short list (max three)** | The **short list** holds **at most three** tasks: the **focus** task **highlighted**, plus **up to two** others. It is a **primary, prominent** surface in the UI (not buried in a long backlog view). **Structured** backlog lives in **Planning**; the **inbox** in **Capture** stays **deliberately minimal**; the short list is the **now / next** lens. **Daily life maintenance** basics appear during **between-blocks** assessment, **not** here by default. |
| **Daily life maintenance** | **Basic upkeep** items (user-defined) **reset each day** and show on the **between work periods** / assessment UI so life minima stay visible **outside** deep-focus blocks — see [DOMAINS.md](./DOMAINS.md) **Planning**. |
| **Mental focus demand** | Each task is classified by **how much sustained attention** it needs to be done **efficiently** — e.g. **deep focus** (fragile to distraction) vs **flexible focus** (a more scattered mind still works). This is **user-set** (or refined over time), not guessed by the app on day one. |
| **Day-part fit (soft)** | The app **encourages** scheduling **deep-focus** tasks **earlier** in the working day and **flexible-focus** tasks **later**, when concentration often wanes — **suggestions and visibility**, not blocking or shaming. The user can override anytime. |
| **Trust during work** | During a **work period**, interruptions and new work are **deferred** to **assessment** — the user trusts the system to hold and triage them so concentration stays on the Focus element. |
| **Time-boxed work** | **Work periods** are **limited in duration** (Pomodoro-like) to reduce exhaustion and make breaks predictable. |
| **Flexible block length** | **Duration is not fixed forever** — you pick (or adjust) length **per block** or from **quick presets**. **As you tire**, **smaller** blocks are expected and **supported**; no shame for shortening the day’s blocks. |
| **Work block tracking (optional)** | Optionally **log** each block’s **planned and/or actual** duration (and count). **Reflection** can show **daily** totals and **trends over time** — e.g. more blocks, longer focus, or steadier rhythm — to fuel **motivation** and **achievement**, without turning into punitive productivity scores. |
| **Assessment bridges work and rest** | **Between** work periods and breaks, **assessment** triages inputs, **re-prioritizes horizon-ladder rungs** and the **short list**, and **selects break type** from state and exhaustion. |
| **Whole person** | Track or surface **physical, mental, and emotional** dimensions where the product helps. |
| **Three break types** | Breaks are **mental rest**, **physical rest / rejuvenation**, or **emotional reward** — chosen to match how you are depleted. |
| **Exercise snacks** | **Under one minute** movement bursts during **between-blocks assessment** to boost **focus** and **physical health**; distinct from full breaks. |
| **Exercise progress** | **Log** each exercise (what you did + **how well** — effort, reps, time, or quality). Surface **improvement over time** to fuel **motivation**. |
| **Breaks matter** | Breaks are **planned and typed** (what they restore), not an afterthought or failure. |
| **Inspiration tied to the top** | Motivational assets (e.g. storyboard, images) link to **Life** and **long-horizon** ladder items, not generic wallpaper. |
| **Goal progress look-back** | From time to time, **look back** at **progress toward specific goals** (not only daily tasks). The **vision board** (see **Inspiration** in [DOMAINS.md](./DOMAINS.md)) should offer an **optional** path into that review — e.g. **per goal** or from the board — so reconnecting with *why* can include *how far you’ve come*. |
| **Rituals for habits** | **Named, ordered task groups** (rituals) support **life habits** over time; habits are a first-class outcome alongside daily focus and breaks. |
| **Achievements and gamification (later)** | **Eventually**, add **achievements**, **badges**, **milestones**, or **streaks** — in the spirit of apps like **Fitbit** — to **celebrate** consistency and progress on **focus**, **rituals**, **exercise**, and **horizon-ladder** outcomes. Must stay **opt-in friendly**, **non-punitive** (no shaming for off days), and **grounded in your ladder and Life tags**, not abstract points. **Not** required for MVP; complements **Reflection** and **Inspiration**. |
| **Database is source of truth** | When we build persistence, the live database defines structure; code and docs follow (see repo [RULES.md](../RULES.md)). |

---

## Top pains to solve (draft — edit as you learn)

1. *TBD — e.g. tasks disconnected from “why”*
2. *TBD — e.g. energy crashes / guilt about breaks*
3. *TBD — e.g. mental load / worry about forgotten work*

Replace these with your real top three as you work through domains.

---

## Non-goals (for early versions)

- Team collaboration, roles, or multi-user tenancy.
- Replacing a full calendar suite on day one (integrate or stub as domains clarify).
- A generic motivation feed with no link to **your** life goals.
- A full **achievement / gamification** system on day one — **later** phase; early versions may still use **trends** and **look-backs** (see **Reflection**) without badges or levels.

---

## Related docs

- [DOMAINS.md](./DOMAINS.md) — capability areas and problems each solves (active working doc).
- [DEFINITIONS.md](./DEFINITIONS.md) — glossary, naming, and workflow for consistent terminology.
- [RULES.md](../RULES.md) — engineering and data rules for this repo.
