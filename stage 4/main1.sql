-- ==============================================================================
-- Main Program 1: main1.sql
-- Description: Invokes Function 1 (get_client_loans) and Procedure 1 
--              (update_pending_loans).
-- ==============================================================================

DO $$
DECLARE
    v_loan_cursor REFCURSOR;
    v_loan_id INT;
    v_loan_amount NUMERIC;
    v_status VARCHAR;
    v_address VARCHAR;
    v_client_id INT := 1; -- Assuming client 1 exists
BEGIN
    RAISE NOTICE '--- Starting Main Program 1 ---';
    
    -- Call Function 1
    RAISE NOTICE 'Fetching loans for client %...', v_client_id;
    v_loan_cursor := get_client_loans(v_client_id);
    
    -- Fetching from the returned Ref Cursor
    LOOP
        FETCH v_loan_cursor INTO v_loan_id, v_loan_amount, v_status, v_address;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Loan ID: %, Amount: %, Status: %, Property: %', 
                     v_loan_id, v_loan_amount, v_status, v_address;
    END LOOP;
    CLOSE v_loan_cursor;
    
    -- Call Procedure 1
    RAISE NOTICE 'Executing update_pending_loans()...';
    CALL update_pending_loans();
    
    RAISE NOTICE '--- Finished Main Program 1 ---';
END;
$$;
