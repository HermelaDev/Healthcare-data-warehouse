# 🏥 Healthcare Data Warehouse & ETL Pipeline  
*A Complete End-to-End Data Engineering Project*

![Project Banner](image.png)  

---

## 📌 Overview  

This repository contains a **Healthcare Data Warehouse** built as part of the **Data Warehousing & Mining** course.  
It integrates three heterogeneous data sources into a unified **PostgreSQL warehouse**:

1. **CSV clinical encounter data**  
2. **MySQL patient contact data**  
3. **World Bank API healthcare indicators**  

The project demonstrates practical skills in:

- ETL workflow design  
- Dimensional modeling (snowflake-style star schema)  
- Data cleaning & transformation  
- Loading analytical structures into PostgreSQL  
- Indexing & range partitioning for optimization  
- Writing SQL-based healthcare analytics  

---

## 🎯 Project Goals  

### 1. Extract  
From multiple independent sources:

- **CSV** - Diabetes hospital encounter dataset  
- **MySQL** – Patient contact information  
- **World Bank API** – Country-level health indicators  

### 2. Transform  
Including:

- Handling null values  
- Cleaning text fields  
- Standardizing diagnosis codes  
- Creating surrogate keys  
- Deriving analytical attributes (e.g., `readmitted_30d_flag`)  
- Normalizing tables into a snowflake schema  

### 3. Load (PostgreSQL)  
Into a warehouse designed with:

- Fact table: **`fact_hospital_admission_parted`** (range-partitioned)  
- Dimensions: patient, admission, diagnosis, patient_contact, country  

### 4. Optimize  

- PostgreSQL **range partitioning**  
- **Indexes** on keys and frequently queried attributes  
- Ensuring **referential integrity** across dimensions  

### 5. Analyze  
Running SQL-based analytical queries such as:

- 30-day readmission trends  
- Diagnosis frequencies  
- Length-of-stay distributions  
- Cross-country healthcare comparisons  

---

## 🛠️ Tech Stack  

| Layer | Technology |
|------|------------|
| **ETL** | Python (Pandas, SQLAlchemy, Requests) |
| **Data Warehouse** | PostgreSQL |
| **Operational DB** | MySQL |
| **API Source** | World Bank API |
| **Modeling** | Snowflake Star Schema |
| **Partitioning** | PostgreSQL Range Partitioning |
| **Documentation** | Word Report + PowerPoint Slides |

---

# 🔄 ETL Pipelines (Summarized)

## **1️⃣ CSV Pipeline - Clinical Encounters**
- Load diabetic hospital encounter data  
- Replace `"?"` with `NULL`  
- Convert numeric fields  
- Create `readmitted_30d_flag`  
- Build & load:
  - `dim_patient`
  - `dim_admission`
  - `dim_diagnosis`
- Map surrogate keys to construct the fact table

## **2️⃣ MySQL Pipeline - Patient Contact Data**

Reads operational patient contact records and loads them into the snowflake structure: 

```bash
df = pd.read_csv("diabetic_data.csv")
df.replace("?", None, inplace=True)
df["readmitted_30d_flag"] = df["readmitted"].apply(lambda x: x == "<30")
```
## **3️⃣ API Pipeline - Country Health Indicators**

Fetches global health metrics from World Bank API:
```bash
url = "https://api.worldbank.org/v2/country/all/indicator/SH.STA.DIAB.ZS?format=json&per_page=20000"
df = requests.get(url).json()
```
## 🗄️ Data Warehouse Design

### ⭐ Fact Table: `fact_hospital_admission_parted`

Stores measures such as:

- length of stay  
- number of procedures & medications  
- outpatient/emergency visits  
- readmission indicators  
- diagnosis keys  
- patient & admission keys  

### ⭐ Dimensions

- `dim_patient` - demographic attributes  
- `dim_admission` - admission characteristics  
- `dim_diagnosis` - ICD-based diagnostic categories  
- `dim_patient_contact` - contact + country linkage  
- `dim_country` - World Bank country metrics  

---

## ⚙️ Physical Optimization

### 🧩 Partitioning

Fact table partitioned by:

- `time_in_hospital` (RANGE)

This improves query performance for LOS-based analytics.

### ⚡ Indexing

Indexes added on:

- `patient_key`  
- `admission_dim_key`  
- `primary_diagnosis_key`  
- `readmitted_30d_flag`  

---

## 📊 Example Analytical Queries

### 30-Day Readmission Rate

```sql
SELECT
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN readmitted_30d_flag THEN 1 END) AS readmissions,
    ROUND(
        100.0 * SUM(CASE WHEN readmitted_30d_flag THEN 1 END) / COUNT(*),
        2
    ) AS readmission_rate_pct
FROM fact_hospital_admission_parted;
```
## 📊 Example Analytical Queries  

### Average LOS by Admission Type  

```sql
SELECT
    a.admission_type,
    ROUND(AVG(f.time_in_hospital), 2) AS avg_los
FROM fact_hospital_admission_parted f
JOIN dim_admission a ON f.admission_dim_key = a.admission_dim_key
GROUP BY a.admission_type;
```
## 🚀 How to Run This Project
### 1. Clone
```bash
git clone https://github.com/HermelaDev/Healthcare-Data-Warehouse.git
cd Healthcare-Data-Warehouse
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Run ETL Scripts
```bash
python etl/etl_csv_diabetes.py
python etl/etl_mysql_patient_contact.py
python etl/etl_api_country_health.py
```

## 👩‍💻 Author

**Hermela Seltanu Gizaw**
BSc Data Science & Analytics
USIU-Africa • Mastercard Foundation Scholar

## 📜 License
MIT License
