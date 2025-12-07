-- sql/postgres_indexes_partitioning.sql
-- \c hospital_dw;

DROP TABLE IF EXISTS fact_hospital_admission_parted CASCADE;

CREATE TABLE fact_hospital_admission_parted (
    encounter_id        BIGINT,
    patient_key         INT NOT NULL,
    admission_dim_key   INT NOT NULL,
    primary_diagnosis_key   INT,
    secondary_diagnosis_key INT,
    tertiary_diagnosis_key  INT,
    time_in_hospital        INT NOT NULL,
    num_lab_procedures      INT,
    num_procedures          INT,
    num_medications         INT,
    number_outpatient       INT,
    number_emergency        INT,
    number_inpatient        INT,
    number_diagnoses        INT,
    readmitted_raw          VARCHAR(10),
    readmitted_30d_flag     BOOLEAN,
    change                  VARCHAR(10),
    diabetesmed             VARCHAR(10),
    source_system           VARCHAR(50),
    CONSTRAINT fact_hosp_parted_pkey
        PRIMARY KEY (encounter_id, time_in_hospital)
) PARTITION BY RANGE (time_in_hospital);

CREATE TABLE fact_hospital_admission_p0_2
    PARTITION OF fact_hospital_admission_parted
    FOR VALUES FROM (0) TO (3);

CREATE TABLE fact_hospital_admission_p3_5
    PARTITION OF fact_hospital_admission_parted
    FOR VALUES FROM (3) TO (6);

CREATE TABLE fact_hospital_admission_p6_14
    PARTITION OF fact_hospital_admission_parted
    FOR VALUES FROM (6) TO (15);

-- Indexes
CREATE INDEX idx_fact_parted_patient_key
    ON fact_hospital_admission_parted (patient_key);

CREATE INDEX idx_fact_parted_readmitted_30d_flag
    ON fact_hospital_admission_parted (readmitted_30d_flag);

CREATE INDEX idx_fact_parted_admission_dim_key
    ON fact_hospital_admission_parted (admission_dim_key);
