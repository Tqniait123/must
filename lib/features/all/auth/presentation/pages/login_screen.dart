import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/core/utils/widgets/logo_widget.dart';
import 'package:must_invest/features/all/auth/data/models/login_params.dart';
import 'package:must_invest/features/all/auth/data/models/user.dart';
import 'package:must_invest/features/all/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/all/auth/presentation/cubit/user_cubit/user_cubit.dart';
import 'package:must_invest/features/all/auth/presentation/widgets/sign_up_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isRemembered = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background container with primary color and pattern
          Container(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            decoration: BoxDecoration(color: AppColors.primary),
            child: Stack(
              children: [
                Positioned(
                  left: -100,
                  top: -550,
                  right: 0,
                  bottom: 0,
                  child: Opacity(
                    opacity: 0.3,
                    child: AppIcons.splashPattern.svg(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      height: MediaQuery.sizeOf(context).height * 0.8,
                      // fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Logo positioned in the visible area above the bottom sheet
                Positioned(
                  top: MediaQuery.sizeOf(context).height * 0.15,
                  left: 0,
                  right: 0,
                  child: Center(child: LogoWidget(type: LogoType.svg)),
                ),
                PositionedDirectional(
                  top: MediaQuery.sizeOf(context).height * 0.27,
                  start: 0,

                  child: Text(
                    LocaleKeys.sign_in_to_your_account.tr(),
                    style: context.bodyMedium.s24.bold.copyWith(
                      color: AppColors.white,
                    ),
                    textAlign: TextAlign.center,
                  ).paddingHorizontal(20),
                ),
              ],
            ),
          ),

          // Bottom sheet with form
          DraggableScrollableSheet(
            initialChildSize:
                0.65, // Take up 65% of the screen height initially
            minChildSize: 0.65, // Minimum size
            maxChildSize: 0.65, // Maximum size when expanded
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Small drag indicator at the top of the sheet
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(top: 12, bottom: 20),
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.grey60.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2.5),
                            ),
                          ),
                        ),

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
                                    controller: _emailController,
                                    margin: 0,
                                    hint: LocaleKeys.email.tr(),
                                    title: LocaleKeys.email.tr(),
                                  ),
                                  16.gap,
                                  CustomTextFormField(
                                    margin: 0,
                                    controller: _passwordController,
                                    hint: LocaleKeys.password.tr(),
                                    title: LocaleKeys.password.tr(),
                                    obscureText: true,
                                    isPassword: true,
                                  ),
                                  19.gap,
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          Text(
                                            LocaleKeys.remember_me.tr(),
                                            style:
                                                context.bodyMedium.s12.regular,
                                          ),
                                        ],
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context.push(Routes.forgetPassword);
                                        },
                                        child: Text(
                                          LocaleKeys.forgot_password.tr(),
                                          style: context.bodyMedium.s12.bold
                                              .copyWith(
                                                color: AppColors.primary,
                                              ),
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
                                listener: (
                                  BuildContext context,
                                  AuthState state,
                                ) async {
                                  if (state is AuthSuccess) {
                                    UserCubit.get(
                                      context,
                                    ).setCurrentUser(state.user);
                                    if (state.user.type == UserType.parent) {
                                      context.go(Routes.layoutParent);
                                    } else {
                                      context.go(Routes.layoutTeen);
                                    }
                                  }
                                  if (state is AuthError) {
                                    showErrorToast(context, state.message);
                                  }
                                },
                                builder:
                                    (
                                      BuildContext context,
                                      AuthState state,
                                    ) => CustomElevatedButton(
                                      heroTag: 'button',
                                      loading: state is AuthLoading,
                                      title: LocaleKeys.login.tr(),
                                      onPressed: () {
                                        // if (_formKey.currentState!.validate()) {
                                        AuthCubit.get(context).login(
                                          LoginParams(
                                            email: _emailController.text,
                                            password: _passwordController.text,
                                            isRemembered: isRemembered,
                                          ),
                                        );
                                        // }
                                      },
                                    ),
                              ),
                            ),
                            20.gap,
                            Expanded(
                              child: BlocConsumer<AuthCubit, AuthState>(
                                listener: (
                                  BuildContext context,
                                  AuthState state,
                                ) async {
                                  if (state is AuthSuccess) {
                                    UserCubit.get(
                                      context,
                                    ).setCurrentUser(state.user);
                                    if (state.user.type == UserType.parent) {
                                      context.go(Routes.layoutParent);
                                    } else {
                                      context.go(Routes.layoutTeen);
                                    }
                                  }
                                  if (state is AuthError) {
                                    showErrorToast(context, state.message);
                                  }
                                },
                                builder:
                                    (
                                      BuildContext context,
                                      AuthState state,
                                    ) => CustomElevatedButton(
                                      heroTag: 'faceId',
                                      icon: AppIcons.faceIdIc,
                                      loading: state is AuthLoading,
                                      title: LocaleKeys.face_id.tr(),
                                      onPressed: () {
                                        // if (_formKey.currentState!.validate()) {
                                        AuthCubit.get(context).login(
                                          LoginParams(
                                            email: _emailController.text,
                                            password: _passwordController.text,
                                            isRemembered: isRemembered,
                                          ),
                                        );
                                        // }
                                      },
                                    ),
                              ),
                            ),
                          ],
                        ),
                        71.gap,
                        // or login with divider
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppColors.grey60.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                            16.gap,
                            Text(
                              LocaleKeys.or_login_with.tr(),
                              style: context.bodyMedium.s12.regular,
                            ),
                            16.gap,
                            Expanded(
                              child: Divider(
                                color: AppColors.grey60.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        20.gap,
                        SocialMediaButtons(),
                        20.gap,
                        SignUpButton(
                          isLogin: true,
                          onTap: () {
                            context.push(Routes.accountType);
                          },
                        ),
                        30.gap, // Add extra bottom padding
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
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
            // isFilled: false,
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
            // isFilled: false,
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
