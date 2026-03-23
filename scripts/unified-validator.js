/**
 * Unified schema validator for MS SQL Server.
 * Compares live database schema to optional expected schema (JSON) and reports mismatches.
 * Usage:
 *   node scripts/unified-validator.js                    # Load and print DB schema; exit 0
 *   node scripts/unified-validator.js --expected path.json  # Compare DB to expected; exit 1 on CRITICAL
 * Expected JSON format: { "TableName": { "columns": { "colName": { "type": "...", "nullable": true } } } }
 */

const fs = require('fs');
const path = require('path');
const db = require('../lib/db-client');

const SEVERITY = { CRITICAL: 'CRITICAL', HIGH: 'HIGH', LOW: 'LOW' };

function normalizeType(t) {
  if (!t) return '';
  const u = t.toUpperCase();
  if (u.includes('CHAR') || u.includes('TEXT')) return 'string';
  if (u.includes('INT') || u === 'BIT') return 'integer';
  if (u.includes('DECIMAL') || u.includes('NUMERIC') || u.includes('FLOAT') || u.includes('REAL')) return 'numeric';
  if (u.includes('DATE') || u.includes('TIME')) return 'datetime';
  if (u === 'BIT') return 'boolean';
  return u;
}

function compareSchemas(dbSchema, expectedSchema) {
  const issues = [];

  for (const [tableName, expectedDef] of Object.entries(expectedSchema)) {
    const expectedCols = expectedDef && expectedDef.columns ? expectedDef.columns : {};
    const dbCols = dbSchema[tableName] && dbSchema[tableName].columns ? dbSchema[tableName].columns : {};

    if (!dbSchema[tableName]) {
      issues.push({ severity: SEVERITY.CRITICAL, table: tableName, message: `Expected table "${tableName}" not found in database` });
      continue;
    }

    for (const [colName, expectedMeta] of Object.entries(expectedCols)) {
      const dbMeta = dbCols[colName];
      if (!dbMeta) {
        issues.push({ severity: SEVERITY.CRITICAL, table: tableName, column: colName, message: `Expected column "${colName}" not found in table "${tableName}"` });
        continue;
      }
      const expType = normalizeType(expectedMeta.type);
      const dbType = normalizeType(dbMeta.type);
      if (expType && dbType && expType !== dbType) {
        issues.push({ severity: SEVERITY.HIGH, table: tableName, column: colName, message: `Type mismatch: expected ${expectedMeta.type}, DB has ${dbMeta.type}` });
      }
      if (expectedMeta.nullable === false && dbMeta.nullable === true) {
        issues.push({ severity: SEVERITY.LOW, table: tableName, column: colName, message: `Expected NOT NULL, DB allows NULL` });
      }
    }

    for (const colName of Object.keys(dbCols)) {
      if (!expectedCols[colName] && Object.keys(expectedCols).length > 0) {
        issues.push({ severity: SEVERITY.HIGH, table: tableName, column: colName, message: `Column "${colName}" in DB but not in expected schema` });
      }
    }
  }

  return issues;
}

function loadExpected(filePath) {
  const resolved = path.resolve(process.cwd(), filePath);
  if (!fs.existsSync(resolved)) {
    throw new Error('Expected schema file not found: ' + resolved);
  }
  const raw = fs.readFileSync(resolved, 'utf8');
  return JSON.parse(raw);
}

async function main() {
  const args = process.argv.slice(2);
  let expectedPath = null;
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--expected' && args[i + 1]) {
      expectedPath = args[i + 1];
      break;
    }
  }

  try {
    await db.connect();
    const dbSchema = await db.getDatabaseSchema();
    await db.disconnect();

    const tableCount = Object.keys(dbSchema).length;
    console.log('Database schema loaded:', tableCount, 'table(s).');

    if (!expectedPath) {
      if (args.includes('--dump')) {
        console.log(JSON.stringify(dbSchema, null, 2));
      }
      process.exit(0);
    }

    const expectedSchema = loadExpected(expectedPath);
    const issues = compareSchemas(dbSchema, expectedSchema);

    const bySeverity = { CRITICAL: [], HIGH: [], LOW: [] };
    for (const i of issues) {
      bySeverity[i.severity].push(i);
    }

    if (issues.length === 0) {
      console.log('No issues found. Schema matches expected.');
      process.exit(0);
    }

    for (const s of [SEVERITY.CRITICAL, SEVERITY.HIGH, SEVERITY.LOW]) {
      const list = bySeverity[s];
      if (list.length === 0) continue;
      console.log('\n' + s + ' (' + list.length + '):');
      for (const i of list) {
        console.log('  -', i.table + (i.column ? '.' + i.column : ''), ':', i.message);
      }
    }

    console.log('\nSummary: CRITICAL=' + bySeverity.CRITICAL.length + ', HIGH=' + bySeverity.HIGH.length + ', LOW=' + bySeverity.LOW.length);
    process.exit(bySeverity.CRITICAL.length > 0 ? 1 : 0);
  } catch (err) {
    console.error('Validator failed:', err.message);
    process.exit(1);
  }
}

main();
