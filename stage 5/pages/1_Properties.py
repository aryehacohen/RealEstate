import streamlit as st
import pandas as pd
import sys
import os

# Add parent directory to path so we can import db_utils
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from db_utils import run_query

st.set_page_config(page_title="ניהול נכסים", page_icon="🏢", layout="wide")

if 'authenticated' not in st.session_state or not st.session_state['authenticated']:
    st.warning("אנא התחבר דרך המסך הראשי תחילה.")
    st.stop()

st.title("ניהול נכסים 🏢")

# --- Helper functions to load dropdown data ---
def get_cities():
    df = run_query("SELECT city_id, city_name FROM City")
    return df.set_index('city_name')['city_id'].to_dict() if not df.empty else {}

def get_agents():
    df = run_query("SELECT agent_id, first_name || ' ' || last_name AS agent_name FROM Agent")
    return df.set_index('agent_name')['agent_id'].to_dict() if not df.empty else {}

# --- Tabs for CRUD operations ---
tab_view, tab_insert, tab_update, tab_delete = st.tabs(["צפייה בנכסים", "הוספת נכס חדש", "עדכון נכס", "מחיקת נכס"])

# 1. View Data (Read)
with tab_view:
    st.subheader("רשימת נכסים קיימים")
    query_view = """
        SELECT 
            p.property_id AS "מזהה נכס", 
            p.address AS "כתובת", 
            p.price AS "מחיר", 
            c.city_name AS "עיר", 
            a.first_name || ' ' || a.last_name AS "שם סוכן"
        FROM Property p
        LEFT JOIN City c ON p.city_id = c.city_id
        LEFT JOIN Agent a ON p.agent_id = a.agent_id
        ORDER BY p.property_id
    """
    df_props = run_query(query_view)
    if not df_props.empty:
        st.dataframe(df_props, use_container_width=True)
    else:
        st.info("לא נמצאו נכסים או שיש בעיה בחיבור למסד הנתונים.")

# 2. Insert Data (Create)
with tab_insert:
    st.subheader("הוספת נכס חדש")
    with st.form("insert_property_form"):
        prop_id = st.number_input("מזהה נכס (Property ID)", min_value=1, step=1)
        address = st.text_input("כתובת (Address)")
        price = st.number_input("מחיר (Price)", min_value=1.0, step=1000.0)
        
        cities = get_cities()
        agents = get_agents()
        
        selected_city = st.selectbox("עיר (City)", options=list(cities.keys()) if cities else [""])
        selected_agent = st.selectbox("סוכן מטפל (Agent)", options=list(agents.keys()) if agents else [""])
        
        submit_insert = st.form_submit_button("הוסף נכס")
        
        if submit_insert:
            if address and selected_city and selected_agent:
                city_id = cities[selected_city]
                agent_id = agents[selected_agent]
                
                query_insert = "INSERT INTO Property (property_id, address, price, city_id, agent_id) VALUES (%s, %s, %s, %s, %s)"
                success = run_query(query_insert, (prop_id, address, price, city_id, agent_id), fetch=False)
                if success:
                    st.success("הנכס נוסף בהצלחה!")
                    st.rerun()
            else:
                st.error("אנא מלא את כל השדות.")

# 3. Update Data (Update)
with tab_update:
    st.subheader("עדכון נכס קיים")
    st.markdown("הכנס מזהה נכס ולחץ על אנטר כדי למשוך את הנתונים הקיימים.")
    
    update_prop_id = st.number_input("הזן מזהה נכס לעדכון (Property ID)", min_value=1, step=1, key="upd_prop_id")
    
    # Fetch existing data
    if update_prop_id:
        existing_data = run_query("SELECT address, price, city_id, agent_id FROM Property WHERE property_id = %s", (update_prop_id,))
        
        if not existing_data.empty:
            row = existing_data.iloc[0]
            
            with st.form("update_property_form"):
                new_address = st.text_input("כתובת (Address)", value=row['address'])
                new_price = st.number_input("מחיר (Price)", min_value=1.0, value=float(row['price']), step=1000.0)
                
                cities = get_cities()
                agents = get_agents()
                
                # Find current index for selectbox
                city_names = list(cities.keys())
                agent_names = list(agents.keys())
                
                current_city_name = [k for k, v in cities.items() if v == row['city_id']]
                current_agent_name = [k for k, v in agents.items() if v == row['agent_id']]
                
                city_idx = city_names.index(current_city_name[0]) if current_city_name else 0
                agent_idx = agent_names.index(current_agent_name[0]) if current_agent_name else 0
                
                new_city = st.selectbox("עיר (City)", options=city_names, index=city_idx)
                new_agent = st.selectbox("סוכן מטפל (Agent)", options=agent_names, index=agent_idx)
                
                submit_update = st.form_submit_button("עדכן נכס")
                if submit_update:
                    query_update = "UPDATE Property SET address=%s, price=%s, city_id=%s, agent_id=%s WHERE property_id=%s"
                    success = run_query(query_update, (new_address, new_price, cities[new_city], agents[new_agent], update_prop_id), fetch=False)
                    if success:
                        st.success("הנכס עודכן בהצלחה!")
                        st.rerun()
        else:
            st.warning("לא נמצא נכס עם מזהה זה.")

# 4. Delete Data (Delete)
with tab_delete:
    st.subheader("מחיקת נכס")
    with st.form("delete_property_form"):
        del_prop_id = st.number_input("מזהה נכס למחיקה (Property ID)", min_value=1, step=1)
        st.warning("פעולה זו בלתי הפיכה ותמחק גם רשומות מקושרות (אם יש ON DELETE CASCADE).")
        submit_delete = st.form_submit_button("מחק נכס")
        
        if submit_delete:
            query_check = "SELECT 1 FROM Property WHERE property_id = %s"
            if not run_query(query_check, (del_prop_id,)).empty:
                query_del = "DELETE FROM Property WHERE property_id = %s"
                success = run_query(query_del, (del_prop_id,), fetch=False)
                if success:
                    st.success("הנכס נמחק בהצלחה!")
                    st.rerun()
            else:
                st.error("לא נמצא נכס עם מזהה זה.")
