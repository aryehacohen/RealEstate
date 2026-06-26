-- ==============================================================================
-- Procedure 1: proc_update_loan_status
-- Description: Iterates through pending loans and approves/rejects them 
--              based on client credit score and risk ratio.
-- Elements used: Explicit Cursor, Loop, DML (UPDATE), Branching.
-- ==============================================================================

CREATE OR REPLACE PROCEDURE update_pending_loans()
LANGUAGE plpgsql AS $$
DECLARE
    -- Explicit Cursor definition
    cur_pending_loans CURSOR FOR 
        SELECT m.loan_id, m.client_id, c.credit_score
        FROM MortgageLoan m
        JOIN Client c ON m.client_id = c.client_id
        WHERE m.status = 'Pending';
        
    v_loan_id INT;
    v_client_id INT;
    v_credit_score INT;
    v_risk NUMERIC;
BEGIN
    -- Open Explicit Cursor
    OPEN cur_pending_loans;
    
    LOOP
        FETCH cur_pending_loans INTO v_loan_id, v_client_id, v_credit_score;
        EXIT WHEN NOT FOUND; -- Exit loop if no more records
        
        -- Call function to get risk ratio
        v_risk := calculate_loan_risk(v_loan_id);
        
        -- Branching (IF/ELSIF)
        IF v_risk IS NOT NULL THEN
            IF v_credit_score >= 700 AND v_risk < 0.95 THEN
                -- DML UPDATE
                UPDATE MortgageLoan SET status = 'Approved' WHERE loan_id = v_loan_id;
                RAISE NOTICE 'Loan % Approved', v_loan_id;
            ELSIF v_credit_score < 600 OR v_risk > 1.00 THEN
                -- DML UPDATE
                UPDATE MortgageLoan SET status = 'Rejected' WHERE loan_id = v_loan_id;
                RAISE NOTICE 'Loan % Rejected', v_loan_id;
            END IF;
        END IF;
    END LOOP;
    
    CLOSE cur_pending_loans;
END;
$$;
