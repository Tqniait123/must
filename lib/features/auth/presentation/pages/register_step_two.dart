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
import 'package:must_invest/core/utils/widgets/logo_widget.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/user_cubit/user_cubit.dart';
import 'package:must_invest/features/auth/presentation/widgets/id_upload_widget.dart'; // Import the custom widget
import 'package:must_invest/features/auth/presentation/widgets/sign_up_button.dart';

class RegisterStepTwoScreen extends StatefulWidget {
  const RegisterStepTwoScreen({super.key});

  @override
  State<RegisterStepTwoScreen> createState() => _RegisterStepTwoScreenState();
}

class _RegisterStepTwoScreenState extends State<RegisterStepTwoScreen> {
  final _formKey = GlobalKey<FormState>();
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
                    // Add ID Upload Widgets here
                    IdUploadWidget(
                      title: LocaleKeys.egyptian_id_front_side_picture.tr(),
                      onImageSelected: _onFrontIdSelected,
                    ),
                    20.gap,
                    IdUploadWidget(
                      title: LocaleKeys.egyptian_id_back_side_picture.tr(),
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
                      (
                        BuildContext context,
                        AuthState state,
                      ) => CustomElevatedButton(
                        heroTag: 'button',
                        loading: state is AuthLoading,
                        title: LocaleKeys.next.tr(),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Validate ID images are selected
                            if (_frontIdImage == null || _backIdImage == null) {
                              showErrorToast(
                                context,
                                "Please upload both ID images",
                              );
                              return;
                            }

                            // Continue to next step with the selected images
                            context.push(Routes.registerStepThree);
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
