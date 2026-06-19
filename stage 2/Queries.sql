-- ==========================================
-- 8 שאילתות SELECT 
-- ==========================================

-- שאילתא 1: סוכנים עם פגישות מתוכננות בחודש מאי
-- גרסה א' (JOIN)
SELECT DISTINCT a.first_name, a.last_name 
FROM Agent a 
JOIN Schedule s ON a.agent_id = s.agent_id 
WHERE EXTRACT(MONTH FROM s.meeting_date) = 5;

-- גרסה ב' (EXISTS - יעילה יותר)
SELECT a.first_name, a.last_name 
FROM Agent a 
WHERE EXISTS (
    SELECT 1 FROM Schedule s 
    WHERE a.agent_id = s.agent_id AND EXTRACT(MONTH FROM s.meeting_date) = 5
);

-- שאילתא 2: נכסי מגורים עם מרפסת בתל אביב
-- גרסה א' (IN)
SELECT p.address, p.price, r.bedrooms 
FROM Property p 
JOIN Residential r ON p.property_id = r.property_id 
WHERE p.city_id IN (SELECT city_id FROM City WHERE city_name = 'Tel Aviv') 
AND r.has_balcony = 'Y';

-- גרסה ב' (INNER JOIN - יעילה יותר)
SELECT p.address, p.price, r.bedrooms 
FROM Property p 
JOIN Residential r ON p.property_id = r.property_id 
JOIN City c ON p.city_id = c.city_id 
WHERE c.city_name = 'Tel Aviv' AND r.has_balcony = 'Y';

-- שאילתא 3: כמות חוזים שנסגרו לכל סוכן
-- גרסה א' (תת-שאילתא ב-SELECT)
SELECT a.first_name, a.last_name, 
       (SELECT COUNT(*) FROM Contract c 
        JOIN Property p ON c.property_id = p.property_id 
        WHERE p.agent_id = a.agent_id) AS total_contracts 
FROM Agent a;

-- גרסה ב' (GROUP BY - יעילה יותר)
SELECT a.first_name, a.last_name, COUNT(c.contract_id) AS total_contracts 
FROM Agent a 
LEFT JOIN Property p ON a.agent_id = p.agent_id 
LEFT JOIN Contract c ON p.property_id = c.property_id 
GROUP BY a.agent_id, a.first_name, a.last_name;

-- שאילתא 4: נכסים ללא תגיות מיוחדות (Amenities)
-- גרסה א' (NOT IN)
SELECT address, price 
FROM Property 
WHERE property_id NOT IN (SELECT property_id FROM Property_Amenity);

-- גרסה ב' (LEFT JOIN - יעילה ובטוחה יותר)
SELECT p.address, p.price 
FROM Property p 
LEFT JOIN Property_Amenity pa ON p.property_id = pa.property_id 
WHERE pa.amenity_id IS NULL;

-- שאילתא 5: פירוט פגישות עם פירוק תאריכים
SELECT c.first_name || ' ' || c.last_name AS client_name, 
       p.address, 
       EXTRACT(DAY FROM s.meeting_date) AS meeting_day, 
       EXTRACT(MONTH FROM s.meeting_date) AS meeting_month, 
       EXTRACT(YEAR FROM s.meeting_date) AS meeting_year 
FROM Schedule s 
JOIN Client c ON s.client_id = c.client_id 
JOIN Property p ON s.property_id = p.property_id 
WHERE s.status = 'Scheduled' 
ORDER BY meeting_year, meeting_month, meeting_day;

-- שאילתא 6: ממוצע דירוג לסוכנים עם יותר מביקורת אחת
SELECT a.first_name, a.last_name, AVG(r.rating) AS avg_rating 
FROM Agent a 
JOIN AgentReview r ON a.agent_id = r.agent_id 
GROUP BY a.agent_id, a.first_name, a.last_name 
HAVING COUNT(r.review_id) > 1 
ORDER BY avg_rating DESC;

-- שאילתא 7: נכסים שמחירם גבוה מהממוצע בעיר שלהם
SELECT p.address, p.price, c.city_name 
FROM Property p 
JOIN City c ON p.city_id = c.city_id 
WHERE p.price > (
    SELECT AVG(price) 
    FROM Property 
    WHERE city_id = p.city_id
);

-- שאילתא 8: שווי חוזים לפי סוג עסק מסחרי
SELECT com.business_type, SUM(con.final_price) AS total_revenue 
FROM Commercial com 
JOIN Property p ON com.property_id = p.property_id 
JOIN Contract con ON p.property_id = con.property_id 
GROUP BY com.business_type 
ORDER BY total_revenue DESC;


-- ==========================================
-- 3 שאילתות UPDATE
-- ==========================================

-- 1. עדכון סטטוס פגישות ישנות ל-'Completed'
UPDATE Schedule 
SET status = 'Completed' 
WHERE meeting_date < CURRENT_DATE AND status = 'Scheduled';

-- 2. העלאת מחיר ב-5% לנכסי מגורים עם מרפסת
UPDATE Property 
SET price = price * 1.05 
WHERE property_id IN (SELECT property_id FROM Residential WHERE has_balcony = 'Y');

-- 3. העברת נכסים של סוכנים עם דירוג נמוך מ-3 לסוכן מספר 1
UPDATE Property 
SET agent_id = 1 
WHERE agent_id IN (
    SELECT agent_id FROM AgentReview GROUP BY agent_id HAVING AVG(rating) < 3.0
);


-- ==========================================
-- 3 שאילתות DELETE
-- ==========================================

-- 1. מחיקת פגישות שבוטלו לפני למעלה משנה
DELETE FROM Schedule 
WHERE status = 'Cancelled' AND meeting_date < CURRENT_DATE - INTERVAL '1 year';

-- 2. מחיקת תגיות שאין בהן שימוש
DELETE FROM Amenity 
WHERE amenity_id NOT IN (SELECT amenity_id FROM Property_Amenity);

-- 3. מחיקת ביקורות ללא תוכן
DELETE FROM AgentReview 
WHERE TRIM(review_text) = '' OR review_text IS NULL;