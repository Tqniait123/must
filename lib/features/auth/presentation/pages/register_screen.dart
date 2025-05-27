import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/widgets/adaptive_layout/custom_layout.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/core/utils/widgets/logo_widget.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/user_cubit/user_cubit.dart';
import 'package:must_invest/features/auth/presentation/widgets/sign_up_button.dart';

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
                LocaleKeys.register.tr(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        children: [
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
                      title: LocaleKeys.password_confirmation.tr(),
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
                  listener: (BuildContext context, AuthState state) async {
                    if (state is AuthSuccess) {
                      UserCubit.get(context).setCurrentUser(state.user);
                      if (state.user.type == UserType.user) {
                        context.go(Routes.homeUser);
                      } else {
                        // context.go(Routes.homeParkingMan);
                      }
                    }
                    if (state is AuthError) {
                      showErrorToast(context, state.message);
                    }
                  },
                  builder:
                      (BuildContext context, AuthState state) =>
                          CustomElevatedButton(
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
    );
  }

  // Widget _buildWelcomeSection() {
  //   return
  // }
}
