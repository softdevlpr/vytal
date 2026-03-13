import pandas as pd
import random

rows = []

for i in range(1000):

    # symptoms
    chest_pain = random.choice([0,1])
    short_breath = random.choice([0,1])
    dizziness = random.choice([0,1])
    high_bp = random.choice([0,1])
    sweating = random.choice([0,1])
    nausea = random.choice([0,1])
    fatigue = random.choice([0,1])
    arm_pain = random.choice([0,1])
    jaw_pain = random.choice([0,1])
    irregular_heartbeat = random.choice([0,1])
    swelling_legs = random.choice([0,1])
    fainting = random.choice([0,1])

    # default tests
    ECG=Troponin=Chest_Xray=BNP=Holter=Echo=BP=Tilt=0

    # RULE 1 ACS
    if chest_pain and (sweating or nausea or arm_pain or jaw_pain):
        ECG=1
        Troponin=1
        Chest_Xray=1

    # RULE 2 ARRHYTHMIA
    if irregular_heartbeat and dizziness:
        Holter=1
        ECG=1

    # RULE 3 HEART FAILURE
    if short_breath and swelling_legs:
        Echo=1
        BNP=1
        Chest_Xray=1

    # RULE 4 HYPERTENSION
    if high_bp:
        BP=1
        ECG=1

    # RULE 5 SYNCOPE
    if fainting and dizziness:
        Tilt=1
        ECG=1

    rows.append([
        chest_pain,short_breath,dizziness,high_bp,sweating,nausea,
        fatigue,arm_pain,jaw_pain,irregular_heartbeat,swelling_legs,fainting,
        ECG,Troponin,Chest_Xray,BNP,Holter,Echo,BP,Tilt
    ])

columns = [
"chest_pain","short_breath","dizziness","high_bp","sweating","nausea",
"fatigue","arm_pain","jaw_pain","irregular_heartbeat","swelling_legs","fainting",
"ECG","Troponin","Chest_Xray","BNP","Holter_Monitor","Echocardiography","BP_Monitoring","Tilt_Table_Test"
]

df = pd.DataFrame(rows, columns=columns)

df.to_csv("cardiac_multilabel_dataset.csv",index=False)