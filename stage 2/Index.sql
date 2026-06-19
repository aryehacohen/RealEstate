-- אינדקס 1: על עיר הנכס
CREATE INDEX idx_property_city ON Property(city_id);

-- אינדקס 2: על תאריך פגישה
CREATE INDEX idx_schedule_date ON Schedule(meeting_date);

-- אינדקס 3: על סטטוס פגישה
CREATE INDEX idx_schedule_status ON Schedule(status);