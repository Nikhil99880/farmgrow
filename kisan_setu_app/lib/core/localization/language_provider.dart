import 'package:flutter/material.dart';
import 'app_locale.dart';

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.english;

  AppLanguage get currentLanguage => _currentLanguage;

  bool get isHindi => _currentLanguage == AppLanguage.hindi;

  void toggleLanguage() {
    if (_currentLanguage == AppLanguage.english) {
      _currentLanguage = AppLanguage.hindi;
    } else {
      _currentLanguage = AppLanguage.english;
    }
    notifyListeners();
  }

  void setLanguage(AppLanguage language) {
    _currentLanguage = language;
    notifyListeners();
  }

  String tr(String key) {
    return AppLocale.get(key, _currentLanguage);
  }
}
