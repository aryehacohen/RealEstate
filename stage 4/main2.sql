-- ==============================================================================
-- Main Program 2: main2.sql
-- Description: Invokes Function 2 (calculate_loan_risk) inside a loop and 
--              calls Procedure 2 (log_high_risk_clients).
-- ==============================================================================

DO $$
DECLARE
    rec RECORD;
    v_risk_ratio NUMERIC;
BEGIN
    RAISE NOTICE '--- Starting Main Program 2 ---';
    
    -- Iterate through a few loans and call Function 2
    RAISE NOTICE 'Calculating risk ratios...';
    FOR rec IN 
        SELECT loan_id FROM MortgageLoan LIMIT 5
    LOOP
        BEGIN
            v_risk_ratio := calculate_loan_risk(rec.loan_id);
            IF v_risk_ratio IS NOT NULL THEN
                RAISE NOTICE 'Loan %: Risk Ratio = %', rec.loan_id, ROUND(v_risk_ratio, 2);
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                RAISE NOTICE 'Error processing Loan %: %', rec.loan_id, SQLERRM;
        END;
    END LOOP;
    
    -- Call Procedure 2
    RAISE NOTICE 'Executing log_high_risk_clients()...';
    CALL log_high_risk_clients();
    
    RAISE NOTICE '--- Finished Main Program 2 ---';
END;
$$;
