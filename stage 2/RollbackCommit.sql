-- ==========================================
-- בדיקת Rollback
-- ==========================================
BEGIN;

-- מחיקת הנתונים
DELETE FROM AgentReview;

-- להריץ כדי לצלם שהטבלה ריקה
SELECT * FROM AgentReview;

-- ביטול הפעולה
ROLLBACK;

-- להריץ כדי לצלם שהנתונים חזרו
SELECT * FROM AgentReview;


-- ==========================================
-- בדיקת Commit
-- ==========================================
BEGIN;

-- עדכון מחיר
UPDATE Property SET price = price + 10000 WHERE property_id = 1;

-- להריץ כדי לצלם שהמחיר עלה
SELECT price FROM Property WHERE property_id = 1;

-- שמירת הפעולה לצמיתות
COMMIT;

-- להריץ כדי להראות שהשינוי נשאר
SELECT price FROM Property WHERE property_id = 1;