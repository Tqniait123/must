// lib/core/services/biometric_service.dart
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
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

  // Platform channel for Android biometric detection
  static const MethodChannel _channel = MethodChannel('biometric_capabilities');

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

  /// Get detailed biometric capabilities (Android only)
  static Future<Map<String, dynamic>> getAndroidBiometricCapabilities() async {
    if (!Platform.isAndroid) {
      return {};
    }

    try {
      final result = await _channel.invokeMethod('getBiometricCapabilities');

      // Convert the result to Map<String, dynamic>
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }

      return {};
    } catch (e) {
      log('Error getting Android biometric capabilities: $e');
      return {};
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

      // For Android, also check platform channel capabilities
      if (Platform.isAndroid) {
        final capabilities = await getAndroidBiometricCapabilities();
        final canAuthenticate = capabilities['canAuthenticate'] ?? false;
        if (!canAuthenticate) {
          log('Android biometric authentication not available per platform channel');
          return false;
        }
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

    // Check for explicit face type first
    if (availableBiometrics.contains(BiometricType.face)) {
      return true;
    }

    // For Android, use platform channel for accurate detection
    if (Platform.isAndroid) {
      try {
        final capabilities = await getAndroidBiometricCapabilities();
        final hasFaceAuth = capabilities['hasFaceAuth'] ?? false;
        final canAuthenticate = capabilities['canAuthenticate'] ?? false;

        log('Android Face Auth - hasFaceAuth: $hasFaceAuth, canAuthenticate: $canAuthenticate');

        return hasFaceAuth && canAuthenticate;
      } catch (e) {
        log('Error checking face auth via platform channel: $e');
        // Fallback: check if we have strong/weak biometrics (might include face)
        return availableBiometrics.contains(BiometricType.strong) || availableBiometrics.contains(BiometricType.weak);
      }
    }

    return false;
  }

  /// Check if Touch ID/Fingerprint is available
  static Future<bool> isFingerprintAvailable() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();

    // Check for explicit fingerprint type first
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return true;
    }

    // For Android, use platform channel for accurate detection
    if (Platform.isAndroid) {
      try {
        final capabilities = await getAndroidBiometricCapabilities();
        final hasFingerprint = capabilities['hasFingerprint'] ?? false;
        final canAuthenticate = capabilities['canAuthenticate'] ?? false;

        return hasFingerprint && canAuthenticate;
      } catch (e) {
        log('Error checking fingerprint via platform channel: $e');
        // Fallback: check if we have strong/weak biometrics (might include fingerprint)
        return availableBiometrics.contains(BiometricType.strong) || availableBiometrics.contains(BiometricType.weak);
      }
    }

    return false;
  }

  /// Check if Iris recognition is available (some Android devices)
  static Future<bool> isIrisAvailable() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();

    if (availableBiometrics.contains(BiometricType.iris)) {
      return true;
    }

    // For Android, check platform channel
    if (Platform.isAndroid) {
      try {
        final capabilities = await getAndroidBiometricCapabilities();
        final hasIris = capabilities['hasIris'] ?? false;
        final canAuthenticate = capabilities['canAuthenticate'] ?? false;

        return hasIris && canAuthenticate;
      } catch (e) {
        return false;
      }
    }

    return false;
  }

  /// Get the primary biometric type (Face ID preferred, then Touch ID/Fingerprint, then others)
  static Future<String> getPrimaryBiometricType() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();

    if (availableBiometrics.isEmpty) {
      return 'Biometric';
    }

    // Check for specific biometric types first
    if (availableBiometrics.contains(BiometricType.face)) {
      return Platform.isIOS ? 'Face ID' : 'Face Recognition';
    }

    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return Platform.isIOS ? 'Touch ID' : 'Fingerprint';
    }

    if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris Recognition';
    }

    // For Android with generic types, use platform channel
    if (Platform.isAndroid) {
      try {
        final capabilities = await getAndroidBiometricCapabilities();

        final hasFaceAuth = capabilities['hasFaceAuth'] ?? false;
        final hasFingerprint = capabilities['hasFingerprint'] ?? false;
        final hasIris = capabilities['hasIris'] ?? false;

        if (hasFaceAuth) {
          return 'Face Recognition';
        }

        if (hasFingerprint) {
          return 'Fingerprint';
        }

        if (hasIris) {
          return 'Iris Recognition';
        }
      } catch (e) {
        log('Error getting biometric type via platform channel: $e');
      }
    }

    return 'Biometric Authentication';
  }

  /// Get user-friendly display name for biometric type
  static String getBiometricDisplayName(List<BiometricType> availableBiometrics) {
    if (availableBiometrics.isEmpty) {
      return 'Biometric Authentication';
    }

    List<String> names = [];

    // Check for specific types first
    if (availableBiometrics.contains(BiometricType.face)) {
      names.add(Platform.isIOS ? 'Face ID' : 'Face Recognition');
    }

    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      names.add(Platform.isIOS ? 'Touch ID' : 'Fingerprint');
    }

    if (availableBiometrics.contains(BiometricType.iris)) {
      names.add('Iris Recognition');
    }

    // Handle Android generic types
    if (Platform.isAndroid && names.isEmpty) {
      if (availableBiometrics.contains(BiometricType.strong) || availableBiometrics.contains(BiometricType.weak)) {
        return 'Biometric Authentication';
      }
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

      // Handle Android generic biometric types
      if (Platform.isAndroid &&
          (availableBiometrics.contains(BiometricType.strong) || availableBiometrics.contains(BiometricType.weak))) {
        try {
          // Check what type of biometric is actually available via platform channel
          final capabilities = await getAndroidBiometricCapabilities();
          final hasFaceAuth = capabilities['hasFaceAuth'] ?? false;
          final hasFingerprint = capabilities['hasFingerprint'] ?? false;

          if (hasFaceAuth && hasFingerprint) {
            localizedReason = 'Please authenticate with Face Recognition or Fingerprint to login to your account';
          } else if (hasFaceAuth) {
            localizedReason = 'Please authenticate with Face Recognition to login to your account';
          } else if (hasFingerprint) {
            localizedReason = 'Please authenticate with Fingerprint to login to your account';
          } else {
            localizedReason = 'Please authenticate with Biometric Authentication to login to your account';
          }
        } catch (e) {
          localizedReason = 'Please authenticate with Biometric Authentication to login to your account';
        }
      } else {
        // Original logic for specific biometric types
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
    // Check for specific types first
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Face Authentication';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Fingerprint Authentication';
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Iris Authentication';
    }

    // Handle generic Android types
    if (availableBiometrics.contains(BiometricType.strong) || availableBiometrics.contains(BiometricType.weak)) {
      return 'Biometric Authentication';
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
    if (Platform.isAndroid) {
      try {
        final capabilities = await getAndroidBiometricCapabilities();
        final hasFaceAuth = capabilities['hasFaceAuth'] ?? false;
        final hasFingerprint = capabilities['hasFingerprint'] ?? false;

        List<String> instructions = [];

        if (hasFaceAuth) {
          instructions.add('Face Recognition: Go to Settings > Biometrics and security > Face recognition');
        }

        if (hasFingerprint) {
          instructions.add('Fingerprint: Go to Settings > Biometrics and security > Fingerprints');
        }

        if (instructions.isEmpty) {
          return 'Please set up biometric authentication in your device settings.';
        }

        return instructions.join('\n');
      } catch (e) {
        return 'Please set up biometric authentication in your device settings.';
      }
    }

    // iOS
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();

    if (availableBiometrics.isEmpty) {
      return 'Biometric authentication is not available on this device.';
    }

    List<String> instructions = [];

    if (availableBiometrics.contains(BiometricType.face)) {
      instructions.add('Face ID: Go to Settings > Face ID & Passcode');
    }

    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      instructions.add('Touch ID: Go to Settings > Touch ID & Passcode');
    }

    if (instructions.isEmpty) {
      return 'Please set up biometric authentication in your device settings.';
    }

    return instructions.join('\n');
  }
  // Add this method to your BiometricService class for debugging

  /// Debug method to check all biometric capabilities
  static Future<void> debugBiometricCapabilities() async {
    log('=== BIOMETRIC DEBUG INFO ===');

    try {
      // Basic checks
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

      log('Device supported: $isDeviceSupported');
      log('Can check biometrics: $canCheckBiometrics');
      log('Available biometrics: $availableBiometrics');

      // Platform-specific checks
      if (Platform.isAndroid) {
        try {
          final capabilities = await getAndroidBiometricCapabilities();
          log('Android capabilities: $capabilities');

          // Individual method checks
          final hasFace = await _channel.invokeMethod('hasFaceUnlock');
          final hasFingerprint = await _channel.invokeMethod('hasFingerprint');

          log('Individual checks - Face: $hasFace, Fingerprint: $hasFingerprint');
        } catch (e) {
          log('Platform channel error: $e');
        }
      }

      // Service method results
      final isAvailable = await isAvailableBiometric();
      final isFaceAvailable = await isFaceIdAvailable();
      // final isFingerprintAvailable = await isFingerprintAvailable();
      final primaryType = await getPrimaryBiometricType();

      log('Service results:');
      log('  - Is available: $isAvailable');
      log('  - Face available: $isFaceAvailable');
      log('  - Fingerprint available: $isFingerprintAvailable');
      log('  - Primary type: $primaryType');

      log('=== END DEBUG INFO ===');
    } catch (e) {
      log('Debug error: $e');
    }
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
