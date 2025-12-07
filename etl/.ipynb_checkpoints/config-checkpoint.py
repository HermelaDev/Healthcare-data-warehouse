from sqlalchemy import create_engine
from dotenv import load_dotenv
import os

# Load .env from project root
BASE_DIR = os.path.dirname(os.path.dirname(__file__))  # .../Healthcare-data-warehouse
load_dotenv(os.path.join(BASE_DIR, ".env"))

# POSTGRES
PG_PASSWORD = os.getenv("PG_PASSWORD")

PG_URI = f"postgresql+psycopg2://postgres:{PG_PASSWORD}@localhost:5432/hospital_dw"
pg_engine = create_engine(PG_URI)

# MYSQL
MYSQL_USER = os.getenv("MYSQL_USER", "root")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD")
MYSQL_HOST = os.getenv("MYSQL_HOST", "localhost")

MYSQL_URI = f"mysql+mysqlconnector://{MYSQL_USER}:{MYSQL_PASSWORD}@{MYSQL_HOST}:3306/hospital_source"
mysql_engine = create_engine(MYSQL_URI)