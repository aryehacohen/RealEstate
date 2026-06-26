-- ======================================================
-- Integrate.sql
-- Integration of Mortgage Bank System into Real Estate System
-- ======================================================

-- 1. Modify existing Client table to include BankClient attributes
ALTER TABLE Client
ADD COLUMN credit_score INT CHECK (credit_score BETWEEN 300 AND 850);

-- 2. Create the MortgageLoan table linked to existing Client and Property tables
CREATE TABLE MortgageLoan (
    loan_id INT PRIMARY KEY,
    client_id INT NOT NULL,
    property_id INT NOT NULL,
    loan_amount NUMERIC(12, 2) NOT NULL,
    interest_rate NUMERIC(4, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected')),
    CONSTRAINT fk_loan_client FOREIGN KEY (client_id) REFERENCES Client(client_id) ON DELETE CASCADE,
    CONSTRAINT fk_loan_prop FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE
);

-- 3. Create the Appraisal table
CREATE TABLE Appraisal (
    appraisal_id INT PRIMARY KEY,
    loan_id INT NOT NULL,
    appraiser_name VARCHAR(100) NOT NULL,
    appraised_value NUMERIC(12, 2) NOT NULL,
    appraisal_date DATE NOT NULL,
    CONSTRAINT fk_appraisal_loan FOREIGN KEY (loan_id) REFERENCES MortgageLoan(loan_id) ON DELETE CASCADE
);

-- ======================================================
-- Data Migration / Injection
-- ======================================================

-- Adding credit_score to existing clients
UPDATE Client SET credit_score = 750 WHERE client_id = 1;
UPDATE Client SET credit_score = 680 WHERE client_id = 2;
UPDATE Client SET credit_score = 810 WHERE client_id = 3;

-- Inserting into MortgageLoan
-- We use existing clients (1, 2, 3) and properties (1, 2)
INSERT INTO MortgageLoan (loan_id, client_id, property_id, loan_amount, interest_rate, status) VALUES 
(1001, 1, 1, 1500000.00, 3.50, 'Approved'),
(1002, 2, 2, 800000.00, 4.00, 'Pending');

-- Inserting into Appraisal
INSERT INTO Appraisal (appraisal_id, loan_id, appraiser_name, appraised_value, appraisal_date) VALUES 
(501, 1001, 'Moshe Appraiser', 1600000.00, '2024-05-15'),
(502, 1002, 'Ronit Valuer', 850000.00, '2024-06-01');
