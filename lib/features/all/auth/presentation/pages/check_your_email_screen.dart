import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';

class CheckYourEmailScreen extends StatefulWidget {
  final String email;
  const CheckYourEmailScreen({super.key, required this.email});

  @override
  State<CheckYourEmailScreen> createState() => _CheckYourEmailScreenState();
}

class _CheckYourEmailScreenState extends State<CheckYourEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AppIcons.checkMailIllu.svg(),
                49.gap,
                Text(
                  LocaleKeys.check_your_email.tr(),
                  style: context.bodyMedium.copyWith(color: AppColors.primary),
                ),
                16.gap,
                Text(
                  LocaleKeys.we_have_sent_a_password_recove.tr(),
                  textAlign: TextAlign.center,
                  style: context.bodyMedium.regular.s14.copyWith(
                    color: AppColors.primary.withValues(alpha: 0.5),
                  ),
                ),
                70.gap,
                Material(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Column(
                          children: [
                            CustomElevatedButton(
                              heroTag: 'open-email',
                              title: LocaleKeys.open_email_app.tr(),
                              onPressed: () {},
                            ).paddingHorizontal(46),
                            24.gap,
                            CustomElevatedButton(
                              heroTag: 'button',
                              title: LocaleKeys.enter_otp.tr(),
                              onPressed: () {
                                context.push(
                                  Routes.otpScreen,
                                  extra: widget.email,
                                );
                              },
                            ).paddingHorizontal(46),
                            16.gap,
                            // Text Button
                            TextButton(
                              onPressed: () {
                                context.go(Routes.login);
                              },
                              child: Text(
                                LocaleKeys.skip_ill_confirm_later.tr(),
                                style: context.bodyMedium.regular.s14.copyWith(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                            ),
                            60.gap,
                            // Rich Text
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        LocaleKeys
                                            .didnt_receive_the_email_check_
                                            .tr(),
                                    style: context.bodyMedium.regular.s12
                                        .copyWith(color: AppColors.grey),
                                  ),
                                  TextSpan(
                                    text: ' ',
                                    style: context.bodyMedium.regular.s12
                                        .copyWith(color: AppColors.primary),
                                  ),
                                  TextSpan(
                                    text:
                                        LocaleKeys.try_another_email_address
                                            .tr(),
                                    style: context.bodyMedium.regular.s12
                                        .copyWith(color: AppColors.redED),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            context.pop();
                                          },
                                  ),
                                ],
                              ),
                            ),
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
      ),
      // bottomNavigationBar: Column(
      //   mainAxisSize: MainAxisSize.min,
      //   children: [
      //     BlocProvider(
      //       create: (BuildContext context) => AuthCubit(sl()),
      //       child: BlocConsumer<AuthCubit, AuthState>(
      //         listener: (BuildContext context, AuthState state) {
      //           if (state is ForgetPasswordError) {
      //             showErrorToast(context, state.message);
      //           }
      //           if (state is ForgetPasswordSentOTP) {
      //             context.push(Routes.otpScreen);
      //           }
      //         },
      //         builder:
      //             (BuildContext context, AuthState state) =>
      //                 CustomElevatedButton(
      //                   loading: state is ForgetPasswordLoading,
      //                   title: LocaleKeys.send.tr(),
      //                   onPressed: () {
      //                     if (_formKey.currentState!.validate()) {
      //                       context.push(
      //                         Routes.otpScreen,
      //                         extra: emailController.text,
      //                       );
      //                       // AuthCubit.get(
      //                       //   context,
      //                       // ).forgetPassword(phoneController.text);
      //                     }
      //                   },
      //                 ),
      //       ),
      //     ),
      //     20.gap,
      //   ],
      // ).paddingHorizontal(32),
    );
  }
}
