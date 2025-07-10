import 'package:app_settings/app_settings.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'debug_logger.dart'; // Import the debug logger

class BiometricService2 {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  // Keys for secure storage
  static const String _phoneKey = 'saved_phone';
  static const String _passwordKey = 'saved_password';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // Save credentials to secure storage
  static Future<bool> saveCredentials({required String phone, required String password}) async {
    await DebugLogger.instance.log('BiometricService', 'Attempting to save credentials', level: LogLevel.info);

    try {
      // Normalize phone number (remove spaces, special characters)
      final normalizedPhone = _normalizePhone(phone);

      await DebugLogger.instance.log('BiometricService', 'Normalized phone: $normalizedPhone (original: $phone)');

      await Future.wait([
        _storage.write(key: _phoneKey, value: normalizedPhone),
        _storage.write(key: _passwordKey, value: password),
        _storage.write(key: _biometricEnabledKey, value: 'true'),
      ]);

      await DebugLogger.instance.logCredentialsSave(true, null);
      await DebugLogger.instance.log('BiometricService', 'Credentials saved successfully');

      return true;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logCredentialsSave(false, e.toString());
      await DebugLogger.instance.logError('BiometricService', 'Failed to save credentials', e, stackTrace);
      return false;
    }
  }

  // Clear saved credentials
  static Future<bool> clearCredentials() async {
    await DebugLogger.instance.log('BiometricService', 'Attempting to clear credentials');

    try {
      await Future.wait([
        _storage.delete(key: _phoneKey),
        _storage.delete(key: _passwordKey),
        _storage.delete(key: _biometricEnabledKey),
      ]);

      await DebugLogger.instance.logSecureStorage('clear_credentials', true, null);
      await DebugLogger.instance.log('BiometricService', 'Credentials cleared successfully');

      return true;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logSecureStorage('clear_credentials', false, e.toString());
      await DebugLogger.instance.logError('BiometricService', 'Failed to clear credentials', e, stackTrace);
      return false;
    }
  }

  // Check if biometric authentication is enabled
  static Future<bool> isBiometricEnabled() async {
    await DebugLogger.instance.log('BiometricService', 'Checking if biometric is enabled');

    try {
      final result = await _storage.read(key: _biometricEnabledKey);
      final isEnabled = result == 'true';

      await DebugLogger.instance.log('BiometricService', 'Biometric enabled status: $isEnabled (raw: $result)');
      await DebugLogger.instance.logSecureStorage('read_biometric_enabled', true, null);

      return isEnabled;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logSecureStorage('read_biometric_enabled', false, e.toString());
      await DebugLogger.instance.logError(
        'BiometricService',
        'Failed to check biometric enabled status',
        e,
        stackTrace,
      );
      return false;
    }
  }

  // Get saved phone number
  static Future<String?> getSavedPhone() async {
    await DebugLogger.instance.log('BiometricService', 'Getting saved phone');

    try {
      final phone = await _storage.read(key: _phoneKey);

      await DebugLogger.instance.log('BiometricService', 'Saved phone: ${phone != null ? 'Found' : 'Not found'}');
      await DebugLogger.instance.logSecureStorage('read_phone', true, null);

      return phone;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logSecureStorage('read_phone', false, e.toString());
      await DebugLogger.instance.logError('BiometricService', 'Failed to get saved phone', e, stackTrace);
      return null;
    }
  }

  // Get saved password
  static Future<String?> getSavedPassword() async {
    await DebugLogger.instance.log('BiometricService', 'Getting saved password');

    try {
      final password = await _storage.read(key: _passwordKey);

      await DebugLogger.instance.log('BiometricService', 'Saved password: ${password != null ? 'Found' : 'Not found'}');
      await DebugLogger.instance.logSecureStorage('read_password', true, null);

      return password;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logSecureStorage('read_password', false, e.toString());
      await DebugLogger.instance.logError('BiometricService', 'Failed to get saved password', e, stackTrace);
      return null;
    }
  }

  // Check if saved credentials exist
  static Future<bool> hasSavedCredentials() async {
    await DebugLogger.instance.log('BiometricService', 'Checking for saved credentials');

    try {
      final phone = await _storage.read(key: _phoneKey);
      final password = await _storage.read(key: _passwordKey);

      final hasCredentials = phone != null && password != null && phone.isNotEmpty && password.isNotEmpty;

      await DebugLogger.instance.log('BiometricService', 'Has saved credentials: $hasCredentials');
      await DebugLogger.instance.logCredentialsLoad(hasCredentials, null);

      return hasCredentials;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logCredentialsLoad(false, e.toString());
      await DebugLogger.instance.logError('BiometricService', 'Failed to check saved credentials', e, stackTrace);
      return false;
    }
  }

  // Normalize phone number for consistent comparison
  static String _normalizePhone(String phone) {
    final normalized = phone.trim().replaceAll(RegExp(r'[^\d+]'), '');
    DebugLogger.instance.log('BiometricService', 'Phone normalization: "$phone" -> "$normalized"');
    return normalized;
  }

  // Check if device supports biometrics
  Future<bool> get isDeviceHasBiometrics async {
    await DebugLogger.instance.log('BiometricService', 'Checking if device has biometrics');

    try {
      final result = await _localAuth.canCheckBiometrics;

      await DebugLogger.instance.log('BiometricService', 'Device has biometrics: $result');
      await DebugLogger.instance.logBiometricStatus('device_has_biometrics', {'result': result});

      return result;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logError('BiometricService', 'Failed to check device biometrics', e, stackTrace);
      return false;
    }
  }

  // Check if device supports biometric authentication
  Future<bool> get isDeviceHasFingerprint async {
    await DebugLogger.instance.log('BiometricService', 'Checking if device supports fingerprint');

    try {
      final result = await _localAuth.isDeviceSupported();

      await DebugLogger.instance.log('BiometricService', 'Device supports fingerprint: $result');
      await DebugLogger.instance.logBiometricStatus('device_supports_fingerprint', {'result': result});

      return result;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logError(
        'BiometricService',
        'Failed to check device fingerprint support',
        e,
        stackTrace,
      );
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> get availableBiometrics async {
    await DebugLogger.instance.log('BiometricService', 'Getting available biometrics');

    try {
      final result = await _localAuth.getAvailableBiometrics();

      await DebugLogger.instance.log('BiometricService', 'Available biometrics: ${result.map((e) => e.name).toList()}');
      await DebugLogger.instance.logBiometricStatus('available_biometrics', {
        'count': result.length,
        'types': result.map((e) => e.name).toList(),
      });

      return result;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logError('BiometricService', 'Failed to get available biometrics', e, stackTrace);
      return [];
    }
  }

  // Authenticate with biometrics only
  Future<bool> authenticateWithBiometrics({required String localizedReason}) async {
    await DebugLogger.instance.log('BiometricService', 'Starting biometric authentication');
    await DebugLogger.instance.log('BiometricService', 'Localized reason: $localizedReason');

    try {
      final result = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(biometricOnly: true),
      );

      await DebugLogger.instance.logBiometricAuthentication('biometric_only', result, null);
      await DebugLogger.instance.log('BiometricService', 'Biometric authentication result: $result');

      return result;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logBiometricAuthentication('biometric_only', false, e.toString());
      await DebugLogger.instance.logError('BiometricService', 'Biometric authentication failed', e, stackTrace);
      return false;
    }
  }

  // Authenticate with device credentials (PIN/Password/Pattern)
  Future<bool> authenticateWithDeviceCredentials({required String localizedReason}) async {
    await DebugLogger.instance.log('BiometricService', 'Starting device credentials authentication');
    await DebugLogger.instance.log('BiometricService', 'Localized reason: $localizedReason');

    try {
      final result = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: false, // Allow fallback to device credentials
          stickyAuth: true,
        ),
      );

      await DebugLogger.instance.logBiometricAuthentication('device_credentials', result, null);
      await DebugLogger.instance.log('BiometricService', 'Device credentials authentication result: $result');

      return result;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logBiometricAuthentication('device_credentials', false, e.toString());
      await DebugLogger.instance.logError(
        'BiometricService',
        'Device credentials authentication failed',
        e,
        stackTrace,
      );
      return false;
    }
  }

  // Check if biometrics are available but not enrolled
  Future<bool> get isBiometricAvailableButNotEnrolled async {
    await DebugLogger.instance.log('BiometricService', 'Checking if biometric is available but not enrolled');

    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();

      final result = canCheckBiometrics && isDeviceSupported && availableBiometrics.isEmpty;

      await DebugLogger.instance.log('BiometricService', 'Biometric status check:');
      await DebugLogger.instance.log('BiometricService', '  canCheckBiometrics: $canCheckBiometrics');
      await DebugLogger.instance.log('BiometricService', '  isDeviceSupported: $isDeviceSupported');
      await DebugLogger.instance.log('BiometricService', '  availableBiometrics: ${availableBiometrics.length}');
      await DebugLogger.instance.log('BiometricService', '  availableButNotEnrolled: $result');

      await DebugLogger.instance.logBiometricStatus('available_but_not_enrolled', {
        'canCheckBiometrics': canCheckBiometrics,
        'isDeviceSupported': isDeviceSupported,
        'availableBiometricsCount': availableBiometrics.length,
        'result': result,
      });

      return result;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logError('BiometricService', 'Failed to check biometric availability', e, stackTrace);
      return false;
    }
  }

  // Open device settings for biometric enrollment
  Future<bool> openBiometricSettings() async {
    await DebugLogger.instance.log('BiometricService', 'Attempting to open biometric settings');

    try {
      await AppSettings.openAppSettings(type: AppSettingsType.security);
      await DebugLogger.instance.log('BiometricService', 'Successfully opened security settings');
      return true;
    } catch (e) {
      await DebugLogger.instance.log(
        'BiometricService',
        'Failed to open security settings, trying lock and password: $e',
      );

      try {
        await AppSettings.openAppSettings(type: AppSettingsType.lockAndPassword);
        await DebugLogger.instance.log('BiometricService', 'Successfully opened lock and password settings');
        return true;
      } catch (e2) {
        await DebugLogger.instance.log(
          'BiometricService',
          'Failed to open lock and password settings, trying general settings: $e2',
        );

        try {
          await AppSettings.openAppSettings();
          await DebugLogger.instance.log('BiometricService', 'Successfully opened general settings');
          return true;
        } catch (e3, stackTrace) {
          await DebugLogger.instance.logError('BiometricService', 'Failed to open any settings', e3, stackTrace);
          return false;
        }
      }
    }
  }

  // Check biometric status and provide appropriate action
  Future<BiometricStatus> checkBiometricStatus() async {
    await DebugLogger.instance.log('BiometricService', 'Checking biometric status');

    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      await DebugLogger.instance.log('BiometricService', 'Initial biometric check:');
      await DebugLogger.instance.log('BiometricService', '  canCheckBiometrics: $canCheckBiometrics');
      await DebugLogger.instance.log('BiometricService', '  isDeviceSupported: $isDeviceSupported');

      if (!canCheckBiometrics || !isDeviceSupported) {
        await DebugLogger.instance.log('BiometricService', 'Biometric not supported');
        await DebugLogger.instance.logBiometricStatus('not_supported', {
          'canCheckBiometrics': canCheckBiometrics,
          'isDeviceSupported': isDeviceSupported,
        });
        return BiometricStatus.notSupported;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      await DebugLogger.instance.log('BiometricService', 'Available biometrics: ${availableBiometrics.length}');

      if (availableBiometrics.isEmpty) {
        await DebugLogger.instance.log('BiometricService', 'Biometric available but not enrolled');
        await DebugLogger.instance.logBiometricStatus('available_but_not_enrolled', {
          'canCheckBiometrics': canCheckBiometrics,
          'isDeviceSupported': isDeviceSupported,
          'availableBiometricsCount': 0,
        });
        return BiometricStatus.availableButNotEnrolled;
      }

      await DebugLogger.instance.log('BiometricService', 'Biometric available and enrolled');
      await DebugLogger.instance.logBiometricStatus('available', {
        'canCheckBiometrics': canCheckBiometrics,
        'isDeviceSupported': isDeviceSupported,
        'availableBiometricsCount': availableBiometrics.length,
        'types': availableBiometrics.map((e) => e.name).toList(),
      });

      return BiometricStatus.available;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logError('BiometricService', 'Error checking biometric status', e, stackTrace);
      return BiometricStatus.error;
    }
  }

  // Prompt user to enroll biometrics with option to open settings
  Future<bool> promptBiometricEnrollment() async {
    await DebugLogger.instance.log('BiometricService', 'Prompting biometric enrollment');

    final status = await checkBiometricStatus();

    await DebugLogger.instance.log('BiometricService', 'Biometric status for enrollment: ${status.name}');

    switch (status) {
      case BiometricStatus.availableButNotEnrolled:
        final result = await openBiometricSettings();
        await DebugLogger.instance.log('BiometricService', 'Enrollment prompt result: $result');
        return result;
      case BiometricStatus.notSupported:
        await DebugLogger.instance.log('BiometricService', 'Biometric not supported for enrollment');
        return false;
      case BiometricStatus.available:
        await DebugLogger.instance.log('BiometricService', 'Biometric already available');
        return true;
      case BiometricStatus.error:
        await DebugLogger.instance.log('BiometricService', 'Error during enrollment prompt');
        return false;
    }
  }
}

// Enum to represent biometric status
enum BiometricStatus { available, availableButNotEnrolled, notSupported, error }

extension LocalAuthExtension on BiometricService2 {
  Future<bool> authenticate({required String phone, required String password}) async {
    await DebugLogger.instance.log('BiometricExtension', 'Starting authentication process');
    await DebugLogger.instance.log('BiometricExtension', 'Phone: ${phone.isNotEmpty ? 'Provided' : 'Empty'}');
    await DebugLogger.instance.log('BiometricExtension', 'Password: ${password.isNotEmpty ? 'Provided' : 'Empty'}');

    try {
      final isBiometricEnabled = await BiometricService2.isBiometricEnabled();
      await DebugLogger.instance.log('BiometricExtension', 'Biometric enabled: $isBiometricEnabled');

      if (isBiometricEnabled) {
        final biometricStatus = await checkBiometricStatus();
        await DebugLogger.instance.log('BiometricExtension', 'Biometric status: ${biometricStatus.name}');

        if (biometricStatus == BiometricStatus.availableButNotEnrolled) {
          await DebugLogger.instance.log('BiometricExtension', 'Prompting biometric enrollment');
          await promptBiometricEnrollment();
          return false;
        }

        if (biometricStatus == BiometricStatus.available) {
          await DebugLogger.instance.log('BiometricExtension', 'Attempting biometric authentication');

          final isAuthenticated = await authenticateWithBiometrics(
            localizedReason: 'Please authenticate with biometrics',
          );

          await DebugLogger.instance.log('BiometricExtension', 'Biometric authentication result: $isAuthenticated');

          if (isAuthenticated) {
            final savedPhone = await BiometricService2.getSavedPhone();
            final savedPassword = await BiometricService2.getSavedPassword();

            await DebugLogger.instance.log('BiometricExtension', 'Comparing credentials:');
            await DebugLogger.instance.log('BiometricExtension', '  Saved phone: ${savedPhone ?? 'null'}');
            await DebugLogger.instance.log('BiometricExtension', '  Input phone: $phone');

            // Normalize phone numbers for comparison
            final normalizedInputPhone = BiometricService2._normalizePhone(phone);
            final normalizedSavedPhone = savedPhone != null ? BiometricService2._normalizePhone(savedPhone) : null;

            await DebugLogger.instance.log(
              'BiometricExtension',
              '  Normalized saved phone: ${normalizedSavedPhone ?? 'null'}',
            );
            await DebugLogger.instance.log('BiometricExtension', '  Normalized input phone: $normalizedInputPhone');

            final phoneMatch = normalizedSavedPhone == normalizedInputPhone;
            final passwordMatch = savedPassword == password;
            final finalResult = phoneMatch && passwordMatch;

            await DebugLogger.instance.log('BiometricExtension', 'Credential comparison:');
            await DebugLogger.instance.log('BiometricExtension', '  Phone match: $phoneMatch');
            await DebugLogger.instance.log('BiometricExtension', '  Password match: $passwordMatch');
            await DebugLogger.instance.log('BiometricExtension', '  Final result: $finalResult');

            await DebugLogger.instance.logLoginAttempt(
              'biometric_with_comparison',
              finalResult,
              finalResult ? null : 'Credentials do not match',
            );

            return finalResult;
          } else {
            await DebugLogger.instance.logLoginAttempt('biometric', false, 'Biometric authentication failed');
          }
        }
      }

      await DebugLogger.instance.log('BiometricExtension', 'Authentication process completed with failure');
      return false;
    } catch (e, stackTrace) {
      await DebugLogger.instance.logError('BiometricExtension', 'Authentication process failed', e, stackTrace);
      return false;
    }
  }

  // Enhanced authentication with better error handling
  Future<AuthenticationResult> authenticateWithResult({required String phone, required String password}) async {
    await DebugLogger.instance.log('BiometricExtension', 'Starting authenticateWithResult');
    await DebugLogger.instance.log('BiometricExtension', 'Input phone: ${phone.isNotEmpty ? 'Provided' : 'Empty'}');
    await DebugLogger.instance.log(
      'BiometricExtension',
      'Input password: ${password.isNotEmpty ? 'Provided' : 'Empty'}',
    );

    try {
      final isBiometricEnabled = await BiometricService2.isBiometricEnabled();
      await DebugLogger.instance.log('BiometricExtension', 'Biometric enabled check: $isBiometricEnabled');

      if (!isBiometricEnabled) {
        final result = AuthenticationResult(
          success: false,
          message: 'Biometric authentication is not enabled',
          action: AuthenticationAction.none,
        );
        await DebugLogger.instance.log('BiometricExtension', 'Result: ${result.toString()}');
        return result;
      }

      // Check if we have saved credentials
      final hasSavedCredentials = await BiometricService2.hasSavedCredentials();
      await DebugLogger.instance.log('BiometricExtension', 'Has saved credentials: $hasSavedCredentials');

      if (!hasSavedCredentials) {
        final result = AuthenticationResult(
          success: false,
          message: 'No saved credentials found. Please login with password first.',
          action: AuthenticationAction.usePassword,
        );
        await DebugLogger.instance.log('BiometricExtension', 'Result: ${result.toString()}');
        return result;
      }

      final biometricStatus = await checkBiometricStatus();
      await DebugLogger.instance.log('BiometricExtension', 'Biometric status: ${biometricStatus.name}');

      switch (biometricStatus) {
        case BiometricStatus.notSupported:
          final result = AuthenticationResult(
            success: false,
            message: 'Biometric authentication is not supported on this device',
            action: AuthenticationAction.none,
          );
          await DebugLogger.instance.log('BiometricExtension', 'Result: ${result.toString()}');
          return result;

        case BiometricStatus.availableButNotEnrolled:
          final result = AuthenticationResult(
            success: false,
            message: 'Biometric authentication is available but not enrolled. Please enroll your biometrics.',
            action: AuthenticationAction.openSettings,
          );
          await DebugLogger.instance.log('BiometricExtension', 'Result: ${result.toString()}');
          return result;

        case BiometricStatus.available:
          await DebugLogger.instance.log('BiometricExtension', 'Attempting biometric authentication');

          final isAuthenticated = await authenticateWithBiometrics(
            localizedReason: 'Please authenticate with biometrics',
          );

          await DebugLogger.instance.log('BiometricExtension', 'Biometric authentication result: $isAuthenticated');

          if (isAuthenticated) {
            final savedPhone = await BiometricService2.getSavedPhone();
            final savedPassword = await BiometricService2.getSavedPassword();

            await DebugLogger.instance.log('BiometricExtension', 'Retrieved saved credentials:');
            await DebugLogger.instance.log('BiometricExtension', '  Saved phone: ${savedPhone ?? 'null'}');
            await DebugLogger.instance.log(
              'BiometricExtension',
              '  Saved password: ${savedPassword != null ? 'Found' : 'null'}',
            );

            if (savedPhone == null || savedPassword == null) {
              final result = AuthenticationResult(
                success: false,
                message: 'No saved credentials found. Please login with password first.',
                action: AuthenticationAction.usePassword,
              );
              await DebugLogger.instance.log('BiometricExtension', 'Result: ${result.toString()}');
              return result;
            }

            // For biometric authentication, we should use the saved credentials directly
            // instead of comparing with input credentials
            final result = AuthenticationResult(
              success: true,
              message: 'Authentication successful',
              action: AuthenticationAction.none,
              phone: savedPhone,
              password: savedPassword,
            );

            await DebugLogger.instance.log('BiometricExtension', 'Successful result: ${result.toString()}');
            await DebugLogger.instance.logLoginAttempt('biometric_with_result', true, null);

            return result;
          } else {
            final result = AuthenticationResult(
              success: false,
              message: 'Biometric authentication failed or cancelled',
              action: AuthenticationAction.retry,
            );
            await DebugLogger.instance.log('BiometricExtension', 'Result: ${result.toString()}');
            await DebugLogger.instance.logLoginAttempt(
              'biometric_with_result',
              false,
              'Authentication failed or cancelled',
            );
            return result;
          }

        case BiometricStatus.error:
          final result = AuthenticationResult(
            success: false,
            message: 'Error checking biometric status',
            action: AuthenticationAction.none,
          );
          await DebugLogger.instance.log('BiometricExtension', 'Result: ${result.toString()}');
          return result;
      }
    } catch (e, stackTrace) {
      final result = AuthenticationResult(
        success: false,
        message: 'Authentication error: ${e.toString()}',
        action: AuthenticationAction.none,
      );
      await DebugLogger.instance.logError('BiometricExtension', 'authenticateWithResult failed', e, stackTrace);
      await DebugLogger.instance.log('BiometricExtension', 'Error result: ${result.toString()}');
      return result;
    }
  }

  // FIXED: Device credential authentication with proper parameters
  Future<AuthenticationResult> authenticateWithDeviceCredentialsResult({required String localizedReason}) async {
    await DebugLogger.instance.log('BiometricExtension', 'Starting device credentials authentication');
    await DebugLogger.instance.log('BiometricExtension', 'Localized reason: $localizedReason');

    try {
      final isAuthenticated = await authenticateWithDeviceCredentials(localizedReason: localizedReason);
      await DebugLogger.instance.log(
        'BiometricExtension',
        'Device credentials authentication result: $isAuthenticated',
      );

      final phone = await BiometricService2.getSavedPhone();
      final password = await BiometricService2.getSavedPassword();

      await DebugLogger.instance.log('BiometricExtension', 'Retrieved saved credentials after device auth:');
      await DebugLogger.instance.log('BiometricExtension', '  Phone: ${phone ?? 'null'}');
      await DebugLogger.instance.log('BiometricExtension', '  Password: ${password != null ? 'Found' : 'null'}');

      if (isAuthenticated) {
        final result = AuthenticationResult(
          success: true,
          message: 'Device authentication successful but failed to save credentials.',
          action: AuthenticationAction.none,
          phone: phone,
          password: password,
        );

        await DebugLogger.instance.log('BiometricExtension', 'Device auth result: ${result.toString()}');
        await DebugLogger.instance.logLoginAttempt('device_credentials', true, null);

        return result;
      } else {
        final result = AuthenticationResult(
          success: false,
          message: 'Device authentication failed or cancelled',
          action: AuthenticationAction.retry,
        );

        await DebugLogger.instance.log('BiometricExtension', 'Device auth result: ${result.toString()}');
        await DebugLogger.instance.logLoginAttempt('device_credentials', false, 'Authentication failed or cancelled');

        return result;
      }
    } catch (e, stackTrace) {
      final result = AuthenticationResult(
        success: false,
        message: 'Device authentication error: ${e.toString()}',
        action: AuthenticationAction.none,
      );

      await DebugLogger.instance.logError(
        'BiometricExtension',
        'Device credentials authentication failed',
        e,
        stackTrace,
      );
      await DebugLogger.instance.log('BiometricExtension', 'Device auth error result: ${result.toString()}');

      return result;
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
    return 'AuthenticationResult(success: $success, message: $message, action: $action, phone: $phone, password: ${password != null ? '[HIDDEN]' : 'null'})';
  }
}

// Actions that can be taken based on authentication result
enum AuthenticationAction { none, openSettings, retry, usePassword, useDeviceCredentials }
