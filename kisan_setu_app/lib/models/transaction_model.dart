import 'package:flutter/material.dart';

enum PaymentStatus {
  completed,
  pending,
  actionRequired,
}

class TransactionItem {
  final String id;
  final String titleEn;
  final String titleHi;
  final double amount;
  final String date;
  final String reference;
  final String? quantity;
  final PaymentStatus status;
  final String? actionPrompt;
  final IconData icon;

  const TransactionItem({
    required this.id,
    required this.titleEn,
    required this.titleHi,
    required this.amount,
    required this.date,
    required this.reference,
    this.quantity,
    required this.status,
    this.actionPrompt,
    required this.icon,
  });

  String get displayTitle => '$titleEn / $titleHi';

  static const List<TransactionItem> sampleTransactions = [
    TransactionItem(
      id: 'txn_1',
      titleEn: 'Wheat Sale (Mandi)',
      titleHi: 'गेहूं की बिक्री',
      amount: 45000,
      date: '12 May 2024',
      reference: 'TXN-89234',
      quantity: '20 Quintal',
      status: PaymentStatus.completed,
      icon: Icons.grass,
    ),
    TransactionItem(
      id: 'txn_2',
      titleEn: 'Paddy Procurement',
      titleHi: 'धान की खरीद',
      amount: 32500,
      date: '10 May 2024',
      reference: 'PRQ-1109',
      quantity: '15 Quintal',
      status: PaymentStatus.pending,
      actionPrompt: 'Bank processing',
      icon: Icons.inventory_2,
    ),
    TransactionItem(
      id: 'txn_3',
      titleEn: 'Subsidy Deposit',
      titleHi: 'सब्सिडी जमा',
      amount: 5000,
      date: '05 May 2024',
      reference: 'GOV-SUB-44',
      status: PaymentStatus.actionRequired,
      actionPrompt: 'Please update IFSC code / कृपया IFSC कोड अपडेट करें',
      icon: Icons.account_balance,
    ),
    TransactionItem(
      id: 'txn_4',
      titleEn: 'Fertilizer Subsidy',
      titleHi: 'उर्वरक सब्सिडी',
      amount: 12500,
      date: '20 Apr 2024',
      reference: 'FERT-889',
      status: PaymentStatus.completed,
      icon: Icons.compost,
    ),
  ];
}
