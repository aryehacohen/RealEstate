-- ==============================================================================
-- Procedure 2: proc_log_high_risk
-- Description: Logs high-risk clients (credit score < 600) with active loans.
-- Elements used: Records (FOR rec IN), Loops, DML (INSERT), Exceptions.
-- ==============================================================================

CREATE OR REPLACE PROCEDURE log_high_risk_clients()
LANGUAGE plpgsql AS $$
DECLARE
    -- RECORD variable for implicit cursor loop
    rec RECORD;
    v_count INT := 0;
BEGIN
    -- Loop over clients with credit score < 600
    FOR rec IN 
        SELECT DISTINCT c.client_id, c.first_name, c.last_name, c.credit_score
        FROM Client c
        JOIN MortgageLoan m ON c.client_id = m.client_id
        WHERE c.credit_score < 600
    LOOP
        BEGIN
            -- DML INSERT
            INSERT INTO HighRiskLog (client_id, client_name, credit_score)
            VALUES (rec.client_id, rec.first_name || ' ' || rec.last_name, rec.credit_score);
            
            v_count := v_count + 1;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Failed to log client %: %', rec.client_id, SQLERRM;
        END;
    END LOOP;
    
    RAISE NOTICE 'Logged % high-risk clients.', v_count;
END;
$$;
