import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kIsDark = 'isDark';
const String kToken = 'token';
const String kTempToken = 'temp-token';
const String kLang = 'Lang';
const String kOnBoarding = 'onBoarding'; // Added for onboarding screen

class MustInvestPreferences {
  final SharedPreferences _preferences;
  MustInvestPreferences(this._preferences);

  Future<bool> saveToken(String token) async {
    return await _preferences.setString(kToken, token);
  }

  Future<bool> deleteToken() async {
    return await _preferences.remove(kToken);
  }

  String? getToken() {
    return _preferences.getString(kToken);
  }

  Future<bool> saveTempToken(String token) async {
    return await _preferences.setString(kToken, token);
  }

  Future<bool> deleteTempToken() async {
    return await _preferences.remove(kToken);
  }

  String? getTempToken() {
    return _preferences.getString(kToken);
  }

  Future<bool> saveLang(String codeLang) async {
    return await _preferences.setString(kLang, codeLang);
  }

  String getLang() {
    return _preferences.getString(kLang) ?? 'ar';
  }

  Future<bool> setOnBoardingCompleted() async {
    return await _preferences.setBool(kOnBoarding, true);
  }

  bool isOnBoardingCompleted() {
    return _preferences.getBool(kOnBoarding) ?? false;
  }

  setDarkMode(bool isDark) {
    _preferences.setBool(kIsDark, isDark);
    log("${isDark ? "Dark" : "Light"} Mode saved to shared preferences ");
  }

  Future<bool> getIsDarkMode() async {
    bool? isDark = _preferences.getBool(kIsDark);
    return isDark ?? false;
  }

  Future<ThemeMode> getCurrentTheme() async {
    bool isDarkMode = await getIsDarkMode();
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  Future<bool> saveLastSeenNotificationsTime() async {
    try {
      await _preferences.setString(
        'last_seen_notifications_time',
        DateTime.now().toUtc().toIso8601String(),
      );
      return true;
    } catch (e) {
      log('Error saving last seen notifications time: $e');
      return false;
    }
  }

  String? getLastSeenNotificationsTime() {
    return _preferences.getString('last_seen_notifications_time');
  }
}
