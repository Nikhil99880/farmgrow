class TokenModel {
  final String tokenId;
  final String tokenNumber;
  final String farmerName;
  final String mandiName;
  final String date;
  final String timeSlot;
  final String cropName;
  final double quantityQuintals;
  final double estimatedPayout;
  final bool isOfflineReady;

  const TokenModel({
    required this.tokenId,
    required this.tokenNumber,
    required this.farmerName,
    required this.mandiName,
    required this.date,
    required this.timeSlot,
    required this.cropName,
    required this.quantityQuintals,
    required this.estimatedPayout,
    this.isOfflineReady = true,
  });
}
