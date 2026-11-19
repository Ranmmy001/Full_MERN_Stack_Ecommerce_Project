const { Pool } = require("pg");
require("dotenv").config();

const pool = new Pool({
  host: process.env.DB_HOST || "localhost",
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || "ecommerce_audit",
  user: process.env.DB_USER || "audit_user",
  password: process.env.DB_PASSWORD,
});

pool.on("error", (err) => {
  console.error("Unexpected PostgreSQL error:", err);
});

module.exports = pool;







// What this file does
// It establishes the connection between your Node.js Audit Service and PostgreSQL.

// The environment variables allow us to use different database connection settings for local Docker Compose, Minikube and AWS later.