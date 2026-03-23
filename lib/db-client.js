/**
 * Shared SQL Server client API.
 * Uses sys.* for schema discovery. All DB access for validators and tools goes through this module.
 */

const sql = require('mssql');
const { sqlConfig } = require('./db-config');

let pool = null;

async function connect() {
  if (pool) return true;
  try {
    pool = await sql.connect(sqlConfig);
    return true;
  } catch (err) {
    throw new Error(`Connection failed: ${err.message}`);
  }
}

async function disconnect() {
  try {
    if (pool) {
      await pool.close();
      pool = null;
    }
  } catch (err) {
    // Ignore
  }
}

async function getSchemas() {
  await connect();
  const result = await sql.query`
    SELECT s.name AS SchemaName,
           p.name AS Owner,
           COUNT(t.object_id) AS TableCount
    FROM sys.schemas s
    LEFT JOIN sys.database_principals p ON s.principal_id = p.principal_id
    LEFT JOIN sys.tables t ON s.schema_id = t.schema_id
    GROUP BY s.name, p.name
    HAVING COUNT(t.object_id) > 0
    ORDER BY TableCount DESC, s.name
  `;
  return result.recordset;
}

async function getTables(schemaFilter = null, limit = 500) {
  await connect();
  if (schemaFilter) {
    const result = await sql.query`
      SELECT TOP ${limit}
        SCHEMA_NAME(t.schema_id) AS SchemaName,
        t.name AS TableName,
        SUM(p.rows) AS RowCount
      FROM sys.tables t
      LEFT JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0, 1)
      WHERE SCHEMA_NAME(t.schema_id) = ${schemaFilter}
      GROUP BY t.schema_id, t.name
      ORDER BY t.name
    `;
    return result.recordset;
  }
  const result = await sql.query`
    SELECT TOP ${limit}
      SCHEMA_NAME(t.schema_id) AS SchemaName,
      t.name AS TableName,
      SUM(p.rows) AS RowCount
    FROM sys.tables t
    LEFT JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0, 1)
    GROUP BY t.schema_id, t.name
    ORDER BY SCHEMA_NAME(t.schema_id), t.name
  `;
  return result.recordset;
}

/**
 * Get column list for a table (schema.table). Returns array of { name, dataType, nullable, isIdentity, isPrimaryKey }.
 */
async function getTableColumns(tableName) {
  await connect();
  const request = new sql.Request();
  request.input('tableName', sql.NVarChar, tableName);
  const result = await request.query(`
    SELECT
      c.name AS ColumnName,
      t.name AS DataType,
      CASE WHEN t.name IN ('nvarchar', 'nchar') THEN c.max_length / 2
           WHEN t.name IN ('varchar', 'char', 'varbinary') THEN c.max_length
           ELSE NULL END AS MaxLength,
      c.precision AS Precision,
      c.scale AS Scale,
      c.is_nullable AS IsNullable,
      c.is_identity AS IsIdentity,
      CASE WHEN pkc.column_id IS NOT NULL THEN 1 ELSE 0 END AS IsPrimaryKey
    FROM sys.columns c
    INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
    LEFT JOIN (
      SELECT ic.column_id, ic.object_id
      FROM sys.index_columns ic
      INNER JOIN sys.indexes i ON ic.object_id = i.object_id AND ic.index_id = i.index_id
      WHERE i.is_primary_key = 1
    ) pkc ON c.object_id = pkc.object_id AND c.column_id = pkc.column_id
    WHERE c.object_id = OBJECT_ID(@tableName)
    ORDER BY c.column_id
  `);
  return result.recordset.map((r) => ({
    name: r.ColumnName,
    dataType: r.DataType,
    maxLength: r.MaxLength,
    precision: r.Precision,
    scale: r.Scale,
    nullable: !!r.IsNullable,
    isIdentity: !!r.IsIdentity,
    isPrimaryKey: !!r.IsPrimaryKey,
  }));
}

/**
 * Get full table structure: columns, primary keys, foreign keys.
 * tableName: schema.table
 */
async function getTableStructure(tableName) {
  await connect();
  const columns = await getTableColumns(tableName);
  const request = new sql.Request();
  request.input('tableName', sql.NVarChar, tableName);

  const pkResult = await request.query(`
    SELECT i.name AS IndexName, COL_NAME(ic.object_id, ic.column_id) AS ColumnName, ic.key_ordinal AS KeyOrder
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    WHERE i.object_id = OBJECT_ID(@tableName) AND i.is_primary_key = 1
    ORDER BY ic.key_ordinal
  `);
  const primaryKeys = pkResult.recordset;

  const fkResult = await request.query(`
    SELECT fk.name AS FKName,
           COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ColumnName,
           OBJECT_SCHEMA_NAME(fk.referenced_object_id) + '.' + OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
           COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ReferencedColumn
    FROM sys.foreign_keys fk
    INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
    WHERE fk.parent_object_id = OBJECT_ID(@tableName)
  `);
  const foreignKeys = fkResult.recordset;

  return { columns, primaryKeys, foreignKeys };
}

/**
 * Get all table names in current database (for validators that need a list of tables).
 */
async function getAllTableNames() {
  await connect();
  const result = await sql.query`
    SELECT SCHEMA_NAME(schema_id) AS SchemaName, name AS TableName
    FROM sys.tables
    ORDER BY SCHEMA_NAME(schema_id), name
  `;
  return result.recordset.map((r) => `${r.SchemaName}.${r.TableName}`);
}

/**
 * Get schema info for all tables (or one table) in a shape similar to PG information_schema
 * for compatibility with ported unified-validator logic.
 * Returns { [tableName]: { columns: { [columnName]: { type, nullable, max_length, ... } } } }
 */
async function getDatabaseSchema(tableName = null) {
  await connect();
  const tableNames = tableName ? [tableName] : await getAllTableNames();
  const dbSchemas = {};

  for (const fullName of tableNames) {
    const baseName = fullName.includes('.') ? fullName.split('.')[1] : fullName;
    const cols = await getTableColumns(fullName);
    if (cols.length === 0) continue;
    dbSchemas[baseName] = {
      columns: cols.reduce((acc, c) => {
        acc[c.name] = {
          type: c.dataType,
          nullable: c.nullable,
          max_length: c.maxLength,
          precision: c.precision,
          scale: c.scale,
          is_identity: c.isIdentity,
          is_primary_key: c.isPrimaryKey,
        };
        return acc;
      }, {}),
    };
  }
  return dbSchemas;
}

async function getProcedures(schemaFilter = null, limit = 200) {
  await connect();
  if (schemaFilter) {
    const result = await sql.query`
      SELECT TOP ${limit}
        SCHEMA_NAME(schema_id) AS SchemaName,
        name AS ProcedureName,
        create_date AS Created,
        modify_date AS Modified
      FROM sys.procedures
      WHERE SCHEMA_NAME(schema_id) = ${schemaFilter}
      ORDER BY name
    `;
    return result.recordset;
  }
  const result = await sql.query`
    SELECT TOP ${limit}
      SCHEMA_NAME(schema_id) AS SchemaName,
      name AS ProcedureName,
      create_date AS Created,
      modify_date AS Modified
    FROM sys.procedures
    ORDER BY SCHEMA_NAME(schema_id), name
  `;
  return result.recordset;
}

async function testConnection() {
  await connect();
  const result = await sql.query`SELECT @@VERSION AS Version, DB_NAME() AS CurrentDB`;
  await disconnect();
  return { db: result.recordset[0].CurrentDB, version: result.recordset[0].Version };
}

/**
 * Execute a single batch of raw T-SQL. Used by the script runner.
 * @param {string} sqlText - One batch of T-SQL (no GO).
 * @returns {Promise<{ recordset?: any[], rowsAffected?: number[] }>}
 */
async function executeSql(sqlText) {
  await connect();
  const request = new sql.Request(pool);
  const result = await request.query(sqlText);
  return { recordset: result.recordset, rowsAffected: result.rowsAffected };
}

module.exports = {
  connect,
  disconnect,
  getSchemas,
  getTables,
  getTableColumns,
  getTableStructure,
  getAllTableNames,
  getDatabaseSchema,
  getProcedures,
  testConnection,
  executeSql,
  sqlConfig,
};
