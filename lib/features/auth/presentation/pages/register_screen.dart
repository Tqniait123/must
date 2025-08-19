import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/dialogs/selection_bottom_sheet.dart';
import 'package:must_invest/core/utils/widgets/adaptive_layout/custom_layout.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_phone_field.dart';
import 'package:must_invest/core/utils/widgets/logo_widget.dart';
import 'package:must_invest/features/auth/data/models/city.dart';
import 'package:must_invest/features/auth/data/models/country.dart';
import 'package:must_invest/features/auth/data/models/governorate.dart';
import 'package:must_invest/features/auth/data/models/register_params.dart';
import 'package:must_invest/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/cities_cubit/cities_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/countires_cubit/countries_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/governorates_cubit/governorates_cubit.dart';
import 'package:must_invest/features/auth/presentation/pages/otp_screen.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _governorateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String _code = "+20";
  String _countryCode = 'EG';
  int? selectedCityId;

  @override
  void initState() {
    super.initState();
    context.read<CountriesCubit>().getCountries();
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
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
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return LocaleKeys.please_enter_full_name.tr();
                        }
                        // Check if text contains special characters
                        if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(text)) {
                          return LocaleKeys.name_should_not_contain_special_characters.tr();
                        }
                        return null;
                      },
                    ),
                    16.gap,
                    CustomTextFormField(
                      controller: _emailController,
                      margin: 0,
                      hint: LocaleKeys.email.tr(),
                      title: LocaleKeys.email.tr(),
                    ),
                    16.gap,
                    CustomPhoneFormField(
                      controller: _phoneController,
                      margin: 0,
                      hint: LocaleKeys.phone_number.tr(),
                      title: LocaleKeys.phone_number.tr(),
                      includeCountryCodeInValue: true,
                      onChanged: (phone) {
                        log('Phone number changed: $phone');
                      },
                      onChangedCountryCode: (code, countryCode) {
                        setState(() {
                          _countryCode = countryCode;
                          _code = code;
                          log('Country code changed: $code , countryCode: $countryCode');
                        });
                      },

                      // keyboardType: TextInputType.phone,
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return LocaleKeys.please_enter_phone_number.tr();
                      //   }
                      //   // Check if value contains only digits
                      //   if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      //     return LocaleKeys.please_enter_phone_number.tr();
                      //   }
                      //   return null;
                      // },
                      selectedCode: _code,
                    ),
                    16.gap,
                    BlocProvider.value(
                      value: context.read<CountriesCubit>(),
                      child: BlocBuilder<CountriesCubit, CountriesState>(
                        builder: (BuildContext context, CountriesState state) {
                          if (state is CountriesLoaded) {
                            return Column(
                              children: [
                                CustomTextFormField(
                                  controller: _countryController,
                                  margin: 0,
                                  hint: LocaleKeys.country.tr(),
                                  title: LocaleKeys.country.tr(),
                                  suffixIC: Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                                  readonly: true,
                                  onTap: () {
                                    showSelectionBottomSheet<Country>(
                                      context,
                                      items: state.countries,
                                      itemLabelBuilder: (country) => country.name,
                                      onSelect: (country) {
                                        setState(() {
                                          selectedCityId = null;
                                          _cityController.clear();
                                          _governorateController.clear();
                                          _countryController.text = country.name;
                                          context.read<GovernoratesCubit>().getGovernorates(country.id);
                                        });
                                      },
                                    );
                                  },
                                ),
                                16.gap,
                              ],
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ),
                    BlocProvider.value(
                      value: context.read<GovernoratesCubit>(),
                      child: BlocBuilder<GovernoratesCubit, GovernoratesState>(
                        builder: (BuildContext context, GovernoratesState state) {
                          if (state is GovernoratesLoaded) {
                            return Column(
                              children: [
                                CustomTextFormField(
                                  controller: _governorateController,
                                  margin: 0,
                                  hint: LocaleKeys.governorate.tr(),
                                  title: LocaleKeys.governorate.tr(),
                                  suffixIC: Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                                  readonly: true,
                                  onTap: () {
                                    showSelectionBottomSheet<Governorate>(
                                      context,
                                      items: state.governorates,
                                      itemLabelBuilder: (governorate) => governorate.name,
                                      onSelect: (governorate) {
                                        setState(() {
                                          selectedCityId = null;
                                          _cityController.clear();
                                          _governorateController.text = governorate.name;
                                          context.read<CitiesCubit>().getCities(governorate.id);
                                        });
                                      },
                                    );
                                  },
                                ),

                                16.gap,
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    BlocProvider.value(
                      value: context.read<CitiesCubit>(),
                      child: BlocBuilder<CitiesCubit, CitiesState>(
                        builder: (BuildContext context, CitiesState state) {
                          if (state is CitiesLoaded) {
                            return Column(
                              children: [
                                CustomTextFormField(
                                  controller: _cityController,
                                  margin: 0,
                                  hint: LocaleKeys.city.tr(),
                                  title: LocaleKeys.city.tr(),
                                  suffixIC: Icon(Icons.arrow_drop_down_rounded, color: AppColors.primary),
                                  readonly: true,
                                  onTap: () {
                                    showSelectionBottomSheet<City>(
                                      context,
                                      items: state.cities,
                                      itemLabelBuilder: (city) => city.name,
                                      onSelect: (city) {
                                        setState(() {
                                          _cityController.text = city.name;
                                          selectedCityId = city.id;
                                        });
                                      },
                                    );
                                  },
                                ),
                                16.gap,
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
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
                    if (state is RegisterSuccess) {
                      context.go(
                        Routes.otpScreen,
                        extra: {'phone': "$_code${_phoneController.text}", 'flow': OtpFlow.registration},
                      );
                    }
                    if (state is AuthError) {
                      showErrorToast(context, state.message);
                    }
                  },
                  builder:
                      (BuildContext context, AuthState state) => CustomElevatedButton(
                        heroTag: 'button',
                        loading: state is AuthLoading,
                        title: LocaleKeys.next.tr(),
                        onPressed: () {
                          if (selectedCityId == null) {
                            showErrorToast(context, LocaleKeys.city.tr());
                          }
                          if (_formKey.currentState!.validate()) {
                            AuthCubit.get(context).register(
                              RegisterParams(
                                email: _emailController.text,
                                password: _passwordController.text,
                                name: _userNameController.text,
                                phone: "$_code${_phoneController.text}",
                                passwordConfirmation: _passwordController.text,
                                cityId: selectedCityId ?? 0,
                                phoneCode: _countryCode,

                                // address : _AddressController.text,
                              ),
                            );

                            // }
                          }
                        },
                      ),
                ),
              ),
            ],
          ),
          71.gap,

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
