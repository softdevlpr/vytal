import pandas as pd
from pymongo import MongoClient
from datetime import datetime

# -----------------------------
# CONFIG
# -----------------------------
MONGO_URI = "mongodb://localhost:27017/"
DB_NAME = "VYTALDB"
COLLECTION_NAME = "symptom_dataset"
EXCEL_FILE = "symptom_v5.xlsx"   # make sure file is in same folder

# -----------------------------
# CONNECT TO MONGODB
# -----------------------------
client = MongoClient(MONGO_URI)
db = client[DB_NAME]
collection = db[COLLECTION_NAME]

# -----------------------------
# LOAD EXCEL
# -----------------------------
df = pd.read_excel(EXCEL_FILE)

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

    if pd.notna(row.get("Test1_Name")):
        tests.append({
            "rank": 1,
            "name": str(row["Test1_Name"]),
            "description": str(row["Test1_Description"])
        })

    if pd.notna(row.get("Test2_Name")):
        tests.append({
            "rank": 2,
            "name": str(row["Test2_Name"]),
            "description": str(row["Test2_Description"])
        })

    return tests

# -----------------------------
# INSERT DATA
# -----------------------------
documents = []

for _, row in df.iterrows():
    doc = {
        "primary_symptom": str(row["Symptom"]).strip(),
        "answers": build_answers(row),
        "urgency": str(row["Urgency"]).strip(),
        "recommended_tests": build_tests(row)
    }

    documents.append(doc)

# Bulk insert (FAST)
if documents:
    collection.insert_many(documents)

print(f"✅ Inserted {len(documents)} records into symptom_dataset")
