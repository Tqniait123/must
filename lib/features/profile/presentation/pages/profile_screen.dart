import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/flipped_for_lcale.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/services/biometric_service_2.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/adaptive_layout/custom_layout.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/features/profile/presentation/widgets/profile_item_widget.dart';
// Import your biometric service
// import 'package:must_invest/path/to/biometric_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      _showBiometricNotSupportedDialog();
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
      _showErrorDialog('Failed to update biometric settings: ${e.toString()}');
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
          _showBiometricNotSupportedDialog();
          return;

        case BiometricStatus.availableButNotEnrolled:
          final shouldOpenSettings = await _showBiometricEnrollmentDialog();
          if (shouldOpenSettings) {
            final opened = await _biometricService.openBiometricSettings();
            if (!opened) {
              _showErrorDialog(
                'Failed to open biometric settings. Please enable biometrics manually in device settings.',
              );
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
              _showSuccessDialog('Biometric authentication enabled successfully!');
            } else {
              _showErrorDialog(authResult.message);
            }
          }
          break;

        case BiometricStatus.error:
          _showErrorDialog('Error checking biometric status. Please try again.');
          break;
      }
    } catch (e) {
      _showErrorDialog('Failed to enable biometric authentication: ${e.toString()}');
    }
  }

  Future<void> _authenticateAndSaveCredentials() async {
    // Show dialog to get user credentials
    final credentials = await _showCredentialsDialog();

    if (credentials != null) {
      // Test device credential authentication first
      final authResult = await _biometricService.authenticateWithDeviceCredentialsResult(
        localizedReason: 'Please authenticate to enable biometric login',
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
          _showSuccessDialog('Biometric authentication enabled successfully!');
        } else {
          _showErrorDialog('Failed to save credentials securely.');
        }
      } else {
        _showErrorDialog(authResult.message);
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
        _showSuccessDialog('Biometric authentication disabled successfully!');
      } else {
        _showErrorDialog('Failed to disable biometric authentication.');
      }
    } catch (e) {
      _showErrorDialog('Error disabling biometric authentication: ${e.toString()}');
    }
  }

  // Dialog Methods
  void _showBiometricNotSupportedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Biometric Not Supported'),
            content: Text('Your device does not support biometric authentication or it is not available.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
          ),
    );
  }

  Future<bool> _showBiometricEnrollmentDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Biometric Setup Required'),
            content: Text(
              'Biometric authentication is available but not set up. Would you like to open settings to enroll your biometrics?',
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Open Settings')),
            ],
          ),
    );
    return result ?? false;
  }

  Future<Map<String, String>?> _showCredentialsDialog() async {
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();

    return await showDialog<Map<String, String>>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Enter Your Credentials'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Please enter your login credentials to enable biometric authentication.'),
                SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              TextButton(
                onPressed: () {
                  if (phoneController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                    Navigator.pop(context, {'phone': phoneController.text, 'password': passwordController.text});
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Success'),
            content: Text(message),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
          ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Error'),
            content: Text(message),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomLayout(
        withPadding: true,
        patternOffset: const Offset(-150, -400),
        spacerHeight: 35,
        topPadding: 70,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),

        upperContent: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomBackButton(),
                Text(LocaleKeys.profile.tr(), style: context.titleLarge.copyWith(color: AppColors.white)),
                NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
              ],
            ),
            30.gap,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (context.user.image != null && context.user.image!.isNotEmpty)
                        CircleAvatar(radius: 43, backgroundImage: NetworkImage(context.user.image ?? '')),
                      24.gap,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              LocaleKeys.welcome.tr(),
                              style: context.bodyMedium.copyWith(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            8.gap,
                            Text(
                              context.user.name,
                              style: context.titleLarge.copyWith(
                                color: AppColors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                CustomIconButton(
                  color: Color(0xff6468AC),
                  iconAsset: AppIcons.logout,
                  onPressed: () {
                    context.go(Routes.login);
                  },
                ).flippedForLocale(context),
              ],
            ),
          ],
        ),

        children: [
          30.gap,
          ProfileItemWidget(
            title: LocaleKeys.profile.tr(),
            iconPath: AppIcons.profileIc,
            onPressed: () {
              context.push(Routes.editProfile);
            },
          ),
          ProfileItemWidget(
            title: LocaleKeys.my_cars.tr(),
            iconPath: AppIcons.outlinedCarIc,
            onPressed: () {
              context.push(Routes.myCars);
            },
          ),
          // Biometric/Face ID Toggle with full logic
          // ProfileItemWidget(
          //   title: LocaleKeys.face_id.tr(),
          //   iconPath: AppIcons.faceIdIc,
          //   trailing:
          //       _isLoading
          //           ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
          //           : Switch.adaptive(
          //             value: _isBiometricEnabled && _isBiometricSupported,
          //             onChanged: _isBiometricSupported ? _handleBiometricToggle : null,
          //           ),
          // ),
          ProfileItemWidget(
            title: LocaleKeys.my_cards.tr(),
            iconPath: AppIcons.cardIc,
            onPressed: () {
              context.push(Routes.myCards);
            },
          ),

          ProfileItemWidget(
            title: LocaleKeys.terms_and_conditions.tr(),
            iconPath: AppIcons.termsIc,
            onPressed: () {
              context.push(Routes.termsAndConditions);
            },
          ),
          ProfileItemWidget(
            title: LocaleKeys.privacy_policy.tr(),
            iconPath: AppIcons.privacyPolicyIc,
            onPressed: () {
              context.push(Routes.privacyPolicy);
            },
          ),
          ProfileItemWidget(
            title: LocaleKeys.history.tr(),
            iconPath: AppIcons.historyIc,
            onPressed: () {
              context.push(Routes.history);
            },
          ),
          ProfileItemWidget(
            title: LocaleKeys.faq.tr(),
            iconPath: AppIcons.faqIc,
            onPressed: () {
              context.push(Routes.faq);
            },
          ),
          ProfileItemWidget(
            title: LocaleKeys.about_us.tr(),
            iconPath: AppIcons.aboutUsIc,
            onPressed: () {
              context.push(Routes.aboutUs);
            },
          ),
          ProfileItemWidget(
            title: LocaleKeys.settings.tr(),
            iconPath: AppIcons.settingsIc,
            onPressed: () {
              context.push(Routes.settings);
            },
          ),
          20.gap,
          CustomElevatedButton(
            icon: AppIcons.supportIc,
            onPressed: () {
              context.push(Routes.contactUs);
            },
            title: LocaleKeys.how_can_we_help_you.tr(),
          ),
        ],
      ),
    );
  }
}
