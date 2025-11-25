# 🏥 Healthcare Data Warehouse & ETL Pipeline  
*A Complete End-to-End Data Engineering Project*

![Project Banner](image.png)  
> *(Replace with your generated banner image)*

---

## 📌 Overview  

This repository contains a **fully functional Healthcare Data Warehouse** built as part of the **Data Warehousing & Mining** course.  
It integrates **three heterogeneous data sources** into a unified **PostgreSQL analytical warehouse**, supported by a complete **Python ETL pipeline** and a **star-schema data model**.

The project demonstrates professional-level skills in:

- ETL workflow design  
- Star-schema dimensional modeling  
- Data quality handling  
- Data integration from CSV, MySQL, API sources  
- PostgreSQL warehousing  
- Partitioning & indexing for query optimization  
- Analytical SQL reporting  

---

## 🎯 Project Goals  

### 1. Extract  
From **three heterogeneous data sources**:

1. **CSV** – Diabetes hospital encounters dataset  
2. **MySQL** – Operational patient contact data  
3. **REST API** – Country & region metadata (RESTCountries API)

### 2. Transform  
Includes:

- Null-handling  
- Data type corrections  
- Normalization of categories  
- Surrogate key generation  
- Derivation of `readmitted_30d_flag`  
- Table normalization (1NF → 2NF → 3NF)  
- Diagnosis code standardization  

### 3. Load (PostgreSQL)  
Using a designed **Star Schema** with:  

- Fact table: `fact_hospital_admission` (partitioned)  
- Dimension tables: patient, admission, diagnosis, contact, country  

### 4. Optimize  

- **Range partitioning**  
- **Foreign key constraints**  
- **Bitmap-style indexes**  
- **Join indexes**  
- **Not-null constraints**  

### 5. Analyze  
SQL-based analytical reports such as:

- 30-day readmission rate  
- Top diagnoses  
- Average length of stay  
- Regional patient distributions  

---

## 🛠️ Tech Stack  

| Layer | Technology |
|------|------------|
| ETL | Python (Pandas, SQLAlchemy, Requests) |
| Data Warehouse | PostgreSQL |
| Operational DB | MySQL |
| API Source | RESTCountries |
| Modeling | Star Schema |
| Partitioning | PostgreSQL Range Partitioning |
| Documentation | Word Report + PowerPoint Slides |

---

## 🏗️ System Architecture  

```
                 ┌──────────────┐
   CSV ----------►              │
                 │              │
 MySQL ----------►   ETL Layer  │──► PostgreSQL DW ──► Analytics
                 │   (Python)   │
 API ------------►              │
                 └──────────────┘
```

---

## ⭐ Star Schema Diagram  
*(Add your diagram PNG here)*

```
![Star Schema](diagrams/star_schema.png)
```

---

# 🔄 ETL Pipelines (Summarized)

## **1️⃣ CSV Pipeline**
- Load diabetes hospital data  
- Clean missing values  
- Normalize text fields  
- Create surrogate keys  
- Generate fact table measures  

```python
df = pd.read_csv("diabetes.csv")
df.replace("?", None, inplace=True)
df["readmitted_30d_flag"] = df["readmitted"].apply(lambda x: 1 if x == "<30" else 0)
```

---

## **2️⃣ MySQL Pipeline**
Reads operational patient contact data:

```python
mysql_df = pd.read_sql("SELECT * FROM patient_contact", mysql_engine)
```

---

## **3️⃣ API Pipeline**

```python
url = "https://restcountries.com/v3.1/all?fields=name,cca2,region,subregion,population"
df = pd.json_normalize(requests.get(url).json())
```

---

## 🗄️ Data Warehouse Design

### ⭐ Fact Table: `fact_hospital_admission`
Stores clinical encounter metrics.

### ⭐ Dimensions:
- `dim_patient`
- `dim_admission`
- `dim_diagnosis`
- `dim_patient_contact`
- `dim_country`

---

## ⚙️ Physical Optimization  

### 🧩 Partitioning  
`PARTITION BY RANGE (time_in_hospital)`  

### ⚡ Indexing  
`patient_key`, `diagnosis_key`, `readmitted_30d_flag`, etc.

---

# 📊 Example Analytical Queries  

### 30-Day Readmission Rate  
```sql
SELECT
    COUNT(*) AS total_encounters,
    SUM(CASE WHEN readmitted_30d_flag = 1 THEN 1 END) AS readmissions,
    ROUND(100.0 * SUM(CASE WHEN readmitted_30d_flag = 1 THEN 1 END) / COUNT(*), 2)
      AS readmission_rate_pct
FROM fact_hospital_admission_parted;
```

---

# 🚀 How to Run This Project  

### 1. Clone  
```bash
git clone https://github.com/HermelaDev/Healthcare-Data-Warehouse.git
cd Healthcare-Data-Warehouse
```

### 2. Install Dependencies  
```bash
pip install -r requirements.txt
```

### 3. Run ETL  
```bash
python etl/etl_csv.py
python etl/etl_mysql.py
python etl/etl_api.py
```

---

# 🎬 Project Demo GIF  
*(Replace the GIF below)*

```
![Demo](images/demo.gif)
```

---

# 👩‍💻 Author

**Hermela Seltanu Gizaw**  
Bachelor of Science in Data Science & Analytics  
USIU–Africa • Mastercard Foundation Scholar  

---

# 🌟 Acknowledgements  
- USIU-Africa School of Science & Technology  
- Data Warehousing & Mining Course Faculty  

---

# 📜 License  
MIT License — feel free to use or adapt the project structure.
