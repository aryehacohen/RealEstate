-- אילוץ 1: מחיר חוזה מינימלי 50,000
ALTER TABLE Contract 
ADD CONSTRAINT chk_min_contract_price CHECK (final_price >= 50000);

-- אילוץ 2: טלפון לקוח לפחות 9 תווים
ALTER TABLE Client 
ADD CONSTRAINT chk_phone_length CHECK (LENGTH(phone) >= 9);

-- אילוץ 3: ביקורת לא יכולה להיות ריקה
ALTER TABLE AgentReview 
ADD CONSTRAINT chk_valid_review_text CHECK (LENGTH(TRIM(review_text)) > 0);