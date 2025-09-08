import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:must_invest/core/services/biometric_service_2.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kIsDark = 'isDark';
const String kToken = 'token';
const String kTempToken = 'temp-token';
const String kLang = 'Lang';
const String kOnBoarding = 'onBoarding'; // Added for onboarding screen
const String kRememberMe = 'rememberMe';

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

  Future<bool> setRememberMe(bool remember) async {
    return await _preferences.setBool(kRememberMe, remember);
  }

  bool isRememberedMe() {
    return _preferences.getBool(kRememberMe) ?? false;
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
      await _preferences.setString('last_seen_notifications_time', DateTime.now().toUtc().toIso8601String());
      return true;
    } catch (e) {
      log('Error saving last seen notifications time: $e');
      return false;
    }
  }

  String? getLastSeenNotificationsTime() {
    return _preferences.getString('last_seen_notifications_time');
  }

  // Method to update biometric phone number after phone verification
  Future<bool> updateBiometricPhoneAfterVerification(String verifiedPhone) async {
    try {
      // Update the phone number in biometric service 
      final result = await BiometricService2.updatePhoneInCredentials(verifiedPhone);
      if (result) {
        log('Biometric phone number updated successfully to: $verifiedPhone');
      } else {
        log('No biometric credentials to update or update failed');
      }
      return result;
    } catch (e) {
      log('Error updating biometric phone number: $e');
      return false;
    }
  }

  // General method to sync biometric data with user data changes
  Future<bool> syncBiometricWithUserData(String newPhone) async {
    try {
      // This can be called when user data changes (not just verification)
      final result = await BiometricService2.updatePhoneFromUserData(newPhone);
      if (result) {
        log('Biometric data synced successfully with new phone: $newPhone');
      } else {
        log('Biometric sync not needed or failed');
      }
      return result;
    } catch (e) {
      log('Error syncing biometric data: $e');
      return false;
    }
  }

  // Method to update biometric password after password reset
  Future<bool> updateBiometricPasswordAfterReset(String phone, String newPassword) async {
    try {
      // Update the password in biometric service if phone matches
      final result = await BiometricService2.updatePasswordInCredentials(phone, newPassword);
      if (result) {
        log('Biometric password updated successfully for phone: $phone');
      } else {
        log('No matching biometric credentials to update or update failed');
      }
      return result;
    } catch (e) {
      log('Error updating biometric password: $e');
      return false;
    }
  }
}
