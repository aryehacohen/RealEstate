import streamlit as st
import pandas as pd
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from db_utils import run_query

st.set_page_config(page_title="פרוצדורות ופונקציות", page_icon="⚙️", layout="wide")

if 'authenticated' not in st.session_state or not st.session_state['authenticated']:
    st.warning("אנא התחבר דרך המסך הראשי תחילה.")
    st.stop()

st.title("פרוצדורות ופונקציות מתקדמות (שלב ד') ⚙️")
st.markdown("כאן ניתן להריץ את הלוגיקה העסקית המתקדמת שכתבנו ב-PL/pgSQL.")

st.subheader("1. עדכון אוטומטי של סטטוס הלוואות")
st.markdown("פרוצדורה זו (`proc_update_loan_status`) רצה על כל ההלוואות שממתינות לאישור ('Pending'). היא מחשבת את יחס הסיכון ודירוג האשראי, ומעדכנת את הסטטוס ל-'Approved' או 'Rejected'.")

if st.button("הפעל פרוצדורת עדכון משכנתאות"):
    # CALL procedure
    success = run_query("CALL update_pending_loans()", fetch=False)
    if success:
        st.success("הפרוצדורה רצה בהצלחה! סטטוס ההלוואות הרלוונטיות עודכן במסד הנתונים.")
        # Show the updated status
        df = run_query("SELECT loan_id, loan_amount, status FROM MortgageLoan")
        st.dataframe(df)

st.markdown("---")

st.subheader("2. יומן מעקב לקוחות בסיכון")
st.markdown("פרוצדורה זו (`log_high_risk_clients`) סורקת את כל הלקוחות שיש להם משכנתא ודירוג האשראי שלהם נמוך מ-600, ומוסיפה אותם לטבלת המעקב `HighRiskLog`.")

if st.button("הפעל פרוצדורת סימון לקוחות בסיכון"):
    # CALL procedure
    success = run_query("CALL log_high_risk_clients()", fetch=False)
    if success:
        st.success("הפרוצדורה רצה בהצלחה! לקוחות רלוונטיים נשמרו ביומן.")
        df = run_query("SELECT * FROM HighRiskLog")
        if not df.empty:
            st.dataframe(df)
        else:
            st.info("טבלת היומן ריקה. לא נמצאו לקוחות מתחת לדירוג האשראי שדורש סימון.")
