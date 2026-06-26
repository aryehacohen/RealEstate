-- ==============================================================================
-- Function 2: func_calculate_risk
-- Description: Calculates the risk ratio of a loan (loan_amount / appraised_value).
-- Elements used: Implicit Cursor (SELECT INTO), Exceptions, Branching (IF).
-- ==============================================================================

CREATE OR REPLACE FUNCTION calculate_loan_risk(p_loan_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_loan_amount NUMERIC;
    v_appraised_value NUMERIC;
    v_risk_ratio NUMERIC;
BEGIN
    -- Implicit Cursor: fetch loan amount
    SELECT loan_amount INTO STRICT v_loan_amount
    FROM MortgageLoan
    WHERE loan_id = p_loan_id;
    
    -- Implicit Cursor: fetch the latest appraised value
    -- If no appraisal exists, this will raise a NO_DATA_FOUND exception (caught below)
    SELECT appraised_value INTO STRICT v_appraised_value
    FROM Appraisal
    WHERE loan_id = p_loan_id
    ORDER BY appraisal_date DESC
    LIMIT 1;

    -- Branching: Check if appraised value is zero to prevent division by zero
    IF v_appraised_value = 0 THEN
        RAISE EXCEPTION 'Appraised value cannot be zero for loan ID %', p_loan_id;
    END IF;

    -- Calculate risk ratio
    v_risk_ratio := v_loan_amount / v_appraised_value;
    
    RETURN v_risk_ratio;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handling exception if loan or appraisal doesn't exist
        RAISE NOTICE 'Data not found for loan ID %', p_loan_id;
        RETURN NULL;
    WHEN OTHERS THEN
        RAISE EXCEPTION 'An unexpected error occurred: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
