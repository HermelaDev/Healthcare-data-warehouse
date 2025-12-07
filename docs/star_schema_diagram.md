erDiagram
    FACT_HOSPITAL_ADMISSION {
        int encounter_id PK
        int patient_key FK
        int admission_dim_key FK
        int primary_diagnosis_key FK
        int secondary_diagnosis_key FK
        int tertiary_diagnosis_key FK
        int time_in_hospital
        int num_lab_procedures
        int num_procedures
        int num_medications
        int number_outpatient
        int number_emergency
        int number_inpatient
        int number_diagnoses
        boolean readmitted_30d_flag
    }

    DIM_PATIENT {
        int patient_key PK
        bigint patient_nbr
        string race
        string gender
        string age_group
        string payer_code
    }

    DIM_ADMISSION {
        int admission_dim_key PK
        string admission_type
        string discharge_disposition
        string admission_source
    }

    DIM_DIAGNOSIS {
        int diagnosis_key PK
        string diagnosis_code
        string icd_category
    }

    DIM_PATIENT_CONTACT {
        int patient_contact_key PK
        bigint patient_nbr
        string phone
        string city
        string country
    }

    DIM_COUNTRY {
        int country_key PK
        string country_name
        string iso2_code
        string region
        string subregion
        float health_expenditure
        float diabetes_prevalence
    }

    FACT_HOSPITAL_ADMISSION }o--|| DIM_PATIENT : "patient_key"
    FACT_HOSPITAL_ADMISSION }o--|| DIM_ADMISSION : "admission_dim_key"
    FACT_HOSPITAL_ADMISSION }o--|| DIM_DIAGNOSIS : "primary_diag"
    FACT_HOSPITAL_ADMISSION }o--|| DIM_DIAGNOSIS : "secondary_diag"
    FACT_HOSPITAL_ADMISSION }o--|| DIM_DIAGNOSIS : "tertiary_diag"
    FACT_HOSPITAL_ADMISSION }o--|| DIM_PATIENT_CONTACT : "patient_nbr"
    FACT_HOSPITAL_ADMISSION }o--|| DIM_COUNTRY : "country_key"
