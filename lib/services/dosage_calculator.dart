class DosageCalculationResult {
  final double totalWaterLiters;
  final double totalProductGramsOrMl;
  final String unit; // 'g' for powder, 'ml' for liquid
  final String dosageSummaryMl;

  DosageCalculationResult({
    required this.totalWaterLiters,
    required this.totalProductGramsOrMl,
    required this.unit,
    required this.dosageSummaryMl,
  });
}

class DosageCalculator {
  /// Calculates exact chemical/organic quantity based on sprayer tank capacity in Liters
  static DosageCalculationResult calculateByTankVolume({
    required double tankVolumeLiters,
    required double dosagePerLiter,
    required String chemicalName,
    bool isLiquid = false,
  }) {
    final totalProduct = tankVolumeLiters * dosagePerLiter;
    final unit = isLiquid ? 'ml' : 'ഗ്രാം';

    final summaryMalayalam = 
        "$tankVolumeLiters ലീറ്റർ വെള്ളത്തിൽ $totalProduct $unit $chemicalName കലക്കി തളിക്കുക.";

    return DosageCalculationResult(
      totalWaterLiters: tankVolumeLiters,
      totalProductGramsOrMl: totalProduct,
      unit: unit,
      dosageSummaryMl: summaryMalayalam,
    );
  }

  /// Calculates dosage by land area in Cents (1 Cent ≈ 40.46 sq meters)
  /// Standard thumb rule for vegetable crops: ~1.5 Liters of spray solution per Cent
  static DosageCalculationResult calculateByAreaInCents({
    required double cents,
    required double dosagePerLiter,
    required String chemicalName,
    bool isLiquid = false,
  }) {
    final estimatedWaterRequired = cents * 1.5;
    final totalProduct = estimatedWaterRequired * dosagePerLiter;
    final unit = isLiquid ? 'ml' : 'ഗ്രാം';

    final summaryMalayalam = 
        "$cents സെന്റ് കൃഷിസ്ഥലത്തേക്ക് ഏകദേശം $estimatedWaterRequired ലീറ്റർ വെള്ളത്തിൽ $totalProduct $unit $chemicalName ആവശ്യമാണ്.";

    return DosageCalculationResult(
      totalWaterLiters: estimatedWaterRequired,
      totalProductGramsOrMl: totalProduct,
      unit: unit,
      dosageSummaryMl: summaryMalayalam,
    );
  }
}