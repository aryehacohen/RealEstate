-- ======================================================
-- Views.sql
-- Views and Queries for Stage 3
-- ======================================================

-- ------------------------------------------------------
-- View 1: Real Estate Perspective (נקודת המבט של סוכנות הנדל"ן)
-- Shows properties along with their assigned agent and any active mortgage status.
-- This helps agents know if their property has a secured buyer.
-- ------------------------------------------------------
CREATE VIEW AgentPropertyMortgageView AS
SELECT 
    p.property_id,
    p.address AS property_address,
    p.price AS asking_price,
    a.first_name || ' ' || a.last_name AS agent_name,
    COALESCE(m.status, 'No Mortgage') AS mortgage_status,
    m.loan_amount
FROM 
    Property p
JOIN 
    Agent a ON p.agent_id = a.agent_id
LEFT JOIN 
    MortgageLoan m ON p.property_id = m.property_id;

-- Query 1.1: Get all properties that have an 'Approved' mortgage.
SELECT * FROM AgentPropertyMortgageView
WHERE mortgage_status = 'Approved';

-- Query 1.2: Get properties handled by agent 'Yossi Cohen' sorted by asking price.
SELECT property_id, property_address, mortgage_status, asking_price 
FROM AgentPropertyMortgageView
WHERE agent_name = 'Yossi Cohen'
ORDER BY asking_price DESC;


-- ------------------------------------------------------
-- View 2: Mortgage Bank Perspective (נקודת המבט של הבנק)
-- Shows comprehensive loan details including client credit score, property address, 
-- and the appraised value of the property to assess risk.
-- ------------------------------------------------------
CREATE VIEW ComprehensiveLoanView AS
SELECT 
    m.loan_id,
    c.first_name || ' ' || c.last_name AS client_name,
    c.credit_score,
    p.address AS property_address,
    m.loan_amount,
    ap.appraised_value,
    (ap.appraised_value - m.loan_amount) AS equity
FROM 
    MortgageLoan m
JOIN 
    Client c ON m.client_id = c.client_id
JOIN 
    Property p ON m.property_id = p.property_id
LEFT JOIN 
    Appraisal ap ON m.loan_id = ap.loan_id;

-- Query 2.1: Find low-risk loans where the appraised value is significantly higher than the loan amount (Equity > 100,000).
SELECT loan_id, client_name, loan_amount, appraised_value, equity 
FROM ComprehensiveLoanView
WHERE equity > 100000;

-- Query 2.2: List all loans given to clients with an excellent credit score (> 700).
SELECT loan_id, client_name, credit_score, loan_amount 
FROM ComprehensiveLoanView
WHERE credit_score > 700;
