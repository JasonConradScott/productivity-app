/**
 * Minimal schema validation: verifies connection and that we can read schema from the database.
 * Run: npm run validate  or  node scripts/validate-schema.js
 * Exit 0 if DB is reachable and schema is readable; exit 1 otherwise.
 * Full definition-vs-DB and unified-validator checks will be added later.
 */

const db = require('../lib/db-client');

async function main() {
  try {
    await db.connect();
    const schemas = await db.getSchemas();
    await db.disconnect();
    console.log('Schema validation OK: connected,', schemas.length, 'schema(s) with tables.');
    process.exit(0);
  } catch (err) {
    console.error('Schema validation failed:', err.message);
    process.exit(1);
  }
}

main();
