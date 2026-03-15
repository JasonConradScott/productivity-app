# Productivity App Development Rules

Rules for SQL Server–backed development in this project. These were ported from proven practices in related projects and adapted for MS-SQL and this toolkit.

**Platform:** This project targets **Windows only** and **MS SQL Server only**. PostgreSQL, other databases, Linux, macOS, and cross-platform or multi-database support are out of scope. All examples, tooling, and rules assume Windows and SQL Server.

---

## 1. Database as source of truth and three-layer alignment

**The database is the source of truth.** When checking three-layer alignment (frontend ↔ API ↔ database), always check the database **directly**—using the live database and this project’s schema discovery (e.g. `lib/db-client.js`: `getTableStructure`, `getTableColumns`, `getProcedures`) or SQL Server system queries—**not** via documentation, comments, or assumptions from code.

**If something is out of alignment with the database structure, change the other thing, not the database.** When code, API, or frontend expectations disagree with the actual database (tables, columns, types, procedures), update the code, API, or frontend to match the database. Do not change the database to match code or documentation.

- Verify tables, columns, keys, and procedures from the live database before making code recommendations or changes.
- Document any discrepancies you find; then fix the non-database layers.
- Use SQL Server system tables (e.g. `sys.columns`, `sys.types`, `OBJECT_DEFINITION(OBJECT_ID('procedure_name'))`) or this project’s schema helpers when verifying structure.

---

## 2. Database structure verification first

Before any code recommendations or changes, the actual database structure must be verified. This is the first step in any database-related development.

- **What to verify:** Table existence and structure; column names, data types, and constraints; primary and foreign keys; stored procedure existence and definitions.
- **Only after verification:** Proceed with code recommendations, creating or modifying stored procedures, or other database-dependent changes.
- **Checklist:** Database structure verified before code recommendations; table structure confirmed from live database; stored procedure existence and definitions confirmed; no assumptions from code or docs alone; findings documented.

---

## 3. Automated schema validation

In addition to manual verification, run the project’s schema validation (e.g. `npm run validate` or the validation script in `scripts/`) when available:

- At the start of each development session.
- Immediately after any database schema changes.
- Before committing database-related code.

Success criteria: zero critical issues before proceeding. Address critical issues immediately; document and plan resolution for high-priority issues.

---

## 4. Three-layer consistency

Keep naming and types consistent across:

1. **Frontend** – Form fields, data attributes, and client-side variables match API parameters and database column names.
2. **API** – Endpoints and parameters match stored procedure parameters and return shapes.
3. **Database** – Tables and procedures define the canonical structure (see §1).

- Before changing any layer, check table and procedure definitions using the live database (or this project’s schema tools).
- Parameter and column names must match exactly across layers; data types must be consistent.
- When implementing an endpoint that calls a stored procedure, get and review the procedure definition (e.g. `OBJECT_DEFINITION(OBJECT_ID('procedure_name'))`) first.

---

## 5. Pre-development database analysis (database-first order)

- Database objects must be created and verified **before** dependent code (API or UI).
- Order of operations: (1) Database – tables and procedures verified or created and tested; (2) API – endpoints only after DB is verified; (3) UI – only after API is verified.
- Before making code changes: examine current database structure (e.g. via schema discovery or system queries), review relevant procedure definitions, and understand data types and constraints.

---

## 6. Stored procedure retrieval and usage

- Prefer Node scripts (or this project’s tools) to retrieve procedure definitions so output is not truncated.
- Use `sys.sql_modules` or `OBJECT_DEFINITION(OBJECT_ID('name'))` for full definitions; avoid relying on truncated console output.
- Never embed real credentials in scripts; use project `db-config` and `.env` only.
- For application and API database operations, use stored procedures where applicable. Schema discovery and validation scripts may query system catalogs (e.g. `sys.tables`, `sys.columns`) and application tables as needed.

---

## 7. SQL script safety

All SQL scripts must be written so they can be run multiple times safely without errors. The goal is **idempotency where possible**: running the script once or ten times should leave the database in the same consistent state. That way deployments, migrations, and ad‑hoc runs don’t depend on “has this already been run?” and won’t break if someone runs the script again.

### Why it matters

- **Deployments and migrations** – Same script can be applied in dev, test, and prod without special “run once” logic.
- **Recovery and reruns** – A failed run can be fixed and the script re-run without “object already exists” or “column already exists” errors.
- **Consistency** – The database stays in a defined state regardless of current state when the script runs.

### Practical patterns (SQL Server)

- **Creating objects only if missing**  
  Use existence checks so creates don’t fail on re-run:
  - Tables: `IF OBJECT_ID('dbo.MyTable', 'U') IS NULL CREATE TABLE dbo.MyTable (...);`
  - Schemas: `IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'MySchema') EXEC('CREATE SCHEMA MySchema');`
  - Procedures/views: `IF OBJECT_ID('dbo.MyProc', 'P') IS NULL EXEC('CREATE PROCEDURE dbo.MyProc AS SELECT 1');` then `ALTER PROCEDURE` in a separate step, or use a single “create or alter” pattern if you have it.

- **Changing objects safely**  
  - Adding a column: check `sys.columns` (or `COL_LENGTH`) before `ALTER TABLE ... ADD`.
  - Dropping a column or object: check that it exists before `DROP` so the script doesn’t error on a second run.

- **Data updates**  
  Prefer patterns that give the same result on re-run:
  - `MERGE` for “insert or update” (upsert).
  - `IF NOT EXISTS (...)` around `INSERT` for one-time or reference data.
  - `UPDATE`/`DELETE` that are safe to repeat (e.g. keyed updates, or “set to X” rather than “increment by 1” unless that’s intended).

- **Avoid**  
  - Bare `CREATE TABLE` / `CREATE PROCEDURE` with no check (fails on second run).
  - `DROP TABLE` / `DROP PROCEDURE` without an existence check (fails if already dropped).
  - Assumptions like “this table is empty” or “this column doesn’t exist” without checking.

### Checklist

- [ ] Object creation guarded by existence checks (or equivalent “create or replace”).
- [ ] Object drops guarded by existence checks.
- [ ] Data changes written so re-running leaves data in the same intended state.
- [ ] No hardcoded credentials; use project config or environment.
- [ ] Script is documented (purpose, prerequisites, and that it’s safe to run multiple times).

### Script lifecycle: temporary vs versioned

- **Temporary execution or change scripts** (one-off scripts created during a session for a fix or ad-hoc migration): Delete them after they have been run successfully, and only after the change is committed or otherwise recorded. That keeps the workspace clear and avoids accidentally re-running a one-time change.
- **Versioned migration or change scripts** (scripts that live in the repo and are part of your release or migration process): Do not delete these after running. Keep them as the permanent record of what changed and in what order; they may be run in other environments or reviewed later.

---

## 8. Endpoint–procedure validation

Before implementing an endpoint that calls a stored procedure:

1. Get and examine the procedure definition from the database (e.g. `OBJECT_DEFINITION(OBJECT_ID('procedure_name'))`).
2. Ensure parameter names and types match the procedure signature, data types are used consistently, error handling is appropriate, and return format is consistent.
3. Implement the API and frontend to use the same names and types as the database and procedure.

---

## 9. API endpoint separation and data minimization

- Each endpoint should have a single, well-defined purpose.
- Return only the data needed for that use case; use separate endpoints for different data needs (e.g. list vs full details).
- Document each endpoint’s purpose, required fields, and return fields.

---

## 10. Security

- Authentication: login status, session handling, and user/role display as appropriate.
- Authorization: role-based access where needed; secure API endpoints; proper logout.
- Validate and sanitize inputs; use secure connections and avoid exposing credentials.

---

## 11. Case sensitivity (SQL Server and JavaScript)

SQL Server column names are case-insensitive by default; JavaScript property access is case-sensitive. Use consistent casing in the database and match it in JavaScript (and API contracts). Document expected property names where it helps.

---

## 12. Code style and error handling

- Clear separation of concerns; modular, maintainable code.
- **Code reuse is encouraged.** Use shared modules and utilities (e.g. `lib/db-client.js`) where they keep the codebase DRY and maintainable. Do not avoid reuse in order to reduce coupling during normal development.
- Consistent error handling and logging; meaningful error messages for users and developers.
- Use comments where they clarify intent or non-obvious behavior.

---

## 13. Rule management

When adding or changing rules:

- Prefer rules that prevent common mistakes, enforce best practices, and improve maintainability.
- Prefer rules that are broadly applicable rather than situation-specific.
- Avoid duplicating existing rules or encoding implementation details that belong in code comments.
- Discuss significant rule changes before adopting them.

---

## 14. Project context

This project is a productivity app with shared SQL Server analysis and validation tools. It may be used with or without a web frontend. The stack is Node.js and MS SQL Server on Windows; schema discovery and validation go through `lib/db-client.js` and project scripts.

---

## 15. Terminal usage on Windows (PowerShell)

Development and tooling run on Windows; the default shell is PowerShell. To avoid session freezes, buffer overflows, and parser errors when using the terminal (e.g. in Cursor):

- **Do not use `&&`** to chain commands. Run commands separately (e.g. one `cd`, then in a second step the `node` or `npm` command).
- **Use PowerShell-native commands** where possible (e.g. `Get-ChildItem`, `Select-String`) instead of Bash-style `ls`, `grep`.
- **Run long or heavy commands in the background** when the environment supports it—especially database operations, schema validation, `npm install`, or any command that can produce a lot of output. Reserve foreground for simple navigation (e.g. `cd`).
- **Use full or correct paths** when invoking scripts (e.g. `node scripts/validate-schema.js` from the project root) so the right directory is used.

If a command appears to hang or the session prompts to move to background, use background execution for that type of command next time.
