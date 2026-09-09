import sqlite3

# Connect to database (creates file if not present)
conn = sqlite3.connect('agronomy_prescriptions.db')
cursor = conn.cursor()

# Create table schema
cursor.execute('''
CREATE TABLE IF NOT EXISTS Prescriptions (
    disease_key TEXT PRIMARY KEY,
    crop_name TEXT NOT NULL,
    disease_name_en TEXT NOT NULL,
    disease_name_ml TEXT NOT NULL,
    chemical_cure TEXT NOT NULL,
    dosage_per_liter REAL NOT NULL,
    chemical_instructions_ml TEXT NOT NULL,
    organic_cure TEXT NOT NULL,
    organic_instructions_ml TEXT NOT NULL,
    waiting_period_days INTEGER NOT NULL
)
''')

# 10 Core KAU dataset classes
records = [
    (
        'Pepper_bell_Bacterial_spot', 'Pepper', 'Bacterial Leaf Spot', 'മുളകിലെ ബാക്ടീരിയൽ ഇലപ്പുള്ളി രോഗം',
        'Copper Oxychloride 50 WP', 2.0,
        '1 ലീറ്റർ വെള്ളത്തിൽ 2 ഗ്രാം കോപ്പർ ഓക്സിക്ലോറൈഡ് കലക്കി ഇലകളിൽ തളിക്കുക.',
        'Neem Oil Garlic Emulsion (2%)', '2% വീര്യമുള്ള വേപ്പെണ്ണ വെളുത്തുള്ളി മിശ്രിതം തളിക്കുക.', 7
    ),
    (
        'Pepper_bell_healthy', 'Pepper', 'Healthy Plant', 'ആരോഗ്യമുള്ള മുളക് ചെടി',
        'None', 0.0, 'ചെടി പൂർണ്ണ ആരോഗ്യത്തോടെയിരിക്കുന്നു. രാസവസ്തുക്കൾ ആവശ്യമില്ല.',
        'Panchagavya (3%)', '3% പഞ്ചഗവ്യം വളർച്ചക്കായി തളിക്കാം.', 0
    ),
    (
        'Potato_Early_blight', 'Potato', 'Early Blight', 'ഉരുളക്കിഴങ്ങിലെ ഏർലി ബ്ലൈറ്റ്',
        'Mancozeb 75% WP', 2.0,
        '1 ലീറ്റർ വെള്ളത്തിൽ 2 ഗ്രാം മാങ്കോസെബ് കലക്കി തളിക്കുക.',
        'Pseudomonas fluorescens', '20 ഗ്രാം സ്യൂഡോമോണസ് 1 ലീറ്റർ വെള്ളത്തിൽ കലക്കി തളിക്കുക.', 7
    ),
    (
        'Potato_Late_blight', 'Potato', 'Late Blight', 'ഉരുളക്കിഴങ്ങിലെ ലേറ്റ് ബ്ലൈറ്റ് (കരിഞ്ഞുണങ്ങൽ)',
        'Metalaxyl + Mancozeb (Ridomil)', 2.5,
        '1 ലീറ്റർ വെള്ളത്തിൽ 2.5 ഗ്രാം റിഡോമിൽ കലക്കി ചെടിയുടെ എല്ലാ ഭാഗത്തും തളിക്കുക.',
        'Bordeaux Mixture (1%)', '1% വീര്യമുള്ള ബോർഡോ മിശ്രിതം തളിക്കുക.', 14
    ),
    (
        'Potato_healthy', 'Potato', 'Healthy Plant', 'ആരോഗ്യമുള്ള ഉരുളക്കിഴങ്ങ് ചെടി',
        'None', 0.0, 'ചെടി ആരോഗ്യത്തോടെയിരിക്കുന്നു.',
        'Organic Compost', 'തടങ്ങളിൽ ജൈവവളം ചേർത്ത് കൊടുക്കുക.', 0
    ),
    (
        'Tomato_Early_blight', 'Tomato', 'Early Blight (Alternaria)', 'തക്കാളിയിലെ ഏർലി ബ്ലൈറ്റ് (വളയപ്പുള്ളി)',
        'Chlorothalonil 75 WP', 2.0,
        '1 ലീറ്റർ വെള്ളത്തിൽ 2 ഗ്രാം ക്ലോറോതലോനിൽ കലക്കി തളിക്കുക.',
        'Pseudomonas fluorescens', '20 ഗ്രാം സ്യൂഡോമോണസ് 1 ലീറ്റർ വെള്ളത്തിൽ ഇലകളിൽ തളിക്കുക.', 5
    ),
    (
        'Tomato_Late_blight', 'Tomato', 'Late Blight (Phytophthora)', 'തക്കാളിയിലെ ലേറ്റ് ബ്ലൈറ്റ് (കരിഞ്ഞുണങ്ങൽ)',
        'Mancozeb 75% WP', 2.0,
        '1 ലീറ്റർ വെള്ളത്തിൽ 2 ഗ്രാം മാങ്കോസെബ് കലക്കി ഇലകളുടെ ഇരുവശത്തും തളിക്കുക.',
        'Bordeaux Mixture (1%)', '1% വീര്യമുള്ള ബോർഡോ മിശ്രിതം ഇലകളിൽ തളിക്കുക.', 7
    ),
    (
        'Tomato_Leaf_Mold', 'Tomato', 'Leaf Mold (Passalora fulva)', 'തക്കാളിയിലെ ഇലപ്പൂപ്പ് രോഗം',
        'Copper Oxychloride', 2.0,
        '1 ലീറ്റർ വെള്ളത്തിൽ 2 ഗ്രാം കോപ്പർ ഓക്സിക്ലോറൈഡ് കലക്കി തളിക്കുക.',
        'Baking Soda Spray', '5 ഗ്രാം ബേക്കിംഗ് സോഡ 1 ലീറ്റർ വെള്ളത്തിൽ കലക്കി തളിക്കുക.', 5
    ),
    (
        'Tomato_Septoria_leaf_spot', 'Tomato', 'Septoria Leaf Spot', 'തക്കാളിയിലെ സെപ്റ്റോറിയ ഇലപ്പുള്ളി',
        'Mancozeb 75% WP', 2.0,
        '1 ലീറ്റർ വെള്ളത്തിൽ 2 ഗ്രാം മാങ്കോസെബ് കലക്കി തളിക്കുക.',
        'Neem Cake Extract', 'വേപ്പിൻ പിണ്ണാക്ക് ലായനി തടത്തിലും ഇലകളിലും തളിക്കുക.', 7
    ),
    (
        'Tomato_healthy', 'Tomato', 'Healthy Plant', 'ആരോഗ്യമുള്ള തക്കാളി ചെടി',
        'None', 0.0, 'ചെടി പൂർണ്ണ ആരോഗ്യത്തോടെയിരിക്കുന്നു.',
        'Vermicompost Tea', '3% വീര്യമുള്ള വെർമിവാഷ് അല്ലെങ്കിൽ പഞ്ചഗവ്യം തളിക്കുക.', 0
    )
]

cursor.executemany('INSERT OR REPLACE INTO Prescriptions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', records)
conn.commit()
conn.close()
print("Success! agronomy_prescriptions.db generated with all 10 records.")