import 'package:flutter/material.dart';
import '../models/crop_model.dart';
import '../models/transaction_model.dart';
import '../models/booking_model.dart';

enum AppLanguage {
  english('English', 'English'),
  hindi('हिंदी', 'Hindi'),
  punjabi('ਪੰਜਾਬੀ', 'Punjabi'),
  gujarati('ગુજરાતી', 'Gujarati'),
  marathi('मराठी', 'Marathi');

  final String nativeLabel;
  final String englishLabel;
  const AppLanguage(this.nativeLabel, this.englishLabel);
}

class AppState extends ChangeNotifier {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  AppLanguage _currentLanguage = AppLanguage.english;
  AppLanguage get currentLanguage => _currentLanguage;

  bool _isLoggedIn = true;
  bool get isLoggedIn => _isLoggedIn;

  bool _isAadhaarLinked = true;
  bool get isAadhaarLinked => _isAadhaarLinked;

  bool _isDbtEnabled = true;
  bool get isDbtEnabled => _isDbtEnabled;

  bool _isVoiceGuideActive = false;
  bool get isVoiceGuideActive => _isVoiceGuideActive;

  int _queueAheadCount = 3;
  int get queueAheadCount => _queueAheadCount;

  String _queueWaitTime = '45 mins';
  String get queueWaitTime => _queueWaitTime;

  String _userMobile = '98765 43210';
  String get userMobile => _userMobile;

  String _farmerName = 'Ram Singh';
  String get farmerName => _farmerName;

  String _farmerId = '482910';
  String get farmerId => _farmerId;

  String _village = 'Sonipat';
  String get village => _village;

  BookingSlot _currentBooking = BookingSlot.defaultSample;
  BookingSlot get currentBooking => _currentBooking;

  List<TransactionItem> _transactions = List.from(TransactionItem.sampleTransactions);
  List<TransactionItem> get transactions => _transactions;

  int _currentNavIndex = 0;
  int get currentNavIndex => _currentNavIndex;

  void setLanguage(AppLanguage lang) {
    _currentLanguage = lang;
    notifyListeners();
  }

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  void setMobile(String mobile) {
    _userMobile = mobile;
    notifyListeners();
  }

  void login() {
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void linkAadhaar(String aadhaar) {
    _isAadhaarLinked = true;
    notifyListeners();
  }

  void setDbtEnabled(bool enabled) {
    _isDbtEnabled = enabled;
    notifyListeners();
  }

  void toggleVoiceGuide() {
    _isVoiceGuideActive = !_isVoiceGuideActive;
    notifyListeners();
  }

  void createBooking({
    required String centerId,
    required String centerName,
    required String centerHindi,
    required DateTime date,
    required Crop crop,
    required double quantityQuintals,
    required double estimatedPayout,
    required String timeSlotTitle,
    required String timeSlotHours,
  }) {
    _currentBooking = BookingSlot(
      centerId: centerId,
      centerName: centerName,
      centerHindi: centerHindi,
      date: date,
      crop: crop,
      quantityQuintals: quantityQuintals,
      estimatedPayout: estimatedPayout,
      timeSlotTitle: timeSlotTitle,
      timeSlotHours: timeSlotHours,
      tokenNumber: '#${40 + (DateTime.now().second % 60)}',
      farmerName: _farmerName,
      farmerId: _farmerId,
      lotNumber: '8902A',
    );
    notifyListeners();
  }
}
