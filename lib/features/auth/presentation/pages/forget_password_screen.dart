import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/auth/presentation/pages/otp_screen.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  String _code = "+20";
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
                  Text(LocaleKeys.forgot_password.tr(), style: context.titleLarge.copyWith()),
                  51.gap,
                ],
              ),
              46.gap,
              Text(LocaleKeys.reset_password.tr(), style: context.bodyMedium.copyWith(color: AppColors.primary)),
              Text(
                LocaleKeys.password_reset_instructions.tr(),
                style: context.bodyMedium.regular.s14.copyWith(color: AppColors.grey60),
              ),
              48.gap,
              Form(
                key: _formKey,
                child: Hero(
                  tag: "form",
                  child: Material(
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
                          child: Column(
                            children: [
                              CustomPhoneFormField(
                                controller: phoneController,

                                hint: LocaleKeys.phone_number.tr(),
                                title: LocaleKeys.phone_number.tr(),
                                // keyboardType: TextInputType.phone,
                                isRequired: true,
                                includeCountryCodeInValue: true,
                                onChanged: (phone) {
                                  log('Phone number changed: $phone');
                                },
                                onChangedCountryCode: (code) {
                                  setState(() {
                                    _code = code;
                                    log('Country code changed: $code');
                                  });
                                },

                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return LocaleKeys.please_enter_phone_number.tr();
                                  }
                                  // Check if value contains only digits
                                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                    return LocaleKeys.please_enter_phone_number.tr();
                                  }
                                  return null;
                                },
                                selectedCode: '+20',
                              ),
                              48.gap,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
              listener: (BuildContext context, AuthState state) {
                if (state is ForgetPasswordError) {
                  showErrorToast(context, state.message);
                }
                if (state is ForgetPasswordSentOTP) {
                  context.push(
                    Routes.otpScreen,
                    extra: {'phone': "$_code${phoneController.text}", 'flow': OtpFlow.passwordReset},
                  );
                }
              },
              builder:
                  (BuildContext context, AuthState state) => CustomElevatedButton(
                    loading: state is ForgetPasswordLoading,
                    title: LocaleKeys.send.tr(),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        AuthCubit.get(context).forgetPassword("$_code${phoneController.text}");
                      }
                    },
                  ),
            ),
          ),
          20.gap,
        ],
      ).paddingHorizontal(32),
    );
  }
}
