import sqlite3

conn = sqlite3.connect('agronomy_prescriptions.db')
cursor = conn.cursor()

cursor.execute("SELECT disease_name_en, disease_name_ml, chemical_cure, dosage_per_liter FROM Prescriptions WHERE disease_key = 'Tomato_Late_blight'")
result = cursor.fetchone()

print("Query Test:")
print(f"Disease: {result[0]} ({result[1]})")
print(f"Chemical: {result[2]}")
print(f"Dosage: {result[3]} g/L")

conn.close()