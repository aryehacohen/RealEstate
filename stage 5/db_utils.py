import psycopg2
import pandas as pd
import streamlit as st

# Helper to initialize connection
# We use @st.cache_resource so the connection isn't recreated on every rerun
@st.cache_resource
def init_connection():
    try:
        # User: Change these credentials to match your local PostgreSQL setup
        return psycopg2.connect(
            host="localhost",
            database="real_estate", # Change to your DB name
            user="postgres",        # Change to your DB username
            password="admin"        # Change to your DB password
        )
    except Exception as e:
        st.error(f"Failed to connect to database: {e}")
        return None

def run_query(query, params=None, fetch=True):
    conn = init_connection()
    if conn is None:
        return pd.DataFrame() if fetch else False
        
    try:
        with conn.cursor() as cur:
            cur.execute(query, params)
            if fetch:
                # If it's a SELECT query, fetch and return a DataFrame
                if cur.description:
                    columns = [desc[0] for desc in cur.description]
                    return pd.DataFrame(cur.fetchall(), columns=columns)
                else:
                    return pd.DataFrame()
            else:
                # If it's an INSERT/UPDATE/DELETE query
                conn.commit()
                return True
    except Exception as e:
        st.error(f"Query failed: {e}")
        conn.rollback()
        return False
