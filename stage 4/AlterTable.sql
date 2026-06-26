-- ==============================================================================
-- AlterTable.sql
-- Contains schema modifications to support Stage 4 PL/pgSQL programs.
-- ==============================================================================

-- Create a log table for high risk clients (used by proc_log_high_risk.sql)
CREATE TABLE HighRiskLog (
    log_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL,
    client_name VARCHAR(100),
    credit_score INT,
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_client FOREIGN KEY (client_id) REFERENCES Client(client_id) ON DELETE CASCADE
);
