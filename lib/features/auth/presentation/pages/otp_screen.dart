import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/features/auth/data/models/verify_params.dart';
import 'package:must_invest/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/user_cubit/user_cubit.dart';
import 'package:must_invest/features/auth/presentation/widgets/custom_pin_field.dart';
import 'package:must_invest/features/auth/presentation/widgets/resend_otp_widget.dart';

enum OtpFlow { passwordReset, registration, login }

class OtpScreen extends StatefulWidget {
  final String phone;
  final OtpFlow flow;
  const OtpScreen({super.key, required this.phone, required this.flow});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  String otp = "";
  final int pinLength = 6;

  void _onKeyPressed(String value) {
    if (value == 'X') {
      if (otp.isNotEmpty) {
        setState(() {
          otp = otp.substring(0, otp.length - 1);
          _otpController.text = otp;
        });
      }
    } else if (otp.length < pinLength) {
      setState(() {
        otp = otp + value;
        _otpController.text = otp;
      });
    }
  }

  void _handleResendOtp() {
    AuthCubit.get(context).resendOTP(widget.phone);
  }

  void _handleNavigationAfterVerification() {
    switch (widget.flow) {
      case OtpFlow.passwordReset:
        context.push(Routes.resetPassword, extra: widget.phone);
        break;
      case OtpFlow.registration:
      case OtpFlow.login:
        context.go(Routes.homeUser);
        break;
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                clipBehavior: Clip.none,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // const CustomBackButton(),
                        51.gap,
                        Text(LocaleKeys.otp_verification.tr(), style: context.titleLarge.copyWith()),
                        51.gap,
                      ],
                    ),
                    46.gap,
                    Text(LocaleKeys.otp_code.tr()),
                    Text(
                      LocaleKeys.activation_code_sent.tr(namedArgs: {"phone_number": widget.phone}),
                      style: context.bodyMedium.regular.s16.copyWith(color: AppColors.grey60),
                    ),
                    16.gap,
                    Material(
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Form(
                                  key: _formKey,
                                  child: CustomPinField(
                                    onChanged: (fieldOtp) {
                                      setState(() {
                                        otp = fieldOtp;
                                      });
                                    },
                                    controller: _otpController,
                                    readOnly: true,
                                  ),
                                ),
                                BlocListener<AuthCubit, AuthState>(
                                  listener: (context, state) {
                                    if (state is ResendOTPError) {
                                      showErrorToast(context, state.message);
                                    }
                                  },
                                  child: ResendOtpWidget(phone: widget.phone, onResend: _handleResendOtp),
                                ),
                                48.gap,
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
            // Custom number keyboard
            NumericKeyboard(
              onKeyPressed: _onKeyPressed,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ).paddingHorizontal(20),
            20.gap,
            Column(
              children: [
                BlocConsumer<AuthCubit, AuthState>(
                  listener: (BuildContext context, AuthState state) async {
                    if (state is AuthSuccess) {
                      UserCubit.get(context).setCurrentUser(state.user);
                      _handleNavigationAfterVerification();
                    }
                    if (state is AuthError) {
                      showErrorToast(context, state.message);
                    }
                    if (state is ResetPasswordSentOTP) {
                      _handleNavigationAfterVerification();
                    }
                  },
                  builder:
                      (BuildContext context, state) => CustomElevatedButton(
                        loading: state is AuthLoading,
                        title: LocaleKeys.confirm.tr(),
                        onPressed: () {
                          if (otp.length == pinLength) {
                            switch (widget.flow) {
                              case OtpFlow.passwordReset:
                                AuthCubit.get(context).verifyPasswordReset(
                                  VerifyParams(phone: widget.phone, loginCode: otp, codeKey: 'reset_password_code'),
                                );
                              case OtpFlow.registration:
                                AuthCubit.get(
                                  context,
                                ).verifyRegistration(VerifyParams(phone: widget.phone, loginCode: otp));
                              case OtpFlow.login:
                              // AuthCubit.get(context).verifyLogin(
                              //   VerifyParams(
                              //     phone: widget.phone,
                              //     loginCode: otp,
                              //   ),
                              // );
                            }
                          }
                        },
                      ),
                ),
                20.gap,
              ],
            ).paddingHorizontal(24),
          ],
        ),
      ),
    );
  }
}

class NumericKeyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final MainAxisAlignment mainAxisAlignment;

  const NumericKeyboard({
    super.key,
    required this.onKeyPressed,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          buildRow(['1', '2', '3']),
          buildRow(['4', '5', '6']),
          buildRow(['7', '8', '9']),
          buildRow(['.', '0', 'X']),
        ],
      ),
    );
  }

  Widget buildRow(List<String> keys) {
    return Row(mainAxisAlignment: mainAxisAlignment, children: keys.map((key) => buildKey(key)).toList());
  }

  Widget buildKey(String text) {
    return Expanded(
      child: Container(
        height: 70,
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(color: const Color(0xFFE9E6F7), borderRadius: BorderRadius.circular(32)),
        child:
            text.isEmpty
                ? const SizedBox()
                : text == 'backspace'
                ? MaterialButton(
                  onPressed: () => onKeyPressed('backspace'),
                  child: const Icon(Icons.backspace_outlined),
                )
                : MaterialButton(
                  onPressed: () => onKeyPressed(text),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                  child: Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
      ),
    );
  }
}
