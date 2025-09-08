import 'package:app_settings/app_settings.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class BiometricService2 {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  // Keys for secure storage
  static const String _phoneKey = 'saved_phone';
  static const String _passwordKey = 'saved_password';
  static const String _biometricEnabledKey = 'biometric_messages_enabled';
  static const String _rememberedPhoneKey = 'remembered_phone'; // New key for remembered phone

  // Save credentials to secure storage
  static Future<bool> saveCredentials({required String phone, required String password}) async {
    try {
      // Normalize phone number (remove spaces, special characters)
      final normalizedPhone = _normalizePhone(phone);

      await Future.wait([
        _storage.write(key: _phoneKey, value: normalizedPhone),
        _storage.write(key: _passwordKey, value: password),
        _storage.write(key: _biometricEnabledKey, value: 'true'),
      ]);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Clear saved credentials
  static Future<bool> clearCredentials() async {
    try {
      await Future.wait([
        _storage.delete(key: _phoneKey),
        _storage.delete(key: _passwordKey),
        _storage.delete(key: _biometricEnabledKey),
      ]);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ==================== NEW FUNCTIONS FOR REMEMBERED PHONE ====================

  // Save remembered phone number
  static Future<bool> saveRememberedPhone(String phone) async {
    try {
      final normalizedPhone = _normalizePhone(phone);
      await _storage.write(key: _rememberedPhoneKey, value: normalizedPhone);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get remembered phone number
  static Future<String?> getRememberedPhone() async {
    try {
      return await _storage.read(key: _rememberedPhoneKey);
    } catch (e) {
      return null;
    }
  }

  // Clear remembered phone number
  static Future<bool> clearRememberedPhone() async {
    try {
      await _storage.delete(key: _rememberedPhoneKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Check if remembered phone exists
  static Future<bool> hasRememberedPhone() async {
    try {
      final phone = await _storage.read(key: _rememberedPhoneKey);
      return phone != null && phone.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Update phone number in saved credentials (called after OTP verification)
  static Future<bool> updatePhoneInCredentials(String newPhone) async {
    try {
      // Check if biometric is enabled and we have saved credentials
      final isBiometricEnabled = await BiometricService2.isBiometricEnabled();
      final hasSavedCredentials = await BiometricService2.hasSavedCredentials();
      
      if (isBiometricEnabled && hasSavedCredentials) {
        // Get the current saved password to preserve it
        final savedPassword = await getSavedPassword();
        if (savedPassword != null) {
          // Update the phone number while keeping the same password
          final normalizedPhone = _normalizePhone(newPhone);
          await _storage.write(key: _phoneKey, value: normalizedPhone);
          
          // Also update the remembered phone
          await saveRememberedPhone(newPhone);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Method to be called from shared preferences or when user data changes
  static Future<bool> updatePhoneFromUserData(String newPhone) async {
    try {
      // This method can be called from anywhere in the app to sync biometric phone
      final normalizedPhone = _normalizePhone(newPhone);
      
      // Check if we have biometric enabled
      final isBiometricEnabled = await BiometricService2.isBiometricEnabled();
      if (isBiometricEnabled) {
        // Update phone in credentials
        final result = await updatePhoneInCredentials(newPhone);
        if (result) {
          return true;
        }
        
        // If no saved credentials but biometric is enabled, save the phone for future use
        await saveRememberedPhone(newPhone);
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if saved phone matches the provided phone
  static Future<bool> isPhoneMatching(String phoneToCheck) async {
    try {
      final savedPhone = await getSavedPhone();
      if (savedPhone == null) return false;
      
      final normalizedSaved = _normalizePhone(savedPhone);
      final normalizedCheck = _normalizePhone(phoneToCheck);
      
      return normalizedSaved == normalizedCheck;
    } catch (e) {
      return false;
    }
  }

  // ==================== END OF NEW FUNCTIONS ====================

  // Check if biometric authentication is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final result = await _storage.read(key: _biometricEnabledKey);
      return result == 'true';
    } catch (e) {
      return false;
    }
  }

  // Get saved phone number
  static Future<String?> getSavedPhone() async {
    try {
      return await _storage.read(key: _phoneKey);
    } catch (e) {
      return null;
    }
  }

  // Get saved password
  static Future<String?> getSavedPassword() async {
    try {
      return await _storage.read(key: _passwordKey);
    } catch (e) {
      return null;
    }
  }

  // Check if saved credentials exist
  static Future<bool> hasSavedCredentials() async {
    try {
      final phone = await _storage.read(key: _phoneKey);
      final password = await _storage.read(key: _passwordKey);
      return phone != null && password != null && phone.isNotEmpty && password.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Normalize phone number for consistent comparison
  static String _normalizePhone(String phone) {
    return phone.trim().replaceAll(RegExp(r'[^\d+]'), '');
  }

  // Check if device supports biometrics
  Future<bool> get isDeviceHasBiometrics async => await _localAuth.canCheckBiometrics;

  // Check if device supports biometric authentication
  Future<bool> get isDeviceHasFingerprint async => await _localAuth.isDeviceSupported();

  // Get available biometric types
  Future<List<BiometricType>> get availableBiometrics async => await _localAuth.getAvailableBiometrics();

  // Authenticate with biometrics only
  Future<bool> authenticateWithBiometrics({required String localizedReason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      return false;
    }
  }

  // Authenticate with device credentials (PIN/Password/Pattern)
  Future<bool> authenticateWithDeviceCredentials({required String localizedReason}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow fallback to device credentials
          stickyAuth: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // Check if biometrics are available but not enrolled
  Future<bool> get isBiometricAvailableButNotEnrolled async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      return canCheckBiometrics && isDeviceSupported && availableBiometrics.isEmpty;
    } catch (e) {
      return false;
    }
  }

  // Open device settings for biometric enrollment
  Future<bool> openBiometricSettings() async {
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.security);
      return true;
    } catch (e) {
      try {
        await AppSettings.openAppSettings(type: AppSettingsType.lockAndPassword);
        return true;
      } catch (e) {
        try {
          await AppSettings.openAppSettings();
          return true;
        } catch (e) {
          return false;
        }
      }
    }
  }

  // Check biometric status and provide appropriate action
  Future<BiometricStatus> checkBiometricStatus() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        return BiometricStatus.notSupported;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      if (availableBiometrics.isEmpty) {
        return BiometricStatus.availableButNotEnrolled;
      }

      return BiometricStatus.available;
    } catch (e) {
      return BiometricStatus.error;
    }
  }

  // Prompt user to enroll biometrics with option to open settings
  Future<bool> promptBiometricEnrollment() async {
    final status = await checkBiometricStatus();

    switch (status) {
      case BiometricStatus.availableButNotEnrolled:
        return await openBiometricSettings();
      case BiometricStatus.notSupported:
        return false;
      case BiometricStatus.available:
        return true;
      case BiometricStatus.error:
        return false;
    }
  }
}

// Enum to represent biometric status
enum BiometricStatus { available, availableButNotEnrolled, notSupported, error }

extension LocalAuthExtension on BiometricService2 {
  Future<bool> authenticate({required String phone, required String password}) async {
    try {
      final isBiometricEnabled = await BiometricService2.isBiometricEnabled();
      if (isBiometricEnabled) {
        final biometricStatus = await checkBiometricStatus();

        if (biometricStatus == BiometricStatus.availableButNotEnrolled) {
          await promptBiometricEnrollment();
          return false;
        }

        if (biometricStatus == BiometricStatus.available) {
          final isAuthenticated = await authenticateWithBiometrics(
            localizedReason: LocaleKeys.biometric_messages_authenticate_reason.tr(),
          );
          if (isAuthenticated) {
            final savedPhone = await BiometricService2.getSavedPhone();
            final savedPassword = await BiometricService2.getSavedPassword();

            // Normalize phone numbers for comparison
            final normalizedInputPhone = BiometricService2._normalizePhone(phone);
            final normalizedSavedPhone = savedPhone != null ? BiometricService2._normalizePhone(savedPhone) : null;

            return normalizedSavedPhone == normalizedInputPhone && savedPassword == password;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Enhanced authentication with better error handling
  Future<AuthenticationResult> authenticateWithResult({required String phone, required String password}) async {
    try {
      final isBiometricEnabled = await BiometricService2.isBiometricEnabled();

      if (!isBiometricEnabled) {
        return AuthenticationResult(
          success: false,
          message: LocaleKeys.biometric_messages_not_enabled.tr(),
          action: AuthenticationAction.none,
        );
      }

      // Check if we have saved credentials
      final hasSavedCredentials = await BiometricService2.hasSavedCredentials();
      if (!hasSavedCredentials) {
        return AuthenticationResult(
          success: false,
          message: LocaleKeys.no_saved_credentials.tr(),
          action: AuthenticationAction.usePassword,
        );
      }

      final biometricStatus = await checkBiometricStatus();

      switch (biometricStatus) {
        case BiometricStatus.notSupported:
          return AuthenticationResult(
            success: false,
            message: LocaleKeys.biometric_messages_not_supported.tr(),
            action: AuthenticationAction.none,
          );

        case BiometricStatus.availableButNotEnrolled:
          return AuthenticationResult(
            success: false,
            message: LocaleKeys.biometric_messages_not_enrolled.tr(),
            action: AuthenticationAction.openSettings,
          );

        case BiometricStatus.available:
          final isAuthenticated = await authenticateWithBiometrics(
            localizedReason: LocaleKeys.biometric_messages_authenticate_reason.tr(),
          );

          if (isAuthenticated) {
            final savedPhone = await BiometricService2.getSavedPhone();
            final savedPassword = await BiometricService2.getSavedPassword();

            if (savedPhone == null || savedPassword == null) {
              return AuthenticationResult(
                success: false,
                message: LocaleKeys.no_saved_credentials.tr(),
                action: AuthenticationAction.usePassword,
              );
            }

            // For biometric authentication, we should use the saved credentials directly
            // instead of comparing with input credentials
            return AuthenticationResult(
              success: true,
              message: LocaleKeys.authentication_successful.tr(),
              action: AuthenticationAction.none,
              phone: savedPhone,
              password: savedPassword,
            );
          } else {
            return AuthenticationResult(
              success: false,
              message: LocaleKeys.biometric_messages_authentication_failed.tr(),
              action: AuthenticationAction.retry,
            );
          }

        case BiometricStatus.error:
          return AuthenticationResult(
            success: false,
            message: LocaleKeys.biometric_messages_status_error.tr(),
            action: AuthenticationAction.none,
          );
      }
    } catch (e) {
      return AuthenticationResult(
        success: false,
        message: '${LocaleKeys.biometric_messages_authentication_error.tr()}: ${e.toString()}',
        action: AuthenticationAction.none,
      );
    }
  }

  // FIXED: Device credential authentication with proper parameters
  Future<AuthenticationResult> authenticateWithDeviceCredentialsResult({required String localizedReason}) async {
    try {
      final isAuthenticated = await authenticateWithDeviceCredentials(localizedReason: localizedReason);
      final phone = await BiometricService2.getSavedPhone();
      final password = await BiometricService2.getSavedPassword();

      if (isAuthenticated) {
        return AuthenticationResult(
          success: true,
          message: LocaleKeys.biometric_messages_device_authentication_successful.tr(),
          action: AuthenticationAction.none,
          phone: phone,
          password: password,
        );
      } else {
        return AuthenticationResult(
          success: false,
          message: LocaleKeys.device_authentication_failed.tr(),
          action: AuthenticationAction.retry,
        );
      }
    } catch (e) {
      return AuthenticationResult(
        success: false,
        message: '${LocaleKeys.biometric_messages_device_authentication_error.tr()}: ${e.toString()}',
        action: AuthenticationAction.none,
      );
    }
  }
}

// Result class for better error handling
class AuthenticationResult {
  final bool success;
  final String message;
  final AuthenticationAction action;
  final String? phone;
  final String? password;

  AuthenticationResult({required this.success, required this.message, required this.action, this.phone, this.password});

  @override
  String toString() {
    return 'AuthenticationResult(success: $success, message: $message, action: $action, phone: $phone, password: $password)';
  }
}

// Actions that can be taken based on authentication result
enum AuthenticationAction { none, openSettings, retry, usePassword, useDeviceCredentials }
