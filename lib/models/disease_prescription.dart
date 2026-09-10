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

  DiseasePrescription copyWith({
    double? confidence,
  }) {
    return DiseasePrescription(
      diseaseId: diseaseId,
      diseaseName: diseaseName,
      cropName: cropName,
      scientificName: scientificName,
      confidence: confidence ?? this.confidence,
      severity: severity,
      symptoms: symptoms,
      chemicalTreatment: chemicalTreatment,
      organicTreatment: organicTreatment,
      knapsackTankDosage: knapsackTankDosage,
      malayalamAudioText: malayalamAudioText,
      englishAudioText: englishAudioText,
    );
  }

  static DiseasePrescription fromLabel(String label, double confidence) {
    final cleanLabel = label.trim().toLowerCase();

    final match = prescriptionsMap.entries.firstWhere(
      (entry) =>
          entry.key.toLowerCase() == cleanLabel ||
          cleanLabel.contains(entry.key.toLowerCase()),
      orElse: () => prescriptionsMap.entries.firstWhere(
        (e) => e.key == 'unmapped_pathology',
        orElse: () => prescriptionsMap.entries.first,
      ),
    ).value;

    return match.copyWith(confidence: confidence);
  }

  static final Map<String, DiseasePrescription> prescriptionsMap = {
    'Pepper_bell_Bacterial_spot': const DiseasePrescription(
      diseaseId: 'Pepper_bell_Bacterial_spot',
      diseaseName: 'Bacterial Spot',
      cropName: 'Bell Pepper / Capsicum',
      scientificName: 'Xanthomonas campestris pv. vesicatoria',
      confidence: 0.94,
      severity: SeverityLevel.severe,
      symptoms:
          'Small, circular water-soaked dark spots on leaves with chlorotic yellow halos, causing premature leaf drop.',
      chemicalTreatment:
          'Copper Oxychloride 50% WP (2.5g/L) mixed with Streptocycline (100 ppm / 1g per 10L).',
      organicTreatment:
          'Spray Pseudomonas fluorescens (20g/L) or neem oil emulsion (5ml/L) at 7-day intervals.',
      knapsackTankDosage:
          '40g Copper Oxychloride + 1.5g Streptocycline in 16L knapsack sprayer. 1 tank per 5 cents.',
      malayalamAudioText:
          'കാപ്സിക്കത്തിൽ ബാക്ടീരിയൽ ഇലപ്പുള്ളി രോഗം കണ്ടെത്തി. കോപ്പർ ഓക്സിക്ലോറൈഡും സ്ട്രെപ്റ്റോസൈക്ലിനും കലർത്തി തളിക്കുക.',
      englishAudioText:
          'Bacterial Spot detected on Bell Pepper. Spray Copper Oxychloride at 2.5 grams per liter with Streptocycline.',
    ),
    'Pepper_bell_healthy': const DiseasePrescription(
      diseaseId: 'Pepper_bell_healthy',
      diseaseName: 'Healthy Foliage',
      cropName: 'Bell Pepper / Capsicum',
      scientificName: 'Capsicum annuum (Healthy)',
      confidence: 0.98,
      severity: SeverityLevel.healthy,
      symptoms:
          'Vibrant green leaves, robust stems, no necrotic spotting or leaf curling.',
      chemicalTreatment: 'No chemical treatment required.',
      organicTreatment:
          'Maintain balanced NPK fertigation and prophylactic neem cake application.',
      knapsackTankDosage: 'None. Maintain well-drained soil moisture.',
      malayalamAudioText:
          'കാപ്സിക്കം ചെടി തികച്ചും ആരോഗ്യകരമാണ്. രോഗബാധകൾ ഒന്നും തന്നെയില്ല.',
      englishAudioText:
          'Bell Pepper foliage is healthy. No disease symptoms detected.',
    ),
    'Potato_Early_blight': const DiseasePrescription(
      diseaseId: 'Potato_Early_blight',
      diseaseName: 'Early Blight',
      cropName: 'Potato',
      scientificName: 'Alternaria solani',
      confidence: 0.93,
      severity: SeverityLevel.moderate,
      symptoms:
          'Dark brown to black circular lesions with characteristic concentric "target-board" rings on older leaves.',
      chemicalTreatment:
          'Mancozeb 75% WP (2.5g/L) or Chlorothalonil 75% WP (2g/L) at 10-day intervals.',
      organicTreatment:
          'Foliar spray of Trichoderma viride or Pseudomonas fluorescens (20g/L).',
      knapsackTankDosage:
          '40g Mancozeb in 16L knapsack sprayer. 1 tank covers approx. 5 cents.',
      malayalamAudioText:
          'ഉരുളക്കിഴങ്ങിൽ ആൾട്ടർനേറിയ ഇലപ്പുള്ളി രോഗം. മാങ്കോസെബ് 75 ശതമാനം WP തളിക്കുക.',
      englishAudioText:
          'Early Blight detected on Potato. Spray Mancozeb 75% WP at 2.5 grams per liter.',
    ),
    'Potato_Late_blight': const DiseasePrescription(
      diseaseId: 'Potato_Late_blight',
      diseaseName: 'Late Blight',
      cropName: 'Potato',
      scientificName: 'Phytophthora infestans',
      confidence: 0.96,
      severity: SeverityLevel.severe,
      symptoms:
          'Water-soaked pale lesions turning dark brown, with white downy mildew under humid conditions; rapid vine death.',
      chemicalTreatment:
          'Metalaxyl 8% + Mancozeb 64% WP (Ridomil MZ @ 2g/L) or Cymoxanil + Mancozeb.',
      organicTreatment:
          'Prophylactic spray of 1% Bordeaux mixture; destroy and bury severely infected foliage.',
      knapsackTankDosage:
          '32g Metalaxyl + Mancozeb (Ridomil MZ) in 16L knapsack sprayer. Thorough canopy drenching.',
      malayalamAudioText:
          'ഉരുളക്കിഴങ്ങിൽ ഗുരുതരമായ ലേറ്റ് ബ്ലൈറ്റ് രോഗം. ഉടൻതന്നെ റിഡോമിൽ എം.ഇസഡ് തളിക്കുക.',
      englishAudioText:
          'Late Blight detected on Potato. Apply Metalaxyl plus Mancozeb at 2 grams per liter immediately.',
    ),
    'Potato_healthy': const DiseasePrescription(
      diseaseId: 'Potato_healthy',
      diseaseName: 'Healthy Foliage',
      cropName: 'Potato',
      scientificName: 'Solanum tuberosum (Healthy)',
      confidence: 0.99,
      severity: SeverityLevel.healthy,
      symptoms:
          'Vigorous compound leaves with uniform green chlorophyll and healthy haulm development.',
      chemicalTreatment: 'No chemical treatment required.',
      organicTreatment:
          'Earth up soil around tubers and apply enriched farmyard manure.',
      knapsackTankDosage: 'None. Maintain regular soil aeration.',
      malayalamAudioText:
          'ഉരുളക്കിഴങ്ങ് വിള പൂർണ്ണ ആരോഗ്യത്തോടെ വളരുന്നു. രോഗബാധകൾ ഇല്ല.',
      englishAudioText:
          'Potato foliage is completely healthy. No pathogen detected.',
    ),
    'Tomato_Early_blight': const DiseasePrescription(
      diseaseId: 'Tomato_Early_blight',
      diseaseName: 'Early Blight',
      cropName: 'Tomato',
      scientificName: 'Alternaria solani',
      confidence: 0.95,
      severity: SeverityLevel.moderate,
      symptoms:
          'Concentric brown target rings on lower leaves, surrounded by yellow chlorotic halos, causing defoliation.',
      chemicalTreatment:
          'Mancozeb 75% WP (2.5g/L) or Azoxystrobin 23% SC (1ml/L).',
      organicTreatment:
          'Weekly foliar spray of Pseudomonas fluorescens (20g/L).',
      knapsackTankDosage:
          '40g Mancozeb in 16L knapsack sprayer. 1 tank per 5 cents.',
      malayalamAudioText:
          'തക്കാളിയിലെ നേർത്ത വളയങ്ങളോട് കൂടിയ അൾട്ടർനേറിയ ഇലപ്പുള്ളി രോഗം. മാങ്കോസെബ് തളിക്കുക.',
      englishAudioText:
          'Early Blight detected on Tomato. Spray Mancozeb 75% WP at 2.5 grams per liter.',
    ),
    'Tomato_Late_blight': const DiseasePrescription(
      diseaseId: 'Tomato_Late_blight',
      diseaseName: 'Late Blight',
      cropName: 'Tomato',
      scientificName: 'Phytophthora infestans',
      confidence: 0.97,
      severity: SeverityLevel.severe,
      symptoms:
          'Large dark, water-soaked oily lesions on leaves and stems with white fungal mold underneath in wet weather.',
      chemicalTreatment:
          'Dimethomorph 50% WP (1g/L) or Metalaxyl + Mancozeb (2g/L).',
      organicTreatment:
          '1% Bordeaux mixture spray; improve spacing to avoid canopy humidity accumulation.',
      knapsackTankDosage: '32g Metalaxyl + Mancozeb in 16L knapsack sprayer.',
      malayalamAudioText:
          'തക്കാളിയിലെ ഗുരുതരമായ ലേറ്റ് ബ്ലൈറ്റ് രോഗം. മെറ്റലാക്സിൽ മാങ്കോസെബ് തളിക്കുക.',
      englishAudioText:
          'Late Blight detected on Tomato. Spray Metalaxyl plus Mancozeb at 2 grams per liter immediately.',
    ),
    'Tomato_Leaf_Mold': const DiseasePrescription(
      diseaseId: 'Tomato_Leaf_Mold',
      diseaseName: 'Leaf Mold',
      cropName: 'Tomato',
      scientificName: 'Passalora fulva',
      confidence: 0.92,
      severity: SeverityLevel.moderate,
      symptoms:
          'Pale green or yellowish chlorotic spots on upper leaf surface with olive-green or velvety brown mold underneath.',
      chemicalTreatment:
          'Copper Oxychloride 50% WP (2.5g/L) or Difenoconazole 25% EC (0.5ml/L).',
      organicTreatment:
          'Increase cross ventilation, avoid wet foliage, spray Bacillus subtilis.',
      knapsackTankDosage: '40g Copper Oxychloride in 16L knapsack sprayer.',
      malayalamAudioText:
          'തക്കാളിയിലെ ലീഫ് മോൾഡ് കുമിൾ രോഗം. കോപ്പർ ഓക്സിക്ലോറൈഡ് തളിക്കുകയും വായുസഞ്ചാരം ഉറപ്പാക്കുകയും ചെയ്യുക.',
      englishAudioText:
          'Leaf Mold detected on Tomato. Spray Copper Oxychloride at 2.5 grams per liter and lower humidity.',
    ),
    'Tomato_Septoria_leaf_spot': const DiseasePrescription(
      diseaseId: 'Tomato_Septoria_leaf_spot',
      diseaseName: 'Septoria Leaf Spot',
      cropName: 'Tomato',
      scientificName: 'Septoria lycopersici',
      confidence: 0.94,
      severity: SeverityLevel.moderate,
      symptoms:
          'Multiple small, circular spots with dark brown margins and gray centers containing tiny black fruiting pycnidia.',
      chemicalTreatment:
          'Chlorothalonil 75% WP (2g/L) or Mancozeb 75% WP (2.5g/L).',
      organicTreatment:
          'Prune infected bottom leaves; mulch around base to prevent rain splash dispersal.',
      knapsackTankDosage: '32g Chlorothalonil in 16L knapsack sprayer.',
      malayalamAudioText:
          'തക്കാളിയിലെ സെപ്റ്റോറിയ ഇലപ്പുള്ളി രോഗം. ക്ലോറോതലോനിൽ അല്ലെങ്കിൽ മാങ്കോസെബ് തളിക്കുക.',
      englishAudioText:
          'Septoria Leaf Spot detected on Tomato. Spray Chlorothalonil 75% WP at 2 grams per liter.',
    ),
    'Tomato_healthy': const DiseasePrescription(
      diseaseId: 'Tomato_healthy',
      diseaseName: 'Healthy Foliage',
      cropName: 'Tomato',
      scientificName: 'Solanum lycopersicum (Healthy)',
      confidence: 0.99,
      severity: SeverityLevel.healthy,
      symptoms:
          'Deep green foliage, robust flowering stems, uniform leaf texture free of spots or wilting.',
      chemicalTreatment: 'No chemical treatment required.',
      organicTreatment:
          'Periodic organic mulch and prophylactic neem oil (3ml/L) spray.',
      knapsackTankDosage: 'None. Maintain consistent irrigation.',
      malayalamAudioText:
          'തക്കാളി ചെടി പൂർണ്ണ ആരോഗ്യത്തോടെ വളരുന്നു. രോഗബാധകൾ ഒന്നും കണ്ടെത്താനായില്ല.',
      englishAudioText:
          'Tomato crop is completely healthy with robust foliage.',
    ),
    'unmapped_pathology': const DiseasePrescription(
      diseaseId: 'unmapped_pathology',
      diseaseName: 'Unclassified Foliar Anomaly',
      cropName: 'Field Crop',
      scientificName: 'General Agronomic Assessment',
      confidence: 0.50,
      severity: SeverityLevel.moderate,
      symptoms:
          'Atypical foliar lesion or discoloration detected. Symptoms do not closely match the standard KAU pathology signatures in the edge model.',
      chemicalTreatment:
          'Avoid applying synthetic fungicides without positive pathogen identification. Consult your local Krishi Bhavan or KAU Extension Officer.',
      organicTreatment:
          'Spray 1% Bordeaux mixture or Pseudomonas fluorescens (20g/L) as a broad-spectrum prophylactic measure. Remove and destroy heavily infected leaves.',
      knapsackTankDosage:
          '160g Copper Sulphate + 160g Quicklime in 16L water for 1% Bordeaux mixture.',
      malayalamAudioText:
          'രോഗലക്ഷണം വ്യക്തമായി തിരിച്ചറിയാൻ കഴിഞ്ഞിട്ടില്ല. അനാവശ്യ കീടനാശിനികൾ ഒഴിവാക്കി കൃഷിഭവൻ ഉദ്യോഗസ്ഥരുമായി ബന്ധപ്പെടുക.',
      englishAudioText:
          'Unclassified foliar anomaly detected. Avoid indiscriminate spraying and consult local agricultural extension officer.',
    ),
  };

  static List<DiseasePrescription> get samplePrescriptions =>
      prescriptionsMap.values.toList();
}
