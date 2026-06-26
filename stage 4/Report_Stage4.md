# דוח הפרויקט שלב ד' - תכנות ב-PL/pgSQL
**הוגש ע"י:** איתן דוד וייס ואריה זבולון הכהן

בשלב זה הוספנו תוכניות PL/pgSQL לבסיס הנתונים שלנו על מנת לממש לוגיקה עסקית מורכבת של מערכת הנדל"ן ומשכנתאות. 
כל התוכניות נבדקו בהצלחה והן עושות שימוש נרחב ב-Cursors, לולאות, תנאים (Branching), טיפול בשגיאות (Exceptions) ופקודות DML.

---

## 1. שינויים בסכמה (Alter Tables)
**תיאור:** בכדי לתמוך בפרוצדורה שאוספת נתונים על לקוחות בסיכון, יצרנו טבלת יומן חדשה `HighRiskLog`.
**קוד:**
```sql
CREATE TABLE HighRiskLog (
    log_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL,
    client_name VARCHAR(100),
    credit_score INT,
    log_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_client FOREIGN KEY (client_id) REFERENCES Client(client_id) ON DELETE CASCADE
);
```

---

## 2. פונקציות

### פונקציה 1: `func_get_client_loans`
* **תיאור מילולי:** הפונקציה מקבלת מזהה לקוח (`client_id`) ומחזירה סמן התייחסות (`REFCURSOR`). הסמן כולל את כל המשכנתאות של הלקוח יחד עם כתובת הנכס מתוך טבלת `Property`.
* **אלמנטים:** חזרת `REFCURSOR`.
* **קוד הפונקציה:** נמצא בקובץ `func_get_client_loans.sql`.
* **הוכחת הרצה:**
**פלט הרצה (מתוך התוכנית הראשית `main1.sql`):**
```text
NOTICE:  Fetching loans for client 1...
NOTICE:  Loan ID: 1001, Amount: 1500000.00, Status: Approved, Property: Herzl 10, Tel Aviv
```

### פונקציה 2: `func_calculate_risk`
* **תיאור מילולי:** הפונקציה מקבלת מזהה הלוואה, ושולפת את סכום ההלוואה ואת ערך השמאות (האחרון) בעזרת סמנים סמויים (Implicit Cursors `SELECT INTO`). הפונקציה מחשבת את יחס הסיכון (Risk Ratio). במקרה של שמאות חסרה, מופעלת חריגת `NO_DATA_FOUND`. במידה וערך השמאות הוא אפס, נזרקת שגיאה יזומה `RAISE EXCEPTION`.
* **אלמנטים:** Implicit Cursor, Branching (IF), Exception Handling.
* **קוד הפונקציה:** נמצא בקובץ `func_calculate_risk.sql`.
* **הוכחת הרצה (כולל זריקת שגיאה במידת הצורך):**
**פלט הרצה מתוך תוכנית ההדגמה `main2.sql`:**
```text
NOTICE:  Calculating risk ratios...
NOTICE:  Loan 1001: Risk Ratio = 0.94
NOTICE:  Loan 1002: Risk Ratio = 0.94
```

---

## 3. פרוצדורות

### פרוצדורה 1: `proc_update_loan_status`
* **תיאור מילולי:** הפרוצדורה עוברת בלולאה על כל ההלוואות הנמצאות בסטטוס 'Pending' תוך שימוש בסמן מפורש (Explicit Cursor). עבור כל הלוואה היא קוראת לפונקציית יחס הסיכון ובודקת את דירוג האשראי של הלקוח: אם הדירוג גבוה מ-700 והסיכון נמוך, הסטטוס מתעדכן ל-'Approved'. אם הדירוג נמוך מדי, מבוצע `UPDATE` ל-'Rejected'.
* **אלמנטים:** Explicit Cursor, Loop, DML (UPDATE), Branching.
* **קוד הפרוצדורה:** נמצא בקובץ `proc_update_loan_status.sql`.
* **הוכחת הרצה (עדכון בסיס הנתונים):**
**פלט ההדפסה של הפרוצדורה במסוף:**
```text
NOTICE:  Executing update_pending_loans()...
NOTICE:  Loan 1002 Approved
```

### פרוצדורה 2: `proc_log_high_risk_clients`
* **תיאור מילולי:** הפרוצדורה שולפת לקוחות בעלי ציון אשראי נמוך (מתחת ל-600) אשר מחזיקים במשכנתא. היא משתמשת בסמן של רשומות (FOR rec IN ... LOOP) ועבור כל רשומה מבצעת הכנסה `INSERT` לטבלת `HighRiskLog`. במקרה של שגיאת הכנסה, יש תפיסת שגיאה בעזרת חריגות `EXCEPTION`.
* **אלמנטים:** Records, Loops, DML (INSERT), Exceptions.
* **קוד הפרוצדורה:** נמצא בקובץ `proc_log_high_risk.sql`.
* **הוכחת הרצה (הכנסת נתונים):**
**פלט במסוף ותוצאת השאילתה `SELECT * FROM HighRiskLog;`:**
```text
NOTICE:  Logged 1 high-risk clients.

 log_id | client_id | client_name | credit_score |         log_date          
--------+-----------+-------------+--------------+---------------------------
      1 |         2 | Michal Ziv  |          580 | 2024-06-15 10:23:45.123
(1 row)
```

---

## 4. טריגרים

### טריגר 1: `trigger_appraisal_update`
* **תיאור מילולי:** טריגר המופעל **לפני עדכון (BEFORE UPDATE)** על טבלת שמאויות (`Appraisal`). במידה והשמאי עדכן את ערך הנכס ומתברר שהוא נמוך מסכום ההלוואה המקורי, הטריגר יבצע `UPDATE` לסטטוס ההלוואה ל-'Pending' לצורך בחינה מחודשת.
* **קוד הטריגר:** נמצא בקובץ `trigger_appraisal_update.sql`.
* **הוכחת הרצה:**
**פלט הרצת שאילתת `UPDATE` המפעילה את הטריגר:**
```text
db=> UPDATE Appraisal SET appraised_value = 1400000.00 WHERE appraisal_id = 501;
NOTICE:  Appraisal lower than loan amount. Loan 1001 set to Pending.
UPDATE 1
```

### טריגר 2: `trigger_credit_score_alert`
* **תיאור מילולי:** טריגר המופעל **לפני עדכון (BEFORE UPDATE)** על שדה `credit_score` בטבלת הלקוחות (`Client`). אם ציון האשראי של הלקוח נופל בצורה חדה (יותר מ-100 נקודות בבת אחת), הטריגר מקפיץ הודעת התראה.
* **קוד הטריגר:** נמצא בקובץ `trigger_credit_score_alert.sql`.
* **הוכחת הרצה:**
**פלט הרצת שאילתת `UPDATE` המפעילה את הטריגר:**
```text
db=> UPDATE Client SET credit_score = 550 WHERE client_id = 1;
NOTICE:  ALERT: Credit score for client 1 dropped significantly from 750 to 550
UPDATE 1
```

---

## 5. תוכניות ראשיות

### תוכנית ראשית 1 (`main1.sql`)
* **תיאור מילולי:** בלוק אנונימי (DO block) הפותח את סמן ה-Ref Cursor מתוך פונקציה 1, מדפיס את נתוני המשכנתאות של לקוח נבחר בלולאה, ולאחר מכן מזמן את פרוצדורה 1 לבדיקת ההלוואות הממתינות.
* **הוכחת הרצה:**
**פלט ההרצה (Message Output):**
```text
NOTICE:  --- Starting Main Program 1 ---
NOTICE:  Fetching loans for client 1...
NOTICE:  Loan ID: 1001, Amount: 1500000.00, Status: Approved, Property: Herzl 10, Tel Aviv
NOTICE:  Executing update_pending_loans()...
NOTICE:  Loan 1002 Approved
NOTICE:  --- Finished Main Program 1 ---
DO
```

### תוכנית ראשית 2 (`main2.sql`)
* **תיאור מילולי:** תוכנית הרצה שעוברת על מספר הלוואות, מפעילה את פונקציה 2 לחישוב סיכונים, ולבסוף מפעילה את פרוצדורה 2 האחראית לרישום לקוחות בסיכון.
* **הוכחת הרצה:**
**פלט ההרצה (Message Output):**
```text
NOTICE:  --- Starting Main Program 2 ---
NOTICE:  Calculating risk ratios...
NOTICE:  Loan 1001: Risk Ratio = 0.94
NOTICE:  Loan 1002: Risk Ratio = 0.94
NOTICE:  Executing log_high_risk_clients()...
NOTICE:  Logged 1 high-risk clients.
NOTICE:  --- Finished Main Program 2 ---
DO
```
