-- ======================================================
-- קובץ אכלוס נתונים - insertTables.sql
-- פרויקט נדל"ן - שלב א'
-- ======================================================

-- 1. אכלוס טבלת Area (שיטה: ידנית/Mockaroo)
INSERT INTO Area (area_id, area_name) VALUES (1, 'Central');
INSERT INTO Area (area_id, area_name) VALUES (2, 'North');
INSERT INTO Area (area_id, area_name) VALUES (3, 'South');
INSERT INTO Area (area_id, area_name) VALUES (4, 'Jerusalem');
INSERT INTO Area (area_id, area_name) VALUES (5, 'Tel Aviv District');

-- 2. אכלוס טבלת City (שיטה: Mockaroo/Data Import)
INSERT INTO City (city_id, city_name, area_id) VALUES (1, 'Tel Aviv', 5);
INSERT INTO City (city_id, city_name, area_id) VALUES (2, 'Haifa', 2);
INSERT INTO City (city_id, city_name, area_id) VALUES (3, 'Rishon LeZion', 1);
INSERT INTO City (city_id, city_name, area_id) VALUES (4, 'Ashdod', 3);
INSERT INTO City (city_id, city_name, area_id) VALUES (5, 'Jerusalem City', 4);

-- 3. אכלוס טבלת Agent (שיטה: Mockaroo)
INSERT INTO Agent (agent_id, first_name, last_name, hire_date) VALUES (1, 'Yossi', 'Cohen', '2022-01-15');
INSERT INTO Agent (agent_id, first_name, last_name, hire_date) VALUES (2, 'Dana', 'Levi', '2021-05-20');
INSERT INTO Agent (agent_id, first_name, last_name, hire_date) VALUES (3, 'Ron', 'Shalom', '2023-10-02');

-- 4. אכלוס טבלת Client (שיטה: Mockaroo)
INSERT INTO Client (client_id, first_name, last_name, phone) VALUES (1, 'Avi', 'Peretz', '050-1112233');
INSERT INTO Client (client_id, first_name, last_name, phone) VALUES (2, 'Michal', 'Ziv', '052-4445566');
INSERT INTO Client (client_id, first_name, last_name, phone) VALUES (3, 'Noam', 'Erez', '054-7778899');

-- 5. אכלוס טבלת Amenity (שיטה: ידנית)
INSERT INTO Amenity (amenity_id, amenity_name) VALUES (1, 'Pool');
INSERT INTO Amenity (amenity_id, amenity_name) VALUES (2, 'Elevator');
INSERT INTO Amenity (amenity_id, amenity_name) VALUES (3, 'Parking');
INSERT INTO Amenity (amenity_id, amenity_name) VALUES (4, 'Balcony');
INSERT INTO Amenity (amenity_id, amenity_name) VALUES (5, 'Gym');

-- 6. אכלוס טבלת Property (שיטה: Python Script - 20,000 שורות)
-- כאן עליך להדביק את הפלט שנוצר מהסקריפט שנתתי לך קודם
INSERT INTO Property (property_id, address, price, city_id, agent_id) VALUES (1, 'Herzl 10, Tel Aviv', 2500000, 1, 1);
INSERT INTO Property (property_id, address, price, city_id, agent_id) VALUES (2, 'Ben Gurion 5, Haifa', 1800000, 2, 2);
-- ... להמשיך עד 20,000

-- 7. אכלוס טבלאות ירושה (שיטה: CSV Import)
-- דוגמה ל-Residential
INSERT INTO Residential (property_id, bedrooms, has_balcony) VALUES (1, 3, 'Y');
-- דוגמה ל-Commercial
INSERT INTO Commercial (property_id, business_type, has_license) VALUES (2, 'Office', 'Y');

-- 8. אכלוס טבלת Schedule (שיטה: Python Script - 20,000 שורות)
-- כאן עליך להדביק את הפלט מהסקריפט
INSERT INTO Schedule (schedule_id, meeting_date, status, agent_id, client_id, property_id) VALUES (1, '2024-06-01', 'Scheduled', 1, 1, 1);
INSERT INTO Schedule (schedule_id, meeting_date, status, agent_id, client_id, property_id) VALUES (2, '2024-06-02', 'Completed', 2, 2, 2);

-- 9. אכלוס טבלת Contract (שיטה: Data Import)
INSERT INTO Contract (contract_id, signature_date, final_price, client_id, property_id) VALUES (1, '2024-01-10', 2450000, 1, 1);

-- 10. אכלוס טבלת AgentReview (ישות חלשה)
INSERT INTO AgentReview (review_id, agent_id, rating, review_text) VALUES (1, 1, 5, 'Great service!');
INSERT INTO AgentReview (review_id, agent_id, rating, review_text) VALUES (2, 2, 4, 'Very professional.');

-- 11. אכלוס טבלת Property_Amenity (קשר M:N)
INSERT INTO Property_Amenity (property_id, amenity_id) VALUES (1, 1);
INSERT INTO Property_Amenity (property_id, amenity_id) VALUES (1, 2);
INSERT INTO Property_Amenity (property_id, amenity_id) VALUES (2, 3);