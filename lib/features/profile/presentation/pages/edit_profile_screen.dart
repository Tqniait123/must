import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/dialogs/selection_bottom_sheet.dart';
import 'package:must_invest/core/utils/widgets/adaptive_layout/custom_layout.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/core/utils/widgets/inputs/image_picker_avatar.dart';
import 'package:must_invest/core/utils/widgets/logo_widget.dart';
import 'package:must_invest/features/auth/data/models/city.dart';
import 'package:must_invest/features/auth/data/models/country.dart';
import 'package:must_invest/features/auth/data/models/governorate.dart';
import 'package:must_invest/features/auth/presentation/cubit/cities_cubit/cities_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/countires_cubit/countries_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/governorates_cubit/governorates_cubit.dart';
import 'package:must_invest/features/profile/data/models/update_profile_params.dart';
import 'package:must_invest/features/profile/presentation/cubit/profile_cubit.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // File uploads
  PlatformFile? profileImage;
  PlatformFile? nationalIdFront;
  PlatformFile? nationalIdBack;
  PlatformFile? drivingLicenseFront;
  PlatformFile? drivingLicenseBack;

  // Text editing controllers
  late final TextEditingController _nameController;
  late final TextEditingController _countryController;
  late final TextEditingController _governorateController;
  late final TextEditingController _cityController;
  int? selectedCityId;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current user data
    _nameController = TextEditingController(text: context.user.name);
    _countryController = TextEditingController(text: '');
    _governorateController = TextEditingController(text: '');
    _cityController = TextEditingController(text: '');

    // Load countries on init
    context.read<CountriesCubit>().getCountries();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _governorateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Widget _buildImageUploadCard({
    required String title,
    required String subtitle,
    required PlatformFile? currentFile,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final isSelected = currentFile != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withOpacity(0.1),
          highlightColor: AppColors.primary.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient:
                  isSelected
                      ? LinearGradient(
                        colors: [AppColors.primary.withOpacity(0.05), AppColors.primary.withOpacity(0.02)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                      : LinearGradient(
                        colors: [Colors.grey[50]!, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.black.withOpacity(0.04),
                  blurRadius: isSelected ? 12 : 8,
                  offset: const Offset(0, 4),
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon Container with Enhanced Design
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient:
                        isSelected
                            ? LinearGradient(
                              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                            : LinearGradient(
                              colors: [Colors.grey[100]!, Colors.grey[50]!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                            : null,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isSelected ? Icons.check_circle_rounded : icon,
                      key: ValueKey(isSelected),
                      color: isSelected ? Colors.white : Colors.grey[600],
                      size: 26,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // Content Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: context.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : Colors.black87,
                          height: 1.2,
                        ),
                        child: Text(title),
                      ),

                      const SizedBox(height: 6),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          isSelected ? '${currentFile.name} • ${_formatFileSize(currentFile.size)}' : subtitle,
                          key: ValueKey(isSelected),
                          style: context.textTheme.bodySmall!.copyWith(
                            color: isSelected ? AppColors.primary.withOpacity(0.7) : Colors.grey[600],
                            height: 1.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Progress indicator for selected state
                      if (isSelected) ...[
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 3,
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.grey[200]),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: 1.0, // You can make this dynamic for upload progress
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Action Icon
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isSelected ? Icons.edit_rounded : Icons.cloud_upload_rounded,
                    color: isSelected ? AppColors.primary : Colors.grey[500],
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  Future<void> _pickFile(Function(PlatformFile?) onFileSelected) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result != null && result.files.isNotEmpty) {
      onFileSelected(result.files.first);
    }
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
                LocaleKeys.edit_profile.tr(),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Image Section
                    Center(
                      child: ImagePickerAvatar(
                        initialImage: context.user.image,
                        pickedImage: profileImage,
                        onPick: (file) {
                          setState(() {
                            profileImage = file;
                          });
                        },
                      ),
                    ),
                    28.gap,

                    // Basic Information
                    CustomTextFormField(
                      controller: _nameController,
                      margin: 0,
                      hint: LocaleKeys.full_name.tr(),
                      title: LocaleKeys.full_name.tr(),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    16.gap,

                    // Country Selection
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

                    // Governorate Selection
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

                    // City Selection
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
                                  validator: (value) {
                                    if (selectedCityId == null) {
                                      return 'City is required';
                                    }
                                    return null;
                                  },
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
                                24.gap,
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),

                    // Document Upload Section
                    Text(
                      'Documents',
                      style: context.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    12.gap,

                    _buildImageUploadCard(
                      title: 'National ID Front',
                      subtitle: 'Upload front side of your national ID',
                      currentFile: nationalIdFront,
                      icon: Icons.credit_card,
                      onTap:
                          () => _pickFile((file) {
                            setState(() {
                              nationalIdFront = file;
                            });
                          }),
                    ),
                    12.gap,

                    _buildImageUploadCard(
                      title: 'National ID Back',
                      subtitle: 'Upload back side of your national ID',
                      currentFile: nationalIdBack,
                      icon: Icons.credit_card,
                      onTap:
                          () => _pickFile((file) {
                            setState(() {
                              nationalIdBack = file;
                            });
                          }),
                    ),
                    12.gap,

                    _buildImageUploadCard(
                      title: 'Driving License Front',
                      subtitle: 'Upload front side of your driving license',
                      currentFile: drivingLicenseFront,
                      icon: Icons.drive_eta,
                      onTap:
                          () => _pickFile((file) {
                            setState(() {
                              drivingLicenseFront = file;
                            });
                          }),
                    ),
                    12.gap,

                    _buildImageUploadCard(
                      title: 'Driving License Back',
                      subtitle: 'Upload back side of your driving license',
                      currentFile: drivingLicenseBack,
                      icon: Icons.drive_eta,
                      onTap:
                          () => _pickFile((file) {
                            setState(() {
                              drivingLicenseBack = file;
                            });
                          }),
                    ),
                    24.gap,
                  ],
                ),
              ),
            ),
          ),
          40.gap,

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomElevatedButton(
                  heroTag: 'cancel',
                  onPressed: () {
                    context.pop();
                  },
                  title: LocaleKeys.cancel.tr(),
                  backgroundColor: Color(0xffF4F4FA),
                  textColor: AppColors.primary.withValues(alpha: 0.5),
                  isBordered: false,
                ),
              ),
              16.gap,
              Expanded(
                child: BlocProvider(
                  create: (BuildContext context) => ProfileCubit(sl()),
                  child: BlocConsumer<ProfileCubit, ProfileState>(
                    listener: (BuildContext context, ProfileState state) {
                      if (state is ProfileSuccess) {
                        context.setCurrentUser(state.user);
                        showSuccessToast(context, LocaleKeys.profile_updated_successfully.tr());
                      }
                      if (state is ProfileError) {
                        showErrorToast(context, state.message);
                      }
                    },
                    builder:
                        (BuildContext context, ProfileState state) => CustomElevatedButton(
                          heroTag: 'save',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // TODO: Implement API call with form data
                              _updateProfile(context.read<ProfileCubit>());
                            }
                          },
                          title: LocaleKeys.save.tr(),
                        ),
                  ),
                ),
              ),
            ],
          ),
          71.gap,
          30.gap, // Add extra bottom padding
        ],
      ),
    );
  }

  void _updateProfile([ProfileCubit? profileCubit]) async {
    // Use the passed cubit or try to get it from context
    final cubit = profileCubit ?? context.read<ProfileCubit>();

    // Create UpdateProfileParams instance
    final params = UpdateProfileParams(
      name: _nameController.text.trim(),
      cityId: selectedCityId!,
      image: profileImage,
      nationalIdFront: nationalIdFront,
      nationalIdBack: nationalIdBack,
      drivingLicenseFront: drivingLicenseFront,
      drivingLicenseBack: drivingLicenseBack,
    );

    // Validate the params
    if (!params.isValid()) {
      final errors = params.getValidationErrors();
      print('Validation errors: ${errors.join(', ')}');
      // Show error message to user
      return;
    }

    try {
      // Convert to FormData
      final formData = await params.toFormData();

      // Log the data being sent (for debugging)
      log('Update Profile Data: ${params.toMap()}');
      log('Files count: ${params.getFilesCount()}');
      log('Total files size: ${(params.getTotalFilesSize() / 1024).toStringAsFixed(1)} KB');

      // TODO: Call your API with formData
      // Example:
      // final response = await apiClient.updateProfile(formData);
      await cubit.updateProfile(params);
      // For now, just pop the screen
      context.pop();
    } catch (e) {
      log('Error creating form data: $e');
      // Handle error
    }
  }
}
