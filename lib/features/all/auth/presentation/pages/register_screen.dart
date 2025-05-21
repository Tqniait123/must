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
import 'package:must_invest/features/all/auth/data/models/user.dart';
import 'package:must_invest/features/all/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/all/auth/presentation/cubit/user_cubit/user_cubit.dart';
import 'package:must_invest/features/all/auth/presentation/widgets/sign_up_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _AddressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
                    LocaleKeys.register.tr(),
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
                                    controller: _userNameController,
                                    margin: 0,
                                    hint: LocaleKeys.full_name.tr(),
                                    title: LocaleKeys.full_name.tr(),
                                  ),
                                  16.gap,
                                  CustomTextFormField(
                                    controller: _emailController,
                                    margin: 0,
                                    hint: LocaleKeys.email.tr(),
                                    title: LocaleKeys.email.tr(),
                                  ),
                                  16.gap,
                                  CustomTextFormField(
                                    controller: _phoneController,
                                    margin: 0,
                                    hint: LocaleKeys.phone_number.tr(),
                                    title: LocaleKeys.phone_number.tr(),
                                  ),
                                  16.gap,
                                  CustomTextFormField(
                                    controller: _AddressController,
                                    margin: 0,
                                    hint: LocaleKeys.address.tr(),
                                    title: LocaleKeys.address.tr(),
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
                                  16.gap,
                                  CustomTextFormField(
                                    margin: 0,
                                    controller: _confirmPasswordController,
                                    hint: LocaleKeys.password_confirmation.tr(),
                                    title:
                                        LocaleKeys.password_confirmation.tr(),
                                    obscureText: true,
                                    isPassword: true,
                                  ),
                                  19.gap,
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
                                      title: LocaleKeys.next.tr(),
                                      onPressed: () {
                                        // if (_formKey.currentState!.validate()) {
                                        // AuthCubit.get(context).register(
                                        //   RegisterParams(
                                        //     email: _emailController.text,
                                        //     password: _passwordController.text,
                                        //     name: _userNameController.text,
                                        //     phone: _phoneController.text,
                                        //     passwordConfirmation:
                                        //         _passwordController.text,

                                        //     // address : _AddressController.text,
                                        //   ),
                                        // );
                                        context.push(Routes.registerStepTwo);
                                        // }
                                      },
                                    ),
                              ),
                            ),
                          ],
                        ),
                        71.gap,

                        // // or login with divider
                        // Row(
                        //   children: [
                        //     Expanded(
                        //       child: Divider(
                        //         color: AppColors.grey60.withOpacity(0.3),
                        //         thickness: 1,
                        //       ),
                        //     ),
                        //     16.gap,
                        //     Text(
                        //       LocaleKeys.or_login_with.tr(),
                        //       style: context.bodyMedium.s12.regular,
                        //     ),
                        //     16.gap,
                        //     Expanded(
                        //       child: Divider(
                        //         color: AppColors.grey60.withOpacity(0.3),
                        //         thickness: 1,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // 20.gap,
                        SignUpButton(
                          isLogin: false,
                          onTap: () {
                            context.pop();
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
