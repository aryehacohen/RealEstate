import streamlit as st
import pandas as pd
import sys
import os

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from db_utils import run_query

st.set_page_config(page_title="לקוחות ומשכנתאות", page_icon="👥", layout="wide")

if 'authenticated' not in st.session_state or not st.session_state['authenticated']:
    st.warning("אנא התחבר דרך המסך הראשי תחילה.")
    st.stop()

st.title("ניהול לקוחות ומשכנתאות 👥")

# --- Helpers ---
def get_clients():
    df = run_query("SELECT client_id, first_name || ' ' || last_name AS full_name FROM Client")
    return df.set_index('full_name')['client_id'].to_dict() if not df.empty else {}

def get_properties():
    df = run_query("SELECT property_id, address FROM Property")
    return df.set_index('address')['property_id'].to_dict() if not df.empty else {}

# --- Mortgages CRUD ---
st.header("הלוואות משכנתא (Mortgages)")
tab_view_m, tab_insert_m, tab_update_m, tab_delete_m = st.tabs(["צפייה בהלוואות", "הוספת הלוואה", "עדכון הלוואה", "מחיקת הלוואה"])

with tab_view_m:
    query_view_m = """
        SELECT 
            m.loan_id AS "מזהה הלוואה", 
            c.first_name || ' ' || c.last_name AS "שם לקוח", 
            p.address AS "כתובת נכס", 
            m.loan_amount AS "סכום", 
            m.interest_rate AS "ריבית", 
            m.status AS "סטטוס"
        FROM MortgageLoan m
        LEFT JOIN Client c ON m.client_id = c.client_id
        LEFT JOIN Property p ON m.property_id = p.property_id
        ORDER BY m.loan_id
    """
    df_mortgages = run_query(query_view_m)
    if not df_mortgages.empty:
        st.dataframe(df_mortgages, use_container_width=True)
    else:
        st.info("אין נתונים להצגה.")

with tab_insert_m:
    with st.form("insert_loan_form"):
        loan_id = st.number_input("מזהה הלוואה (Loan ID)", min_value=1, step=1)
        loan_amount = st.number_input("סכום (Amount)", min_value=1000.0, step=10000.0)
        interest_rate = st.number_input("ריבית (Interest Rate %)", min_value=0.1, step=0.1)
        status = st.selectbox("סטטוס", ["Pending", "Approved", "Rejected"])
        
        clients = get_clients()
        properties = get_properties()
        
        selected_client = st.selectbox("לקוח (Client)", options=list(clients.keys()) if clients else [""])
        selected_property = st.selectbox("נכס (Property)", options=list(properties.keys()) if properties else [""])
        
        if st.form_submit_button("הוסף הלוואה"):
            if selected_client and selected_property:
                query = "INSERT INTO MortgageLoan (loan_id, client_id, property_id, loan_amount, interest_rate, status) VALUES (%s, %s, %s, %s, %s, %s)"
                if run_query(query, (loan_id, clients[selected_client], properties[selected_property], loan_amount, interest_rate, status), fetch=False):
                    st.success("ההלוואה נוספה בהצלחה!")
                    st.rerun()

with tab_update_m:
    upd_loan_id = st.number_input("הזן מזהה הלוואה לעדכון", min_value=1, step=1)
    if upd_loan_id:
        existing_loan = run_query("SELECT client_id, property_id, loan_amount, interest_rate, status FROM MortgageLoan WHERE loan_id=%s", (upd_loan_id,))
        if not existing_loan.empty:
            row = existing_loan.iloc[0]
            with st.form("update_loan_form"):
                new_amount = st.number_input("סכום", min_value=1000.0, value=float(row['loan_amount']), step=10000.0)
                new_interest = st.number_input("ריבית", min_value=0.1, value=float(row['interest_rate']), step=0.1)
                
                statuses = ["Pending", "Approved", "Rejected"]
                stat_idx = statuses.index(row['status']) if row['status'] in statuses else 0
                new_status = st.selectbox("סטטוס", statuses, index=stat_idx)
                
                if st.form_submit_button("עדכן הלוואה"):
                    q = "UPDATE MortgageLoan SET loan_amount=%s, interest_rate=%s, status=%s WHERE loan_id=%s"
                    if run_query(q, (new_amount, new_interest, new_status, upd_loan_id), fetch=False):
                        st.success("עודכן בהצלחה!")
                        st.rerun()
        else:
            st.warning("לא נמצאה הלוואה.")

with tab_delete_m:
    with st.form("delete_loan_form"):
        del_id = st.number_input("מזהה למחיקה", min_value=1, step=1)
        if st.form_submit_button("מחק הלוואה"):
            if not run_query("SELECT 1 FROM MortgageLoan WHERE loan_id=%s", (del_id,)).empty:
                if run_query("DELETE FROM MortgageLoan WHERE loan_id=%s", (del_id,), fetch=False):
                    st.success("נמחק בהצלחה!")
                    st.rerun()
            else:
                st.error("לא נמצא.")
