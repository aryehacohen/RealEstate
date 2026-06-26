-- ==============================================================================
-- Function 1: func_get_client_loans
-- Description: Returns a Ref Cursor containing all loans for a specific client.
-- Elements used: REFCURSOR (return type).
-- ==============================================================================

CREATE OR REPLACE FUNCTION get_client_loans(p_client_id INT)
RETURNS REFCURSOR AS $$
DECLARE
    loan_cursor REFCURSOR;
BEGIN
    -- Open the cursor for a query joining MortgageLoan and Property
    OPEN loan_cursor FOR
        SELECT m.loan_id, m.loan_amount, m.status, p.address AS property_address
        FROM MortgageLoan m
        JOIN Property p ON m.property_id = p.property_id
        WHERE m.client_id = p_client_id;
        
    RETURN loan_cursor;
END;
$$ LANGUAGE plpgsql;
