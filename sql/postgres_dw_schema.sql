-- sql/postgres_dw_schema.sql

-- CREATE DATABASE hospital_dw;

-- \c hospital_dw;

-- DIM PATIENT
DROP TABLE IF EXISTS dim_patient CASCADE;

CREATE TABLE dim_patient (
    patient_key      SERIAL PRIMARY KEY,
    patient_nbr      BIGINT UNIQUE,
    race             VARCHAR(50),
    gender           VARCHAR(10),
    age_group        VARCHAR(20),
    payer_code       VARCHAR(20),
    source_system    VARCHAR(50)
);

-- DIM ADMISSION
DROP TABLE IF EXISTS dim_admission CASCADE;

CREATE TABLE dim_admission (
    admission_dim_key     SERIAL PRIMARY KEY,
    admission_type        VARCHAR(50),
    discharge_disposition VARCHAR(100),
    admission_source      VARCHAR(100),
    source_system         VARCHAR(50)
);

-- DIM DIAGNOSIS
DROP TABLE IF EXISTS dim_diagnosis CASCADE;

CREATE TABLE dim_diagnosis (
    diagnosis_key     SERIAL PRIMARY KEY,
    diagnosis_code    VARCHAR(20),
    icd_category      VARCHAR(100),
    source_system     VARCHAR(50)
);

-- DIM PATIENT CONTACT (MySQL source)
DROP TABLE IF EXISTS dim_patient_contact CASCADE;

CREATE TABLE dim_patient_contact (
    patient_contact_key SERIAL PRIMARY KEY,
    patient_nbr         BIGINT UNIQUE,
    phone               VARCHAR(20),
    city                VARCHAR(50),
    country             VARCHAR(50),
    source_system       VARCHAR(50)
);

-- DIM COUNTRY (API source)
DROP TABLE IF EXISTS dim_country CASCADE;

CREATE TABLE dim_country (
    country_key    SERIAL PRIMARY KEY,
    country_name   VARCHAR(100),
    iso2_code      VARCHAR(10),
    region         VARCHAR(100),
    subregion      VARCHAR(100),
    diabetes_prevalence NUMERIC(10,4),
    health_expenditure_per_capita NUMERIC(14,4),
    hospital_beds_per_1k NUMERIC(10,4),
    income_level   VARCHAR(50),
    source_system  VARCHAR(50)
);


--  Editing
ALTER TABLE dim_patient
ALTER COLUMN gender TYPE VARCHAR(20);

ALTER TABLE dim_patient_contact
ADD COLUMN country_key INT;

-- Populating it by joining to dim_country
UPDATE dim_patient_contact pc
SET country_key = c.country_key
FROM dim_country c
WHERE pc.country = c.country_name;

-- Adding Add the Foreign Key Constraints
ALTER TABLE fact_hospital_admission_parted
ADD CONSTRAINT fk_fact_patient
FOREIGN KEY (patient_key)
REFERENCES dim_patient(patient_key);

ALTER TABLE fact_hospital_admission_parted
ADD CONSTRAINT fk_fact_admission
FOREIGN KEY (admission_dim_key)
REFERENCES dim_admission(admission_dim_key);

ALTER TABLE fact_hospital_admission_parted
ADD CONSTRAINT fk_fact_primary_diag
FOREIGN KEY (primary_diagnosis_key)
REFERENCES dim_diagnosis(diagnosis_key);

ALTER TABLE fact_hospital_admission_parted
ADD CONSTRAINT fk_fact_secondary_diag
FOREIGN KEY (secondary_diagnosis_key)
REFERENCES dim_diagnosis(diagnosis_key);

ALTER TABLE fact_hospital_admission_parted
ADD CONSTRAINT fk_fact_tertiary_diag
FOREIGN KEY (tertiary_diagnosis_key)
REFERENCES dim_diagnosis(diagnosis_key);

ALTER TABLE dim_patient_contact
ADD CONSTRAINT fk_patient_contact_country
FOREIGN KEY (country_key)
REFERENCES dim_country (country_key);

-- Editing the Schema
-- 1) Link patient_contact -> patient   (snowflake)
ALTER TABLE dim_patient_contact
ADD CONSTRAINT fk_patient_contact_patient
FOREIGN KEY (patient_nbr)
REFERENCES dim_patient (patient_nbr);

-- 2) Link patient_contact -> country   (snowflake again)
ALTER TABLE dim_patient_contact
ADD CONSTRAINT fk_patient_contact_country
FOREIGN KEY (country)
REFERENCES dim_country (country_name);
