const AUDIT_SERVICE_URL =
  process.env.AUDIT_SERVICE_URL || "http://localhost:5001";

const logAuditEvent = async ({
  userId,
  username,
  action,
  entity,
  entityId,
  details = {},
  req,
}) => {
  try {
    const response = await fetch(`${AUDIT_SERVICE_URL}/api/audit`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        user_id: userId ? String(userId) : null,
        username: username || null,
        action,
        entity: entity || null,
        entity_id: entityId ? String(entityId) : null,
        details,
        ip_address: req?.ip || null,
        user_agent: req?.get("user-agent") || null,
      }),
    });

    if (!response.ok) {
      console.error(
        `Audit logging failed. HTTP status: ${response.status}`
      );
    }
  } catch (error) {
    // Audit logging failure should not interrupt the main application.
    console.error("Audit Service unavailable:", error.message);
  }
};

module.exports = logAuditEvent;