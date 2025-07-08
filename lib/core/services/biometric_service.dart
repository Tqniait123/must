// lib/core/services/biometric_service.dart
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys for secure storage
  static const String _phoneKey = 'saved_phone';
  static const String _passwordKey = 'saved_password';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // Check if biometric authentication is available
  static Future<bool> isAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Check if Face ID is available (iOS) or Face Recognition (Android)
  static Future<bool> isFaceIdAvailable() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.contains(BiometricType.face);
  }

  // Check if Touch ID/Fingerprint is available
  static Future<bool> isFingerprintAvailable() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();
    return availableBiometrics.contains(BiometricType.fingerprint);
  }

  // Authenticate with biometrics (THIS WILL TRIGGER FACE ID/FINGERPRINT)
  static Future<BiometricAuthResult> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      final bool isAvailable = await BiometricService.isAvailable();

      if (!isAvailable) {
        return BiometricAuthResult(
          isSuccess: false,
          errorMessage: 'Biometric authentication is not available',
          errorType: BiometricErrorType.notAvailable,
        );
      }

      // THIS IS THE IMPORTANT PART - This will trigger Face ID camera or fingerprint scanner
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric Authentication',
            cancelButton: 'Cancel',
            deviceCredentialsRequiredTitle: 'Please authenticate',
            deviceCredentialsSetupDescription: 'Please set up your biometric authentication',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription: 'Biometric authentication is not set up on your device',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
            goToSettingsButton: 'Go to Settings',
            goToSettingsDescription: 'Biometric authentication is not set up on your device',
            lockOut: 'Biometric authentication is disabled. Please lock and unlock your screen to enable it',
          ),
        ],
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
        ),
      );

      return BiometricAuthResult(
        isSuccess: didAuthenticate,
        errorMessage: didAuthenticate ? null : 'Authentication failed',
        errorType: didAuthenticate ? null : BiometricErrorType.authenticationFailed,
      );

    } catch (e) {
      BiometricErrorType errorType;
      String errorMessage;

      if (e.toString().contains('UserCancel')) {
        errorType = BiometricErrorType.userCancel;
        errorMessage = 'Authentication was cancelled by user';
      } else if (e.toString().contains('NotAvailable')) {
        errorType = BiometricErrorType.notAvailable;
        errorMessage = 'Biometric authentication is not available';
      } else if (e.toString().contains('NotEnrolled')) {
        errorType = BiometricErrorType.notEnrolled;
        errorMessage = 'No biometric credentials are enrolled';
      } else if (e.toString().contains('LockedOut')) {
        errorType = BiometricErrorType.lockedOut;
        errorMessage = 'Biometric authentication is temporarily locked';
      } else {
        errorType = BiometricErrorType.unknown;
        errorMessage = 'An unknown error occurred: ${e.toString()}';
      }

      return BiometricAuthResult(
        isSuccess: false,
        errorMessage: errorMessage,
        errorType: errorType,
      );
    }
  }

  // Save credentials to secure storage
  static Future<bool> saveCredentials({
    required String phone,
    required String password,
  }) async {
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

  // Get saved credentials from secure storage
  static Future<Map<String, String?>> getSavedCredentials() async {
    try {
      final results = await Future.wait([
        _storage.read(key: _phoneKey),
        _storage.read(key: _passwordKey),
      ]);

      return {
        'phone': results[0],
        'password': results[1],
      };
    } catch (e) {
      return {
        'phone': null,
        'password': null,
      };
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

  // Check if biometric authentication is enabled
  static Future<bool> isBiometricEnabled() async {
    try {
      final result = await _storage.read(key: _biometricEnabledKey);
      return result == 'true';
    } catch (e) {
      return false;
    }
  }

  // Enable/disable biometric authentication
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricEnabledKey, value: enabled.toString());
  }

  // Complete biometric login flow
  static Future<BiometricAuthResult> authenticateAndGetCredentials({
    required String reason,
  }) async {
    try {
      // First, authenticate with biometrics (this will show Face ID/Fingerprint)
      final authResult = await authenticate(reason: reason, biometricOnly: true);

      if (!authResult.isSuccess) {
        return authResult;
      }

      // If authentication successful, get saved credentials
      final credentials = await getSavedCredentials();

      return BiometricAuthResult(
        isSuccess: true,
        data: credentials,
      );
    } catch (e) {
      return BiometricAuthResult(
        isSuccess: false,
        errorMessage: 'Failed to get credentials: ${e.toString()}',
        errorType: BiometricErrorType.unknown,
      );
    }
  }
}

// Result class for biometric authentication
class BiometricAuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final BiometricErrorType? errorType;
  final Map<String, String?>? data; // For credentials

  BiometricAuthResult({
    required this.isSuccess,
    this.errorMessage,
    this.errorType,
    this.data,
  });
}

// Error types for biometric authentication
enum BiometricErrorType {
  notAvailable,
  notEnrolled,
  userCancel,
  lockedOut,
  authenticationFailed,
  timeout,
  unknown,
}
