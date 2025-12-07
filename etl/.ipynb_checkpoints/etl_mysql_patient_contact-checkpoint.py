# etl/etl_mysql_patient_contact.py
import pandas as pd
from config import mysql_engine, pg_engine

patient_contact_df = pd.read_sql("SELECT * FROM patient_contact", con=mysql_engine)
patient_contact_df["source_system"] = "MySQL_patient_contact"

with pg_engine.begin() as conn:
    patient_contact_df.to_sql(
        "dim_patient_contact",
        con=conn,
        if_exists="append",
        index=False,
    )