class MandiModel {
  final String id;
  final String nameEn;
  final String nameHi;
  final double distanceKm;
  final int waitMinutes;
  final int capacityPercent;
  final bool isRecommended;
  final String locationDistrict;

  const MandiModel({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.distanceKm,
    required this.waitMinutes,
    required this.capacityPercent,
    this.isRecommended = false,
    this.locationDistrict = 'Karnal',
  });

  String get displayName => '$nameEn | $nameHi';
}
