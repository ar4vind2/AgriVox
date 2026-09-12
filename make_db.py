import sqlite3
import shutil
import os

# Connect to database (creates file if not present)
db_filename = 'agronomy_prescriptions.db'
conn = sqlite3.connect(db_filename)
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

# 27 KAU & Regional Kerala Agronomy Records (Solanaceae + Kerala Cash Crops + Background Noise Guardrail)
records = [
    # 1. Pepper (മുളക്)
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

    # 2. Potato (ഉരുളക്കിഴങ്ങ്)
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

    # 3. Tomato (തക്കാളി)
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
    ),

    # 4. Paddy / Rice (നെല്ല്)
    (
        'Rice_Blast', 'Paddy', 'Rice Blast (Magnaporthe oryzae)', 'നെല്ലിലെ കുലവാട്ടം / ബ്ലാസ്റ്റ് രോഗം',
        'Tricyclazole 75 WP', 0.6,
        '1 ലീറ്റർ വെള്ളത്തിൽ 0.6 ഗ്രാം ട്രൈസൈക്ലാസോൾ കലക്കി ഇലകളിലും കതിരുകളിലും തളിക്കുക.',
        'Pseudomonas fluorescens', '10 ഗ്രാം സ്യൂഡോമോണസ് 1 ലീറ്റർ വെള്ളത്തിൽ കലക്കി തളിക്കുക.', 21
    ),
    (
        'Rice_Bacterial_Blight', 'Paddy', 'Bacterial Leaf Blight (Xanthomonas oryzae)', 'നെല്ലിലെ ബാക്ടീരിയൽ ഇലകരിച്ചിൽ',
        'Streptocycline + Copper Oxychloride', 2.0,
        '1 ലീറ്റർ വെള്ളത്തിൽ 2 ഗ്രാം കോപ്പർ ഓക്സിക്ലോറൈഡും 1 ഗ്രാം സ്ട്രെപ്റ്റോസൈക്ലിൻ (10L-ൽ) കലക്കി തളിക്കുക.',
        'Cow Dung Supernatant (20%)', '20% വീര്യമുള്ള ചാണകപ്പാൽ തെളിച്ചെടുത്ത ലായനി ഇലകളിൽ തളിക്കുക.', 14
    ),
    (
        'Rice_healthy', 'Paddy', 'Healthy Paddy Crop', 'ആരോഗ്യമുള്ള നെൽച്ചെടി',
        'None', 0.0, 'നെൽച്ചെടി പൂർണ്ണ ആരോഗ്യത്തോടെയിരിക്കുന്നു. രാസവസ്തുക്കൾ ആവശ്യമില്ല.',
        'Azospirillum & Organic Compost', 'തടങ്ങളിൽ ജൈവവളവും അസോസ്പൈറില്ലവും ചേർത്തു കൊടുക്കുക.', 0
    ),

    # 5. Coconut (തെങ്ങ്)
    (
        'Coconut_Bud_Rot', 'Coconut', 'Bud Rot (Phytophthora palmivora)', 'തെങ്ങിലെ മണ്ടയഴുകൽ രോഗം',
        'Bordeaux Paste (10%) / Mancozeb', 2.0,
        'ചീഞ്ഞ ഭാഗങ്ങൾ ചെത്തിമാറ്റി 10% വീര്യമുള്ള ബോർഡോ പേസ്റ്റ് തേക്കുക. മാങ്കോസെബ് പാക്കറ്റുകൾ (5g) മണ്ടയിൽ വയ്ക്കുക.',
        'Trichoderma viride suspension', '50 ഗ്രാം ട്രൈക്കോഡെർമ അര ലീറ്റർ വെള്ളത്തിൽ കലക്കി മണ്ടയിലേക്ക് ഒഴിക്കുക.', 0
    ),
    (
        'Coconut_Stem_Bleeding', 'Coconut', 'Stem Bleeding (Thielaviopsis paradoxa)', 'തെങ്ങിലെ തടി ഒഴുക്ക്',
        'Hexaconazole (Contaf) / Coal Tar', 2.0,
        'രോഗബാധിതമായ തടി ഭാഗം ചെത്തിമാറ്റി ഹെക്സാകൊണസോൾ (2ml/L) പുരട്ടി കോൾടാർ തേക്കുക.',
        'Neem Cake + Trichoderma', '5 കിലോഗ്രാം വേപ്പിൻ പിണ്ണാക്കും ട്രൈക്കോഡെർമ ചേർത്ത ചാണകവളവും തടത്തിൽ ഇട്ടുകൊടുക്കുക.', 0
    ),
    (
        'Coconut_healthy', 'Coconut', 'Healthy Coconut Palm', 'ആരോഗ്യമുള്ള തെങ്ങ്',
        'None', 0.0, 'തെങ്ങ് പൂർണ്ണ ആരോഗ്യത്തോടെയിരിക്കുന്നു. രാസവസ്തുക്കൾ ആവശ്യമില്ല.',
        'Green Manuring & Vermicompost', 'തടത്തിൽ പച്ചിലവളവും മണ്ണിരവളവും ചേർത്ത് ഈർപ്പം നിലനിർത്തുക.', 0
    ),

    # 6. Banana (വാഴ)
    (
        'Banana_Sigatoka_Leaf_Spot', 'Banana', 'Sigatoka Leaf Spot (Mycosphaerella)', 'വാഴയിലെ സിഗാറ്റോക്ക ഇലപ്പുള്ളി രോഗം',
        'Mancozeb 75 WP / Propiconazole', 2.0,
        '1 ലീറ്റർ വെള്ളത്തിൽ 2 ഗ്രാം മാങ്കോസെബ് അല്ലെങ്കിൽ 1 മില്ലി പ്രൊപ്പിക്കൊണസോൾ കലക്കി തളിക്കുക.',
        'Bordeaux Mixture (1%) + Mineral Oil', '1% വീര്യമുള്ള ബോർഡോ മിശ്രിതവും 10 മില്ലി മിനറൽ ഓയിലും കലക്കി ഇലകളുടെ അടിവശത്ത് തളിക്കുക.', 10
    ),
    (
        'Banana_Panama_Wilt', 'Banana', 'Panama Wilt (Fusarium oxysporum)', 'വാഴയിലെ പനാമ വാട്ടം',
        'Carbendazim 50 WP', 2.0,
        '1 ലീറ്റർ വെള്ളത്തിൽ 2 ഗ്രാം കാർബൻഡാസിം കലക്കി വാഴയുടെ ചുവട്ടിൽ മണ്ണിലേക്ക് ഒഴിച്ചു കൊടുക്കുക.',
        'Trichoderma viride + Pseudomonas', 'തടത്തിൽ 50 ഗ്രാം ട്രൈക്കോഡെർമയും സ്യൂഡോമോണസും ചാണകപ്പൊടിയിൽ ചേർത്തു കൊടുക്കുക.', 15
    ),
    (
        'Banana_healthy', 'Banana', 'Healthy Banana Plant', 'ആരോഗ്യമുള്ള വാഴച്ചെടി',
        'None', 0.0, 'വാഴച്ചെടി പൂർണ്ണ ആരോഗ്യത്തോടെയിരിക്കുന്നു. രാസവസ്തുക്കൾ ആവശ്യമില്ല.',
        'Panchagavya (3%)', '3% വീര്യമുള്ള പഞ്ചഗവ്യം വളർച്ചക്കായി തളിക്കുക.', 0
    ),

    # 7. Brinjal / Eggplant (വഴുതന)
    (
        'Brinjal_Bacterial_Wilt', 'Brinjal', 'Bacterial Wilt (Ralstonia solanacearum)', 'വഴുതനയിലെ ബാക്ടീരിയൽ വാട്ടം',
        'Copper Oxychloride + Streptocycline', 2.5,
        '1 ലീറ്റർ വെള്ളത്തിൽ 2.5 ഗ്രാം കോപ്പർ ഓക്സിക്ലോറൈഡും സ്ട്രെപ്റ്റോസൈക്ലിനും കലക്കി ചെടിയുടെ ചുവട്ടിൽ ഒഴിക്കുക.',
        'Pseudomonas fluorescens (2%)', '20 ഗ്രാം സ്യൂഡോമോണസ് 1 ലീറ്റർ വെള്ളത്തിൽ കലക്കി വേരുകളിൽ ഒഴിച്ച് കൊടുക്കുക.', 7
    ),
    (
        'Brinjal_Little_Leaf', 'Brinjal', 'Little Leaf Disease (Phytoplasma)', 'വഴുതനയിലെ ചെറു ഇല രോഗം',
        'Dimethoate 30 EC', 1.5,
        'രോഗം പരത്തുന്ന തണ്ടുതുരപ്പൻ കീടങ്ങളെ നിയന്ത്രിക്കാൻ 1.5 മില്ലി ഡൈമെത്തോയേറ്റ് 1 ലീറ്റർ വെള്ളത്തിൽ തളിക്കുക.',
        'Neem Seed Kernel Extract (5%)', '5% വീര്യമുള്ള വേപ്പിൻകുരു സത്ത് തളിക്കുക.', 10
    ),
    (
        'Brinjal_healthy', 'Brinjal', 'Healthy Brinjal Plant', 'ആരോഗ്യമുള്ള വഴുതന ചെടി',
        'None', 0.0, 'ചെടി പൂർണ്ണ ആരോഗ്യത്തോടെയിരിക്കുന്നു. രാസവസ്തുക്കൾ ആവശ്യമില്ല.',
        'Vermicompost Tea', 'തടങ്ങളിൽ ജൈവവളവും വെർമിവാഷും നൽകുക.', 0
    ),

    # 8. Okra / Ladies Finger (വെണ്ട)
    (
        'Okra_Yellow_Vein_Mosaic', 'Okra', 'Yellow Vein Mosaic Virus (BYVMV)', 'വെണ്ടയിലെ ഞരമ്പ് മഞ്ഞളിപ്പ് രോഗം',
        'Dimethoate 30 EC / Acetamiprid', 1.5,
        'വെള്ളീച്ചകളെ നിയന്ത്രിക്കാൻ 1.5 മില്ലി ഡൈമെത്തോയേറ്റ് അല്ലെങ്കിൽ 0.5 ഗ്രാം അസെറ്റാമിപ്രിഡ് 1 ലീറ്റർ വെള്ളത്തിൽ തളിക്കുക.',
        'Neem Oil Garlic Emulsion (2%)', '2% വീര്യമുള്ള വേപ്പെണ്ണ-വെളുത്തുള്ളി മിശ്രിതം ആഴ്ചയിലൊരിക്കൽ തളിക്കുക.', 7
    ),
    (
        'Okra_Powdery_Mildew', 'Okra', 'Powdery Mildew (Erysiphe)', 'വെണ്ടയിലെ ചാരരോഗം',
        'Wettable Sulphur 80 WP', 2.5,
        '1 ലീറ്റർ വെള്ളത്തിൽ 2.5 ഗ്രാം വെറ്റബിൾ സൾഫർ കലക്കി ഇലകളിൽ തളിക്കുക.',
        'Baking Soda / Buttermilk (5%)', '5 ഗ്രാം ബേക്കിംഗ് സോഡ അല്ലെങ്കിൽ 5% വീര്യമുള്ള പുളിച്ച മോര് വെള്ളത്തിൽ കലക്കി തളിക്കുക.', 5
    ),
    (
        'Okra_healthy', 'Okra', 'Healthy Okra Plant', 'ആരോഗ്യമുള്ള വെണ്ട ചെടി',
        'None', 0.0, 'ചെടി പൂർണ്ണ ആരോഗ്യത്തോടെയിരിക്കുന്നു. രാസവസ്തുക്കൾ ആവശ്യമില്ല.',
        'Jeevamrutham', 'ജീവമൃതം തടങ്ങളിൽ ഒഴിച്ച് കൊടുക്കുക.', 0
    ),

    # 9. Non-Plant / Background Noise Guardrail Fallback
    (
        'Background_Noise', 'Non-Crop', 'Non-Plant / Background Surface', 'ചെടിയല്ലാത്ത പ്രതലം / പശ്ചാത്തലം',
        'None', 0.0,
        'ക്യാമറയിൽ ചെടിയുടെ ഇല വ്യക്തമായി കാണുന്നില്ല. രോഗബാധയുള്ള ഇല ചതുരത്തിനുള്ളിൽ നിർത്തി വീണ്ടും സ്കാൻ ചെയ്യുക.',
        'Visual Rescan',
        'ഇലയുടെ പ്രതലം വെളിച്ചത്തിൽ കേന്ദ്രീകരിച്ച് സ്കാൻ ചെയ്യുക.', 0
    ),
    (
        'unmapped_pathology', 'Field Crop', 'Unclassified Foliar Anomaly', 'വ്യക്തമല്ലാത്ത ഇല രോഗലക്ഷണം',
        'Bordeaux Mixture (1%) / Prophylactic', 2.0,
        'അനാവശ്യമായ രാസകീടനാശിനി പ്രയോഗം ഒഴിവാക്കുക. 1% വീര്യമുള്ള ബോർഡോ മിശ്രിതം തളിക്കുക.',
        'Pseudomonas fluorescens (20g/L)',
        '20 ഗ്രാം സ്യൂഡോമോണസ് 1 ലീറ്റർ വെള്ളത്തിൽ കലക്കി ഇലകളിൽ തളിക്കുക. പ്രാദേശിക കൃഷിഭവനുമായി ബന്ധപ്പെടുക.', 5
    )
]

cursor.executemany('INSERT OR REPLACE INTO Prescriptions VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', records)
conn.commit()
conn.close()

# Copy to Flutter assets directory
asset_dest = os.path.join('assets', 'database', 'agronomy_prescriptions.db')
os.makedirs(os.path.dirname(asset_dest), exist_ok=True)
shutil.copy2(db_filename, asset_dest)

print(f"Success! {len(records)} records inserted into {db_filename} and copied to {asset_dest}")