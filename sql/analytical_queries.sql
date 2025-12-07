SELECT current_database();
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

SELECT COUNT(*) FROM fact_hospital_admission_parted;

-- Q1. Overall 30-day readmission rate
SELECT
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN readmitted_30d_flag THEN 1 ELSE 0 END) AS readmitted_30d,
    ROUND(
        100.0 * SUM(CASE WHEN readmitted_30d_flag THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS readmission_rate_30d_pct
FROM fact_hospital_admission_parted;


-- Q2. Average length of stay by age group and gender
SELECT
    p.age_group,
    p.gender,
    COUNT(*) AS encounters,
    ROUND(AVG(f.time_in_hospital), 2) AS avg_los_days
FROM fact_hospital_admission_parted f
JOIN dim_patient p
  ON f.patient_key = p.patient_key
GROUP BY p.age_group, p.gender
ORDER BY p.age_group, p.gender;


-- Q3. Readmission rate by primary diagnosis ICD category
SELECT
    d.icd_category,
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN f.readmitted_30d_flag THEN 1 ELSE 0 END) AS readmitted_30d,
    ROUND(
        100.0 * SUM(CASE WHEN f.readmitted_30d_flag THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS readmission_rate_30d_pct
FROM fact_hospital_admission_parted f
JOIN dim_diagnosis d
  ON f.primary_diagnosis_key = d.diagnosis_key
GROUP BY d.icd_category
ORDER BY readmission_rate_30d_pct DESC
LIMIT 10;

-- Q4. Length of stay buckets (ties into partitioning)
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


-- Q5. Average medications and LOS by admission type
SELECT
    a.admission_type,
    COUNT(*) AS encounters,
    ROUND(AVG(f.num_medications), 2) AS avg_num_medications,
    ROUND(AVG(f.time_in_hospital), 2) AS avg_los_days
FROM fact_hospital_admission_parted f
JOIN dim_admission a
  ON f.admission_dim_key = a.admission_dim_key
GROUP BY a.admission_type
ORDER BY avg_los_days DESC;



