enum SeverityLevel { mild, moderate, severe, healthy }

class DiseasePrescription {
  final String diseaseId;
  final String diseaseName;
  final String cropName;
  final String scientificName;
  final double confidence;
  final SeverityLevel severity;
  final String symptoms;
  final String chemicalTreatment;
  final String organicTreatment;
  final String knapsackTankDosage;
  final String malayalamAudioText;
  final String englishAudioText;

  const DiseasePrescription({
    required this.diseaseId,
    required this.diseaseName,
    required this.cropName,
    required this.scientificName,
    required this.confidence,
    required this.severity,
    required this.symptoms,
    required this.chemicalTreatment,
    required this.organicTreatment,
    required this.knapsackTankDosage,
    required this.malayalamAudioText,
    required this.englishAudioText,
  });

  static List<DiseasePrescription> get samplePrescriptions => [
    const DiseasePrescription(
      diseaseId: 'rubber_abnormal_leaf_fall',
      diseaseName: 'Abnormal Leaf Fall',
      cropName: 'Rubber (Hevea brasiliensis)',
      scientificName: 'Phytophthora meadii',
      confidence: 0.948,
      severity: SeverityLevel.severe,
      symptoms: 'Water-soaked lesions on petiole and pods, rapid leaf shedding during monsoon rains.',
      chemicalTreatment: 'Prophylactic spray of 1% Bordeaux mixture or Copper Oxychloride (COC 0.2%).',
      organicTreatment: 'Trichoderma viride bio-fungicide soil application around tree basin.',
      knapsackTankDosage: '160g Copper Oxychloride in 16L knapsack sprayer (10g/L). 2-3 tanks per 10 cents.',
      malayalamAudioText: 'റബ്ബറിലെ പൈറ്റോഫ്ത്തോറ ഫംഗസ് മൂലം ഉണ്ടാകുന്ന അസാധാരണ ഇലകൊഴിച്ചിൽ രോഗം സ്ഥിരീകരിച്ചു. ഉടനടി 1 ശതമാനം ബോർഡോ മിശ്രിതം തളിക്കുക.',
      englishAudioText: 'Abnormal Leaf Fall detected on Rubber. Apply 1% Bordeaux mixture or 0.2% Copper Oxychloride immediately.',
    ),
    const DiseasePrescription(
      diseaseId: 'rubber_powdery_mildew',
      diseaseName: 'Powdery Mildew',
      cropName: 'Rubber (Hevea brasiliensis)',
      scientificName: 'Oidium heveae',
      confidence: 0.923,
      severity: SeverityLevel.moderate,
      symptoms: 'White powdery dust on tender flush leaves, curling and secondary leaf fall.',
      chemicalTreatment: 'Dusting with wettable sulfur 80% WP or spray Carbendazim 0.05%.',
      organicTreatment: 'Neem seed kernel extract (NSKE 5%) spray during morning hours.',
      knapsackTankDosage: '32g Wettable Sulfur in 16L water (2g/L). 2 tanks per 10 cents.',
      malayalamAudioText: 'റബ്ബറിലെ കുമിൾ രോഗമായ പൗഡറി മിൽഡ്യൂ കണ്ടെത്തി. സൾഫർ പൊടി തളിക്കുക.',
      englishAudioText: 'Powdery Mildew detected on Rubber flush leaves. Dust wettable sulfur 80% WP.',
    ),
    const DiseasePrescription(
      diseaseId: 'tomato_early_blight',
      diseaseName: 'Early Blight',
      cropName: 'Tomato (Solanum lycopersicum)',
      scientificName: 'Alternaria solani',
      confidence: 0.956,
      severity: SeverityLevel.moderate,
      symptoms: 'Concentric brown rings ("target-board" spots) on lower leaves, yellow chlorotic halo.',
      chemicalTreatment: 'Mancozeb 75% WP (2.5g/L) or Chlorothalonil at 10-day intervals.',
      organicTreatment: 'Spray Pseudomonas fluorescens (20g/L) weekly.',
      knapsackTankDosage: '40g Mancozeb per 16L knapsack sprayer. 1 tank per 5 cents.',
      malayalamAudioText: 'തക്കാളിയിലെ നേർത്ത വളയങ്ങളോട് കൂടിയ അൾട്ടർനേറിയ ഇലപ്പുള്ളി രോഗം. മാങ്കോസെബ് തളിക്കുക.',
      englishAudioText: 'Early Blight detected on Tomato. Spray Mancozeb 75% WP at 2.5 grams per liter.',
    ),
    const DiseasePrescription(
      diseaseId: 'pepper_quick_wilt',
      diseaseName: 'Quick Wilt (Foot Rot)',
      cropName: 'Black Pepper (Piper nigrum)',
      scientificName: 'Phytophthora capsici',
      confidence: 0.961,
      severity: SeverityLevel.severe,
      symptoms: 'Sudden wilting of vines, dark necrotic lesions at leaf base and collar rot.',
      chemicalTreatment: 'Soil drenching with 1% Bordeaux mixture or Potassium Phosphonate 0.3%.',
      organicTreatment: 'Trichoderma harzianum enriched farmyard manure basin incorporation.',
      knapsackTankDosage: 'Drench 3-5 liters of 1% Bordeaux mixture per vine basin.',
      malayalamAudioText: 'കുരുമുളകിലെ ദ്രുതവാട്ടം രോഗം. കടയ്ക്കൽ ബോർഡോ മിശ്രിതം ഒഴിച്ച് കൊടുക്കുക.',
      englishAudioText: 'Quick Wilt detected on Black Pepper. Drench root collar with 1% Bordeaux mixture.',
    ),
    const DiseasePrescription(
      diseaseId: 'healthy_leaf',
      diseaseName: 'Healthy Foliage',
      cropName: 'Crop Leaf',
      scientificName: 'No pathogen detected',
      confidence: 0.985,
      severity: SeverityLevel.healthy,
      symptoms: 'Vibrant green chlorophyll, uniform lamina, no lesions or chlorosis.',
      chemicalTreatment: 'No chemical treatment required.',
      organicTreatment: 'Maintain balanced NPK fertilization and periodic prophylactic neem oil spray.',
      knapsackTankDosage: 'None. Keep soil adequately drained.',
      malayalamAudioText: 'ഇലയിൽ രോഗബാധകൾ ഒന്നും തന്നെ കാണുന്നില്ല. വിള ആരോഗ്യകരമാണ്.',
      englishAudioText: 'Leaf tissue is healthy with no pathogenic lesions detected.',
    ),
  ];
}
