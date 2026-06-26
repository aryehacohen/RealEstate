import random
from datetime import datetime, timedelta

# פונקציה לייצור תאריך אקראי
def random_date(start_year=2020, end_year=2024):
    start = datetime(start_year, 1, 1)
    end = datetime(end_year, 12, 31)
    return (start + timedelta(days=random.randint(0, (end - start).days))).strftime('%Y-%m-%d')

# יצירת 20,000 נכסים (Property)
with open('insert_massive.sql', 'w', encoding='utf-8') as f:
    f.write("-- Inserting 20,000 Properties\n")
    for i in range(1, 20001):
        address = f"Street {random.randint(1, 1000)}, House {random.randint(1, 200)}"
        price = random.randint(500000, 10000000)
        city_id = random.randint(1, 500) # בהנחה שיש 500 ערים
        agent_id = random.randint(1, 500)
        f.write(f"INSERT INTO Property (property_id, address, price, city_id, agent_id) VALUES ({i}, '{address}', {price}, {city_id}, {agent_id});\n")

    f.write("\n-- Inserting 20,000 Schedules\n")
    for i in range(1, 20001):
        m_date = random_date()
        status = random.choice(['Scheduled', 'Completed', 'Cancelled'])
        agent_id = random.randint(1, 500)
        client_id = random.randint(1, 500)
        prop_id = random.randint(1, 20000)
        f.write(f"INSERT INTO Schedule (schedule_id, meeting_date, status, agent_id, client_id, property_id) VALUES ({i}, '{m_date}', '{status}', {agent_id}, {client_id}, {prop_id});\n")

print("File insert_massive.sql created successfully!")