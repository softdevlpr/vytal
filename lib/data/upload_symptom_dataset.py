import pandas as pd
import os
from dotenv import load_dotenv
from pymongo import MongoClient
from datetime import datetime

# -----------------------------
# LOAD ENV VARIABLES
# -----------------------------
load_dotenv(dotenv_path=r"D:\vytal\.env")

MONGO_URI = os.getenv("MONGO_URI")

if not MONGO_URI:
    raise Exception("❌ MONGO_URI not found in .env file")

# -----------------------------
# CONFIG
# -----------------------------
DB_NAME = "VYTALDB"
COLLECTION_NAME = "symptom_dataset"
EXCEL_FILE = r"D:\vytal\lib\data\symptom_v5.xlsx"

# -----------------------------
# CONNECT TO MONGODB
# -----------------------------
client = MongoClient(MONGO_URI)

try:
    client.admin.command('ping')
    print("✅ Connected to MongoDB")
except Exception as e:
    print("❌ MongoDB connection failed:", e)
    exit()

db = client[DB_NAME]
collection = db[COLLECTION_NAME]

# -----------------------------
# LOAD EXCEL
# -----------------------------
if not os.path.exists(EXCEL_FILE):
    raise Exception(f"❌ Excel file not found: {EXCEL_FILE}")

df = pd.read_excel(EXCEL_FILE)

# 🔥 CLEAN COLUMN NAMES (handles extra spaces)
df.columns = df.columns.str.strip()

print("📊 Columns detected:", df.columns.tolist())

# -----------------------------
# CLEAN OLD DATA (OPTIONAL)
# -----------------------------
collection.delete_many({})
print("🧹 Old dataset cleared")

# -----------------------------
# HELPER FUNCTION
# -----------------------------
def build_answers(row):
    return {
        "Q1": int(row["Q1"]),
        "Q2": int(row["Q2"]),
        "Q3": int(row["Q3"]),
        "Q4": int(row["Q4"]),
        "Q5": int(row["Q5"]),
        "Q6": int(row["Q6"])
    }

def build_tests(row):
    tests = []

    for i in range(1, 7):
        test_name_col = f"Recommended Test {i}"
        test_desc_col = f"Test {i} Description"

        test_name = row.get(test_name_col)
        test_desc = row.get(test_desc_col)

        # ✅ skip if test name is empty or NaN
        if pd.notna(test_name) and str(test_name).strip() != "":
            tests.append({
                "rank": i,
                "name": str(test_name).strip(),
                "description": str(test_desc).strip() if pd.notna(test_desc) else ""
            })

    return tests

# -----------------------------
# INSERT DATA
# -----------------------------
documents = []

for _, row in df.iterrows():
    doc = {
        "primary_symptom": str(row["Primary Symptom"]).strip(),
        "answers": build_answers(row),
        "urgency": str(row["Urgency"]).strip(),
        "recommended_tests": build_tests(row),
        "created_at": datetime.utcnow()
    }

    documents.append(doc)

# Bulk insert
if documents:
    collection.insert_many(documents)

print(f"✅ Inserted {len(documents)} records into symptom_dataset")
