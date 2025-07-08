import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/services/biometric_service.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/widgets/adaptive_layout/custom_layout.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/core/utils/widgets/logo_widget.dart';
import 'package:must_invest/features/auth/data/models/login_params.dart';
import 'package:must_invest/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/user_cubit/user_cubit.dart';
import 'package:must_invest/features/auth/presentation/widgets/sign_up_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isRemembered = true;

  // Biometric authentication variables
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isCheckingBiometrics = false;

  @override
  void initState() {
    super.initState();
    _setupBiometricAuth();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Check and setup biometric authentication
  Future<void> _setupBiometricAuth() async {
    setState(() {
      _isCheckingBiometrics = true;
    });

    try {
      final isAvailable = await BiometricService.isAvailable();
      final isEnabled = await BiometricService.isBiometricEnabled();

      setState(() {
        _isBiometricAvailable = isAvailable;
        _isBiometricEnabled = isEnabled;
        _isCheckingBiometrics = false;
      });

      // Show biometric prompt if enabled and available
      if (isEnabled && isAvailable) {
        await _showBiometricLoginBottomSheet();
      }
    } catch (e) {
      setState(() {
        _isCheckingBiometrics = false;
      });
    }
  }

  // Show biometric login prompt bottom sheet
  Future<void> _showBiometricLoginBottomSheet() async {
    final shouldUseBiometric = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _QuickLoginBottomSheet(
            onUseBiometric: () => Navigator.of(context).pop(true),
            onUsePassword: () => Navigator.of(context).pop(false),
          ),
    );

    if (shouldUseBiometric == true) {
      await _authenticateWithBiometrics();
    }
  }

  // Authenticate with biometrics
  Future<void> _authenticateWithBiometrics() async {
    try {
      final result = await BiometricService.authenticate(
        reason: 'Please authenticate to login to your account',
        biometricOnly: true,
      );

      if (result.isSuccess) {
        // Get saved credentials
        final credentials = await BiometricService.getSavedCredentials();
        final phone = credentials['phone'];
        final password = credentials['password'];

        if (phone != null && password != null) {
          // Auto-fill form
          setState(() {
            _phoneController.text = phone;
            _passwordController.text = password;
          });

          // Perform login
          if (mounted) {
            AuthCubit.get(context).login(LoginParams(phone: phone, password: password, isRemembered: true));
          }
        } else {
          _showBiometricError('No saved credentials found. Please login manually first.');
        }
      } else {
        _handleBiometricError(result);
      }
    } catch (e) {
      _showBiometricError('Biometric authentication failed: ${e.toString()}');
    }
  }

  // Handle biometric authentication errors
  void _handleBiometricError(BiometricAuthResult result) {
    switch (result.errorType) {
      case BiometricErrorType.userCancel:
        // User cancelled, don't show error
        break;
      case BiometricErrorType.notAvailable:
        _showBiometricError('Biometric authentication is not available on this device');
        break;
      case BiometricErrorType.notEnrolled:
        _showBiometricError('Please set up biometric authentication in your device settings');
        break;
      case BiometricErrorType.lockedOut:
        _showBiometricError('Biometric authentication is temporarily locked. Please try again later.');
        break;
      case BiometricErrorType.timeout:
        _showBiometricError('Authentication timed out. Please try again.');
        break;
      default:
        _showBiometricError(result.errorMessage ?? 'Authentication failed');
    }
  }

  // Show biometric error
  void _showBiometricError(String message) {
    if (mounted) {
      showErrorToast(context, message);
      log(message);
    }
  }

  // Save credentials after successful login
  Future<void> _saveCredentialsAfterLogin() async {
    if (isRemembered && _isBiometricAvailable) {
      // Ask user if they want to enable biometric authentication
      if (!_isBiometricEnabled) {
        await _showBiometricSetupBottomSheet();
      } else {
        // Update existing credentials
        await BiometricService.saveCredentials(phone: _phoneController.text, password: _passwordController.text);
      }
    }
  }

  // Show biometric setup bottom sheet
  Future<void> _showBiometricSetupBottomSheet() async {
    final shouldEnable = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _BiometricSetupBottomSheet(
            onEnable: () => Navigator.of(context).pop(true),
            onSkip: () => Navigator.of(context).pop(false),
          ),
    );

    if (shouldEnable == true) {
      final success = await BiometricService.saveCredentials(
        phone: _phoneController.text,
        password: _passwordController.text,
      );

      if (success) {
        setState(() {
          _isBiometricEnabled = true;
        });
        if (mounted) {
          showErrorToast(context, 'Biometric authentication enabled successfully!');
        }
      } else {
        if (mounted) {
          showErrorToast(context, 'Failed to enable biometric authentication');
        }
      }
    }
  }

  // Regular login method
  void _performLogin() {
    if (_formKey.currentState!.validate()) {
      AuthCubit.get(context).login(
        LoginParams(phone: _phoneController.text, password: _passwordController.text, isRemembered: isRemembered),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomLayout(
        withPadding: true,
        patternOffset: const Offset(-150, -200),
        spacerHeight: 35,
        topPadding: 70,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        upperContent: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: LogoWidget(type: LogoType.svg)),
              27.gap,
              Text(
                LocaleKeys.login_to_your_account.tr(),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        children: [
          30.gap,
          Form(
            key: _formKey,
            child: Hero(
              tag: "form",
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    CustomTextFormField(
                      controller: _phoneController,
                      margin: 0,
                      hint: LocaleKeys.phone_number.tr(),
                      title: LocaleKeys.phone_number.tr(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                    ),
                    16.gap,
                    CustomTextFormField(
                      margin: 0,
                      controller: _passwordController,
                      hint: LocaleKeys.password.tr(),
                      title: LocaleKeys.password.tr(),
                      obscureText: true,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    19.gap,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                activeColor: AppColors.secondary,
                                checkColor: AppColors.white,
                                value: isRemembered,
                                onChanged: (value) {
                                  setState(() {
                                    isRemembered = value ?? false;
                                  });
                                },
                              ),
                            ),
                            8.gap,
                            Text(LocaleKeys.remember_me.tr(), style: context.bodyMedium.s12.regular),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            context.push(Routes.forgetPassword);
                          },
                          child: Text(
                            LocaleKeys.forgot_password.tr(),
                            style: context.bodyMedium.s12.bold.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          40.gap,
          Row(
            children: [
              Expanded(
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: (BuildContext context, AuthState state) async {
                    if (state is AuthSuccess) {
                      // Save credentials if login is successful
                      await _saveCredentialsAfterLogin();

                      UserCubit.get(context).setCurrentUser(state.user);
                      context.go(Routes.homeUser);
                    } else {
                      // context.go(Routes.homeParkingMan);
                    }
                    if (state is AuthError) {
                      showErrorToast(context, state.message);
                    }
                  },
                  builder:
                      (BuildContext context, AuthState state) => CustomElevatedButton(
                        heroTag: 'button',
                        loading: state is AuthLoading,
                        title: LocaleKeys.login.tr(),
                        onPressed: _performLogin,
                      ),
                ),
              ),
              20.gap,
              Expanded(
                child: CustomElevatedButton(
                  heroTag: 'faceId',
                  icon: AppIcons.faceIdIc,
                  title: LocaleKeys.face_id.tr(),
                  loading: _isCheckingBiometrics,
                  onPressed:
                      (_isBiometricAvailable && !_isCheckingBiometrics)
                          ? _authenticateWithBiometrics
                          : () {
                            if (_isCheckingBiometrics) {
                              return; // Don't show error while checking
                            }
                            _showBiometricError('Biometric authentication is not available on this device');
                          },
                  // Change button appearance based on biometric availability
                  backgroundColor:
                      _isBiometricAvailable
                          ? (_isBiometricEnabled
                              ? AppColors.primary.withOpacity(0.8) // Highlight if enabled
                              : null) // Use default color if available but not enabled
                          : AppColors.grey60.withOpacity(0.3), // Disabled if not available
                ),
              ),
            ],
          ),
          71.gap,
          // or login with divider
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.grey60.withOpacity(0.3), thickness: 1)),
              16.gap,
              Text(LocaleKeys.or_login_with.tr(), style: context.bodyMedium.s12.regular),
              16.gap,
              Expanded(child: Divider(color: AppColors.grey60.withOpacity(0.3), thickness: 1)),
            ],
          ),
          20.gap,
          const SocialMediaButtons(),
          20.gap,
          SignUpButton(
            isLogin: true,
            onTap: () {
              context.push(Routes.register);
            },
          ),
          30.gap, // Add extra bottom padding
        ],
      ),
    );
  }
}

// Quick Login Bottom Sheet Widget
class _QuickLoginBottomSheet extends StatelessWidget {
  final VoidCallback onUseBiometric;
  final VoidCallback onUsePassword;

  const _QuickLoginBottomSheet({required this.onUseBiometric, required this.onUsePassword});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey60.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              24.gap,
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.fingerprint, size: 40, color: AppColors.primary),
              ),
              24.gap,
              // Title
              Text('Quick Login', style: context.headlineSmall.bold.copyWith(color: AppColors.black)),
              12.gap,
              // Description
              Text(
                'Welcome back! Use your biometric authentication to login quickly and securely.',
                style: context.bodyMedium.regular.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              32.gap,
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                      heroTag: 'use_password',
                      title: 'Use Password',
                      isBordered: true,
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.primary,
                      onPressed: onUsePassword,
                    ),
                  ),
                  16.gap,
                  Expanded(
                    child: CustomElevatedButton(
                      heroTag: 'use_face_id',
                      title: 'Use Face ID',
                      icon: AppIcons.faceIdIc,
                      backgroundColor: AppColors.primary,
                      textColor: Colors.white,
                      onPressed: onUseBiometric,
                    ),
                  ),
                ],
              ),
              16.gap,
            ],
          ),
        ),
      ),
    );
  }
}

// Biometric Setup Bottom Sheet Widget
class _BiometricSetupBottomSheet extends StatelessWidget {
  final VoidCallback onEnable;
  final VoidCallback onSkip;

  const _BiometricSetupBottomSheet({required this.onEnable, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey60.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              24.gap,
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(color: AppColors.secondary.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(Icons.security, size: 40, color: AppColors.secondary),
              ),
              24.gap,
              // Title
              Text(
                'Enable Biometric Authentication',
                style: context.headlineSmall.bold.copyWith(color: AppColors.black),
                textAlign: TextAlign.center,
              ),
              12.gap,
              // Description
              Text(
                'Secure your account and login faster with Face ID or fingerprint authentication.',
                style: context.bodyMedium.regular.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              24.gap,
              // Features list
              _FeatureItem(
                icon: Icons.speed,
                title: 'Quick Access',
                description: 'Login in seconds with just a look or touch',
              ),
              12.gap,
              _FeatureItem(
                icon: Icons.shield,
                title: 'Enhanced Security',
                description: 'Your biometric data stays on your device',
              ),
              12.gap,
              _FeatureItem(
                icon: Icons.lock,
                title: 'Privacy Protected',
                description: 'No passwords to remember or type',
              ),
              32.gap,
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                      heroTag: 'skip_biometric',
                      title: 'Skip for Now',
                      isBordered: true,
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.grey,
                      onPressed: onSkip,
                    ),
                  ),
                  16.gap,
                  Expanded(
                    child: CustomElevatedButton(
                      heroTag: 'enable_biometric',
                      title: 'Enable',
                      icon: AppIcons.faceIdIc,
                      backgroundColor: AppColors.secondary,
                      textColor: Colors.white,
                      onPressed: onEnable,
                    ),
                  ),
                ],
              ),
              16.gap,
            ],
          ),
        ),
      ),
    );
  }
}

// Feature Item Widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        16.gap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.bodyMedium.bold.copyWith(color: AppColors.black)),
              2.gap,
              Text(description, style: context.bodySmall.regular.copyWith(color: AppColors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

class SocialMediaButtons extends StatelessWidget {
  const SocialMediaButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: CustomElevatedButton(
            heroTag: 'google',
            height: 48,
            icon: AppIcons.google,
            iconColor: null,
            textColor: AppColors.black,
            isBordered: true,
            backgroundColor: AppColors.white,
            title: LocaleKeys.google.tr(),
            onPressed: () {},
          ),
        ),
        20.gap,
        Expanded(
          child: CustomElevatedButton(
            heroTag: 'facebook',
            height: 48,
            isBordered: true,
            icon: AppIcons.facebook,
            iconColor: null,
            textColor: AppColors.black,
            backgroundColor: AppColors.white,
            title: LocaleKeys.facebook.tr(),
            onPressed: () {},
          ),
        ),
      ],
    );
  }
}
