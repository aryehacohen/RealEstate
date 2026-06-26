-- ==============================================================================
-- Trigger 1: trigger_appraisal_update
-- Description: Triggers BEFORE UPDATE on Appraisal. If the new appraised value 
--              is lower than the loan amount, it updates the loan status to Pending.
-- Elements used: Trigger on UPDATE, DML.
-- ==============================================================================

CREATE OR REPLACE FUNCTION trg_func_check_appraisal()
RETURNS TRIGGER AS $$
DECLARE
    v_loan_amount NUMERIC;
BEGIN
    -- Get the loan amount
    SELECT loan_amount INTO v_loan_amount
    FROM MortgageLoan
    WHERE loan_id = NEW.loan_id;

    -- If the new appraisal is less than the loan amount, 
    -- we need to mark the loan as Pending for review.
    IF NEW.appraised_value < v_loan_amount THEN
        UPDATE MortgageLoan 
        SET status = 'Pending' 
        WHERE loan_id = NEW.loan_id AND status != 'Pending';
        
        RAISE NOTICE 'Appraisal lower than loan amount. Loan % set to Pending.', NEW.loan_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_appraisal_update
BEFORE UPDATE ON Appraisal
FOR EACH ROW
EXECUTE FUNCTION trg_func_check_appraisal();
