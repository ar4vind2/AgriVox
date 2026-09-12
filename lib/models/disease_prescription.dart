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
          cleanLabel.contains(entry.key.toLowerCase()) ||
          entry.key.toLowerCase().contains(cleanLabel),
      orElse: () => prescriptionsMap.entries.firstWhere(
        (e) => e.key == 'unmapped_pathology',
        orElse: () => prescriptionsMap.entries.first,
      ),
    ).value;

    return match.copyWith(confidence: confidence);
  }

  static final Map<String, DiseasePrescription> prescriptionsMap = {
    'Rice_Blast': const DiseasePrescription(
      diseaseId: 'Rice_Blast',
      diseaseName: 'Rice Blast',
      cropName: 'Paddy / Rice (നെല്ല്)',
      scientificName: 'Magnaporthe oryzae',
      confidence: 0.95,
      severity: SeverityLevel.severe,
      symptoms:
          'Spindle-shaped elliptical lesions with gray-white centers and reddish-brown borders on leaf blades, nodes, and panicle neck.',
      chemicalTreatment:
          'Tricyclazole 75 WP (0.6g/L) foliar spray at boot leaf and panicle emergence stage.',
      organicTreatment:
          'Spray Pseudomonas fluorescens (10g/L) or cow dung supernatant (20%) at 10-day intervals.',
      knapsackTankDosage:
          '10g Tricyclazole in 16L knapsack sprayer. 1 tank covers approx. 5 cents. 21 days waiting period.',
      malayalamAudioText:
          'നെല്ലിൽ ബ്ലാസ്റ്റ് കുലവാട്ടം കണ്ടെത്തി. ട്രൈസൈക്ലാസോൾ അല്ലെങ്കിൽ സ്യൂഡോമോണസ് തളിക്കുക.',
      englishAudioText:
          'Rice Blast detected on Paddy crop. Spray Tricyclazole 75 WP at 0.6 grams per liter.',
    ),
    'Rice_Bacterial_Blight': const DiseasePrescription(
      diseaseId: 'Rice_Bacterial_Blight',
      diseaseName: 'Bacterial Leaf Blight',
      cropName: 'Paddy / Rice (നെല്ല്)',
      scientificName: 'Xanthomonas oryzae pv. oryzae',
      confidence: 0.93,
      severity: SeverityLevel.severe,
      symptoms:
          'Water-soaked to yellowish-white wavy stripes starting from leaf tips and margins, with bacterial ooze crusts.',
      chemicalTreatment:
          'Streptocycline (100 ppm / 1g per 10L) mixed with Copper Oxychloride 50 WP (2.0g/L).',
      organicTreatment:
          'Spray 20% cow dung supernatant solution (200g cow dung in 1L water) or Pseudomonas fluorescens (20g/L).',
      knapsackTankDosage:
          '32g Copper Oxychloride + 1.6g Streptocycline in 16L knapsack sprayer. 14 days waiting period.',
      malayalamAudioText:
          'നെല്ലിൽ ബാക്ടീരിയൽ ഇലകരിച്ചിൽ കണ്ടെത്തി. കോപ്പർ ഓക്സിക്ലോറൈഡും സ്ട്രെപ്റ്റോസൈക്ലിനും കലർത്തി തളിക്കുക.',
      englishAudioText:
          'Bacterial Leaf Blight detected on Paddy. Spray Streptocycline with Copper Oxychloride at 2.0 grams per liter.',
    ),
    'Rice_healthy': const DiseasePrescription(
      diseaseId: 'Rice_healthy',
      diseaseName: 'Healthy Foliage',
      cropName: 'Paddy / Rice (നെല്ല്)',
      scientificName: 'Oryza sativa (Healthy)',
      confidence: 0.98,
      severity: SeverityLevel.healthy,
      symptoms:
          'Lush green upright tillers, smooth leaf margin, active root formation, no necrotic lesions.',
      chemicalTreatment: 'No chemical treatment required.',
      organicTreatment:
          'Maintain 5cm standing water, apply Azospirillum and enriched organic compost.',
      knapsackTankDosage: 'None. Maintain balanced water management.',
      malayalamAudioText:
          'നെൽച്ചെടി പൂർണ്ണ ആരോഗ്യത്തോടെ വളരുന്നു. രോഗബാധകൾ ഒന്നും കണ്ടെത്തിയിട്ടില്ല.',
      englishAudioText:
          'Paddy crop is completely healthy with vigorous tillering.',
    ),
    'Coconut_Bud_Rot': const DiseasePrescription(
      diseaseId: 'Coconut_Bud_Rot',
      diseaseName: 'Bud Rot',
      cropName: 'Coconut (തെങ്ങ്)',
      scientificName: 'Phytophthora palmivora',
      confidence: 0.94,
      severity: SeverityLevel.severe,
      symptoms:
          'Yellowing of central spear leaves, necrotic rot at base of spindle, spear leaf withers and pulls out with foul odor.',
      chemicalTreatment:
          'Excise rotten tissues and apply 10% Bordeaux paste. Place Mancozeb perforated sachets (5g) in leaf axils.',
      organicTreatment:
          'Pour 50g Trichoderma viride in 500ml water directly into the central spindle crown.',
      knapsackTankDosage:
          'Spot crown treatment: 10% Bordeaux paste directly on wound surface; prophylactic Mancozeb (2g/L) spray.',
      malayalamAudioText:
          'തെങ്ങിൽ മണ്ടയഴുകൽ രോഗം കണ്ടെത്തി. ചീഞ്ഞ ഭാഗങ്ങൾ ചെത്തിമാറ്റി ബോർഡോ പേസ്റ്റ് തേക്കുക.',
      englishAudioText:
          'Coconut Bud Rot detected. Chisel out infected crown tissues and apply 10% Bordeaux paste.',
    ),
    'Coconut_Stem_Bleeding': const DiseasePrescription(
      diseaseId: 'Coconut_Stem_Bleeding',
      diseaseName: 'Stem Bleeding',
      cropName: 'Coconut (തെങ്ങ്)',
      scientificName: 'Thielaviopsis paradoxa',
      confidence: 0.92,
      severity: SeverityLevel.moderate,
      symptoms:
          'Exudation of dark reddish-brown sticky liquid through bark longitudinal fissures, decaying underlying trunk tissues.',
      chemicalTreatment:
          'Chisel out decayed tissues, swab with Hexaconazole 5% EC (2ml/L), and seal the wound with warm coal tar.',
      organicTreatment:
          'Incorporate 5kg neem cake enriched with Trichoderma harzianum into the palm basin at 1.5m radius.',
      knapsackTankDosage:
          'Direct trunk wound dressing: swab Hexaconazole (2ml/L) followed by Coal Tar sealing.',
      malayalamAudioText:
          'തെങ്ങിൽ തടി ഒഴുക്ക് രോഗം കണ്ടെത്തി. തടി ചെത്തി ഹെക്സാകൊണസോൾ പുരട്ടി കോൾടാർ തേക്കുക.',
      englishAudioText:
          'Coconut Stem Bleeding detected. Chisel out necrotic bark, swab Hexaconazole and coat with coal tar.',
    ),
    'Coconut_healthy': const DiseasePrescription(
      diseaseId: 'Coconut_healthy',
      diseaseName: 'Healthy Palm',
      cropName: 'Coconut (തെങ്ങ്)',
      scientificName: 'Cocos nucifera (Healthy)',
      confidence: 0.99,
      severity: SeverityLevel.healthy,
      symptoms:
          'Deep green spherical crown, strong fibrous trunk, sturdy spathes, no weeping lesions.',
      chemicalTreatment: 'No chemical treatment required.',
      organicTreatment:
          'Apply 50kg farmyard manure, 1.3kg urea, 2kg rock phosphate, and 3.5kg potash per palm basin annually.',
      knapsackTankDosage: 'None. Maintain circular basin mulching.',
      malayalamAudioText:
          'തെങ്ങ് തികച്ചും ആരോഗ്യകരമാണ്. കീടരോഗ ബാധകൾ ഒന്നും തന്നെയില്ല.',
      englishAudioText:
          'Coconut palm is healthy with robust spherical canopy.',
    ),
    'Banana_Sigatoka_Leaf_Spot': const DiseasePrescription(
      diseaseId: 'Banana_Sigatoka_Leaf_Spot',
      diseaseName: 'Sigatoka Leaf Spot',
      cropName: 'Banana (വാഴ)',
      scientificName: 'Mycosphaerella musicola',
      confidence: 0.95,
      severity: SeverityLevel.moderate,
      symptoms:
          'Small yellowish linear streaks turning dark brown spindle spots with gray centers, causing rapid leaf blade drying.',
      chemicalTreatment:
          'Mancozeb 75 WP (2.0g/L) or Propiconazole 25 EC (1ml/L) + mineral oil (10ml/L).',
      organicTreatment:
          'Spray 1% Bordeaux mixture with mineral oil (10ml/L). Cut and burn severely spotted lower leaves.',
      knapsackTankDosage:
          '32g Mancozeb 75 WP + 160ml mineral oil in 16L knapsack sprayer. Drench underside of foliage. 10 days PHI.',
      malayalamAudioText:
          'വാഴയിൽ സിഗാറ്റോക്ക ഇലപ്പുള്ളി രോഗം. മാങ്കോസെബും മിനറൽ ഓയിലും കലർത്തി ഇലകളിൽ തളിക്കുക.',
      englishAudioText:
          'Sigatoka Leaf Spot detected on Banana. Spray Mancozeb 75 WP at 2.0 grams per liter with mineral oil.',
    ),
    'Banana_Panama_Wilt': const DiseasePrescription(
      diseaseId: 'Banana_Panama_Wilt',
      diseaseName: 'Panama Wilt',
      cropName: 'Banana (വാഴ)',
      scientificName: 'Fusarium oxysporum f. sp. cubense',
      confidence: 0.94,
      severity: SeverityLevel.severe,
      symptoms:
          'Yellowing of lower leaves progressing upwards, leaf buckling at petiole junction ("skirt"), vascular ring discoloration.',
      chemicalTreatment:
          'Drench soil basin with Carbendazim 50 WP (2.0g/L) @ 2 to 3 liters per plant pit.',
      organicTreatment:
          'Apply 50g Trichoderma viride + 50g Pseudomonas fluorescens mixed in 5kg FYM per pit at planting and 3rd month.',
      knapsackTankDosage:
          '32g Carbendazim in 16L knapsack sprayer (drenching nozzle). 15 days waiting period.',
      malayalamAudioText:
          'വാഴയിൽ പനാമ വാട്ടം രോഗം കണ്ടെത്തി. കാർബൻഡാസിം അല്ലെങ്കിൽ ട്രൈക്കോഡെർമ വാഴയുടെ ചുവട്ടിൽ ഒഴിക്കുക.',
      englishAudioText:
          'Panama Wilt detected on Banana. Drench root zone with Carbendazim 50 WP at 2.0 grams per liter.',
    ),
    'Banana_healthy': const DiseasePrescription(
      diseaseId: 'Banana_healthy',
      diseaseName: 'Healthy Foliage',
      cropName: 'Banana (വാഴ)',
      scientificName: 'Musa paradisiaca (Healthy)',
      confidence: 0.99,
      severity: SeverityLevel.healthy,
      symptoms:
          'Broad lustrous green erect leaf blades, firm pseudostem, intact vascular tissue without yellowing or wilting.',
      chemicalTreatment: 'No chemical treatment required.',
      organicTreatment:
          'Apply 3% Panchagavya foliar spray and well-rotted farmyard manure with neem cake.',
      knapsackTankDosage: 'None. Maintain adequate moisture and weed-free basin.',
      malayalamAudioText:
          'വാഴച്ചെടി പൂർണ്ണ ആരോഗ്യത്തോടെയിരിക്കുന്നു. യാതൊരുവിധ രോഗലക്ഷണങ്ങളും ഇല്ല.',
      englishAudioText:
          'Banana foliage is vibrant and healthy. No pathogen detected.',
    ),
    'Brinjal_Bacterial_Wilt': const DiseasePrescription(
      diseaseId: 'Brinjal_Bacterial_Wilt',
      diseaseName: 'Bacterial Wilt',
      cropName: 'Brinjal / Eggplant (വഴുതന)',
      scientificName: 'Ralstonia solanacearum',
      confidence: 0.95,
      severity: SeverityLevel.severe,
      symptoms:
          'Sudden irreversible daytime wilting of entire plant while leaves remain green; brown vascular ring oozes milky stream in water.',
      chemicalTreatment:
          'Soil drenching with Copper Oxychloride 50 WP (2.5g/L) + Streptocycline (100 ppm / 1g per 10L).',
      organicTreatment:
          'Drench root collar with Pseudomonas fluorescens (20g/L). Rotate crop with non-solanaceous crops.',
      knapsackTankDosage:
          '40g Copper Oxychloride + 1.6g Streptocycline in 16L knapsack sprayer. Drench plant collar. 7 days PHI.',
      malayalamAudioText:
          'വഴുതനയിൽ ബാക്ടീരിയൽ വാട്ടം കണ്ടെത്തി. കോപ്പർ ഓക്സിക്ലോറൈഡും സ്ട്രെപ്റ്റോസൈക്ലിനും ചെടിയുടെ ചുവട്ടിൽ ഒഴിക്കുക.',
      englishAudioText:
          'Bacterial Wilt detected on Brinjal. Drench soil with Copper Oxychloride at 2.5 grams per liter.',
    ),
    'Brinjal_Little_Leaf': const DiseasePrescription(
      diseaseId: 'Brinjal_Little_Leaf',
      diseaseName: 'Little Leaf Disease',
      cropName: 'Brinjal / Eggplant (വഴുതന)',
      scientificName: 'Candidatus Phytoplasma',
      confidence: 0.91,
      severity: SeverityLevel.moderate,
      symptoms:
          'Severe reduction in leaf blade size, shortened internodes producing a dense bushy phyllody, sterile flowers.',
      chemicalTreatment:
          'Dimethoate 30 EC (1.5ml/L) to control leafhopper vectors (Hishimonus phycitis).',
      organicTreatment:
          'Spray 5% Neem Seed Kernel Extract (NSKE) or 2% neem oil garlic emulsion to repel jassids; rouge out infected bushes.',
      knapsackTankDosage:
          '24ml Dimethoate in 16L knapsack sprayer. 1 tank per 5 cents. 10 days waiting period.',
      malayalamAudioText:
          'വഴുതനയിൽ ചെറു ഇല രോഗം കണ്ടെത്തി. കീടങ്ങളെ നിയന്ത്രിക്കാൻ ഡൈമെത്തോയേറ്റ് അല്ലെങ്കിൽ വേപ്പെണ്ണ സത്ത് തളിക്കുക.',
      englishAudioText:
          'Little Leaf Disease detected on Brinjal. Spray Dimethoate 30 EC at 1.5 ml per liter to control leafhoppers.',
    ),
    'Brinjal_healthy': const DiseasePrescription(
      diseaseId: 'Brinjal_healthy',
      diseaseName: 'Healthy Foliage',
      cropName: 'Brinjal / Eggplant (വഴുതന)',
      scientificName: 'Solanum melongena (Healthy)',
      confidence: 0.98,
      severity: SeverityLevel.healthy,
      symptoms:
          'Broad lobed green leaves, sturdy branching structure, vibrant purple/white flowers, absence of curling.',
      chemicalTreatment: 'No chemical treatment required.',
      organicTreatment:
          'Apply vermicompost tea and prophylactic neem spray (3ml/L).',
      knapsackTankDosage: 'None. Maintain organic mulch around root zone.',
      malayalamAudioText:
          'വഴുതന ചെടി പൂർണ്ണ ആരോഗ്യത്തോടെ വളരുന്നു. രോഗബാധകൾ ഇല്ല.',
      englishAudioText:
          'Brinjal plant is completely healthy with vigorous foliage.',
    ),
    'Okra_Yellow_Vein_Mosaic': const DiseasePrescription(
      diseaseId: 'Okra_Yellow_Vein_Mosaic',
      diseaseName: 'Yellow Vein Mosaic Virus (BYVMV)',
      cropName: 'Ladies Finger / Okra (വെണ്ട)',
      scientificName: 'Bhendi yellow vein mosaic virus',
      confidence: 0.96,
      severity: SeverityLevel.severe,
      symptoms:
          'Clear transparent vein clearing followed by bright yellow vein network across green lamina, stunted chlorotic leaves and small hard yellow pods.',
      chemicalTreatment:
          'Dimethoate 30 EC (1.5ml/L) or Acetamiprid 20 SP (0.5g/L) to control whitefly vector (Bemisia tabaci).',
      organicTreatment:
          'Weekly spray of 2% Neem oil-garlic emulsion; install yellow sticky traps (10 per acre) and uproot early diseased plants.',
      knapsackTankDosage:
          '24ml Dimethoate in 16L knapsack sprayer. 1 tank per 5 cents. 7 days waiting period.',
      malayalamAudioText:
          'വെണ്ടയിൽ ഞരമ്പ് മഞ്ഞളിപ്പ് രോഗം കണ്ടെത്തി. വെള്ളീച്ചകളെ തുരത്താൻ ഡൈമെത്തോയേറ്റ് അല്ലെങ്കിൽ വേപ്പെണ്ണ വെളുത്തുള്ളി മിശ്രിതം തളിക്കുക.',
      englishAudioText:
          'Yellow Vein Mosaic Virus detected on Okra. Spray Dimethoate at 1.5 ml per liter to manage whitefly vectors.',
    ),
    'Okra_Powdery_Mildew': const DiseasePrescription(
      diseaseId: 'Okra_Powdery_Mildew',
      diseaseName: 'Powdery Mildew',
      cropName: 'Ladies Finger / Okra (വെണ്ട)',
      scientificName: 'Erysiphe cichoracearum',
      confidence: 0.93,
      severity: SeverityLevel.moderate,
      symptoms:
          'White powdery talcum-like fungal patches on upper leaf surface, spreading to entire leaf leading to yellowing and premature defoliation.',
      chemicalTreatment:
          'Wettable Sulphur 80 WP (2.5g/L) or Dinocap 48 EC (1ml/L).',
      organicTreatment:
          'Spray 5g/L baking soda (Sodium bicarbonate) solution with soap, or 5% sour buttermilk foliar spray.',
      knapsackTankDosage:
          '40g Wettable Sulphur in 16L knapsack sprayer. 1 tank per 5 cents. 5 days waiting period.',
      malayalamAudioText:
          'വെണ്ടയിൽ ചാരരോഗം കണ്ടെത്തി. വെറ്റബിൾ സൾഫർ അല്ലെങ്കിൽ പുളിച്ച മോര് വെള്ളത്തിൽ കലക്കി തളിക്കുക.',
      englishAudioText:
          'Powdery Mildew detected on Okra. Spray Wettable Sulphur 80 WP at 2.5 grams per liter.',
    ),
    'Okra_healthy': const DiseasePrescription(
      diseaseId: 'Okra_healthy',
      diseaseName: 'Healthy Foliage',
      cropName: 'Ladies Finger / Okra (വെണ്ട)',
      scientificName: 'Abelmoschus esculentus (Healthy)',
      confidence: 0.99,
      severity: SeverityLevel.healthy,
      symptoms:
          'Lush green palmate leaves with sharp serrated lobes, robust upright stem, healthy flower buds, zero mosaic patterns.',
      chemicalTreatment: 'No chemical treatment required.',
      organicTreatment:
          'Apply Jeevamrutham foliar spray and neem cake in basins.',
      knapsackTankDosage: 'None. Ensure well-drained soil.',
      malayalamAudioText:
          'വെണ്ടച്ചെടി തികച്ചും ആരോഗ്യകരമാണ്. യാതൊരുവിധ രോഗബാധകളും ഇല്ല.',
      englishAudioText:
          'Okra plant is completely healthy with vigorous green foliage.',
    ),
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
    'Background_Noise': const DiseasePrescription(
      diseaseId: 'Background_Noise',
      diseaseName: 'Non-Plant / Background Surface',
      cropName: 'Non-Crop Surface',
      scientificName: 'Non-Biological Surface',
      confidence: 0.15,
      severity: SeverityLevel.mild,
      symptoms:
          'No crop leaf lesion detected. The camera is pointing at an artificial surface, furniture, book, wall, or hand.',
      chemicalTreatment: 'No chemical treatment required.',
      organicTreatment:
          'Aim the viewfinder reticle directly at a live crop leaf under good natural lighting.',
      knapsackTankDosage: 'None. Please re-scan a plant leaf.',
      malayalamAudioText:
          'ചെടിയുടെ ഇല കണ്ടെത്താനായില്ല. ദയവായി ക്യാമറ ഇലയിലേക്ക് തിരിച്ച് വീണ്ടും സ്കാൻ ചെയ്യുക.',
      englishAudioText:
          'Non-plant surface detected. Please focus the camera squarely on a crop leaf and scan again.',
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
