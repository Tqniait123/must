import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/services/biometric_service_2.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/languages_bottom_sheet.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_phone_field.dart';
import 'package:must_invest/features/profile/presentation/widgets/profile_item_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isBiometricEnabled = false;
  bool _isLoading = false;
  bool _isBiometricSupported = false;
  final BiometricService2 _biometricService = BiometricService2();

  @override
  void initState() {
    super.initState();
    _initializeBiometricState();
  }

  Future<void> _initializeBiometricState() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Check if device supports biometrics
      final isSupported = await _biometricService.isDeviceHasFingerprint;
      final canCheckBiometrics = await _biometricService.isDeviceHasBiometrics;

      // Check if biometric authentication is currently enabled
      final isEnabled = await BiometricService2.isBiometricEnabled();

      setState(() {
        _isBiometricSupported = isSupported && canCheckBiometrics;
        _isBiometricEnabled = isEnabled && _isBiometricSupported;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isBiometricSupported = false;
        _isBiometricEnabled = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleBiometricToggle(bool value) async {
    if (!_isBiometricSupported) {
      _showBiometricNotSupportedBottomSheet();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (value) {
        // User wants to enable biometric authentication
        await _enableBiometricAuthentication();
      } else {
        // User wants to disable biometric authentication
        await _disableBiometricAuthentication();
      }
    } catch (e) {
      _showErrorBottomSheet(LocaleKeys.biometric_update_failed.tr());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _enableBiometricAuthentication() async {
    try {
      // Check biometric status
      final biometricStatus = await _biometricService.checkBiometricStatus();

      switch (biometricStatus) {
        case BiometricStatus.notSupported:
          _showBiometricNotSupportedBottomSheet();
          return;

        case BiometricStatus.availableButNotEnrolled:
          final shouldOpenSettings = await _showBiometricEnrollmentBottomSheet();
          if (shouldOpenSettings) {
            final opened = await _biometricService.openBiometricSettings();
            if (!opened) {
              _showErrorBottomSheet(LocaleKeys.biometric_settings_open_failed.tr());
            }
          }
          return;

        case BiometricStatus.available:
          // Check if we have saved credentials
          final hasSavedCredentials = await BiometricService2.hasSavedCredentials();

          if (!hasSavedCredentials) {
            // Need to authenticate first to save credentials
            await _authenticateAndSaveCredentials();
          } else {
            // Test biometric authentication with saved credentials
            final authResult = await _biometricService.authenticateWithResult(
              phone: '', // Not needed since we're using saved credentials
              password: '', // Not needed since we're using saved credentials
            );

            if (authResult.success) {
              setState(() {
                _isBiometricEnabled = true;
              });
              _showSuccessBottomSheet(LocaleKeys.biometric_enabled_success.tr());
            } else {
              _showErrorBottomSheet(authResult.message);
            }
          }
          break;

        case BiometricStatus.error:
          _showErrorBottomSheet(LocaleKeys.biometric_status_check_error.tr());
          break;
      }
    } catch (e) {
      _showErrorBottomSheet(LocaleKeys.biometric_enable_failed.tr());
    }
  }

  Future<void> _authenticateAndSaveCredentials() async {
    // Show bottom sheet to get user credentials
    final credentials = await _showCredentialsBottomSheet();

    if (credentials != null) {
      // Test device credential authentication first
      final authResult = await _biometricService.authenticateWithDeviceCredentialsResult(
        localizedReason: LocaleKeys.authenticate_to_enable_biometric.tr(),
      );

      if (authResult.success) {
        // Save the provided credentials
        final saveSuccess = await BiometricService2.saveCredentials(
          phone: credentials['phone']!,
          password: credentials['password']!,
        );

        if (saveSuccess) {
          setState(() {
            _isBiometricEnabled = true;
          });
          _showSuccessBottomSheet(LocaleKeys.biometric_enabled_success.tr());
        } else {
          _showErrorBottomSheet(LocaleKeys.credentials_save_failed.tr());
        }
      } else {
        _showErrorBottomSheet(authResult.message);
      }
    }
  }

  Future<void> _disableBiometricAuthentication() async {
    try {
      final success = await BiometricService2.clearCredentials();

      if (success) {
        setState(() {
          _isBiometricEnabled = false;
        });
        _showSuccessBottomSheet(LocaleKeys.biometric_disabled_success.tr());
      } else {
        _showErrorBottomSheet(LocaleKeys.biometric_disable_failed.tr());
      }
    } catch (e) {
      _showErrorBottomSheet(LocaleKeys.biometric_disable_error.tr());
    }
  }

  // Bottom Sheet Methods
  void _showBiometricNotSupportedBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _buildBottomSheetContainer(
            title: LocaleKeys.biometric_not_supported.tr(),
            content: LocaleKeys.biometric_not_supported_message.tr(),
            primaryButtonText: LocaleKeys.ok.tr(),
            onPrimaryPressed: () => Navigator.pop(context),
          ),
    );
  }

  Future<bool> _showBiometricEnrollmentBottomSheet() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _buildBottomSheetContainer(
            title: LocaleKeys.biometric_setup_required.tr(),
            content: LocaleKeys.biometric_setup_required_message.tr(),
            primaryButtonText: LocaleKeys.open_settings.tr(),
            secondaryButtonText: LocaleKeys.cancel.tr(),
            onPrimaryPressed: () => Navigator.pop(context, true),
            onSecondaryPressed: () => Navigator.pop(context, false),
          ),
    );
    return result ?? false;
  }

  Future<Map<String, String>?> _showCredentialsBottomSheet() async {
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String code = '+20';

    return await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                  ),
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar
                        Container(
                          width: 40,
                          height: 4,
                          margin: EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                        ),
                        24.gap,
                        Text(
                          LocaleKeys.enter_credentials.tr(),
                          style: context.titleLarge.copyWith(color: AppColors.black, fontWeight: FontWeight.bold),
                        ),
                        16.gap,
                        Text(
                          LocaleKeys.enter_credentials_message.tr(),
                          style: context.bodyMedium.copyWith(color: AppColors.grey),
                          textAlign: TextAlign.center,
                        ).paddingHorizontal(24),
                        32.gap,
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              CustomPhoneFormField(
                                includeCountryCodeInValue: true,
                                controller: phoneController,
                                margin: 0,
                                hint: LocaleKeys.phone_number.tr(),
                                title: LocaleKeys.phone_number.tr(),
                                onChanged: (phone) {
                                  // Handle phone change
                                },
                                onChangedCountryCode: (code, countryCode) {
                                  setModalState(() {
                                    code = code;
                                  });
                                },
                                // validator: (value) {
                                //   if (value == null || value.isEmpty) {
                                //     return LocaleKeys.please_enter_phone_number.tr();
                                //   }
                                //   if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                //     return LocaleKeys.please_enter_phone_number.tr();
                                //   }
                                //   return null;
                                // },
                                selectedCode: code,
                              ),
                              16.gap,
                              CustomTextFormField(
                                margin: 0,
                                controller: passwordController,
                                hint: LocaleKeys.password.tr(),
                                title: LocaleKeys.password.tr(),
                                obscureText: true,
                                isPassword: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return LocaleKeys.please_enter_password.tr();
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ).paddingHorizontal(24),
                        32.gap,
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                                  ),
                                ),
                                child: Text(
                                  LocaleKeys.cancel.tr(),
                                  style: context.titleMedium.copyWith(color: AppColors.grey),
                                ),
                              ),
                            ),
                            16.gap,
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  if (formKey.currentState!.validate()) {
                                    Navigator.pop(context, {
                                      'phone':
                                          "$code${phoneController.text}", // Use the selected country code andphoneController.text",
                                      'password': passwordController.text,
                                    });
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  LocaleKeys.save.tr(),
                                  style: context.titleMedium.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ).paddingHorizontal(24),
                        24.gap,
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  void _showSuccessBottomSheet(String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _buildBottomSheetContainer(
            title: LocaleKeys.success.tr(),
            content: message,
            primaryButtonText: LocaleKeys.ok.tr(),
            onPrimaryPressed: () => Navigator.pop(context),
            isSuccess: true,
          ),
    );
  }

  void _showErrorBottomSheet(String message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _buildBottomSheetContainer(
            title: LocaleKeys.error.tr(),
            content: message,
            primaryButtonText: LocaleKeys.ok.tr(),
            onPrimaryPressed: () => Navigator.pop(context),
            isError: true,
          ),
    );
  }

  Widget _buildBottomSheetContainer({
    required String title,
    required String content,
    required String primaryButtonText,
    String? secondaryButtonText,
    required VoidCallback onPrimaryPressed,
    VoidCallback? onSecondaryPressed,
    bool isSuccess = false,
    bool isError = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(top: 12),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            24.gap,
            if (isSuccess || isError) ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSuccess ? Icons.check : Icons.error,
                  color: isSuccess ? Colors.green : Colors.red,
                  size: 32,
                ),
              ),
              16.gap,
            ],
            Text(title, style: context.titleLarge.copyWith(color: AppColors.black, fontWeight: FontWeight.bold)),
            16.gap,
            Text(
              content,
              style: context.bodyMedium.copyWith(color: AppColors.grey),
              textAlign: TextAlign.center,
            ).paddingHorizontal(24),
            32.gap,
            if (secondaryButtonText != null) ...[
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: onSecondaryPressed,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: AppColors.grey.withOpacity(0.3)),
                        ),
                      ),
                      child: Text(secondaryButtonText, style: context.titleMedium.copyWith(color: AppColors.grey)),
                    ),
                  ),
                  16.gap,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPrimaryPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(primaryButtonText, style: context.titleMedium.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ).paddingHorizontal(24),
            ] else ...[
              ElevatedButton(
                onPressed: onPrimaryPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  minimumSize: Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(primaryButtonText, style: context.titleMedium.copyWith(color: Colors.white)),
              ).paddingHorizontal(24),
            ],
            24.gap,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomBackButton(),
                Text(LocaleKeys.settings.tr(), style: context.titleLarge.copyWith(color: AppColors.black)),
                51.gap,
              ],
            ),
            40.gap,
            Expanded(
              child: ListView(
                children: [
                  ProfileItemWidget(
                    title: LocaleKeys.language.tr(),
                    iconPath: AppIcons.languageIc,
                    onPressed: () {
                      showLanguageBottomSheet(context);
                    },
                  ),
                  ProfileItemWidget(
                    title: LocaleKeys.face_id.tr(),
                    iconPath: AppIcons.faceIdIc,
                    trailing:
                        _isLoading
                            ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Switch.adaptive(
                              value: _isBiometricEnabled && _isBiometricSupported,
                              onChanged: _isBiometricSupported ? _handleBiometricToggle : null,
                            ),
                  ),
                ],
              ),
            ),
          ],
        ).paddingHorizontal(16),
      ),
    );
  }
}
