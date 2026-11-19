const express = require("express");
require("dotenv").config();

const pool = require("./db");

const app = express();

app.use(express.json());

const PORT = process.env.PORT || 5001;

// Basic service route
app.get("/", (req, res) => {
  res.status(200).json({
    message: "Ecommerce Audit Service is running",
    service: "audit-service",
  });
});

// Health check
app.get("/health", async (req, res) => {
  try {
    await pool.query("SELECT 1");

    res.status(200).json({
      status: "healthy",
      database: "connected",
    });
  } catch (error) {
    console.error("Health check failed:", error.message);

    res.status(503).json({
      status: "unhealthy",
      database: "disconnected",
    });
  }
});

// Create an audit record
app.post("/api/audit", async (req, res) => {
  try {
    const {
      user_id,
      username,
      action,
      entity,
      entity_id,
      details = {},
      ip_address,
      user_agent,
    } = req.body;

    if (!action) {
      return res.status(400).json({
        message: "The action field is required",
      });
    }

    const result = await pool.query(
      `INSERT INTO audit_logs
       (user_id, username, action, entity, entity_id,
        details, ip_address, user_agent)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       RETURNING *`,
      [
        user_id || null,
        username || null,
        action,
        entity || null,
        entity_id || null,
        JSON.stringify(details),
        ip_address || req.ip,
        user_agent || req.get("user-agent") || null,
      ]
    );

    res.status(201).json({
      message: "Audit record created successfully",
      audit: result.rows[0],
    });
  } catch (error) {
    console.error("Error creating audit record:", error.message);

    res.status(500).json({
      message: "Failed to create audit record",
    });
  }
});

// Retrieve audit records
app.get("/api/audit", async (req, res) => {
  try {
    const requestedLimit = Number.parseInt(req.query.limit, 10);
    const limit = Number.isInteger(requestedLimit)
      ? Math.min(Math.max(requestedLimit, 1), 100)
      : 20;

    const result = await pool.query(
      `SELECT * FROM audit_logs
       ORDER BY created_at DESC
       LIMIT $1`,
      [limit]
    );

    res.status(200).json({
      count: result.rowCount,
      audits: result.rows,
    });
  } catch (error) {
    console.error("Error retrieving audit records:", error.message);

    res.status(500).json({
      message: "Failed to retrieve audit records",
    });
  }
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Audit Service running on port ${PORT}`);
});