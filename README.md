# productivity-app

Productivity app with shared SQL Server analysis and validation tools. **Windows only, MS SQL Server only.** New repo on D: drive; incorporates patterns from mics-analysis and my-webpage (SQL Server only, same capabilities as the former PostgreSQL game-engine validators).

Development rules (database as source of truth, three-layer alignment, SQL script safety, etc.) are in **RULES.md**.

Product and domain documentation (vision, capability domains) is in **[docs/](docs/README.md)**.

## Setup

1. Clone or use this folder; install deps:
   ```bash
   npm install
   ```
2. Copy `.env.example` to `.env` and set your SQL Server connection:
   ```bash
   DB_SERVER=your_server
   DB_USER=your_user
   DB_PASSWORD=your_password
   DB_NAME=your_database
   DB_TIMEOUT=30000
   ```
3. Test connection:
   ```bash
   npm run test-db
   ```
4. Before making DB-related changes, run the unified validator:
   ```bash
   npm run validate
   ```
   To compare the database to an expected schema (JSON): `node scripts/unified-validator.js --expected path/to/expected.json`

## Structure

- **lib/db-config.js** – SQL Server config from env (dotenv). Do not commit `.env`.
- **lib/db-client.js** – Shared DB API: `connect`, `disconnect`, `getSchemas`, `getTables`, `getTableStructure`, `getTableColumns`, `getAllTableNames`, `getDatabaseSchema`, `getProcedures`, `testConnection`, `executeSql`. All use `mssql` + `sys.*`.
- **scripts/** – `test-connection.js` (connection test), `unified-validator.js` (schema validation, optional `--expected` JSON comparison), `validate-schema.js` (quick schema check), `run-sql-script.js` (run .sql files with GO batches).
- **RULES.md** – Development rules (platform, DB as source of truth, validation, script safety).
- **.cursor/rules/** – Cursor rule(s) that always apply; see RULES.md for full text.

**Scripts:**
- `npm run test-db` – Test SQL Server connection.
- `npm run validate` – Run unified validator (loads DB schema; use `--expected path.json` to compare).
- `npm run run-script -- path/to/script.sql` – Execute a .sql file (splits on GO).

Future: frontend route validation when the app has a web UI; optional API coverage checks in the validator.
