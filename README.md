# productivity-app

Productivity app with shared SQL Server analysis and validation tools. New repo on D: drive; incorporates patterns from mics-analysis and my-webpage (SQL Server only, same capabilities as the former PostgreSQL game-engine validators).

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

## Structure

- **lib/db-config.js** – SQL Server config from env (dotenv). Do not commit `.env`.
- **lib/db-client.js** – Shared DB API: `connect`, `disconnect`, `getSchemas`, `getTables`, `getTableStructure`, `getTableColumns`, `getAllTableNames`, `getDatabaseSchema`, `getProcedures`, `testConnection`. All use `mssql` + `sys.*`.
- **scripts/** – One-off scripts (e.g. test-connection).

Next: script runner (execute .sql with GO batches), definition-vs-DB and expected-columns-vs-DB checks, then unified-validator and frontend route validation (all using this client).
