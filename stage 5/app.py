import streamlit as st

st.set_page_config(page_title="Real Estate & Mortgage DB", page_icon="🏠", layout="wide")

st.title("מערכת ניהול נדל״ן ומשכנתאות 🏠")
st.markdown("ברוכים הבאים למערכת הניהול. אנא התחברו על מנת לגשת למסכים השונים.")

# Initialize session state for authentication
if 'authenticated' not in st.session_state:
    st.session_state['authenticated'] = False

if not st.session_state['authenticated']:
    st.subheader("התחברות למערכת")
    with st.form("login_form"):
        username = st.text_input("שם משתמש (Username)")
        password = st.text_input("סיסמה (Password)", type="password")
        submit_button = st.form_submit_button("התחבר")
        
        if submit_button:
            if username == "admin" and password == "admin":
                st.session_state['authenticated'] = True
                st.success("התחברת בהצלחה! אנא השתמש בתפריט הצדדי כדי לנווט.")
                st.rerun()
            else:
                st.error("שם משתמש או סיסמה שגויים. (נסה admin / admin)")
else:
    st.success("אתה מחובר כמנהל (admin). בחר מסך מהתפריט הצדדי.")
    
    st.markdown("""
    ### מה ניתן לעשות במערכת?
    * **ניהול נכסים:** הוספה, עריכה, מחיקה וצפייה בנכסים (מציג את שמות הערים והסוכנים במקום מזהים).
    * **לקוחות ומשכנתאות:** ניהול לקוחות והלוואות תוך כדי חיבור לטבלאות השונות.
    * **שאילתות מתקדמות:** הרצת השאילתות שנכתבו בשלב ב' כדי להפיק דוחות.
    * **פרוצדורות ופונקציות:** הרצת קטעי הקוד המורכבים שנכתבו ב-PL/pgSQL בשלב ד'.
    
    **הגדרות בסיס נתונים:** 
    כדי שהמערכת תעבוד, יש לוודא שיש לכם שרת PostgreSQL רץ מקומית עם פרטי ההתחברות המוגדרים בקובץ `db_utils.py`.
    """)
