// Enhanced BiometricService with enrollment flow and hierarchy - COMPLETE FIXED VERSION

import 'dart:developer';
import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:url_launcher/url_launcher.dart';

class BiometricService {
  // ==================== PUBLIC CAPABILITY CHECK METHODS ====================

  /// Check if device has Face ID capability (iOS) - PUBLIC VERSION
  static Future<bool> checkFaceIDCapability() async {
    return await _checkFaceIDCapability();
  }

  /// Check if device has Touch ID capability (iOS) - PUBLIC VERSION
  static Future<bool> checkTouchIDCapability() async {
    return await _checkTouchIDCapability();
  }

  /// Check if device has face recognition capability (Android) - PUBLIC VERSION
  static Future<bool> checkFaceRecognitionCapability() async {
    return await _checkFaceRecognitionCapability();
  }

  /// Check if device has fingerprint capability (Android) - PUBLIC VERSION
  static Future<bool> checkFingerprintCapability() async {
    return await _checkFingerprintCapability();
  }

  /// Check if device has PIN/passcode capability - PUBLIC VERSION
  static Future<bool> checkPinCapability() async {
    return await _checkPinCapability();
  }

  static final LocalAuthentication _localAuth = LocalAuthentication();
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  // Keys for secure storage
  static const String _phoneKey = 'saved_phone';
  static const String _passwordKey = 'saved_password';
  static const String _biometricEnabledKey = 'biometric_enabled';

  // Get comprehensive authentication capabilities for UI display
  static Future<List<AuthenticationMethodInfo>> getAuthenticationCapabilities() async {
    final List<AuthenticationMethodInfo> methods = [];

    try {
      if (Platform.isIOS) {
        // Check Face ID
        final hasFaceID = await checkFaceIDCapability();
        if (hasFaceID) {
          final availableBiometrics = await getAvailableBiometrics();
          final isEnrolled = availableBiometrics.contains(BiometricType.face);

          methods.add(
            AuthenticationMethodInfo(
              type: BiometricRecommendationType.faceId,
              isAvailable: true,
              isEnrolled: isEnrolled,
              displayName: LocaleKeys.face_id.tr(),
              description: isEnrolled ? LocaleKeys.face_id_enrolled.tr() : LocaleKeys.face_id_not_enrolled.tr(),
              icon: Icons.face,
            ),
          );
        }

        // Check Touch ID
        final hasTouchID = await checkTouchIDCapability();
        if (hasTouchID) {
          final availableBiometrics = await getAvailableBiometrics();
          final isEnrolled = availableBiometrics.contains(BiometricType.fingerprint);

          methods.add(
            AuthenticationMethodInfo(
              type: BiometricRecommendationType.touchId,
              isAvailable: true,
              isEnrolled: isEnrolled,
              displayName: LocaleKeys.touch_id.tr(),
              description: isEnrolled ? LocaleKeys.touch_id_enrolled.tr() : LocaleKeys.touch_id_not_enrolled.tr(),
              icon: Icons.fingerprint,
            ),
          );
        }
      } else {
        // Android - Check Face Recognition
        final hasFaceRecognition = await checkFaceRecognitionCapability();
        if (hasFaceRecognition) {
          final availableBiometrics = await getAvailableBiometrics();
          final isEnrolled =
              availableBiometrics.contains(BiometricType.face) || availableBiometrics.contains(BiometricType.strong);

          methods.add(
            AuthenticationMethodInfo(
              type: BiometricRecommendationType.faceRecognition,
              isAvailable: true,
              isEnrolled: isEnrolled,
              displayName: LocaleKeys.face_recognition.tr(),
              description:
                  isEnrolled
                      ? LocaleKeys.face_recognition_enrolled.tr()
                      : LocaleKeys.face_recognition_not_enrolled.tr(),
              icon: Icons.face,
            ),
          );
        }

        // Android - Check Fingerprint
        final hasFingerprint = await checkFingerprintCapability();
        if (hasFingerprint) {
          final availableBiometrics = await getAvailableBiometrics();
          final isEnrolled =
              availableBiometrics.contains(BiometricType.fingerprint) ||
              availableBiometrics.contains(BiometricType.strong);

          methods.add(
            AuthenticationMethodInfo(
              type: BiometricRecommendationType.fingerprint,
              isAvailable: true,
              isEnrolled: isEnrolled,
              displayName: LocaleKeys.fingerprint.tr(),
              description: isEnrolled ? LocaleKeys.fingerprint_enrolled.tr() : LocaleKeys.fingerprint_not_enrolled.tr(),
              icon: Icons.fingerprint,
            ),
          );
        }
      }

      // Check PIN/Passcode (available on both platforms)
      final hasPIN = await checkPinCapability();
      if (hasPIN) {
        methods.add(
          AuthenticationMethodInfo(
            type: BiometricRecommendationType.pin,
            isAvailable: true,
            isEnrolled: true, // PIN is always considered enrolled if available
            displayName: Platform.isIOS ? LocaleKeys.passcode.tr() : LocaleKeys.pin.tr(),
            description: LocaleKeys.pin_passcode_enrolled.tr(),
            icon: Icons.lock,
          ),
        );
      }
    } catch (e) {
      log('Error getting authentication capabilities: $e');
    }

    return methods;
  }

  // ==================== SETUP & AVAILABILITY ====================

  /// Check if biometric authentication is available
  static Future<bool> isAvailableBiometric() async {
    try {
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      if (!isDeviceSupported) {
        log(LocaleKeys.device_not_support_biometric.tr());
        return false;
      }

      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (!canCheckBiometrics) {
        log(LocaleKeys.cannot_check_biometrics.tr());
        return false;
      }

      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      log('${LocaleKeys.available_biometrics.tr()}: $availableBiometrics');

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

  /// Check biometric capability and enrollment status - FIXED VERSION
  static Future<BiometricCapabilityResult> checkBiometricCapability() async {
    log('Checking biometric capability...');
    try {
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      log('Device supported: $isDeviceSupported');

      if (!isDeviceSupported) {
        log('Device does not support biometrics');
        return BiometricCapabilityResult(
          hasCapability: false,
          isEnrolled: false,
          recommendedType: BiometricRecommendationType.none,
          errorMessage: LocaleKeys.device_not_support_biometric.tr(),
        );
      }

      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      log('Can check biometrics: $canCheckBiometrics');

      if (!canCheckBiometrics) {
        log('Cannot check biometrics on this device');
        return BiometricCapabilityResult(
          hasCapability: false,
          isEnrolled: false,
          recommendedType: BiometricRecommendationType.none,
          errorMessage: LocaleKeys.cannot_check_biometrics.tr(),
        );
      }

      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();
      log('Available biometrics: $availableBiometrics');

      // Check hierarchy: Face → Fingerprint → PIN
      BiometricRecommendationType recommendedType = BiometricRecommendationType.none;
      bool hasEnrolledBiometric = availableBiometrics.isNotEmpty;

      // Check if device has Face ID capability (iOS) or Face Recognition (Android)
      if (Platform.isIOS) {
        log('Checking iOS biometric capabilities...');
        try {
          final bool hasFaceID = await _checkFaceIDCapability();
          log('Has Face ID capability: $hasFaceID');

          if (hasFaceID) {
            recommendedType = BiometricRecommendationType.faceId;
            if (!availableBiometrics.contains(BiometricType.face)) {
              log('Face ID not enrolled');
              hasEnrolledBiometric = false;
            }
          } else {
            // Check for Touch ID
            if (availableBiometrics.contains(BiometricType.fingerprint) || await _checkTouchIDCapability()) {
              log('Touch ID capability detected');
              recommendedType = BiometricRecommendationType.touchId;
              if (!availableBiometrics.contains(BiometricType.fingerprint)) {
                log('Touch ID not enrolled');
                hasEnrolledBiometric = false;
              }
            }
          }
        } catch (e) {
          log('Error checking iOS biometric capability: $e');
        }
      } else {
        log('Checking Android biometric capabilities...');

        // First check if any biometric types are available
        if (availableBiometrics.isEmpty) {
          log('No biometric types available, checking hardware capability...');

          // Check for face recognition capability
          if (await _checkFaceRecognitionCapability()) {
            log('Face recognition capability detected');
            recommendedType = BiometricRecommendationType.faceRecognition;
            hasEnrolledBiometric = false; // We know it's not enrolled since list is empty
          } else if (await _checkFingerprintCapability()) {
            log('Fingerprint capability detected');
            recommendedType = BiometricRecommendationType.fingerprint;
            hasEnrolledBiometric = false; // We know it's not enrolled since list is empty
          }
        } else {
          log('Biometric types available: $availableBiometrics');

          // Android: Check enrolled biometrics in priority order
          if (availableBiometrics.contains(BiometricType.face) || availableBiometrics.contains(BiometricType.strong)) {
            log('Face recognition enrolled');
            recommendedType = BiometricRecommendationType.faceRecognition;
            hasEnrolledBiometric = true;
          } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
            log('Fingerprint enrolled');
            recommendedType = BiometricRecommendationType.fingerprint;
            hasEnrolledBiometric = true;
          } else {
            log('Unknown biometric type enrolled');
            recommendedType = BiometricRecommendationType.fingerprint; // Default to fingerprint
            hasEnrolledBiometric = true;
          }
        }
      }

      // If no biometric capability found, check if PIN/passcode is available
      if (recommendedType == BiometricRecommendationType.none) {
        log('No biometric capability found, checking PIN/passcode availability...');

        // Check if device has PIN/passcode authentication
        final bool hasPinCapability = await _checkPinCapability();
        log('Has PIN/passcode capability: $hasPinCapability');

        if (hasPinCapability) {
          recommendedType = BiometricRecommendationType.pin;
          hasEnrolledBiometric = true; // PIN is considered "enrolled" if it's set up
          log('PIN/passcode is available and enrolled');
        } else {
          log('No authentication methods available');
        }
      }

      log(
        'Final capability check result - hasCapability: ${recommendedType != BiometricRecommendationType.none}, isEnrolled: $hasEnrolledBiometric, recommendedType: $recommendedType',
      );

      return BiometricCapabilityResult(
        hasCapability: recommendedType != BiometricRecommendationType.none,
        isEnrolled: hasEnrolledBiometric,
        recommendedType: recommendedType,
        availableBiometrics: availableBiometrics,
      );
    } catch (e) {
      log('Error checking biometric capability: $e');
      return BiometricCapabilityResult(
        hasCapability: false,
        isEnrolled: false,
        recommendedType: BiometricRecommendationType.none,
        errorMessage: e.toString(),
      );
    }
  }

  /// Check if device has Face ID capability (iOS)
  static Future<bool> _checkFaceIDCapability() async {
    if (!Platform.isIOS) return false;

    try {
      // Try to get available biometrics and check device model
      final List<BiometricType> types = await _localAuth.getAvailableBiometrics();

      // If Face ID is already enrolled, device definitely has it
      if (types.contains(BiometricType.face)) {
        return true;
      }

      // For unenrolled Face ID, we need to check device capability
      // This is a simplified check - in production, you might want to check device model
      try {
        await _localAuth.authenticate(
          localizedReason: 'Check Face ID capability',
          options: const AuthenticationOptions(biometricOnly: true, stickyAuth: false, useErrorDialogs: false),
        );
        return true;
      } catch (e) {
        // Check if error indicates Face ID is available but not enrolled
        return e.toString().contains('NotEnrolled') || e.toString().contains('BiometricNotEnrolled');
      }
    } catch (e) {
      return false;
    }
  }

  /// Check if device has Touch ID capability (iOS)
  static Future<bool> _checkTouchIDCapability() async {
    if (!Platform.isIOS) return false;

    try {
      final List<BiometricType> types = await _localAuth.getAvailableBiometrics();
      return types.contains(BiometricType.fingerprint);
    } catch (e) {
      return false;
    }
  }

  /// Check if device has face recognition capability (Android) - FIXED VERSION
  static Future<bool> _checkFaceRecognitionCapability() async {
    if (!Platform.isAndroid) {
      log('Not Android platform, returning false');
      return false;
    }

    try {
      log('Checking face recognition capability...');
      final List<BiometricType> types = await _localAuth.getAvailableBiometrics();
      log('Available biometric types: $types');

      // Check if face recognition is available
      if (types.contains(BiometricType.face)) {
        log('Face recognition type found');
        return true;
      }

      // Check for strong biometric which might include face
      if (types.contains(BiometricType.strong)) {
        log('Strong biometric type found which may include face');
        return true;
      }

      // If no biometric types are available, device doesn't support face recognition
      if (types.isEmpty) {
        log('No biometric types available, face recognition not supported');
        return false;
      }

      // Additional check for face recognition capability with biometricOnly: true
      try {
        log('Attempting additional face recognition capability check with biometricOnly: true...');
        await _localAuth.authenticate(
          localizedReason: 'Check face recognition capability',
          options: const AuthenticationOptions(
            biometricOnly: true, // Only check biometrics
            stickyAuth: false,
            useErrorDialogs: false,
          ),
        );
        log('Biometric authentication successful, face recognition capability exists');
        return true;
      } catch (e) {
        log('Biometric authentication check error: $e');
        final errorString = e.toString();

        // Check if error indicates biometric is available but not enrolled
        final bool isNotEnrolled =
            errorString.contains('NotEnrolled') ||
            errorString.contains('BiometricNotEnrolled') ||
            errorString.contains('BiometricNotAvailable');

        // Check if error indicates no biometric hardware
        final bool isNotAvailable =
            errorString.contains('NotAvailable') ||
            errorString.contains('HardwareNotAvailable') ||
            errorString.contains('BiometricNotSupported');

        log('Face recognition available but not enrolled: $isNotEnrolled');
        log('Face recognition not available: $isNotAvailable');

        // Only return true if biometric is available but not enrolled
        // Return false if biometric hardware is not available
        return isNotEnrolled && !isNotAvailable;
      }
    } catch (e) {
      log('Error checking face recognition capability: $e');
      return false;
    }
  }

  /// Check if device has fingerprint capability (Android) - FIXED VERSION
  static Future<bool> _checkFingerprintCapability() async {
    if (!Platform.isAndroid) {
      log('Not Android platform, returning false');
      return false;
    }

    try {
      log('Checking fingerprint capability...');
      final List<BiometricType> types = await _localAuth.getAvailableBiometrics();
      log('Available biometric types: $types');

      // Check if fingerprint is available
      if (types.contains(BiometricType.fingerprint)) {
        log('Fingerprint type found');
        return true;
      }

      // Check for strong biometric which might include fingerprint
      if (types.contains(BiometricType.strong)) {
        log('Strong biometric type found which may include fingerprint');
        return true;
      }

      // If no biometric types are available, device doesn't support fingerprint
      if (types.isEmpty) {
        log('No biometric types available, fingerprint not supported');
        return false;
      }

      // Additional check for fingerprint capability with biometricOnly: true
      try {
        log('Attempting additional fingerprint capability check with biometricOnly: true...');
        await _localAuth.authenticate(
          localizedReason: 'Check fingerprint capability',
          options: const AuthenticationOptions(
            biometricOnly: true, // Only check biometrics
            stickyAuth: false,
            useErrorDialogs: false,
          ),
        );
        log('Biometric authentication successful, fingerprint capability exists');
        return true;
      } catch (e) {
        log('Biometric authentication check error: $e');
        final errorString = e.toString();

        // Check if error indicates biometric is available but not enrolled
        final bool isNotEnrolled =
            errorString.contains('NotEnrolled') ||
            errorString.contains('BiometricNotEnrolled') ||
            errorString.contains('BiometricNotAvailable');

        // Check if error indicates no biometric hardware
        final bool isNotAvailable =
            errorString.contains('NotAvailable') ||
            errorString.contains('HardwareNotAvailable') ||
            errorString.contains('BiometricNotSupported');

        log('Fingerprint available but not enrolled: $isNotEnrolled');
        log('Fingerprint not available: $isNotAvailable');

        // Only return true if biometric is available but not enrolled
        return isNotEnrolled && !isNotAvailable;
      }
    } catch (e) {
      log('Error checking fingerprint capability: $e');
      return false;
    }
  }

  /// Check if device has PIN/passcode capability - FIXED VERSION
  static Future<bool> _checkPinCapability() async {
    try {
      log('Checking PIN/passcode capability...');

      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final List<BiometricType> availableBiometrics = await _localAuth.getAvailableBiometrics();

      log(
        'Device supported: $isDeviceSupported, Can check biometrics: $canCheckBiometrics, Available biometrics: $availableBiometrics',
      );

      // If device supports local auth, can check biometrics, but no biometric types available
      // This usually means PIN/passcode is set up
      if (isDeviceSupported && canCheckBiometrics && availableBiometrics.isEmpty) {
        log('Device has authentication capability but no biometrics - PIN/passcode likely available');
        return true;
      }

      // If biometrics are available, PIN is also likely available (as backup)
      if (availableBiometrics.isNotEmpty) {
        log('Biometrics available, PIN/passcode also likely available as backup');
        return true;
      }

      // Additional check for devices that might have PIN but report differently
      if (isDeviceSupported && canCheckBiometrics) {
        log('Device supports authentication, assuming PIN/passcode is available');
        return true;
      }

      log('No authentication methods detected');
      return false;
    } catch (e) {
      log('Error checking PIN/passcode capability: $e');
      return false;
    }
  }

  /// Check if strong biometrics (face/fingerprint) are available
  static Future<bool> isStrongBiometricAvailable() async {
    final List<BiometricType> availableBiometrics = await getAvailableBiometrics();

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

    if (availableBiometrics.contains(BiometricType.face)) {
      return Platform.isIOS ? LocaleKeys.face_id.tr() : LocaleKeys.face_recognition.tr();
    }

    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return Platform.isIOS ? LocaleKeys.touch_id.tr() : LocaleKeys.fingerprint.tr();
    }

    if (availableBiometrics.contains(BiometricType.strong)) {
      return Platform.isIOS ? LocaleKeys.biometric_authentication.tr() : LocaleKeys.face_recognition.tr();
    }

    if (availableBiometrics.contains(BiometricType.weak)) {
      return LocaleKeys.biometric_authentication.tr();
    }

    return LocaleKeys.biometric_authentication.tr();
  }

  /// Get display name for recommended biometric type
  static String getRecommendedBiometricDisplayName(BiometricRecommendationType type) {
    switch (type) {
      case BiometricRecommendationType.faceId:
        return LocaleKeys.face_id.tr();
      case BiometricRecommendationType.touchId:
        return LocaleKeys.touch_id.tr();
      case BiometricRecommendationType.faceRecognition:
        return LocaleKeys.face_recognition.tr();
      case BiometricRecommendationType.fingerprint:
        return LocaleKeys.fingerprint.tr();
      case BiometricRecommendationType.pin:
        return LocaleKeys.pin.tr();
      case BiometricRecommendationType.none:
        return LocaleKeys.biometric_authentication.tr();
    }
  }

  /// Complete setup process for biometric authentication
  static Future<BiometricSetupResult> setupBiometric() async {
    log('Setting up biometric authentication...');
    try {
      final capability = await checkBiometricCapability();
      log(
        'Biometric capability check result: hasCapability=${capability.hasCapability}, isEnrolled=${capability.isEnrolled}, recommendedType=${capability.recommendedType}',
      );

      final isEnabled = await isBiometricEnabled();
      log('Biometric is enabled: $isEnabled');

      final shouldShowQuickLogin = isEnabled && capability.isEnrolled;
      final shouldShowEnrollmentSheet = capability.hasCapability && !capability.isEnrolled;

      log(
        'Setup flags: shouldShowQuickLogin=$shouldShowQuickLogin, shouldShowEnrollmentSheet=$shouldShowEnrollmentSheet',
      );

      final primaryBiometricType =
          capability.isEnrolled
              ? await getBiometricDisplayName()
              : getRecommendedBiometricDisplayName(capability.recommendedType);

      log('Primary biometric type: $primaryBiometricType');

      return BiometricSetupResult(
        isAvailable: capability.isEnrolled,
        hasCapability: capability.hasCapability,
        isEnabled: isEnabled,
        shouldShowQuickLogin: shouldShowQuickLogin,
        shouldShowEnrollmentSheet: shouldShowEnrollmentSheet,
        primaryBiometricType: primaryBiometricType,
        recommendedType: capability.recommendedType,
        availableBiometrics: capability.availableBiometrics ?? [],
      );
    } catch (e) {
      log('Biometric setup failed with error: $e');
      return BiometricSetupResult(
        isAvailable: false,
        hasCapability: false,
        isEnabled: false,
        shouldShowQuickLogin: false,
        shouldShowEnrollmentSheet: false,
        primaryBiometricType: LocaleKeys.biometric.tr(),
        recommendedType: BiometricRecommendationType.none,
        availableBiometrics: [],
        error: '${LocaleKeys.setup_failed.tr()}: ${e.toString()}',
      );
    }
  }

  /// Open device settings for biometric enrollment
  static Future<void> openBiometricSettings(BiometricRecommendationType type) async {
    try {
      if (Platform.isIOS) {
        await _openIOSBiometricSettings(type);
      } else {
        await _openAndroidBiometricSettings(type);
      }
    } catch (e) {
      log('Failed to open biometric settings: $e');
      // Fallback to general settings
      await _openGeneralSettings();
    }
  }

  /// Open iOS biometric settings
  static Future<void> _openIOSBiometricSettings(BiometricRecommendationType type) async {
    String settingsUrl;

    switch (type) {
      case BiometricRecommendationType.faceId:
        settingsUrl = 'App-Prefs:FACEID_PASSCODE';
        break;
      case BiometricRecommendationType.touchId:
        settingsUrl = 'App-Prefs:TOUCHID_PASSCODE';
        break;
      default:
        settingsUrl = 'App-Prefs:PASSCODE';
    }

    try {
      await _launchUrl(settingsUrl);
    } catch (e) {
      // Fallback to general settings if specific setting fails
      await _launchUrl('App-Prefs:root');
    }
  }

  /// Open Android biometric settings
  static Future<void> _openAndroidBiometricSettings(BiometricRecommendationType type) async {
    // For Android, we need to use a different approach
    try {
      await _launchAndroidIntent(type);
    } catch (e) {
      log('Failed to launch Android intent: $e');
      // Fallback to security settings
      await _openGeneralSettings();
    }
  }

  /// Launch Android intent using a proper method channel
  static Future<void> _launchAndroidIntent(BiometricRecommendationType type) async {
    const platform = MethodChannel('com.example.must_invest/settings');

    String action;
    switch (type) {
      case BiometricRecommendationType.faceRecognition:
        action = 'android.settings.FACE_SETTINGS';
        break;
      case BiometricRecommendationType.fingerprint:
        action = 'android.settings.FINGERPRINT_SETTINGS';
        break;
      default:
        action = 'android.settings.SECURITY_SETTINGS';
    }

    try {
      await platform.invokeMethod('openSettings', {'action': action});
    } catch (e) {
      log('Failed to launch intent: $e');
      rethrow;
    }
  }

  /// Open general settings as fallback
  static Future<void> _openGeneralSettings() async {
    try {
      if (Platform.isIOS) {
        await _launchUrl('App-Prefs:root');
      } else {
        // For Android, use url_launcher with settings scheme
        final uri = Uri.parse('package:com.android.settings');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          // Alternative approach
          await _launchAndroidIntent(BiometricRecommendationType.none);
        }
      }
    } catch (e) {
      log('Failed to open general settings: $e');
    }
  }

  /// Launch URL (iOS) - Fixed implementation
  static Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Cannot launch URL: $url');
      }
    } catch (e) {
      log('Failed to launch URL: $e');
      rethrow;
    }
  }

  // ==================== AUTHENTICATION ====================

  /// Perform biometric authentication
  static Future<BiometricLoginResult> performBiometricLogin({BiometricRecommendationType? method}) async {
    try {
      final capability = await checkBiometricCapability();

      if (!capability.hasCapability) {
        return BiometricLoginResult(
          isSuccess: false,
          errorMessage: LocaleKeys.biometric_not_available_on_device_generic.tr(),
          errorType: BiometricErrorType.notAvailable,
        );
      }

      if (!capability.isEnrolled) {
        return BiometricLoginResult(
          isSuccess: false,
          errorMessage: LocaleKeys.biometric_not_setup_device.tr(),
          errorType: BiometricErrorType.notEnrolled,
          shouldShowEnrollmentSheet: true,
          recommendedType: capability.recommendedType,
        );
      }

      final authResult = await _authenticateWithBiometric();

      if (!authResult.isSuccess) {
        return BiometricLoginResult.fromAuthResult(authResult);
      }

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
      final String localizedReason = LocaleKeys.authenticate_to_login.tr();

      log('${LocaleKeys.biometric_auth_started.tr()}: $biometricType');

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
        options: const AuthenticationOptions(biometricOnly: false, stickyAuth: true, useErrorDialogs: true),
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
      final capability = await checkBiometricCapability();

      if (!capability.hasCapability) {
        return BiometricEnableResult(
          isSuccess: false,
          shouldShowSetupDialog: false,
          errorMessage: LocaleKeys.biometric_not_available_on_device_generic.tr(),
        );
      }

      if (!capability.isEnrolled) {
        return BiometricEnableResult(
          isSuccess: false,
          shouldShowSetupDialog: false,
          shouldShowEnrollmentSheet: true,
          recommendedType: capability.recommendedType,
          errorMessage: LocaleKeys.biometric_not_setup_device.tr(),
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
  final bool hasCapability;
  final bool isEnabled;
  final bool shouldShowQuickLogin;
  final bool shouldShowEnrollmentSheet;
  final String primaryBiometricType;
  final BiometricRecommendationType recommendedType;
  final List<BiometricType> availableBiometrics;
  final String? error;

  BiometricSetupResult({
    required this.isAvailable,
    required this.hasCapability,
    required this.isEnabled,
    required this.shouldShowQuickLogin,
    required this.shouldShowEnrollmentSheet,
    required this.primaryBiometricType,
    required this.recommendedType,
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
  final bool shouldShowEnrollmentSheet;
  final BiometricRecommendationType? recommendedType;

  BiometricLoginResult({
    required this.isSuccess,
    this.phone,
    this.password,
    this.errorMessage,
    this.errorType,
    this.shouldShowEnrollmentSheet = false,
    this.recommendedType,
  });

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
  final bool shouldShowEnrollmentSheet;
  final String? successMessage;
  final String? errorMessage;
  final String? pendingPhone;
  final String? pendingPassword;
  final BiometricRecommendationType? recommendedType;

  BiometricEnableResult({
    required this.isSuccess,
    required this.shouldShowSetupDialog,
    this.shouldShowEnrollmentSheet = false,
    this.successMessage,
    this.errorMessage,
    this.pendingPhone,
    this.pendingPassword,
    this.recommendedType,
  });
}

class BiometricAuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final BiometricErrorType? errorType;

  BiometricAuthResult({required this.isSuccess, this.errorMessage, this.errorType});
}

class BiometricCapabilityResult {
  final bool hasCapability;
  final bool isEnrolled;
  final BiometricRecommendationType recommendedType;
  final List<BiometricType>? availableBiometrics;
  final String? errorMessage;

  BiometricCapabilityResult({
    required this.hasCapability,
    required this.isEnrolled,
    required this.recommendedType,
    this.availableBiometrics,
    this.errorMessage,
  });
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

enum BiometricRecommendationType { faceId, touchId, faceRecognition, fingerprint, pin, none }

// ==================== HELPER CLASSES ====================

// Extension class for AuthenticationMethodInfo to support merged biometric types
extension AuthenticationMethodInfoExtension on AuthenticationMethodInfo {
  List<BiometricRecommendationType>? get availableBiometricTypes => null;
}

// You'll need to add this field to your AuthenticationMethodInfo class:
class AuthenticationMethodInfo {
  final BiometricRecommendationType type;
  final String displayName;
  final String description;
  final IconData icon;
  final bool isAvailable;
  final bool isEnrolled;
  final List<BiometricRecommendationType>? availableBiometricTypes;
  final AuthenticationMethodStatus status;

  AuthenticationMethodInfo({
    required this.type,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.isAvailable,
    required this.isEnrolled,
    this.availableBiometricTypes,
  }) : status =
           !isAvailable
               ? AuthenticationMethodStatus.notAvailable
               : !isEnrolled
               ? AuthenticationMethodStatus.availableNotEnrolled
               : AuthenticationMethodStatus.availableAndEnrolled;

  bool get canAuthenticate => isAvailable && isEnrolled;
  bool get needsSetup => isAvailable && !isEnrolled;
}

// // Extension to show the improved bottom sheet
// extension ImprovedAuthenticationSelectionExtension on BuildContext {
//   Future<BiometricRecommendationType?> showImprovedAuthenticationSelectionSheet() async {
//     BiometricRecommendationType? selectedMethod;

//     await showModalBottomSheet<void>(
//       context: this,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       isDismissible: true,
//       enableDrag: true,
//       builder:
//           (context) => ImprovedAuthenticationSelectionSheet(
//             onAuthMethodSelected: (type) {
//               selectedMethod = type;
//               Navigator.of(context).pop();
//             },
//             onCancel: () {
//               Navigator.of(context).pop();
//             },
//           ),
//     );

//     return selectedMethod;
//   }
// }

/// Status of an authentication method
enum AuthenticationMethodStatus { availableAndEnrolled, availableNotEnrolled, notAvailable }

// /// Get status of an authentication method
// extension AuthenticationMethodInfoExtension on AuthenticationMethodInfo {
//   AuthenticationMethodStatus get status {
//     if (!isAvailable) return AuthenticationMethodStatus.notAvailable;
//     if (!isEnrolled) return AuthenticationMethodStatus.availableNotEnrolled;
//     return AuthenticationMethodStatus.availableAndEnrolled;
//   }

//   bool get canAuthenticate => isAvailable && isEnrolled;
//   bool get needsSetup => isAvailable && !isEnrolled;
// }
