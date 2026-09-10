import 'crop_model.dart';

class BookingSlot {
  final String centerId;
  final String centerName;
  final String centerHindi;
  final DateTime date;
  final Crop crop;
  final double quantityQuintals;
  final double estimatedPayout;
  final String timeSlotTitle;
  final String timeSlotHours;
  final String tokenNumber;
  final String farmerName;
  final String farmerId;
  final String lotNumber;

  const BookingSlot({
    required this.centerId,
    required this.centerName,
    required this.centerHindi,
    required this.date,
    required this.crop,
    required this.quantityQuintals,
    required this.estimatedPayout,
    required this.timeSlotTitle,
    required this.timeSlotHours,
    required this.tokenNumber,
    required this.farmerName,
    required this.farmerId,
    required this.lotNumber,
  });

  static BookingSlot defaultSample = BookingSlot(
    centerId: 'mandi_1',
    centerName: 'Sonipat Main Mandi',
    centerHindi: 'सोनीपत मुख्य मंडी',
    date: DateTime(2023, 10, 12),
    crop: Crop.sampleCrops.first,
    quantityQuintals: 50,
    estimatedPayout: 121250.00,
    timeSlotTitle: 'Morning / सुबह',
    timeSlotHours: '08:00 AM - 12:00 PM',
    tokenNumber: '#42',
    farmerName: 'Ram Singh',
    farmerId: '482910',
    lotNumber: '8902A',
  );
}
