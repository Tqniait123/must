import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/services/biometric_service.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class BiometricEnrollmentBottomSheet extends StatelessWidget {
  final BiometricRecommendationType recommendedType;
  final VoidCallback? onCancel;
  final VoidCallback? onSetupCompleted;

  const BiometricEnrollmentBottomSheet({
    super.key,
    required this.recommendedType,
    this.onCancel,
    this.onSetupCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle indicator
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _getIconBackgroundColor(recommendedType),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(_getIconData(recommendedType), size: 40, color: _getIconColor(recommendedType)),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            _getTitle(recommendedType),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            _getDescription(recommendedType),
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Benefits list
          if (recommendedType != BiometricRecommendationType.pin) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LocaleKeys.benefits.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem(Icons.flash_on, LocaleKeys.faster_login.tr()),
                  const SizedBox(height: 8),
                  _buildBenefitItem(Icons.security, LocaleKeys.enhanced_security.tr()),
                  const SizedBox(height: 8),
                  _buildBenefitItem(Icons.touch_app, LocaleKeys.convenient_access.tr()),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Setup button
          ElevatedButton(
            onPressed: () => _handleSetupPressed(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getButtonColor(recommendedType),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getButtonIcon(recommendedType), size: 20),
                const SizedBox(width: 8),
                Text(
                  _getButtonText(recommendedType),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Cancel button - Safe dismissal
          TextButton(
            onPressed: () => _safeClose(context, onCancel),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              LocaleKeys.maybe_later.tr(),
              style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  // Safe close method that ensures proper dismissal
  void _safeClose(BuildContext context, VoidCallback? callback) {
    if (context.mounted) {
      try {
        Navigator.of(context, rootNavigator: true).pop();
        callback?.call();
      } catch (e) {
        // Fallback: try without rootNavigator
        try {
          Navigator.of(context).pop();
          callback?.call();
        } catch (e2) {
          // Last resort: just call the callback
          callback?.call();
        }
      }
    }
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.green[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700]))),
      ],
    );
  }

  String _getTitle(BiometricRecommendationType type) {
    switch (type) {
      case BiometricRecommendationType.faceId:
        return LocaleKeys.setup_face_id.tr();
      case BiometricRecommendationType.touchId:
        return LocaleKeys.setup_touch_id.tr();
      case BiometricRecommendationType.faceRecognition:
        return LocaleKeys.setup_face_recognition.tr();
      case BiometricRecommendationType.fingerprint:
        return LocaleKeys.setup_fingerprint.tr();
      case BiometricRecommendationType.pin:
        return LocaleKeys.setup_pin.tr();
      case BiometricRecommendationType.none:
        return LocaleKeys.setup_security.tr();
    }
  }

  String _getDescription(BiometricRecommendationType type) {
    switch (type) {
      case BiometricRecommendationType.faceId:
        return LocaleKeys.face_id_description.tr();
      case BiometricRecommendationType.touchId:
        return LocaleKeys.touch_id_description.tr();
      case BiometricRecommendationType.faceRecognition:
        return LocaleKeys.face_recognition_description.tr();
      case BiometricRecommendationType.fingerprint:
        return LocaleKeys.fingerprint_description.tr();
      case BiometricRecommendationType.pin:
        return LocaleKeys.pin_description.tr();
      case BiometricRecommendationType.none:
        return LocaleKeys.security_description.tr();
    }
  }

  String _getButtonText(BiometricRecommendationType type) {
    switch (type) {
      case BiometricRecommendationType.faceId:
        return LocaleKeys.setup_face_id_now.tr();
      case BiometricRecommendationType.touchId:
        return LocaleKeys.setup_touch_id_now.tr();
      case BiometricRecommendationType.faceRecognition:
        return LocaleKeys.setup_face_recognition_now.tr();
      case BiometricRecommendationType.fingerprint:
        return LocaleKeys.setup_fingerprint_now.tr();
      case BiometricRecommendationType.pin:
        return LocaleKeys.setup_pin_now.tr();
      case BiometricRecommendationType.none:
        return LocaleKeys.open_settings.tr();
    }
  }

  IconData _getIconData(BiometricRecommendationType type) {
    switch (type) {
      case BiometricRecommendationType.faceId:
      case BiometricRecommendationType.faceRecognition:
        return Icons.face_retouching_natural;
      case BiometricRecommendationType.touchId:
      case BiometricRecommendationType.fingerprint:
        return Icons.fingerprint;
      case BiometricRecommendationType.pin:
        return Icons.pin;
      case BiometricRecommendationType.none:
        return Icons.security;
    }
  }

  IconData _getButtonIcon(BiometricRecommendationType type) {
    switch (type) {
      case BiometricRecommendationType.faceId:
      case BiometricRecommendationType.faceRecognition:
        return Icons.face_retouching_natural;
      case BiometricRecommendationType.touchId:
      case BiometricRecommendationType.fingerprint:
        return Icons.fingerprint;
      case BiometricRecommendationType.pin:
        return Icons.pin;
      case BiometricRecommendationType.none:
        return Icons.settings;
    }
  }

  Color _getIconBackgroundColor(BiometricRecommendationType type) {
    switch (type) {
      case BiometricRecommendationType.faceId:
      case BiometricRecommendationType.faceRecognition:
        return Colors.blue[50]!;
      case BiometricRecommendationType.touchId:
      case BiometricRecommendationType.fingerprint:
        return Colors.orange[50]!;
      case BiometricRecommendationType.pin:
        return Colors.purple[50]!;
      case BiometricRecommendationType.none:
        return Colors.grey[50]!;
    }
  }

  Color _getIconColor(BiometricRecommendationType type) {
    switch (type) {
      case BiometricRecommendationType.faceId:
      case BiometricRecommendationType.faceRecognition:
        return Colors.blue[600]!;
      case BiometricRecommendationType.touchId:
      case BiometricRecommendationType.fingerprint:
        return Colors.orange[600]!;
      case BiometricRecommendationType.pin:
        return Colors.purple[600]!;
      case BiometricRecommendationType.none:
        return Colors.grey[600]!;
    }
  }

  Color _getButtonColor(BiometricRecommendationType type) {
    return AppColors.primary;
    // switch (type) {
    //   case BiometricRecommendationType.faceId:
    //   case BiometricRecommendationType.faceRecognition:
    //     return Colors.blue[600]!;
    //   case BiometricRecommendationType.touchId:
    //   case BiometricRecommendationType.fingerprint:
    //     return Colors.orange[600]!;
    //   case BiometricRecommendationType.pin:
    //     return Colors.purple[600]!;
    //   case BiometricRecommendationType.none:
    //     return Colors.grey[600]!;
    // }
  }

  // Ultra-safe setup pressed method
  void _handleSetupPressed(BuildContext context) async {
    if (!context.mounted) return;

    // Store the navigator and scaffold messenger before async operations
    final navigator = Navigator.of(context, rootNavigator: true);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      // Close the bottom sheet safely
      navigator.pop();

      // Wait for the bottom sheet to close
      await Future.delayed(const Duration(milliseconds: 150));

      // Open the appropriate settings page
      await BiometricService.openBiometricSettings(recommendedType);

      // Show success message if context is still mounted
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(_getSetupInstructions(recommendedType)),
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // Callback when setup is initiated
      onSetupCompleted?.call();
    } catch (e) {
      // Handle error opening settings
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.failed_to_open_settings.tr()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getSetupInstructions(BiometricRecommendationType type) {
    switch (type) {
      case BiometricRecommendationType.faceId:
        return LocaleKeys.face_id_setup_instructions.tr();
      case BiometricRecommendationType.touchId:
        return LocaleKeys.touch_id_setup_instructions.tr();
      case BiometricRecommendationType.faceRecognition:
        return LocaleKeys.face_recognition_setup_instructions.tr();
      case BiometricRecommendationType.fingerprint:
        return LocaleKeys.fingerprint_setup_instructions.tr();
      case BiometricRecommendationType.pin:
        return LocaleKeys.pin_setup_instructions.tr();
      case BiometricRecommendationType.none:
        return LocaleKeys.security_setup_instructions.tr();
    }
  }

  /// Static method to show the bottom sheet - with better error handling
  static Future<void> show({
    required BuildContext context,
    required BiometricRecommendationType recommendedType,
    VoidCallback? onCancel,
    VoidCallback? onSetupCompleted,
  }) async {
    if (!context.mounted) return;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: true,
        enableDrag: true,
        useRootNavigator: true, // This ensures it uses the root navigator
        builder:
            (context) => BiometricEnrollmentBottomSheet(
              recommendedType: recommendedType,
              onCancel: onCancel,
              onSetupCompleted: onSetupCompleted,
            ),
      );
    } catch (e) {
      // If showing the bottom sheet fails, just call the cancel callback
      onCancel?.call();
    }
  }
}
