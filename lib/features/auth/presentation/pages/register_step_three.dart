import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
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
import 'package:must_invest/features/auth/data/models/register_params.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/user_cubit/user_cubit.dart';
import 'package:must_invest/features/auth/presentation/widgets/id_upload_widget.dart';
import 'package:must_invest/features/auth/presentation/widgets/sign_up_button.dart';

class RegisterStepThreeScreen extends StatefulWidget {
  const RegisterStepThreeScreen({super.key});

  @override
  State<RegisterStepThreeScreen> createState() =>
      _RegisterStepThreeScreenState();
}

class _RegisterStepThreeScreenState extends State<RegisterStepThreeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _numberOfCarController = TextEditingController();
  final TextEditingController _carNameController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _modelYearController = TextEditingController();

  final TextEditingController _carPlateNumberController =
      TextEditingController();

  PlatformFile? _frontIdImage;
  PlatformFile? _backIdImage;

  void _onFrontIdSelected(PlatformFile file) {
    if (file.path == null || file.path!.isEmpty) return;
    setState(() {
      _frontIdImage = file;
    });
  }

  void _onBackIdSelected(PlatformFile file) {
    if (file.path == null || file.path!.isEmpty) return;
    setState(() {
      _backIdImage = file;
    });
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
                      controller: _numberOfCarController,
                      margin: 0,
                      hint: LocaleKeys.number_of_car.tr(),
                      title: LocaleKeys.number_of_car.tr(),
                    ),
                    16.gap,
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: _modelYearController,
                            margin: 0,
                            hint: LocaleKeys.model_year.tr(),
                            title: LocaleKeys.model_year.tr(),
                          ),
                        ),
                        16.gap,
                        Expanded(
                          child: CustomTextFormField(
                            controller: _carNameController,
                            margin: 0,
                            hint: LocaleKeys.car_name.tr(),
                            title: LocaleKeys.car_name.tr(),
                          ),
                        ),
                      ],
                    ),
                    16.gap,
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            controller: _carModelController,
                            margin: 0,
                            hint: LocaleKeys.car_model.tr(),
                            title: LocaleKeys.car_model.tr(),
                          ),
                        ),
                        16.gap,
                        Expanded(
                          child: CustomTextFormField(
                            margin: 0,
                            controller: _carPlateNumberController,
                            hint: LocaleKeys.car_plate_number.tr(),
                            title: LocaleKeys.car_plate_number.tr(),
                            obscureText: true,
                            isPassword: true,
                          ),
                        ),
                      ],
                    ),

                    16.gap,
                    IdUploadWidget(
                      title: LocaleKeys.license_front_side_picture.tr(),
                      onImageSelected: _onFrontIdSelected,
                    ),
                    16.gap,

                    IdUploadWidget(
                      title: LocaleKeys.license_back_side_picture.tr(),
                      onImageSelected: _onBackIdSelected,
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
                              AuthCubit.get(context).register(
                                RegisterParams(
                                  email: _modelYearController.text,
                                  password: _carPlateNumberController.text,
                                  name: _numberOfCarController.text,
                                  phone: _carNameController.text,
                                  passwordConfirmation:
                                      _carPlateNumberController.text,

                                  // address : _AddressController.text,
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
}
