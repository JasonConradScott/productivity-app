# Rules Review: What to Port and What to Skip

Review of **RULES.md** and **.cursor/rules.json** from my-webpage for porting to productivity-app. Identifies issues, contradictions, and items to drop or adapt.

---

## 1. Do NOT port (or replace entirely)

### 1.1 PostgreSQL / game-engine specifics
- **RULES.md section 0 (Database Tool Priority)**  
  - References: `PostgreSQL`, `psql-simple.js`, `db-query-util.js`, `psql.bat`, `PGPASSWORD`, port `5432`, `game_db`, `game-engine/` paths.  
  - **Action:** Do not copy as-is. Port only the *principle*: “Use Node.js tools first for DB operations, then API if applicable, then raw CLI last.” Rewrite using this project’s scripts (e.g. `lib/db-client.js`, `npm run test-db`, future validator).

- **RULES.md section 1.6 and elsewhere**  
  - “Required Tool: `game-engine/code-schema-validator.js`”, “Navigate to game-engine”, “node code-schema-validator.js”.  
  - **Action:** Do not port those paths. Refer instead to “the project’s schema validation script” (e.g. `npm run validate` or `node scripts/validate-schema.js` once it exists).

- **.cursor/rules.json Rule 8 (Project Context)**  
  - “Gods Game”, “Dynamic Demiplane Map”, “hexagonal grid”, “Express.js, MSSQL, vanilla JavaScript” in a game context.  
  - **Action:** Do not port. Replace with: “Productivity app with SQL Server analysis and validation tools; may be used with or without a web frontend.”

- **RULES.md section 10.5 last paragraph**  
  - “This rule would have prevented the advantage loading bug…”  
  - **Action:** Drop; it’s a game-specific anecdote.

### 1.2 Hardcoded credentials
- **RULES.md section 9.1**  
  - Example includes: `user: 'GodsSQLUser'`, `password: 'Gack31415'`, `server: 'DESKTOP-EEUSAQH'`.  
  - **Action:** Do not port the example with credentials. Replace with “use project `db-config` / `.env`” and a generic example that reads from config/env.

### 1.3 Procedure/schema helper names that may not exist here
- **RULES.md section 2**  
  - “sp_GetProcedureDefinition”  
  - **Action:** In SQL Server the standard approach is `OBJECT_DEFINITION(OBJECT_ID('procedure_name'))`. Use that (or “project’s get-procedure script”) instead of assuming a custom `sp_GetProcedureDefinition`.

- **.cursor/rules.json Rule 2 and Rule 5**  
  - “sp_GetTableDefinition”  
  - **Action:** If productivity-app does not have this proc, do not require it. Prefer “use project schema discovery (`getTableStructure` / `getTableColumns` from lib/db-client.js) or system table queries”.

---

## 2. Port with careful adaptation

### 2.1 “All DB through stored procedures” vs toolkit usage
- **.cursor/rules.json Rule 1**  
  - “All database operations must be performed through stored procedures. Direct table access is prohibited.”  
  - **Issue:** This project *is* a toolkit. Scripts and validators need to query `sys.*` and possibly application tables for schema discovery and validation. A strict “no direct table access” would forbid that.  
  - **Action:** Qualify the rule. For example: “*Application and API* database operations must use stored procedures where applicable. Schema discovery, validation scripts, and analysis tools may query system catalogs (e.g. sys.tables, sys.columns) and tables as needed.” So: port the principle for “app/API” layer; allow direct queries for tooling.

### 2.2 PowerShell / Cursor terminal behavior
- **RULES.md opening sections and 0.5**  
  - No `&&`, use separate commands, `is_background: true` for non-navigation, avoid long commands in foreground.  
  - **Issue:** Written for Cursor’s `run_terminal_cmd` and Windows PowerShell. Environment-specific.  
  - **Action:** Port as a short “Cursor on Windows” / “Terminal” subsection: “When using the terminal in Cursor on Windows: use separate commands instead of `&&`, run long or DB/validation commands in the background to avoid buffer/session issues.” Omit internal API details like `run_terminal_cmd`; keep it human- and AI-readable. If the app is also used on Linux/Mac or outside Cursor, note that these are optional for that environment.

### 2.3 UI/DOM-specific rules (only when you have a frontend)
- **RULES.md section 6.1 (DOM Reference Tracking)**  
  - querySelector, button state, edit/cancel workflows.  
  - **Action:** Only relevant when this repo contains a web UI that does dynamic DOM updates. Port under a “When building a web UI” or “Frontend” section, or keep in a separate doc so the core rules stay toolkit-agnostic.

- **RULES.md section 7 (UI/UX Rules)**  
  - Forms, responsive design, edit/delete, cancel.  
  - **Action:** Same as above: port only if/when the project has a UI; otherwise skip or file under “Future / when adding a frontend”.

- **RULES.md section 5 (Database Integration) – “Frontend Requirements”**  
  - **Action:** Keep as “when the app exposes a frontend”; optional for a scripts-only setup.

---

## 3. Possible issues (review before enforcing)

### 3.1 Code reuse (Rule 6 in rules.json)
- “During rapid development and prototyping phases, minimize code reuse to reduce the risk of introducing bugs.”  
  - **Issue:** Deliberately limiting reuse can conflict with DRY and shared libs (e.g. one `db-client.js` used everywhere).  
  - **Action:** Do not port. We do not want to prevent code reuse. RULES.md §12 encourages reuse and shared modules; we do not discourage reuse.

### 3.2 sp_GetTableDefinition (rules.json Rule 5)
- “Always use sp_GetTableDefinition stored procedure to validate table structures.”  
  - **Issue:** That may be a custom proc in the game DB. Productivity-app uses `lib/db-client.js` and `sys.*` queries.  
  - **Action:** Do not require `sp_GetTableDefinition`. Use: “Use the project’s schema discovery (e.g. getTableStructure, getTableColumns) or SQL Server system queries to validate table structures before schema or stored procedure changes.”

### 3.3 Naming convention for stored procedures (RULES.md section 4)
- “sp_Get[EntityName]”, “sp_Add[EntityName]”, “sp_” prefix, PascalCase.  
  - **Action:** Port as a *recommendation*, not a hard requirement, in case other conventions are used elsewhere. E.g. “Consider naming conventions such as sp_Get*, sp_Add*, sp_Update*, sp_Delete*.”

---

## 4. Safe to port as-is (concepts)

- **Database structure verification first** (RULES.md §1): Verify tables, columns, keys, procedures from the live DB before code changes; document discrepancies. SQL Server queries (sys.columns, sys.types, OBJECT_DEFINITION) are already correct.
- **Automated schema validation** (RULES.md §1.6): Run validator at session start, after schema changes, and before commit; zero critical issues before proceeding. (Use generic script name.)
- **Three-layer consistency** (RULES.md §2, rules.json Rule 2): Frontend ↔ API ↔ DB naming and types aligned; verify procedure definitions before implementing callers.
- **Pre-development database analysis** (RULES.md §3): Database-first order (DB → API → UI); check tables and procedures before writing dependent code.
- **Stored procedure retrieval** (RULES.md §4, §9): Prefer Node scripts; use `sys.sql_modules` (or OBJECT_DEFINITION); avoid truncated output; no hardcoded credentials.
- **SQL script safety** (rules.json Rule 4): Scripts idempotent / safe to run multiple times.
- **Schema investigation** (rules.json Rule 3): Check SQL Server schema first; don’t rely only on code or docs.
- **Endpoint–procedure validation** (rules.json Rule 2): Get and review procedure definition (e.g. OBJECT_DEFINITION) before implementing an endpoint that calls it.
- **API endpoint separation and data minimization** (RULES.md §10): One purpose per endpoint; return only needed data; document purpose and fields.
- **Security** (RULES.md §8): Auth, session, roles, secure endpoints.
- **Case sensitivity** (RULES.md “Rule 1.5”): Match JavaScript property names to SQL Server column casing where it matters.
- **Code style and error handling** (rules.json 9 & 10, RULES.md §5–6): Consistent structure, error handling, logging.
- **Rule management** (rules.json Rule 7): Add rules that prevent mistakes and are broadly applicable; avoid overly situation-specific or redundant rules.

---

## 5. Summary table

| Item | Action |
|------|--------|
| PostgreSQL, psql, game-engine paths | Do not port; rewrite for MS-SQL and this repo’s scripts. |
| Gods Game / Rule 8 project context | Do not port; replace with productivity-app context. |
| Hardcoded credentials in examples | Do not port; use config/env only. |
| sp_GetTableDefinition / sp_GetProcedureDefinition | Do not require; use lib/db-client or OBJECT_DEFINITION/sys.*. |
| “All DB through stored procedures” | Port only for app/API; allow direct queries for tooling. |
| PowerShell / background execution | Port as short “Cursor on Windows” guidance; no internal API details. |
| DOM / UI rules (6.1, 7, frontend bits of 5) | Port only when/if the project has a web frontend. |
| Code reuse (Rule 6) | Do not port. RULES.md §12 encourages reuse; we do not prevent or discourage reuse. |
| sp_ naming convention | Port as recommendation, not mandatory. |
| Everything in §4 above | Port with the adaptations noted (generic script names, no custom procs). |

---

## 6. Re-assessment: Windows and MS SQL Server only

The project is **strictly Windows** and **strictly MS SQL Server**. That was clarified in **RULES.md** (platform note at top, §14 Project context, and §15 Terminal usage). Re-assessment of "Port with adaptation" and "Possible issues":

### Port with adaptation (re-assessed)

| Item | Re-assessment |
|------|----------------|
| **2.1 Stored procedures vs toolkit** | Unchanged. Already ported in RULES.md §6: app/API use stored procedures where applicable; schema discovery and validation scripts may query `sys.*` and tables. No change for Windows/SQL-only. |
| **2.2 PowerShell / terminal** | **Now fully in scope.** Platform is Windows, so PowerShell is the default shell. Ported as a full rule in **RULES.md §15 (Terminal usage on Windows)**. No longer "optional" or "if Linux/Mac"; it applies whenever using the terminal on this project. |
| **2.3 UI/DOM rules** | Unchanged. Port only when the project has a web frontend; keep core rules toolkit-agnostic until then. |

### Possible issues (re-assessed)

| Item | Re-assessment |
|------|----------------|
| **3.1 Code reuse** | **Do not port** the "minimize code reuse" rule. RULES.md §12 explicitly encourages code reuse and use of shared modules (e.g. `lib/db-client.js`); we do not prevent or discourage reuse in this rules set. |
| **3.2 sp_GetTableDefinition** | Unchanged. We do not require any custom proc. RULES.md uses "project schema discovery (getTableStructure, getTableColumns) or SQL Server system queries" only. |
| **3.3 Stored procedure naming** | Unchanged. Port as recommendation only (e.g. sp_Get*, sp_Add*); not mandatory. |

### Clarifications now in RULES.md

- **Platform:** Opening of RULES.md states Windows only, MS SQL Server only; PostgreSQL, other DBs, Linux, macOS out of scope.
- **§14 Project context:** Explicitly says "Node.js and MS SQL Server on Windows."
- **§15 Terminal usage on Windows:** Full PowerShell/terminal guidance (no `&&`, separate commands, background for long/heavy commands, correct paths). No Cursor-internal API details; human- and AI-readable.

---

## 7. Recommended next step (done)

RULES.md was created and has been updated to:

1. State platform (Windows, MS SQL Server only) at the top and in §14.
2. Include the PowerShell/terminal rule as §15.
3. Omit or replace everything in the "Do NOT port" list.
4. Resolve "Possible issues" as above (no sp_GetTableDefinition requirement; code reuse not added as a blanket rule; naming as recommendation).
5. Keep UI/DOM rules out of the core rules until the project has a frontend.
