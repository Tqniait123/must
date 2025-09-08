import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/preferences/shared_pref.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/features/auth/data/models/reset_password_params.dart';
import 'package:must_invest/features/auth/presentation/cubit/auth_cubit.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String phone;
  const ResetPasswordScreen({super.key, required this.phone});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          clipBehavior: Clip.none,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(),
                  Text(LocaleKeys.reset_password.tr(), style: context.titleLarge.copyWith()),
                  51.gap,
                ],
              ),
              46.gap,
              Text(LocaleKeys.new_password.tr(), style: context.bodyMedium.copyWith(color: AppColors.primary)),
              Text(
                LocaleKeys.enter_the_new_password.tr(),
                style: context.bodyMedium.regular.s14.copyWith(color: AppColors.grey60),
              ),
              // 48.gap,
              48.gap,
              Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
                      child: Column(
                        children: [
                          CustomTextFormField(
                            margin: 0,
                            controller: passwordController,
                            hint: LocaleKeys.password.tr(),
                            title: LocaleKeys.password.tr(),
                            isPassword: true,
                          ),
                          16.gap,
                          CustomTextFormField(
                            margin: 0,
                            controller: confirmPasswordController,
                            hint: LocaleKeys.password_confirmation.tr(),
                            title: LocaleKeys.password_confirmation.tr(),
                            isPassword: true,
                          ),
                          78.gap,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).paddingHorizontal(24),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocProvider(
            create: (BuildContext context) => AuthCubit(sl()),
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (BuildContext context, AuthState state) async {
                if (state is AuthError) {
                  showErrorToast(context, state.message);
                }
                if (state is ResetPasswordSuccess) {
                  // Update biometric password if the phone matches saved biometric phone
                  try {
                    await sl<MustInvestPreferences>().updateBiometricPasswordAfterReset(
                      widget.phone,
                      passwordController.text,
                    );
                  } catch (e) {
                    // Log error but don't block the flow
                    print('Error updating biometric password after reset: $e');
                  }

                  context.go(Routes.login);
                }
              },
              builder:
                  (BuildContext context, AuthState state) => CustomElevatedButton(
                    loading: state is ResetPasswordLoading,
                    title: LocaleKeys.reset_password.tr(),
                    onPressed: () {
                      if (passwordController.text != confirmPasswordController.text) {
                        showErrorToast(context, LocaleKeys.passwords_dont_match.tr());
                        return;
                      }

                      context.read<AuthCubit>().resetPassword(
                        ResetPasswordParams(
                          password: passwordController.text,
                          phone: widget.phone,
                          confirmPassword: confirmPasswordController.text,
                        ),
                      );
                    },
                  ).paddingAll(32),
            ),
          ),
        ],
      ),
    );
  }
}
