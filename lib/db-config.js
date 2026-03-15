/**
 * SQL Server configuration.
 * Reads from environment (use .env via dotenv) or returns defaults for local dev.
 * Do not commit real credentials; use .env (in .gitignore).
 */

require('dotenv').config();

const sqlConfig = {
  user: process.env.DB_USER || '',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'master',
  server: process.env.DB_SERVER || 'localhost',
  options: {
    encrypt: true,
    trustServerCertificate: true,
    requestTimeout: Number(process.env.DB_TIMEOUT) || 30000,
  },
};

module.exports = { sqlConfig };
