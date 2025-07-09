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
import 'package:must_invest/core/utils/dialogs/auth_bottom_sheet.dart';
import 'package:must_invest/core/utils/dialogs/bitometci_bottom_sheet.dart';
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

  // UI State variables
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isCheckingBiometrics = false;
  String _biometricType = 'Face ID';
  BiometricRecommendationType _recommendedType = BiometricRecommendationType.none;
  bool _hasCapability = false;

  // Pending biometric setup data
  String? _pendingPhone;
  String? _pendingPassword;

  @override
  void initState() {
    super.initState();
    _initializeBiometric();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==================== BIOMETRIC INITIALIZATION ====================

  Future<void> _initializeBiometric() async {
    setState(() {
      _isCheckingBiometrics = true;
    });

    final setupResult = await BiometricService.setupBiometric();

    setState(() {
      _isBiometricAvailable = setupResult.isAvailable;
      _isBiometricEnabled = setupResult.isEnabled;
      _biometricType = setupResult.primaryBiometricType;
      _recommendedType = setupResult.recommendedType;
      _hasCapability = setupResult.hasCapability;
      _isCheckingBiometrics = false;
    });

    if (setupResult.error != null) {
      _showError(setupResult.error!);
    }

    // Show quick login if should
    if (setupResult.shouldShowQuickLogin) {
      await _showQuickLoginBottomSheet();
    }
  }

  // ==================== AUTHENTICATION SELECTION ====================

  Future<void> _showAuthenticationSelectionSheet() async {
    final selectedMethod = await context.showImprovedAuthenticationSelectionSheet();

    if (selectedMethod != null) {
      await _handleSelectedAuthMethod(selectedMethod);
    }
  }

  Future<void> _handleSelectedAuthMethod(BiometricRecommendationType method) async {
    try {
      log('Handling selected auth method: $method');

      // Show loading
      setState(() {
        _isCheckingBiometrics = true;
      });
      log('Started biometric check');

      // Perform authentication with the selected method
      final result = await _authenticateWithMethod(method);
      log('Authentication result: ${result.isSuccess}');

      setState(() {
        _isCheckingBiometrics = false;
      });

      if (result.isSuccess) {
        log('Authentication successful with method: $method');
        // Authentication successful
        _showSuccessMessage(method);

        log(
          'Auto-filling credentials - Phone: ${result.phone}, Password: ${result.password?.replaceAll(RegExp(r'.'), '*')}',
        );
        // Auto-fill form and login
        setState(() {
          _phoneController.text = result.phone!;
          _passwordController.text = result.password!;
        });

        if (mounted) {
          log('Initiating login with biometric credentials');
          AuthCubit.get(
            context,
          ).login(LoginParams(phone: result.phone!, password: result.password!, isRemembered: true));
        }
      } else {
        log('Authentication failed - Error type: ${result.errorType}');
        // Authentication failed
        if (BiometricService.shouldShowError(result.errorType)) {
          _showError(result.errorMessage ?? 'Authentication failed');
        }
      }
    } catch (e) {
      log('Error during authentication: ${e.toString()}');
      setState(() {
        _isCheckingBiometrics = false;
      });
      _showError('Error: ${e.toString()}');
    }
  }

  Future<BiometricLoginResult> _authenticateWithMethod(BiometricRecommendationType method) async {
    // For PIN/Passcode, you might want to show a different flow
    if (method == BiometricRecommendationType.pin) {
      return await _authenticateWithPinPasscode();
    }

    // For biometric methods, use the existing biometric authentication
    return await BiometricService.performBiometricLogin();
  }

  Future<BiometricLoginResult> _authenticateWithPinPasscode() async {
    // You can implement a custom PIN input screen or use the system authentication
    try {
      // For now, we'll use the system authentication which includes PIN as fallback
      return await BiometricService.performBiometricLogin();
    } catch (e) {
      return BiometricLoginResult(isSuccess: false, errorMessage: e.toString(), errorType: BiometricErrorType.unknown);
    }
  }

  void _showSuccessMessage(BiometricRecommendationType method) {
    final methodName = BiometricService.getRecommendedBiometricDisplayName(method);
    _showSuccess(LocaleKeys.authentication_successful_with_method.tr().replaceAll('{method}', methodName));
  }

  // ==================== BIOMETRIC LOGIN ====================

  Future<void> _performBiometricLogin() async {
    final loginResult = await BiometricService.performBiometricLogin();

    if (loginResult.isSuccess) {
      // Auto-fill form and login
      setState(() {
        _phoneController.text = loginResult.phone!;
        _passwordController.text = loginResult.password!;
      });

      if (mounted) {
        AuthCubit.get(
          context,
        ).login(LoginParams(phone: loginResult.phone!, password: loginResult.password!, isRemembered: true));
      }
    } else {
      // Handle different error scenarios
      if (loginResult.shouldShowEnrollmentSheet && loginResult.recommendedType != null) {
        await _showBiometricEnrollmentBottomSheet(loginResult.recommendedType!);
      } else if (BiometricService.shouldShowError(loginResult.errorType)) {
        _showError(BiometricService.getErrorMessageForUI(loginResult.errorType));
      }
    }
  }

  // ==================== REGULAR LOGIN ====================

  void _performRegularLogin() {
    if (_formKey.currentState!.validate()) {
      AuthCubit.get(context).login(
        LoginParams(phone: _phoneController.text, password: _passwordController.text, isRemembered: isRemembered),
      );
    }
  }

  // ==================== POST-LOGIN BIOMETRIC SETUP ====================

  Future<void> _handlePostLoginBiometricSetup() async {
    if (!isRemembered) return;

    final enableResult = await BiometricService.enableBiometricAfterLogin(
      phone: _phoneController.text,
      password: _passwordController.text,
      shouldAskUser: !_isBiometricEnabled,
    );

    if (enableResult.isSuccess) {
      if (enableResult.successMessage != null) {
        _showSuccess(enableResult.successMessage!);
      }
      setState(() {
        _isBiometricEnabled = true;
      });
    } else if (enableResult.shouldShowSetupDialog) {
      // Store pending credentials and show setup dialog
      _pendingPhone = enableResult.pendingPhone;
      _pendingPassword = enableResult.pendingPassword;
      await _showBiometricSetupBottomSheet();
    } else if (enableResult.shouldShowEnrollmentSheet && enableResult.recommendedType != null) {
      await _showBiometricEnrollmentBottomSheet(enableResult.recommendedType!);
    } else if (enableResult.errorMessage != null) {
      _showError(enableResult.errorMessage!);
    }
  }

  bool _isNullOrEmpty(String? value) => value == null || value.isEmpty;

  Future<void> _confirmBiometricSetup() async {
    if (_isNullOrEmpty(_pendingPhone) || _isNullOrEmpty(_pendingPassword)) return;

    final result = await BiometricService.confirmEnableBiometric(phone: _pendingPhone!, password: _pendingPassword!);

    if (result.isSuccess) {
      setState(() {
        _isBiometricEnabled = true;
      });
      if (result.successMessage != null) {
        _showSuccess(result.successMessage!);
      }
    } else if (result.errorMessage != null) {
      _showError(result.errorMessage!);
    }

    // Clear pending data
    _pendingPhone = null;
    _pendingPassword = null;
  }

  // ==================== BOTTOM SHEETS ====================

  Future<void> _showQuickLoginBottomSheet() async {
    final shouldUseBiometric = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _QuickLoginBottomSheet(
            biometricType: _biometricType,
            onUseBiometric: () => Navigator.of(context).pop(true),
            onUsePassword: () => Navigator.of(context).pop(false),
          ),
    );

    if (shouldUseBiometric == true) {
      await _performBiometricLogin();
    }
  }

  Future<void> _showBiometricSetupBottomSheet() async {
    final shouldEnable = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _BiometricSetupBottomSheet(
            biometricType: _biometricType,
            onEnable: () => Navigator.of(context).pop(true),
            onSkip: () => Navigator.of(context).pop(false),
          ),
    );

    if (shouldEnable == true) {
      await _confirmBiometricSetup();
    }
  }

  Future<void> _showBiometricEnrollmentBottomSheet(BiometricRecommendationType recommendedType) async {
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => BiometricEnrollmentBottomSheet(
            recommendedType: recommendedType,
            onCancel: () {},
            onSetupCompleted: () async {
              // Re-initialize biometric after setup is completed
              await _initializeBiometric();
            },
          ),
    );
  }

  // ==================== UI HELPERS ====================

  void _showError(String message) {
    if (mounted && message.isNotEmpty) {
      showErrorToast(context, message);
      log('${LocaleKeys.biometric_error.tr()}: $message');
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      showErrorToast(context, message); // Assuming you have a success toast method
      log('${LocaleKeys.biometric_success.tr()}: $message');
    }
  }

  void _handleBiometricButtonPress() {
    if (_isCheckingBiometrics) {
      log('Biometric check in progress, ignoring button press');
      return;
    }

    // Show the authentication selection sheet
    _showAuthenticationSelectionSheet();
  }

  // Get the appropriate icon for the biometric button
  String _getBiometricIcon() {
    switch (_recommendedType) {
      case BiometricRecommendationType.faceId:
      case BiometricRecommendationType.faceRecognition:
        return AppIcons.faceIdIc;
      case BiometricRecommendationType.touchId:
      case BiometricRecommendationType.fingerprint:
        return AppIcons.faceIdIc;
      case BiometricRecommendationType.pin:
        return AppIcons.faceIdIc;
      default:
        return AppIcons.faceIdIc;
    }
  }

  // Get the appropriate button color based on state
  Color? _getBiometricButtonColor() {
    if (!_hasCapability) {
      return AppColors.grey60.withOpacity(0.3); // Disabled state
    }

    if (_isBiometricAvailable && _isBiometricEnabled) {
      return AppColors.primary.withOpacity(0.8); // Enabled and ready
    }

    if (_hasCapability && !_isBiometricAvailable) {
      return AppColors.secondary.withOpacity(0.6); // Has capability but needs setup
    }

    return null; // Default color
  }

  // Get the button title based on state
  String _getBiometricButtonTitle() {
    if (!_hasCapability) {
      return LocaleKeys.authentication_options.tr();
    }

    if (_isBiometricAvailable && _isBiometricEnabled) {
      return _biometricType;
    }

    if (_hasCapability && !_isBiometricAvailable) {
      return LocaleKeys.setup_authentication.tr();
    }

    return LocaleKeys.authentication_options.tr();
  }

  // ==================== BUILD METHOD ====================

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
          _buildLoginForm(),
          40.gap,
          _buildActionButtons(),
          71.gap,
          _buildDivider(),
          20.gap,
          const SocialMediaButtons(),
          20.gap,
          SignUpButton(isLogin: true, onTap: () => context.push(Routes.register)),
          30.gap,
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
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
                    return LocaleKeys.please_enter_phone_number.tr();
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
                    return LocaleKeys.please_enter_password.tr();
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
                    onTap: () => context.push(Routes.forgetPassword),
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
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) async {
              if (state is AuthSuccess) {
                // Handle post-login biometric setup
                await _handlePostLoginBiometricSetup();
                UserCubit.get(context).setCurrentUser(state.user);
                context.go(Routes.homeUser);
              } else if (state is AuthError) {
                showErrorToast(context, state.message);
              }
            },
            builder:
                (context, state) => CustomElevatedButton(
                  heroTag: 'button',
                  loading: state is AuthLoading,
                  title: LocaleKeys.login.tr(),
                  onPressed: _performRegularLogin,
                ),
          ),
        ),
        20.gap,
        Expanded(
          child: CustomElevatedButton(
            heroTag: 'biometric',
            icon: _getBiometricIcon(),
            title: _getBiometricButtonTitle(),
            loading: _isCheckingBiometrics,
            onPressed: _handleBiometricButtonPress,
            backgroundColor: _getBiometricButtonColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.grey60.withOpacity(0.3), thickness: 1)),
        16.gap,
        Text(LocaleKeys.or_login_with.tr(), style: context.bodyMedium.s12.regular),
        16.gap,
        Expanded(child: Divider(color: AppColors.grey60.withOpacity(0.3), thickness: 1)),
      ],
    );
  }
}

// ==================== BOTTOM SHEET WIDGETS ====================

class _QuickLoginBottomSheet extends StatelessWidget {
  final String biometricType;
  final VoidCallback onUseBiometric;
  final VoidCallback onUsePassword;

  const _QuickLoginBottomSheet({
    required this.biometricType,
    required this.onUseBiometric,
    required this.onUsePassword,
  });

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
                child: Icon(
                  biometricType == 'Face ID' || biometricType == 'Face Recognition'
                      ? Icons.face
                      : biometricType == 'PIN'
                      ? Icons.pin
                      : Icons.fingerprint,
                  size: 40,
                  color: AppColors.primary,
                ),
              ),
              24.gap,
              // Title
              Text(LocaleKeys.quick_login.tr(), style: context.headlineSmall.bold.copyWith(color: AppColors.black)),
              12.gap,
              // Description
              Text(
                LocaleKeys.quick_login_description.tr().replaceAll('{biometricType}', biometricType),
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
                      title: LocaleKeys.use_password.tr(),
                      isBordered: true,
                      backgroundColor: Colors.transparent,
                      textColor: AppColors.primary,
                      onPressed: onUsePassword,
                    ),
                  ),
                  16.gap,
                  Expanded(
                    child: CustomElevatedButton(
                      heroTag: 'use_biometric',
                      title: LocaleKeys.use_biometric.tr().replaceAll('{biometricType}', biometricType),
                      icon:
                          biometricType == 'Face ID' || biometricType == 'Face Recognition'
                              ? AppIcons.faceIdIc
                              : biometricType == 'PIN'
                              ? AppIcons.faceIdIc
                              : AppIcons.faceIdIc,
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

class _BiometricSetupBottomSheet extends StatelessWidget {
  final String biometricType;
  final VoidCallback onEnable;
  final VoidCallback onSkip;

  const _BiometricSetupBottomSheet({required this.biometricType, required this.onEnable, required this.onSkip});

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
                LocaleKeys.enable_biometric_authentication.tr().replaceAll('{biometricType}', biometricType),
                style: context.headlineSmall.bold.copyWith(color: AppColors.black),
                textAlign: TextAlign.center,
              ),
              12.gap,
              // Description
              Text(
                LocaleKeys.enable_biometric_description.tr().replaceAll('{biometricType}', biometricType),
                style: context.bodyMedium.regular.copyWith(color: AppColors.grey),
                textAlign: TextAlign.center,
              ),
              24.gap,
              // Features list
              _FeatureItem(
                icon: Icons.speed,
                title: LocaleKeys.quick_access.tr(),
                description: LocaleKeys.quick_access_description.tr().replaceAll(
                  '{action}',
                  biometricType == 'Face ID' || biometricType == 'Face Recognition'
                      ? LocaleKeys.face_action.tr()
                      : biometricType == 'PIN'
                      ? LocaleKeys.pin.tr()
                      : LocaleKeys.touch_action.tr(),
                ),
              ),
              12.gap,
              _FeatureItem(
                icon: Icons.shield,
                title: LocaleKeys.enhanced_security.tr(),
                description: LocaleKeys.enhanced_security_description.tr(),
              ),
              12.gap,
              _FeatureItem(
                icon: Icons.lock,
                title: LocaleKeys.privacy_protected.tr(),
                description: LocaleKeys.privacy_protected_description.tr(),
              ),
              32.gap,
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: CustomElevatedButton(
                      heroTag: 'skip_biometric',
                      title: LocaleKeys.skip_for_now.tr(),
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
                      title: LocaleKeys.enable.tr(),
                      icon:
                          biometricType == 'Face ID' || biometricType == 'Face Recognition'
                              ? AppIcons.faceIdIc
                              : biometricType == 'PIN'
                              ? AppIcons.faceIdIc
                              : AppIcons.faceIdIc,
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
