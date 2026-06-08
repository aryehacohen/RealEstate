-- יצירת טבלאות בסיס
CREATE TABLE Area (
    area_id INT PRIMARY KEY,
    area_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE City (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(50) NOT NULL,
    area_id INT,
    CONSTRAINT fk_area FOREIGN KEY (area_id) REFERENCES Area(area_id)
);

CREATE TABLE Agent (
    agent_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    hire_date DATE DEFAULT CURRENT_DATE,
    CONSTRAINT chk_hire_date CHECK (hire_date <= CURRENT_DATE)
);

CREATE TABLE Client (
    client_id INT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL
);

CREATE TABLE Property (
    property_id INT PRIMARY KEY,
    address VARCHAR(100) NOT NULL,
    price NUMERIC(12, 2) NOT NULL,
    city_id INT,
    agent_id INT,
    CONSTRAINT fk_prop_city FOREIGN KEY (city_id) REFERENCES City(city_id),
    CONSTRAINT fk_prop_agent FOREIGN KEY (agent_id) REFERENCES Agent(agent_id),
    CONSTRAINT chk_price CHECK (price > 0)
);

-- ירושה: נכס מגורים
CREATE TABLE Residential (
    property_id INT PRIMARY KEY,
    bedrooms INT NOT NULL,
    has_balcony CHAR(1) CHECK (has_balcony IN ('Y', 'N')),
    CONSTRAINT fk_res_id FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE
);

-- ירושה: נכס מסחרי
CREATE TABLE Commercial (
    property_id INT PRIMARY KEY,
    business_type VARCHAR(50),
    has_license CHAR(1) CHECK (has_license IN ('Y', 'N')),
    CONSTRAINT fk_com_id FOREIGN KEY (property_id) REFERENCES Property(property_id) ON DELETE CASCADE
);

CREATE TABLE Amenity (
    amenity_id INT PRIMARY KEY,
    amenity_name VARCHAR(50) NOT NULL UNIQUE
);

-- קשר רבים לרבים
CREATE TABLE Property_Amenity (
    property_id INT,
    amenity_id INT,
    PRIMARY KEY (property_id, amenity_id),
    CONSTRAINT fk_pa_prop FOREIGN KEY (property_id) REFERENCES Property(property_id),
    CONSTRAINT fk_pa_amen FOREIGN KEY (amenity_id) REFERENCES Amenity(amenity_id)
);

CREATE TABLE Schedule (
    schedule_id INT PRIMARY KEY,
    meeting_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Scheduled',
    agent_id INT,
    client_id INT,
    property_id INT,
    CONSTRAINT fk_sch_agent FOREIGN KEY (agent_id) REFERENCES Agent(agent_id),
    CONSTRAINT fk_sch_client FOREIGN KEY (client_id) REFERENCES Client(client_id),
    CONSTRAINT fk_sch_prop FOREIGN KEY (property_id) REFERENCES Property(property_id),
    CONSTRAINT chk_status CHECK (status IN ('Scheduled', 'Completed', 'Cancelled'))
);

CREATE TABLE Contract (
    contract_id INT PRIMARY KEY,
    signature_date DATE NOT NULL,
    final_price NUMERIC(12, 2) NOT NULL,
    client_id INT,
    property_id INT,
    CONSTRAINT fk_con_client FOREIGN KEY (client_id) REFERENCES Client(client_id),
    CONSTRAINT fk_con_prop FOREIGN KEY (property_id) REFERENCES Property(property_id),
    CONSTRAINT chk_final_price CHECK (final_price > 0)
);

-- ישות חלשה
CREATE TABLE AgentReview (
    review_id INT PRIMARY KEY,
    agent_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    review_text VARCHAR(500),
    CONSTRAINT fk_rev_agent FOREIGN KEY (agent_id) REFERENCES Agent(agent_id) ON DELETE CASCADE
);