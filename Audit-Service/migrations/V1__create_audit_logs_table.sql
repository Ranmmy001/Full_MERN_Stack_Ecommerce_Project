CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,

    user_id VARCHAR(100),

    username VARCHAR(100),

    action VARCHAR(100) NOT NULL,

    entity VARCHAR(100),

    entity_id VARCHAR(100),

    details JSONB DEFAULT '{}'::jsonb,

    ip_address VARCHAR(50),

    user_agent TEXT,

    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user_id
ON audit_logs(user_id);

CREATE INDEX idx_audit_logs_action
ON audit_logs(action);

CREATE INDEX idx_audit_logs_created_at
ON audit_logs(created_at);







-- What does this migration do?
-- It creates the audit_logs table, which will store activities performed in your ecommerce application.