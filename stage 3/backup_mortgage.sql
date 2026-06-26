-- Backup of the Mortgage Bank System (Group 2)
-- This file represents the database we "received" from another group.

CREATE TABLE BankClient (
    client_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    credit_score INT CHECK (credit_score BETWEEN 300 AND 850)
);

CREATE TABLE MortgageLoan (
    loan_id INT PRIMARY KEY,
    client_id INT NOT NULL,
    property_address VARCHAR(150) NOT NULL,
    loan_amount NUMERIC(12, 2) NOT NULL,
    interest_rate NUMERIC(4, 2) NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending' CHECK (status IN ('Pending', 'Approved', 'Rejected')),
    CONSTRAINT fk_bank_client FOREIGN KEY (client_id) REFERENCES BankClient(client_id)
);

CREATE TABLE Appraisal (
    appraisal_id INT PRIMARY KEY,
    loan_id INT NOT NULL,
    appraiser_name VARCHAR(100) NOT NULL,
    appraised_value NUMERIC(12, 2) NOT NULL,
    appraisal_date DATE NOT NULL,
    CONSTRAINT fk_app_loan FOREIGN KEY (loan_id) REFERENCES MortgageLoan(loan_id) ON DELETE CASCADE
);

-- Dummy Data for Mortgage Bank Backup
INSERT INTO BankClient (client_id, full_name, phone_number, credit_score) VALUES
(201, 'David Cohen', '050-1111111', 750),
(202, 'Sarah Levi', '052-2222222', 680),
(203, 'Yossi Israel', '054-3333333', 810);

INSERT INTO MortgageLoan (loan_id, client_id, property_address, loan_amount, interest_rate, status) VALUES
(1001, 201, '10 Herzl St, Tel Aviv', 1500000.00, 3.50, 'Approved'),
(1002, 202, '5 Ben Yehuda, Jerusalem', 800000.00, 4.00, 'Pending'),
(1003, 203, '12 Rotschild Blvd, Haifa', 2200000.00, 3.20, 'Approved');

INSERT INTO Appraisal (appraisal_id, loan_id, appraiser_name, appraised_value, appraisal_date) VALUES
(501, 1001, 'Moshe Appraiser', 1600000.00, '2026-05-15'),
(502, 1002, 'Ronit Valuer', 850000.00, '2026-06-01'),
(503, 1003, 'Moshe Appraiser', 2400000.00, '2026-06-10');
