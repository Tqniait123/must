// Simplified BiometricService following official documentation

import 'dart:developer';
import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  // Keys for secure storage
  static const String _phoneKey = 'saved_phone';
  static const String _passwordKey = 'saved_password';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // ==================== SETUP & AVAILABILITY ====================

  /// Check if biometric authentication is available
  static Future<bool> isAvailableBiometric() async {
    try {
      // Check if device supports biometric authentication
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        log(LocaleKeys.device_not_support_biometric.tr());
        return false;
      }

      // Check if biometrics can be checked
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        log(LocaleKeys.cannot_check_biometrics.tr());
        return false;
      }

      // Get available biometric methods
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

      log('${LocaleKeys.available_biometrics.tr()}: $availableBiometrics');

      // As per documentation: don't rely on specific types, just check if ANY biometric is enrolled
      if (availableBiometrics.isNotEmpty) {
        return true;
      }

      log(LocaleKeys.no_biometric_methods_enrolled.tr());
      return false;
    } catch (e) {
      log('${LocaleKeys.error_checking_biometric_availability.tr()}: $e');
      return false;
    }
  }

  /// Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Check if strong biometrics (face/fingerprint) are available
  static Future<bool> isStrongBiometricAvailable() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();

    // Check for strong biometrics as recommended by documentation
    return availableBiometrics.contains(BiometricType.strong) ||
        availableBiometrics.contains(BiometricType.face) ||
        availableBiometrics.contains(BiometricType.fingerprint);
  }

  /// Get user-friendly biometric type name
  static Future<String> getBiometricDisplayName() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();

    if (availableBiometrics.isEmpty) {
      return LocaleKeys.biometric_authentication.tr();
    }

    // Check for specific types first
    if (availableBiometrics.contains(BiometricType.face)) {
      return Platform.isIOS ? LocaleKeys.face_id.tr() : LocaleKeys.face_recognition.tr();
    }

    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return Platform.isIOS ? LocaleKeys.touch_id.tr() : LocaleKeys.fingerprint.tr();
    }

    // For Android with strong/weak types, use generic names
    if (availableBiometrics.contains(BiometricType.strong)) {
      return Platform.isIOS ? LocaleKeys.biometric_authentication.tr() : LocaleKeys.face_recognition.tr();
    }

    if (availableBiometrics.contains(BiometricType.weak)) {
      return LocaleKeys.biometric_authentication.tr();
    }

    return LocaleKeys.biometric_authentication.tr();
  }

  /// Complete setup process for biometric authentication
  static Future<BiometricSetupResult> setupBiometric() async {
    try {
      final isAvailable = await isAvailableBiometric();
      final isEnabled = await isBiometricEnabled();

      return BiometricSetupResult(
        isAvailable: isAvailable,
        isEnabled: isEnabled,
        shouldShowQuickLogin: isEnabled && isAvailable,
        primaryBiometricType: await getBiometricDisplayName(),
        availableBiometrics: await getAvailableBiometrics(),
      );
    } catch (e) {
      return BiometricSetupResult(
        isAvailable: false,
        isEnabled: false,
        shouldShowQuickLogin: false,
        primaryBiometricType: LocaleKeys.biometric.tr(),
        availableBiometrics: [],
        error: '${LocaleKeys.setup_failed.tr()}: ${e.toString()}',
      );
    }
  }

  // ==================== AUTHENTICATION ====================

  /// Perform biometric authentication
  static Future<BiometricLoginResult> performBiometricLogin() async {
    try {
      // Check if biometric authentication is available
      final bool isAvailable = await isAvailableBiometric();

      if (!isAvailable) {
        return BiometricLoginResult(
          isSuccess: false,
          errorMessage: LocaleKeys.biometric_not_available_on_device_generic.tr(),
          errorType: BiometricErrorType.notAvailable,
        );
      }

      // Authenticate with biometric
      final authResult = await _authenticateWithBiometric();

      if (!authResult.isSuccess) {
        return BiometricLoginResult.fromAuthResult(authResult);
      }

      // Get saved credentials
      final credentials = await getSavedCredentials();
      final phone = credentials['phone'];
      final password = credentials['password'];

      if (phone == null || password == null) {
        return BiometricLoginResult(
          isSuccess: false,
          errorMessage: LocaleKeys.no_saved_credentials.tr(),
          errorType: BiometricErrorType.noCredentials,
        );
      }

      return BiometricLoginResult(isSuccess: true, phone: phone, password: password);
    } catch (e) {
      return BiometricLoginResult(
        isSuccess: false,
        errorMessage: '${LocaleKeys.biometric_authentication_failed.tr()}: ${e.toString()}',
        errorType: BiometricErrorType.unknown,
      );
    }
  }

  /// Internal method for biometric authentication
  static Future<BiometricAuthResult> _authenticateWithBiometric() async {
    try {
      final String biometricType = await getBiometricDisplayName();

      // Use generic localized reason as recommended
      final String localizedReason = LocaleKeys.authenticate_to_login.tr();

      log('${LocaleKeys.biometric_auth_started.tr()}: $biometricType');

      // Follow documentation recommendation: use authenticate with biometricOnly: true
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: LocaleKeys.biometric_authentication.tr(),
            cancelButton: LocaleKeys.cancel.tr(),
            deviceCredentialsRequiredTitle: LocaleKeys.authentication_required.tr(),
            deviceCredentialsSetupDescription: LocaleKeys.setup_biometric_auth.tr(),
            goToSettingsButton: LocaleKeys.go_to_settings.tr(),
            goToSettingsDescription: LocaleKeys.biometric_not_setup_device.tr(),
            biometricHint: LocaleKeys.verify_identity.tr(),
            biometricRequiredTitle: LocaleKeys.biometric_authentication_required.tr(),
            biometricSuccess: LocaleKeys.authentication_successful.tr(),
          ),
          IOSAuthMessages(
            cancelButton: LocaleKeys.cancel.tr(),
            goToSettingsButton: LocaleKeys.go_to_settings.tr(),
            goToSettingsDescription: LocaleKeys.biometric_not_setup_device.tr(),
            lockOut: LocaleKeys.biometric_disabled_lock_unlock.tr(),
            localizedFallbackTitle: LocaleKeys.use_passcode.tr(),
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: false, // This is key - forces biometric authentication
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      return BiometricAuthResult(
        isSuccess: didAuthenticate,
        errorMessage: didAuthenticate ? null : LocaleKeys.biometric_authentication_failed.tr(),
        errorType: didAuthenticate ? null : BiometricErrorType.authenticationFailed,
      );
    } catch (e) {
      return _handleAuthenticationError(e);
    }
  }

  /// Handle authentication errors
  static BiometricAuthResult _handleAuthenticationError(dynamic error) {
    BiometricErrorType errorType;
    String errorMessage;

    final errorString = error.toString();

    if (errorString.contains('UserCancel')) {
      errorType = BiometricErrorType.userCancel;
      errorMessage = LocaleKeys.authentication_cancelled_by_user.tr();
    } else if (errorString.contains('NotAvailable')) {
      errorType = BiometricErrorType.notAvailable;
      errorMessage = LocaleKeys.biometric_not_available.tr();
    } else if (errorString.contains('NotEnrolled')) {
      errorType = BiometricErrorType.notEnrolled;
      errorMessage = LocaleKeys.biometric_not_setup_device.tr();
    } else if (errorString.contains('LockedOut')) {
      errorType = BiometricErrorType.lockedOut;
      errorMessage = LocaleKeys.biometric_temporarily_locked.tr();
    } else if (errorString.contains('PermanentlyLockedOut')) {
      errorType = BiometricErrorType.permanentlyLockedOut;
      errorMessage = LocaleKeys.biometric_permanently_locked.tr();
    } else {
      errorType = BiometricErrorType.unknown;
      errorMessage = '${LocaleKeys.authentication_failed.tr()}: $errorString';
    }

    return BiometricAuthResult(isSuccess: false, errorMessage: errorMessage, errorType: errorType);
  }

  // ==================== CREDENTIAL MANAGEMENT ====================

  /// Save credentials to secure storage
  static Future<bool> saveCredentials({required String phone, required String password}) async {
    try {
      await Future.wait([
        _storage.write(key: _phoneKey, value: phone),
        _storage.write(key: _passwordKey, value: password),
        _storage.write(key: _biometricEnabledKey, value: 'true'),
      ]);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get saved credentials from secure storage
  static Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final results = await Future.wait([_storage.read(key: _phoneKey), _storage.read(key: _passwordKey)]);

      return {'phone': results[0], 'password': results[1]};
    } catch (e) {
      return {'phone': null, 'password': null};
    }
  }

  /// Clear saved credentials
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

  /// Check if biometric authentication is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final result = await _storage.read(key: _biometricEnabledKey);
      return result == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Enable biometric authentication after login
  static Future<BiometricEnableResult> enableBiometricAfterLogin({
    required String phone,
    required String password,
    required bool shouldAskUser,
  }) async {
    try {
      final isAvailable = await isAvailableBiometric();

      if (!isAvailable) {
        return BiometricEnableResult(
          isSuccess: false,
          shouldShowSetupDialog: false,
          errorMessage: LocaleKeys.biometric_not_available_on_device_generic.tr(),
        );
      }

      final isAlreadyEnabled = await isBiometricEnabled();

      if (isAlreadyEnabled) {
        final success = await saveCredentials(phone: phone, password: password);
        return BiometricEnableResult(
          isSuccess: success,
          shouldShowSetupDialog: false,
          successMessage: success ? LocaleKeys.credentials_updated_successfully.tr() : null,
          errorMessage: success ? null : LocaleKeys.failed_to_update_credentials.tr(),
        );
      }

      if (shouldAskUser) {
        return BiometricEnableResult(
          isSuccess: false,
          shouldShowSetupDialog: true,
          pendingPhone: phone,
          pendingPassword: password,
        );
      }

      return BiometricEnableResult(isSuccess: false, shouldShowSetupDialog: false);
    } catch (e) {
      return BiometricEnableResult(
        isSuccess: false,
        shouldShowSetupDialog: false,
        errorMessage: '${LocaleKeys.failed_to_setup_biometric.tr()}: ${e.toString()}',
      );
    }
  }

  /// Confirm enable biometric authentication
  static Future<BiometricEnableResult> confirmEnableBiometric({required String phone, required String password}) async {
    try {
      final success = await saveCredentials(phone: phone, password: password);
      final biometricType = await getBiometricDisplayName();

      return BiometricEnableResult(
        isSuccess: success,
        shouldShowSetupDialog: false,
        successMessage:
            success
                ? LocaleKeys.biometric_auth_enabled_successfully.tr().replaceAll('{biometricType}', biometricType)
                : null,
        errorMessage:
            success ? null : LocaleKeys.failed_to_enable_biometric.tr().replaceAll('{biometricType}', biometricType),
      );
    } catch (e) {
      return BiometricEnableResult(
        isSuccess: false,
        shouldShowSetupDialog: false,
        errorMessage: '${LocaleKeys.failed_to_enable_biometric_generic.tr()}: ${e.toString()}',
      );
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Get user-friendly error message for UI display
  static String getErrorMessageForUI(BiometricErrorType? errorType) {
    switch (errorType) {
      case BiometricErrorType.userCancel:
        return '';
      case BiometricErrorType.notAvailable:
        return LocaleKeys.biometric_not_available_on_device_generic.tr();
      case BiometricErrorType.notEnrolled:
        return LocaleKeys.setup_biometric_in_settings.tr();
      case BiometricErrorType.lockedOut:
        return LocaleKeys.biometric_temporarily_locked_try_again.tr();
      case BiometricErrorType.permanentlyLockedOut:
        return LocaleKeys.biometric_permanently_locked_use_passcode.tr();
      case BiometricErrorType.noCredentials:
        return LocaleKeys.no_saved_credentials_login_manually.tr();
      case BiometricErrorType.authenticationFailed:
        return LocaleKeys.biometric_authentication_failed.tr();
      default:
        return LocaleKeys.biometric_authentication_failed.tr();
    }
  }

  /// Check if error should be shown to user
  static bool shouldShowError(BiometricErrorType? errorType) {
    return errorType != BiometricErrorType.userCancel;
  }
}

// ==================== RESULT CLASSES ====================

class BiometricSetupResult {
  final bool isAvailable;
  final bool isEnabled;
  final bool shouldShowQuickLogin;
  final String primaryBiometricType;
  final List<BiometricType> availableBiometrics;
  final String? error;

  BiometricSetupResult({
    required this.isAvailable,
    required this.isEnabled,
    required this.shouldShowQuickLogin,
    required this.primaryBiometricType,
    required this.availableBiometrics,
    this.error,
  });
}

class BiometricLoginResult {
  final bool isSuccess;
  final String? phone;
  final String? password;
  final String? errorMessage;
  final BiometricErrorType? errorType;

  BiometricLoginResult({required this.isSuccess, this.phone, this.password, this.errorMessage, this.errorType});

  factory BiometricLoginResult.fromAuthResult(BiometricAuthResult authResult) {
    return BiometricLoginResult(
      isSuccess: false,
      errorMessage: authResult.errorMessage,
      errorType: authResult.errorType,
    );
  }
}

class BiometricEnableResult {
  final bool isSuccess;
  final bool shouldShowSetupDialog;
  final String? successMessage;
  final String? errorMessage;
  final String? pendingPhone;
  final String? pendingPassword;

  BiometricEnableResult({
    required this.isSuccess,
    required this.shouldShowSetupDialog,
    this.successMessage,
    this.errorMessage,
    this.pendingPhone,
    this.pendingPassword,
  });
}

class BiometricAuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final BiometricErrorType? errorType;

  BiometricAuthResult({required this.isSuccess, this.errorMessage, this.errorType});
}

enum BiometricErrorType {
  notAvailable,
  notEnrolled,
  userCancel,
  lockedOut,
  permanentlyLockedOut,
  authenticationFailed,
  noCredentials,
  unknown,
}
