/**
 * Run a .sql file against the configured SQL Server database.
 * Splits the file on GO (batch separator) and executes each batch in order.
 * Usage: node scripts/run-sql-script.js <path-to-script.sql>
 *        npm run run-script -- path/to/script.sql
 */

const fs = require('fs');
const path = require('path');
const db = require('../lib/db-client');

function splitBatches(content) {
  const lines = content.split(/\r?\n/);
  const batches = [];
  let current = [];

  for (const line of lines) {
    if (/^\s*GO\s*$/i.test(line)) {
      const batch = current.join('\n').trim();
      if (batch) batches.push(batch);
      current = [];
    } else {
      current.push(line);
    }
  }
  const last = current.join('\n').trim();
  if (last) batches.push(last);
  return batches;
}

async function main() {
  const scriptPath = process.argv[2];
  if (!scriptPath) {
    console.error('Usage: node scripts/run-sql-script.js <path-to-script.sql>');
    process.exit(1);
  }

  const resolved = path.resolve(process.cwd(), scriptPath);
  if (!fs.existsSync(resolved)) {
    console.error('File not found:', resolved);
    process.exit(1);
  }

  const content = fs.readFileSync(resolved, 'utf8');
  const batches = splitBatches(content);

  if (batches.length === 0) {
    console.log('No batches to run (empty or only GO).');
    process.exit(0);
  }

  console.log('Running', batches.length, 'batch(es) from', path.basename(resolved));

  try {
    await db.connect();
    for (let i = 0; i < batches.length; i++) {
      await db.executeSql(batches[i]);
      console.log('  Batch', i + 1, 'OK');
    }
    await db.disconnect();
    console.log('Done.');
    process.exit(0);
  } catch (err) {
    console.error('Error:', err.message);
    process.exit(1);
  }
}

main();
