enum PaymentStatus { completed, pending, actionRequired }

class PaymentModel {
  final String id;
  final String titleEn;
  final String titleHi;
  final double amount;
  final String date;
  final String refNo;
  final double? quantityQuintals;
  final PaymentStatus status;
  final String? actionMessage;
  final String? iconType;

  const PaymentModel({
    required this.id,
    required this.titleEn,
    required this.titleHi,
    required this.amount,
    required this.date,
    required this.refNo,
    this.quantityQuintals,
    required this.status,
    this.actionMessage,
    this.iconType,
  });

  String get formattedAmount => '₹ ${amount.toStringAsFixed(0)}';
}
