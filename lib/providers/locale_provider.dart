import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  bool get isMalayalam => _locale.languageCode == 'ml';

  String get(String en, String ml) {
    return isMalayalam ? ml : en;
  }
}
