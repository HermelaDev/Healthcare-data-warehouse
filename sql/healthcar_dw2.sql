SELECT *
FROM dim_patient
LIMIT 10;

SELECT COUNT(*) FROM dim_patient;

SELECT *
FROM dim_admission
LIMIT 10;

SELECT COUNT(*) 
FROM dim_admission;

SELECT *
FROM dim_diagnosis
LIMIT 10;

SELECT COUNT(*) 
FROM dim_diagnosis;

SELECT COUNT(*)
FROM fact_hospital_admission;


TRUNCATE TABLE fact_hospital_admission RESTART IDENTITY;

SELECT COUNT(*) FROM fact_hospital_admission;

SELECT COUNT(*) FROM fact_hospital_admission;

SELECT *
FROM fact_hospital_admission
LIMIT 10;

SELECT * FROM dim_patient_contact;

SELECT * FROM dim_country;


-- Basic sanity checks
-- How many rows in each table?

SELECT 'dim_patient' AS table_name, COUNT(*) AS row_count FROM dim_patient
UNION ALL
SELECT 'dim_admission', COUNT(*) FROM dim_admission
UNION ALL
SELECT 'dim_diagnosis', COUNT(*) FROM dim_diagnosis
UNION ALL
SELECT 'fact_hospital_admission', COUNT(*) FROM fact_hospital_admission;



-- Readmission rate within 30 days
SELECT 
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN readmitted_30d_flag THEN 1 ELSE 0 END) AS readmitted_30d,
    ROUND(
        100.0 * SUM(CASE WHEN readmitted_30d_flag THEN 1 ELSE 0 END) 
        / NULLIF(COUNT(*), 0),
        2
    ) AS readmission_rate_30d_pct
FROM fact_hospital_admission;



-- Average length of stay by age band and 30-day readmission
SELECT 
    p.age_band,
    f.readmitted_30d_flag,
    COUNT(*) AS encounters,
    ROUND(AVG(f.time_in_hospital), 2) AS avg_time_in_hospital
FROM fact_hospital_admission f
JOIN dim_patient p
    ON f.patient_key = p.patient_key
GROUP BY p.age_band, f.readmitted_30d_flag
ORDER BY p.age_band, f.readmitted_30d_flag;


-- Top 10 primary diagnoses by number of encounters
SELECT 
    d.diagnosis_code,
    COUNT(*) AS encounter_count
FROM fact_hospital_admission f
JOIN dim_diagnosis d
    ON f.primary_diagnosis_key = d.diagnosis_key
GROUP BY d.diagnosis_code
ORDER BY encounter_count DESC
LIMIT 10;



-- Encounters by admission type
SELECT 
    a.admission_type_id,
    COUNT(*) AS encounter_count
FROM fact_hospital_admission f
JOIN dim_admission a
    ON f.admission_dim_key = a.admission_dim_key
GROUP BY a.admission_type_id
ORDER BY encounter_count DESC;

-- MySQL
-- Create dim_patient_contact
CREATE TABLE IF NOT EXISTS dim_patient_contact (
    patient_contact_key  SERIAL PRIMARY KEY,
    patient_nbr          BIGINT NOT NULL,
    phone                VARCHAR(20),
    city                 VARCHAR(50),
    country              VARCHAR(50)
);


-- API
-- Create dim_country table
CREATE TABLE IF NOT EXISTS dim_country (
    country_key    SERIAL PRIMARY KEY,
    country_name   VARCHAR(100),
    iso2_code      VARCHAR(5),
    region         VARCHAR(100),
    subregion      VARCHAR(100),
    population     BIGINT,
    source_system  VARCHAR(50)
);


-- Load into dim_country in PostgreSQL
CREATE TABLE IF NOT EXISTS dim_country (
    country_key    SERIAL PRIMARY KEY,
    country_name   VARCHAR(100),
    iso2_code      VARCHAR(5),
    region         VARCHAR(100),
    subregion      VARCHAR(100),
    population     BIGINT,
    source_system  VARCHAR(50)
);



-- 1. Indexing strategy
-- 1.1. Indexes on the fact table

-- Ensure primary key on the fact table
ALTER TABLE fact_hospital_admission
ADD CONSTRAINT pk_fact_hospital_admission
PRIMARY KEY (encounter_id);

SELECT conname, contype
FROM pg_constraint
WHERE conrelid = 'fact_hospital_admission'::regclass;


-- Join indexes on fact table
CREATE INDEX idx_fact_patient_key
    ON fact_hospital_admission (patient_key);

CREATE INDEX idx_fact_admission_dim_key
    ON fact_hospital_admission (admission_dim_key);

CREATE INDEX idx_fact_primary_diagnosis_key
    ON fact_hospital_admission (primary_diagnosis_key);

CREATE INDEX idx_fact_secondary_diagnosis_key
    ON fact_hospital_admission (secondary_diagnosis_key);

CREATE INDEX idx_fact_tertiary_diagnosis_key
    ON fact_hospital_admission (tertiary_diagnosis_key);

-- Filter index
CREATE INDEX idx_fact_readmitted_30d_flag
    ON fact_hospital_admission (readmitted_30d_flag);


-- 2. Partitioning the Fact Table

-- 2.1 Create the partitioned parent table
CREATE TABLE fact_hospital_admission_parted (
    encounter_id            BIGINT,
    patient_key             INTEGER,
    admission_dim_key       INTEGER,
    primary_diagnosis_key   INTEGER,
    secondary_diagnosis_key INTEGER,
    tertiary_diagnosis_key  INTEGER,
    time_in_hospital        INTEGER,
    num_lab_procedures      INTEGER,
    num_procedures          INTEGER,
    num_medications         INTEGER,
    number_outpatient       INTEGER,
    number_emergency        INTEGER,
    number_inpatient        INTEGER,
    number_diagnoses        INTEGER,
    readmitted_raw          VARCHAR(20),
    readmitted_30d_flag     BOOLEAN,
    change                  VARCHAR(10),
    diabetesmed             VARCHAR(10),
    source_system           VARCHAR(50)
)
PARTITION BY RANGE (time_in_hospital);


-- 2.2 Create partitions by length of stay

CREATE TABLE fact_hosp_stay_0_3
    PARTITION OF fact_hospital_admission_parted
    FOR VALUES FROM (0) TO (4);

CREATE TABLE fact_hosp_stay_4_7
    PARTITION OF fact_hospital_admission_parted
    FOR VALUES FROM (4) TO (8);

CREATE TABLE fact_hosp_stay_8_15
    PARTITION OF fact_hospital_admission_parted
    FOR VALUES FROM (8) TO (16);

-- Catch-all for extreme long stays
CREATE TABLE fact_hosp_stay_16_plus
    PARTITION OF fact_hospital_admission_parted
    FOR VALUES FROM (16) TO (1000);


-- 2.3 Copy data from the original fact table
INSERT INTO fact_hospital_admission_parted
SELECT
    encounter_id,
    patient_key,
    admission_dim_key,
    primary_diagnosis_key,
    secondary_diagnosis_key,
    tertiary_diagnosis_key,
    time_in_hospital,
    num_lab_procedures,
    num_procedures,
    num_medications,
    number_outpatient,
    number_emergency,
    number_inpatient,
    number_diagnoses,
    readmitted_raw,
    readmitted_30d_flag,
    change,
    diabetesmed,
    source_system
FROM fact_hospital_admission;


-- Check counts:
SELECT COUNT(*) FROM fact_hospital_admission;
SELECT COUNT(*) FROM fact_hospital_admission_parted;

-- Optional: check how many rows landed in each partition
SELECT '0-3'  AS bucket, COUNT(*) FROM fact_hosp_stay_0_3
UNION ALL
SELECT '4-7', COUNT(*) FROM fact_hosp_stay_4_7
UNION ALL
SELECT '8-15', COUNT(*) FROM fact_hosp_stay_8_15
UNION ALL
SELECT '16+', COUNT(*) FROM fact_hosp_stay_16_plus;


-- 2.4 Add indexes on the partitioned table
ALTER TABLE fact_hospital_admission_parted
ADD CONSTRAINT fact_hospital_admission_parted_pkey
PRIMARY KEY (encounter_id, time_in_hospital);


CREATE INDEX idx_fact_parted_patient_key
    ON fact_hospital_admission_parted (patient_key);

CREATE INDEX idx_fact_parted_readmitted_30d_flag
    ON fact_hospital_admission_parted (readmitted_30d_flag);

-- Quick sanity check for partitioned fact table
-- How many rows in the original vs partitioned table?
SELECT 'original' AS table_name, COUNT(*) AS rows
FROM fact_hospital_admission
UNION ALL
SELECT 'partitioned' AS table_name, COUNT(*) AS rows
FROM fact_hospital_admission_parted;


SELECT '0-3'  AS stay_bucket, COUNT(*) AS rows FROM fact_hosp_stay_0_3
UNION ALL
SELECT '4-7', COUNT(*) FROM fact_hosp_stay_4_7
UNION ALL
SELECT '8-15', COUNT(*) FROM fact_hosp_stay_8_15
UNION ALL
SELECT '16+', COUNT(*) FROM fact_hosp_stay_16_plus;


-- Analytical Queries
-- Q1. Overall 30-day readmission rate
SELECT
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN readmitted_30d_flag THEN 1 ELSE 0 END) AS readmitted_30d,
    ROUND(
        100.0 * SUM(CASE WHEN readmitted_30d_flag THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS readmission_rate_30d_pct
FROM fact_hospital_admission_parted;


-- Q2. Readmission by age band and gender
SELECT
    p.age_band,
    p.gender,
    COUNT(*) AS encounters,
    SUM(CASE WHEN f.readmitted_30d_flag THEN 1 ELSE 0 END) AS readmitted_30d,
    ROUND(
        100.0 * SUM(CASE WHEN f.readmitted_30d_flag THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS readmission_rate_30d_pct
FROM fact_hospital_admission_parted f
JOIN dim_patient p
    ON f.patient_key = p.patient_key
GROUP BY p.age_band, p.gender
ORDER BY p.age_band, p.gender;


-- Q3. Readmission by country/region (this proves multi-source integration)
SELECT
    cty.country_name,
    cty.region,
    COUNT(*) AS encounters,
    SUM(CASE WHEN f.readmitted_30d_flag THEN 1 ELSE 0 END) AS readmitted_30d,
    ROUND(
        100.0 * SUM(CASE WHEN f.readmitted_30d_flag THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS readmission_rate_30d_pct
FROM fact_hospital_admission_parted f
JOIN dim_patient p
    ON f.patient_key = p.patient_key
JOIN dim_patient_contact pc
    ON p.patient_nbr = pc.patient_nbr
JOIN dim_country cty
    ON pc.country = cty.country_name
GROUP BY cty.country_name, cty.region
ORDER BY readmission_rate_30d_pct DESC;


--Q4. Length of stay buckets (ties into partitioning)
SELECT
    CASE
        WHEN f.time_in_hospital BETWEEN 0 AND 3  THEN '0–3 days'
        WHEN f.time_in_hospital BETWEEN 4 AND 7  THEN '4–7 days'
        WHEN f.time_in_hospital BETWEEN 8 AND 15 THEN '8–15 days'
        ELSE '16+ days'
    END AS stay_bucket,
    COUNT(*) AS encounters,
    SUM(CASE WHEN f.readmitted_30d_flag THEN 1 ELSE 0 END) AS readmitted_30d,
    ROUND(
        100.0 * SUM(CASE WHEN f.readmitted_30d_flag THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS readmission_rate_30d_pct
FROM fact_hospital_admission_parted f
GROUP BY stay_bucket
ORDER BY stay_bucket;



-- Q5. By diagnosis group (optional but nice)
SELECT
    d.diagnosis_group,
    COUNT(*) AS encounters,
    ROUND(AVG(f.time_in_hospital), 2) AS avg_length_of_stay_days
FROM fact_hospital_admission_parted f
JOIN dim_diagnosis d
    ON f.primary_diagnosis_key = d.diagnosis_key
GROUP BY d.diagnosis_group
ORDER BY avg_length_of_stay_days DESC;