class QualityTestModel {
  final String lotNumber;
  final String cropName;
  final String procurementCenter;
  final double moisturePercentage;
  final double moistureTargetMax;
  final double foreignMatterPercentage;
  final double foreignMatterTargetMax;
  final double damagedShriveledPercentage;
  final double damagedShriveledTargetMax;
  final double grossWeightQtl;
  final double tareWeightQtl;
  final double netWeightQtl;
  final int bagCount;
  final int bagWeightKg;
  final String testStatus;

  const QualityTestModel({
    required this.lotNumber,
    required this.cropName,
    required this.procurementCenter,
    required this.moisturePercentage,
    required this.moistureTargetMax,
    required this.foreignMatterPercentage,
    required this.foreignMatterTargetMax,
    required this.damagedShriveledPercentage,
    required this.damagedShriveledTargetMax,
    required this.grossWeightQtl,
    required this.tareWeightQtl,
    required this.netWeightQtl,
    required this.bagCount,
    required this.bagWeightKg,
    required this.testStatus,
  });
}
