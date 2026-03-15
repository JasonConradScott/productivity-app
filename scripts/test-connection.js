/**
 * Test SQL Server connection. Run: node scripts/test-connection.js
 * Requires .env with DB_SERVER, DB_USER, DB_PASSWORD, DB_NAME (or set env vars).
 */

const db = require('../lib/db-client');

async function main() {
  console.log('Testing SQL Server connection...');
  console.log('Config:', { server: db.sqlConfig.server, database: db.sqlConfig.database, user: db.sqlConfig.user });
  try {
    const info = await db.testConnection();
    console.log('OK. Database:', info.db);
    console.log('Version:', info.version.split('\n')[0]);
  } catch (err) {
    console.error('Failed:', err.message);
    process.exit(1);
  }
}

main();
