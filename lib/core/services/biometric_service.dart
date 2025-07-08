// lib/core/services/biometric_service.dart
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

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

  /// Complete setup process for biometric authentication
  /// Returns BiometricSetupResult with all necessary states
  static Future<BiometricSetupResult> setupBiometric() async {
    try {
      final isAvailable = await isAvailableBiometric();
      final isEnabled = await isBiometricEnabled();

      return BiometricSetupResult(
        isAvailable: isAvailable,
        isEnabled: isEnabled,
        shouldShowQuickLogin: isEnabled && isAvailable,
        primaryBiometricType: await getPrimaryBiometricType(),
        availableBiometrics: await getAvailableBiometrics(),
      );
    } catch (e) {
      return BiometricSetupResult(
        isAvailable: false,
        isEnabled: false,
        shouldShowQuickLogin: false,
        primaryBiometricType: 'Biometric',
        availableBiometrics: [],
        error: 'Setup failed: ${e.toString()}',
      );
    }
  }

  /// Improved biometric availability check with better error handling
  static Future<bool> isAvailableBiometric() async {
    try {
      // First check if the device supports biometric authentication
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        log('Device does not support biometric authentication');
        return false;
      }

      // Then check if we can check biometrics
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        log('Cannot check biometrics on this device');
        return false;
      }

      // Get available biometric methods
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

      log('Available biometrics: $availableBiometrics');

      if (availableBiometrics.isEmpty) {
        log('No biometric methods are enrolled on this device');
        return false;
      }

      return true;
    } catch (e) {
      log('Error checking biometric availability: $e');
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

  /// Check if Face ID is available (iOS) or Face Recognition (Android)
  static Future<bool> isFaceIdAvailable() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.contains(BiometricType.face);
  }

  /// Check if Touch ID/Fingerprint is available
  static Future<bool> isFingerprintAvailable() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.contains(BiometricType.fingerprint);
  }

  /// Check if Iris recognition is available (some Android devices)
  static Future<bool> isIrisAvailable() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.contains(BiometricType.iris);
  }

  /// Get the primary biometric type (Face ID preferred, then Touch ID/Fingerprint, then others)
  static Future<String> getPrimaryBiometricType() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();

    if (availableBiometrics.isEmpty) {
      return 'Biometric';
    }

    // Priority order: Face ID > Touch ID/Fingerprint > Iris > Generic
    if (availableBiometrics.contains(BiometricType.face)) {
      return Platform.isIOS ? 'Face ID' : 'Face Recognition';
    }

    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return Platform.isIOS ? 'Touch ID' : 'Fingerprint';
    }

    if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris Recognition';
    }

    return 'Biometric Authentication';
  }

  /// Get user-friendly display name for biometric type
  static String getBiometricDisplayName(List<BiometricType> availableBiometrics) {
    if (availableBiometrics.isEmpty) {
      return 'Biometric Authentication';
    }

    List<String> names = [];

    if (availableBiometrics.contains(BiometricType.face)) {
      names.add(Platform.isIOS ? 'Face ID' : 'Face Recognition');
    }

    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      names.add(Platform.isIOS ? 'Touch ID' : 'Fingerprint');
    }

    if (availableBiometrics.contains(BiometricType.iris)) {
      names.add('Iris Recognition');
    }

    if (names.isEmpty) {
      return 'Biometric Authentication';
    }

    return names.length == 1 ? names.first : names.join(' or ');
  }

  // ==================== AUTHENTICATION ====================

  /// Complete biometric login flow with credential retrieval
  /// This is the main method the UI should call for login
  static Future<BiometricLoginResult> performBiometricLogin() async {
    try {
      // Check if any biometric method is available
      final bool isAvailable = await isAvailableBiometric();

      if (!isAvailable) {
        return BiometricLoginResult(
          isSuccess: false,
          errorMessage: 'Biometric authentication is not available on this device',
          errorType: BiometricErrorType.notAvailable,
        );
      }

      // Authenticate with available biometric method
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
          errorMessage: 'No saved credentials found. Please login manually first.',
          errorType: BiometricErrorType.noCredentials,
        );
      }

      return BiometricLoginResult(isSuccess: true, phone: phone, password: password);
    } catch (e) {
      return BiometricLoginResult(
        isSuccess: false,
        errorMessage: 'Biometric authentication failed: ${e.toString()}',
        errorType: BiometricErrorType.unknown,
      );
    }
  }

  /// Internal method for biometric authentication
  static Future<BiometricAuthResult> _authenticateWithBiometric() async {
    try {
      final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
      final String biometricType = await getPrimaryBiometricType();

      // Create platform-specific reason text
      String localizedReason;
      if (availableBiometrics.contains(BiometricType.face)) {
        localizedReason =
            Platform.isIOS
                ? 'Please authenticate with Face ID to login to your account'
                : 'Please authenticate with Face Recognition to login to your account';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        localizedReason =
            Platform.isIOS
                ? 'Please authenticate with Touch ID to login to your account'
                : 'Please authenticate with Fingerprint to login to your account';
      } else {
        localizedReason = 'Please authenticate with $biometricType to login to your account';
      }

      log(
        'Biometric authentication started: $biometricType, availableBiometrics: $availableBiometrics, localizedReason: $localizedReason ',
        name: 'BiometricService',
      );

      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: _getAndroidSignInTitle(availableBiometrics),
            cancelButton: 'Cancel',
            deviceCredentialsRequiredTitle: 'Please authenticate with $biometricType',
            deviceCredentialsSetupDescription: 'Please set up $biometricType authentication',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription: '$biometricType is not set up on your device',
            biometricHint: 'Verify your identity',
            // biometricNotRecognizedHint: 'Not recognized, please try again',
            biometricRequiredTitle: 'Biometric authentication required',
            biometricSuccess: 'Authentication successful',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription: '$biometricType is not set up on your device',
            lockOut: '$biometricType is disabled. Please lock and unlock your screen to enable it',
            localizedFallbackTitle: 'Use Passcode',
          ),
        ],
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true, useErrorDialogs: true),
      );

      return BiometricAuthResult(
        isSuccess: didAuthenticate,
        errorMessage: didAuthenticate ? null : 'Biometric authentication failed',
        errorType: didAuthenticate ? null : BiometricErrorType.authenticationFailed,
      );
    } catch (e) {
      return _handleAuthenticationError(e);
    }
  }

  /// Get Android sign-in title based on available biometrics
  static String _getAndroidSignInTitle(List<BiometricType> availableBiometrics) {
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face Authentication';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint Authentication';
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris Authentication';
    }
    return 'Biometric Authentication';
  }

  /// Handle authentication errors and return appropriate result
  static BiometricAuthResult _handleAuthenticationError(dynamic error) {
    BiometricErrorType errorType;
    String errorMessage;

    final errorString = error.toString();

    if (errorString.contains('UserCancel')) {
      errorType = BiometricErrorType.userCancel;
      errorMessage = 'Biometric authentication was cancelled by user';
    } else if (errorString.contains('NotAvailable')) {
      errorType = BiometricErrorType.notAvailable;
      errorMessage = 'Biometric authentication is not available';
    } else if (errorString.contains('NotEnrolled')) {
      errorType = BiometricErrorType.notEnrolled;
      errorMessage = 'Biometric authentication is not set up on this device';
    } else if (errorString.contains('LockedOut')) {
      errorType = BiometricErrorType.lockedOut;
      errorMessage = 'Biometric authentication is temporarily locked';
    } else if (errorString.contains('Timeout')) {
      errorType = BiometricErrorType.timeout;
      errorMessage = 'Biometric authentication timed out';
    } else if (errorString.contains('PermanentlyLockedOut')) {
      errorType = BiometricErrorType.permanentlyLockedOut;
      errorMessage = 'Biometric authentication is permanently locked';
    } else {
      errorType = BiometricErrorType.unknown;
      errorMessage = 'Biometric authentication failed: $errorString';
    }

    return BiometricAuthResult(isSuccess: false, errorMessage: errorMessage, errorType: errorType);
  }

  // ==================== CREDENTIAL MANAGEMENT ====================

  /// Complete flow for enabling biometric authentication after successful login
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
          errorMessage: 'Biometric authentication is not available on this device',
        );
      }

      final isAlreadyEnabled = await isBiometricEnabled();

      if (isAlreadyEnabled) {
        // Just update existing credentials
        final success = await saveCredentials(phone: phone, password: password);
        return BiometricEnableResult(
          isSuccess: success,
          shouldShowSetupDialog: false,
          successMessage: success ? 'Credentials updated successfully' : null,
          errorMessage: success ? null : 'Failed to update credentials',
        );
      }

      if (shouldAskUser) {
        // Return that we should show setup dialog
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
        errorMessage: 'Failed to setup biometric authentication: ${e.toString()}',
      );
    }
  }

  /// Enable biometric authentication with user confirmation
  static Future<BiometricEnableResult> confirmEnableBiometric({required String phone, required String password}) async {
    try {
      final success = await saveCredentials(phone: phone, password: password);
      final biometricType = await getPrimaryBiometricType();

      return BiometricEnableResult(
        isSuccess: success,
        shouldShowSetupDialog: false,
        successMessage: success ? '$biometricType authentication enabled successfully!' : null,
        errorMessage: success ? null : 'Failed to enable $biometricType authentication',
      );
    } catch (e) {
      return BiometricEnableResult(
        isSuccess: false,
        shouldShowSetupDialog: false,
        errorMessage: 'Failed to enable biometric authentication: ${e.toString()}',
      );
    }
  }

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

  /// Enable/disable biometric authentication
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  // ==================== UTILITY METHODS ====================

  /// Get user-friendly error message for UI display
  static String getErrorMessageForUI(BiometricErrorType? errorType) {
    switch (errorType) {
      case BiometricErrorType.userCancel:
        return ''; // Don't show error for user cancellation
      case BiometricErrorType.notAvailable:
        return 'Biometric authentication is not available on this device';
      case BiometricErrorType.notEnrolled:
        return 'Please set up biometric authentication in your device settings';
      case BiometricErrorType.lockedOut:
        return 'Biometric authentication is temporarily locked. Please try again later.';
      case BiometricErrorType.permanentlyLockedOut:
        return 'Biometric authentication is permanently locked. Please use your passcode.';
      case BiometricErrorType.timeout:
        return 'Biometric authentication timed out. Please try again.';
      case BiometricErrorType.noCredentials:
        return 'No saved credentials found. Please login manually first.';
      case BiometricErrorType.authenticationFailed:
        return 'Biometric authentication failed';
      default:
        return 'Biometric authentication failed';
    }
  }

  /// Check if error should be shown to user (some errors like user cancel shouldn't show)
  static bool shouldShowError(BiometricErrorType? errorType) {
    return errorType != BiometricErrorType.userCancel;
  }

  /// Get platform-specific instruction text for biometric setup
  static Future<String> getBiometricSetupInstructions() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();

    if (availableBiometrics.isEmpty) {
      return 'Biometric authentication is not available on this device.';
    }

    List<String> instructions = [];

    if (availableBiometrics.contains(BiometricType.face)) {
      if (Platform.isIOS) {
        instructions.add('Face ID: Go to Settings > Face ID & Passcode');
      } else {
        instructions.add('Face Recognition: Go to Settings > Biometrics and security > Face recognition');
      }
    }

    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      if (Platform.isIOS) {
        instructions.add('Touch ID: Go to Settings > Touch ID & Passcode');
      } else {
        instructions.add('Fingerprint: Go to Settings > Biometrics and security > Fingerprints');
      }
    }

    if (availableBiometrics.contains(BiometricType.iris)) {
      instructions.add('Iris Recognition: Go to Settings > Biometrics and security > Iris Scanner');
    }

    if (instructions.isEmpty) {
      return 'Please set up biometric authentication in your device settings.';
    }

    return instructions.join('\n');
  }
}

// ==================== RESULT CLASSES ====================

/// Result for initial biometric setup
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

  /// Get user-friendly display name for available biometrics
  String get biometricDisplayName => BiometricService.getBiometricDisplayName(availableBiometrics);
}

/// Result for biometric login attempt
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

/// Result for enabling biometric authentication
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

/// Basic authentication result
class BiometricAuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final BiometricErrorType? errorType;

  BiometricAuthResult({required this.isSuccess, this.errorMessage, this.errorType});
}

/// Error types for biometric authentication
enum BiometricErrorType {
  notAvailable,
  notEnrolled,
  userCancel,
  lockedOut,
  permanentlyLockedOut,
  authenticationFailed,
  timeout,
  noCredentials,
  unknown,
}
