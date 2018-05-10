-- Table: point_of_interest
CREATE TABLE point_of_interest ( 
    id        INTEGER PRIMARY KEY,
    type      INTEGER REFERENCES point_of_interest_type ( id ),
    latitude  DOUBLE,
    longitude DOUBLE,
    title     TEXT,
    url       TEXT
);

-- Table: point_of_interest_type
CREATE TABLE point_of_interest_type ( 
    id   INTEGER PRIMARY KEY,
    name TEXT 
);
