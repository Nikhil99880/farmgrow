import 'package:flutter/material.dart';

class CropModel {
  final String id;
  final String nameEn;
  final String nameHi;
  final double mspPerQuintal;
  final IconData icon;

  const CropModel({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.mspPerQuintal,
    required this.icon,
  });

  String get displayName => '$nameEn ($nameHi)';
  String get formattedMsp => 'MSP: ₹${mspPerQuintal.toStringAsFixed(0)}/Qtl';
}
