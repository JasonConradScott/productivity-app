# Productivity & Development Tools Scan

Scan of **mics-analysis** and **my-webpage** for rules, tools, and patterns useful to port into this app (MS-SQL only).

---

## 1. mics-analysis (D:\FCSABIN\FCSA\C#\mics-analysis)

### Rules / Conventions
- **No dedicated RULES.md** in the repo root; project-specific rules appear in notes (e.g. business rules, sequential processing).
- **Documentation**: Strong emphasis on verifying **actual database schema** before changes; notes reference `db-util.js` and `test-ft-archive-columns.js` for schema verification.

### Tools (analyzer/ – all Node.js, SQL Server)

| Tool | Purpose |
|------|---------|
| **db-util.js** | **Primary CLI** – connection test, schemas, tables, describe/columns/keys, procs, **compare** (archive def vs actual table), ad-hoc query, interactive mode. Uses `db-config.js` + `mssql`. |
| **db-config.js** | SQL Server config (user, password, database, server, timeout). |
| **execute-sql-script.js** | Run SQL scripts (e.g. deployment); referenced in FT-FE findings. |
| **test-ft-archive-columns.js** | Validates archive table definitions vs actual DB (FT/FE tables). |
| **analyzer.js** | Code analysis utilities (separate from DB). |
| **config.js** | Code analyzer configuration. |
| **report-generator.js** | Code analysis report generation. |

### Useful to port (MS-SQL, productivity-app)
- **db-util.js**-style CLI: schema discovery, table describe/columns/keys, procs, **compare** (definition vs DB). Your `lib/db-client.js` already covers discovery; the **compare** pattern (expected vs actual) is what to add.
- **execute-sql-script.js** pattern for running .sql scripts (e.g. with GO batches).
- **test-ft-archive-columns.js** pattern: generic “expected columns vs live table” checker, reusable for any table set.

---

## 2. my-webpage (C:\my-webpage)

### Rules

**RULES.md** (root) – main development rules:
- **PowerShell**: No `&&`, use PowerShell-native commands; **always use `is_background: true`** for non-navigation commands to avoid buffer/session issues.
- **Database tool priority**: (1) Node.js tools, (2) API endpoints, (3) PowerShell/batch last resort.
- **Background execution**: All DB/validation/git/npm/node commands in background; only `cd` in foreground.
- **Database structure verification**: Verify live DB first (tables, columns, types, PKs, FKs, procs) before code recommendations; document discrepancies.
- **Automated schema validation**: Run `game-engine/code-schema-validator.js` at session start, after schema changes, and before commits (in my-webpage this was later superseded by `unified-validator.js`).
- **Three-layer architecture**: Pre-change checks (table definitions, stored procedure definitions); mandatory checklist before modifying any layer.
- **Endpoint–stored procedure validation**: Frontend fields ↔ API params ↔ stored procedure params aligned; validate with live schema (e.g. `sp_GetTableDefinition` / system tables).

**.cursor/rules.json** – structured rules (10 entries):
- Database operations via stored procedures; no direct table access.
- Endpoint–stored procedure validation (three layers: HTML ↔ API ↔ procs); verify with `OBJECT_DEFINITION(OBJECT_ID('proc'))` before implementing.
- Database schema investigation: check SQL Server schema first, not only code/docs.
- SQL script safety: scripts idempotent / safe to run multiple times.
- Schema validation: use `sp_GetTableDefinition` (or equivalent) to validate before schema or proc changes.
- Code reuse during early development: minimize to reduce cascading bugs.
- Rule management, project context (Gods Game, Express/MSSQL/vanilla JS), code style, error handling.

### Tools – game-engine/ (validation & DB query)

| Tool | Purpose |
|------|---------|
| **unified-validator.js** | **Primary validator**: DB schema + code vs DB + API coverage + frontend expectations + semantic patterns + **frontend route validation** (fetch vs server.js). Single command; replaces older multi-tool workflow. |
| **dynamic-api-discovery.js** | Shared module: parses `server.js` to discover API endpoints for a table (no hardcoded table→API map). Used by unified-validator. |
| **db-query-util.js** | CLI: `schema <table>`, schema+data; can mirror API `GET /api/db/schema/:table`. |
| **column_comparison_tool.js** | Column-level code vs DB comparison (absorbed into unified-validator but still present). |
| **false-positive-investigator.js** | Phase 2: investigate validator false positives (schema check, etc.). |
| **enhanced_api_tracker.js** | API coverage analysis. |
| **db-priority-reminder.js** | Reminds to use Node.js-first for DB. |
| **git-helper.js** | Git workflow helper (no raw git in terminal per rules). |
| **psql-simple.js** / **psql-wrapper.js** | PostgreSQL CLI helpers – **not for port** (you’re MS-SQL only). |
| Deprecated: `_deprecated_*-validator.js`, `_deprecated_code-schema-validator.js` | Replaced by `unified-validator.js`. |

### Tools – my-webpage root (DB/procedure helpers)

| Tool | Purpose |
|------|---------|
| **check-db.js** | DB check. |
| **get-table-structure.js** | Get table structure from DB. |
| **get-procedures.js**, **get-procedure.js**, **list-procedures.js** | Procedure listing/definition. |
| **create-update-procedure.js**, **get-add-procedure.js**, **get-update-advantage-proc.js**, **update-add-procedure.js** | Procedure generation/update helpers. |
| **check-advantages.js**, **check-advantage-list.js**, **check-kingdom-tables.js** | Domain-specific checks (advantages, kingdom tables). |

### Docs that define workflow
- **UNIFIED_VALIDATOR_GUIDE.md** – how to use unified-validator; session startup and pre-commit; what it catches (schema, columns, API coverage, frontend routes, types).
- **DATABASE_TOOL_PRIORITY.md** – Node.js first, then API, then PowerShell.
- **TWO_PHASE_VALIDATION_WORKFLOW.md** – Phase 1: unified-validator; Phase 2: false-positive-investigator.
- **ROBUST_VALIDATOR_ARCHITECTURE.md** – dynamic discovery, no hardcoded mappings, deprecated legacy tools.
- **SESSION_STARTUP_GUIDE.md**, **GIT_WORKFLOW_GUIDE.md**, **NODE_JS_FIRST.md** – session start, commit checklist, Node-first rule.
- **DATABASE_QUERY_README.md** – db-query-util and API schema endpoints.

### Useful to port (MS-SQL, productivity-app)
- **Unified-validator concept**: One script that does DB schema + code-vs-DB + API coverage + (optional) frontend route checks, using your `lib/db-client.js` and MS-SQL only (no PostgreSQL).
- **Dynamic API discovery**: Parse Express/server routes from code instead of hardcoding table→API map; reuse in validator.
- **Frontend route validation**: Compare HTML/frontend `fetch()` URLs and methods to server routes (if you have a frontend in this app).
- **Rules**: “Verify DB first”, “Node.js tools first”, “single pre-commit validator”, “three-layer consistency” – adapt into `.cursor/rules` or a RULES.md here.
- **db-query-util**-style CLI: `schema <table>`, optional schema+data, backed by `getTableStructure` / `getTableColumns` from `lib/db-client.js`.
- **Procedure helpers**: get/list procedure definitions (you have `getProcedures`; adding “get definition by name” would match get-procedure.js).

---

## 3. Summary: What to port into productivity-app

| Category | From | What to add / adapt |
|---------|------|----------------------|
| **DB discovery** | Both | Already in `lib/db-client.js`. Optional: CLI wrapper (db-util-style or db-query-util-style) so agents/humans can run `node scripts/db-util.js describe dbo.MyTable`. |
| **Definition vs DB** | mics-analysis | “Compare” step: expected columns/definition vs `getTableColumns`/`getTableStructure`. Script or function in lib. |
| **Expected columns vs DB** | mics-analysis, my-webpage | Generic checker: given list of expected columns per table, compare to live DB (like test-ft-archive-columns.js, but table-agnostic). |
| **Unified validator** | my-webpage | One script: (1) DB schema, (2) code vs DB, (3) API coverage, (4) optional frontend routes – all using `lib/db-client.js`, no PostgreSQL. |
| **Dynamic API discovery** | my-webpage | Module that parses server.js (or your API entrypoint) for routes; use in unified validator instead of hardcoded maps. |
| **Script runner** | mics-analysis | Execute .sql files (e.g. with GO batches) using your DB client; like execute-sql-script.js. |
| **Rules** | my-webpage | RULES.md + .cursor/rules: “verify DB first”, “Node tools first”, “single validator before commit”, “three-layer alignment”, SQL script safety. |

Your README already points to: script runner, definition-vs-DB, expected-columns-vs-DB, unified-validator, frontend route validation. This scan aligns with that and names the exact tools and rules in the two source projects to reuse or adapt.
