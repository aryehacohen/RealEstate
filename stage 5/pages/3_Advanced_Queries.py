import streamlit as st
import pandas as pd
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from db_utils import run_query

st.set_page_config(page_title="שאילתות מתקדמות", page_icon="📊", layout="wide")

if 'authenticated' not in st.session_state or not st.session_state['authenticated']:
    st.warning("אנא התחבר דרך המסך הראשי תחילה.")
    st.stop()

st.title("שאילתות מתקדמות (שלב ב') 📊")
st.markdown("כאן תוכלו להריץ שאילתות מורכבות ולצפות בדוחות.")

st.subheader("1. נכסים שמחירם גבוה מהממוצע בעיר שלהם")
st.markdown("שאילתא שמציגה את כל הנכסים שהמחיר שלהם יקר יותר מהמחיר הממוצע של הנכסים באותה העיר.")
if st.button("הרץ שאילתא 1"):
    q1 = """
        SELECT p.address AS "כתובת", p.price AS "מחיר", c.city_name AS "עיר"
        FROM Property p 
        JOIN City c ON p.city_id = c.city_id 
        WHERE p.price > (
            SELECT AVG(price) 
            FROM Property 
            WHERE city_id = p.city_id
        )
    """
    res1 = run_query(q1)
    if not res1.empty:
        st.dataframe(res1, use_container_width=True)
    else:
        st.info("אין נתונים התואמים לשאילתא זו.")

st.markdown("---")

st.subheader("2. כמות נכסים המטופלים לכל סוכן")
st.markdown("דוח המציג לכל סוכן נדל״ן כמה נכסים נמצאים תחת טיפולו במערכת, בעזרת `LEFT JOIN` ו-`GROUP BY`.")
if st.button("הרץ שאילתא 2"):
    q2 = """
        SELECT 
            a.first_name || ' ' || a.last_name AS "שם הסוכן", 
            COUNT(p.property_id) AS "כמות נכסים בטיפול"
        FROM Agent a 
        LEFT JOIN Property p ON a.agent_id = p.agent_id 
        GROUP BY a.agent_id, a.first_name, a.last_name
        ORDER BY "כמות נכסים בטיפול" DESC
    """
    res2 = run_query(q2)
    if not res2.empty:
        st.dataframe(res2, use_container_width=True)
    else:
        st.info("אין נתונים התואמים לשאילתא זו.")
