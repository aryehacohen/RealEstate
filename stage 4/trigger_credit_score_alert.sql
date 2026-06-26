-- ==============================================================================
-- Trigger 2: trigger_credit_score_alert
-- Description: Triggers BEFORE UPDATE on Client. If the credit score drops 
--              significantly, it raises a notice.
-- Elements used: Trigger on UPDATE.
-- ==============================================================================

CREATE OR REPLACE FUNCTION trg_func_credit_score_alert()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if credit score dropped by more than 100 points
    IF OLD.credit_score IS NOT NULL AND NEW.credit_score < (OLD.credit_score - 100) THEN
        RAISE NOTICE 'ALERT: Credit score for client % dropped significantly from % to %', 
                     NEW.client_id, OLD.credit_score, NEW.credit_score;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_credit_score_update
BEFORE UPDATE OF credit_score ON Client
FOR EACH ROW
EXECUTE FUNCTION trg_func_credit_score_alert();
