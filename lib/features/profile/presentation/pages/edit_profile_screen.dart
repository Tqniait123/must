import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/is_logged_in.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/dialogs/image_source_dialog.dart';
import 'package:must_invest/core/utils/dialogs/selection_bottom_sheet.dart';
import 'package:must_invest/core/utils/widgets/adaptive_layout/custom_layout.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_phone_field.dart';
import 'package:must_invest/core/utils/widgets/inputs/image_picker_avatar.dart';
import 'package:must_invest/core/utils/widgets/logo_widget.dart';
import 'package:must_invest/features/auth/data/models/city.dart';
import 'package:must_invest/features/auth/data/models/country.dart';
import 'package:must_invest/features/auth/data/models/governorate.dart';
import 'package:must_invest/features/auth/presentation/cubit/cities_cubit/cities_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/countires_cubit/countries_cubit.dart';
import 'package:must_invest/features/auth/presentation/cubit/governorates_cubit/governorates_cubit.dart';
import 'package:must_invest/features/auth/presentation/pages/otp_screen.dart';
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

  String _code = '+20';
  String _countryCode = 'EG';
  final TextEditingController _phoneController = TextEditingController();

  // Text editing controllers
  late final TextEditingController _nameController;
  late final TextEditingController _countryController;
  late final TextEditingController _governorateController;
  late final TextEditingController _cityController;

  // Selected IDs for tracking user selections
  int? selectedCountryId;
  int? selectedGovernorateId;
  int? selectedCityId;

  @override
  void initState() {
    super.initState();

    final user = context.user;

    // Initialize controllers with current user data
    _nameController = TextEditingController(text: user.name);
    _countryController = TextEditingController();
    _governorateController = TextEditingController();
    _cityController = TextEditingController();

    // Set initial phone number
    _phoneController.text = user.phone;
    log("${LocaleKeys.phone.tr()}: ${_phoneController.text}");

    // Set initial selected IDs from user data
    selectedCountryId = user.countryId;
    selectedGovernorateId = user.governorateId;
    selectedCityId = user.cityId;

    // Load countries on init
    context.read<CountriesCubit>().getCountries();

    // Load user location data if available
    _loadUserLocationData();
  }

  Future<void> _loadUserLocationData() async {
    final user = context.user;

    // If user has location data, load the complete hierarchy
    if (user.countryId != null) {
      // Load governorates for the user's country
      context.read<GovernoratesCubit>().getGovernorates(user.countryId!);

      if (user.governorateId != null) {
        // Load cities for the user's governorate
        context.read<CitiesCubit>().getCities(user.governorateId!);
      }
    }
  }

  // Method to set country name when countries are loaded
  void _setCountryNameFromId(List<Country> countries) {
    if (selectedCountryId != null) {
      final country = countries.firstWhere((c) => c.id == selectedCountryId, orElse: () => countries.first);
      _countryController.text = country.name;
    }
  }

  // Method to set governorate name when governorates are loaded
  void _setGovernorateNameFromId(List<Governorate> governorates) {
    if (selectedGovernorateId != null) {
      final governorate = governorates.firstWhere(
        (g) => g.id == selectedGovernorateId,
        orElse: () => governorates.first,
      );
      _governorateController.text = governorate.name;
    }
  }

  // Method to set city name when cities are loaded
  void _setCityNameFromId(List<City> cities) {
    if (selectedCityId != null) {
      final city = cities.firstWhere((c) => c.id == selectedCityId, orElse: () => cities.first);
      _cityController.text = city.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _governorateController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Show image source selection dialog for profile image
  Future<void> _showProfileImageSourceDialog() async {
    await ImageSourceDialog.show(
      context: context,
      title: LocaleKeys.select_image_source.tr(),
      onSourceSelected: (ImageSourceType sourceType) {
        _pickProfileImageFromSource(sourceType);
      },
    );
  }

  // Show image source selection dialog for documents
  Future<void> _showDocumentSourceDialog(Function(PlatformFile?) onFileSelected) async {
    await ImageSourceDialog.show(
      context: context,
      title: LocaleKeys.select_document_source.tr(),
      cameraLabel: LocaleKeys.scan_document.tr(),
      galleryLabel: LocaleKeys.choose_from_gallery.tr(),
      onSourceSelected: (ImageSourceType sourceType) {
        _pickDocumentFromSource(sourceType, onFileSelected);
      },
    );
  }

  // Handle profile image picking from different sources
  Future<void> _pickProfileImageFromSource(ImageSourceType sourceType) async {
    try {
      if (sourceType == ImageSourceType.camera) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1024,
          maxHeight: 1024,
        );
        if (image != null) {
          final bytes = await image.readAsBytes();
          final platformFile = PlatformFile(name: image.name, size: bytes.length, bytes: bytes, path: image.path);
          setState(() {
            profileImage = platformFile;
          });
        }
      } else {
        final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
        if (result != null && result.files.isNotEmpty) {
          setState(() {
            profileImage = result.files.first;
          });
        }
      }
    } catch (e) {
      showErrorToast(context, LocaleKeys.error_picking_image.tr());
      log('Error picking profile image: $e');
    }
  }

  // Handle document picking from different sources
  Future<void> _pickDocumentFromSource(ImageSourceType sourceType, Function(PlatformFile?) onFileSelected) async {
    try {
      if (sourceType == ImageSourceType.camera) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 90,
          maxWidth: 2048,
          maxHeight: 2048,
        );
        if (image != null) {
          final bytes = await image.readAsBytes();
          final platformFile = PlatformFile(
            name: '${DateTime.now().millisecondsSinceEpoch}_document.jpg',
            size: bytes.length,
            bytes: bytes,
            path: image.path,
          );
          onFileSelected(platformFile);
        }
      } else {
        final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
        if (result != null && result.files.isNotEmpty) {
          onFileSelected(result.files.first);
        }
      }
    } catch (e) {
      showErrorToast(context, LocaleKeys.error_picking_document.tr());
      log('Error picking document: $e');
    }
  }

  Widget _buildImageUploadCard({
    required String title,
    required String subtitle,
    required PlatformFile? currentFile,
    required VoidCallback onTap,
    required IconData icon,
    String? existingImageUrl,
  }) {
    final isSelected = currentFile != null;
    final hasExistingImage = existingImageUrl != null && existingImageUrl.isNotEmpty;
    final hasAnyImage = isSelected || hasExistingImage;

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
                  hasAnyImage
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
                color: hasAnyImage ? AppColors.primary.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
                width: hasAnyImage ? 2 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: hasAnyImage ? AppColors.primary.withOpacity(0.1) : Colors.black.withOpacity(0.04),
                  blurRadius: hasAnyImage ? 12 : 8,
                  offset: const Offset(0, 4),
                  spreadRadius: hasAnyImage ? 2 : 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon Container with Enhanced Design
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient:
                            hasAnyImage
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
                            hasAnyImage
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
                          hasAnyImage ? Icons.check_circle_rounded : icon,
                          key: ValueKey(hasAnyImage),
                          color: hasAnyImage ? Colors.white : Colors.grey[600],
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
                              color: hasAnyImage ? AppColors.primary : Colors.black87,
                              height: 1.2,
                            ),
                            child: Text(title),
                          ),

                          const SizedBox(height: 6),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _getImageDisplayText(currentFile, existingImageUrl, subtitle),
                              key: ValueKey('${isSelected}_$hasExistingImage'),
                              style: context.textTheme.bodySmall!.copyWith(
                                color: hasAnyImage ? AppColors.primary.withOpacity(0.7) : Colors.grey[600],
                                height: 1.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Progress indicator for selected state
                          if (hasAnyImage) ...[
                            const SizedBox(height: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 3,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.grey[200],
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 1.0,
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
                        color: hasAnyImage ? AppColors.primary.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        hasAnyImage ? Icons.edit_rounded : Icons.cloud_upload_rounded,
                        color: hasAnyImage ? AppColors.primary : Colors.grey[500],
                        size: 20,
                      ),
                    ),
                  ],
                ),

                // Image Preview Section
                if (hasAnyImage) ...[
                  const SizedBox(height: 16),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Image Display
                          _buildImagePreview(currentFile, existingImageUrl),

                          // Overlay with action buttons
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // View Full Size Button
                                GestureDetector(
                                  onTap: () => _showImagePreviewDialog(currentFile, existingImageUrl, title),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(Icons.zoom_in_rounded, color: Colors.white, size: 16),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                // Remove Button
                                if (currentFile != null)
                                  GestureDetector(
                                    onTap: () => _removeImage(currentFile, existingImageUrl),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build image preview
  Widget _buildImagePreview(PlatformFile? currentFile, String? existingImageUrl) {
    if (currentFile != null && currentFile.bytes != null) {
      // Show newly picked image
      return Image.memory(
        currentFile.bytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.error, color: Colors.red)));
        },
      );
    } else if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
      // Show existing image from URL
      return Image.network(
        existingImageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(
                value:
                    loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                color: AppColors.primary,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.error, color: Colors.red)));
        },
      );
    }

    return Container(color: Colors.grey[200], child: const Center(child: Icon(Icons.image, color: Colors.grey)));
  }

  // Method to show full-size image preview
  void _showImagePreviewDialog(PlatformFile? currentFile, String? existingImageUrl, String title) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                // Background
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                // Image
                Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: InteractiveViewer(
                        panEnabled: true,
                        boundaryMargin: const EdgeInsets.all(20),
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: _buildImagePreview(currentFile, existingImageUrl),
                      ),
                    ),
                  ),
                ),
                // Close button
                Positioned(
                  top: 40,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                ),
                // Title
                Positioned(
                  top: 40,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Method to remove image
  void _removeImage(PlatformFile? currentFile, String? existingImageUrl) {
    // Determine which type of image to remove based on the parameters
    // You'll need to modify this based on which image is being removed

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.remove_image.tr()),
            content: Text(LocaleKeys.are_you_sure_you_want_to_remove_this_image.tr()),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(LocaleKeys.cancel.tr())),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    // Remove the specific image based on which one was clicked
                    // You might need to pass additional parameters to identify which image to remove
                    if (currentFile == nationalIdFront) {
                      nationalIdFront = null;
                    } else if (currentFile == nationalIdBack) {
                      nationalIdBack = null;
                    } else if (currentFile == drivingLicenseFront) {
                      drivingLicenseFront = null;
                    } else if (currentFile == drivingLicenseBack) {
                      drivingLicenseBack = null;
                    }
                  });
                },
                child: Text(LocaleKeys.remove.tr(), style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // Helper method to get the appropriate display text for images
  String _getImageDisplayText(PlatformFile? currentFile, String? existingImageUrl, String subtitle) {
    if (currentFile != null) {
      return '${currentFile.name} • ${_formatFileSize(currentFile.size)}';
    } else if (existingImageUrl != null && existingImageUrl.isNotEmpty) {
      return LocaleKeys.current_image_uploaded_tap_to_change.tr();
    } else {
      return subtitle;
    }
  }

  // Helper function to format file size
  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
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
              CustomBackButton(),
              20.gap,
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
                          // Use the reusable dialog instead of direct file picking
                          _showProfileImageSourceDialog();
                        },
                      ),
                    ),
                    28.gap,

                    // Basic Information
                    CustomTextFormField(
                      controller: _nameController,
                      margin: 0,
                      isRequired: true,
                      hint: LocaleKeys.full_name.tr(),
                      title: LocaleKeys.full_name.tr(),
                      // validator: (value) {
                      //   if (value?.isEmpty ?? true) {
                      //     return LocaleKeys.name_is_required.tr();
                      //   }
                      //   return null;
                      // },
                    ),
                    16.gap,
                    CustomPhoneFormField(
                      includeCountryCodeInValue: true,
                      controller: _phoneController,
                      margin: 0,
                      hint: LocaleKeys.phone_number.tr(),
                      title: LocaleKeys.phone_number.tr(),
                      // Add autofill hints for phone number
                      // autofillHints: sl<MustInvestPreferences>().isRememberedMe() ? [AutofillHints.telephoneNumber] : null,
                      onChanged: (phone) {
                        log('${LocaleKeys.phone_number_changed.tr()}: $phone');
                      },
                      onChangedCountryCode: (code, countryCode) {
                        setState(() {
                          _code = code;
                          _countryCode = countryCode;
                          log('${LocaleKeys.country_code_changed.tr()}: $code');
                        });
                      },
                    ),
                    16.gap,

                    // Country Selection
                    BlocProvider.value(
                      value: context.read<CountriesCubit>(),
                      child: BlocBuilder<CountriesCubit, CountriesState>(
                        builder: (BuildContext context, CountriesState state) {
                          if (state is CountriesLoaded) {
                            // Set initial country name if not already set
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_countryController.text.isEmpty && selectedCountryId != null) {
                                _setCountryNameFromId(state.countries);
                              }
                            });

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
                                          selectedCountryId = country.id;
                                          selectedGovernorateId = null;
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
                            // Set initial governorate name if not already set
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_governorateController.text.isEmpty && selectedGovernorateId != null) {
                                _setGovernorateNameFromId(state.governorates);
                              }
                            });

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
                                          selectedGovernorateId = governorate.id;
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
                            // Set initial city name if not already set
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_cityController.text.isEmpty && selectedCityId != null) {
                                _setCityNameFromId(state.cities);
                              }
                            });

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
                                      return LocaleKeys.city_is_required.tr();
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
                      LocaleKeys.documents.tr(),
                      style: context.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    12.gap,

                    _buildImageUploadCard(
                      title: LocaleKeys.national_id_front.tr(),
                      subtitle: LocaleKeys.upload_front_side_national_id.tr(),
                      currentFile: nationalIdFront,
                      existingImageUrl: context.user.nationalId?.front,
                      icon: Icons.credit_card,
                      onTap:
                          () => _showDocumentSourceDialog((file) {
                            setState(() {
                              nationalIdFront = file;
                            });
                          }),
                    ),
                    12.gap,

                    _buildImageUploadCard(
                      title: LocaleKeys.national_id_back.tr(),
                      subtitle: LocaleKeys.upload_back_side_national_id.tr(),
                      currentFile: nationalIdBack,
                      existingImageUrl: context.user.nationalId?.back,
                      icon: Icons.credit_card,
                      onTap:
                          () => _showDocumentSourceDialog((file) {
                            setState(() {
                              nationalIdBack = file;
                            });
                          }),
                    ),
                    12.gap,

                    _buildImageUploadCard(
                      title: LocaleKeys.driving_license_front.tr(),
                      subtitle: LocaleKeys.upload_front_side_driving_license.tr(),
                      currentFile: drivingLicenseFront,
                      existingImageUrl: context.user.drivingLicense?.front,
                      icon: Icons.drive_eta,
                      onTap:
                          () => _showDocumentSourceDialog((file) {
                            setState(() {
                              drivingLicenseFront = file;
                            });
                          }),
                    ),
                    // 12.gap,

                    // _buildImageUploadCard(
                    //   title: LocaleKeys.driving_license_back.tr(),
                    //   subtitle: LocaleKeys.upload_back_side_driving_license.tr(),
                    //   currentFile: drivingLicenseBack,
                    //   existingImageUrl: context.user.drivingLicense?.back,
                    //   icon: Icons.drive_eta,
                    //   onTap: () => _showDocumentSourceDialog((file) {
                    //     setState(() {
                    //       drivingLicenseBack = file;
                    //     });
                    //   }),
                    // ),
                    12.gap,
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
                        if (state.user.approved) {
                          context.setCurrentUser(state.user);
                          showSuccessToast(context, LocaleKeys.profile_updated_successfully.tr());
                        } else {
                          showSuccessToast(context, state.message, seconds: 15);
                          context.go(
                            Routes.otpScreen,
                            extra: {'phone': "$_code${_phoneController.text}", 'flow': OtpFlow.registration},
                          );
                        }
                      }
                      if (state is ProfileError) {
                        showErrorToast(context, state.message);
                      }
                    },
                    builder:
                        (BuildContext context, ProfileState state) => CustomElevatedButton(
                          loading: state is ProfileLoading,
                          heroTag: 'save',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
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
          30.gap,
        ],
      ),
    );
  }

  void _updateProfile([ProfileCubit? profileCubit]) async {
    final cubit = profileCubit ?? context.read<ProfileCubit>();

    final params = UpdateProfileParams(
      name: _nameController.text.trim(),
      cityId: selectedCityId!,
      image: profileImage,
      nationalIdFront: nationalIdFront,
      nationalIdBack: nationalIdBack,
      drivingLicenseFront: drivingLicenseFront,
      drivingLicenseBack: drivingLicenseBack,
      // Only update phone if controller value differs from current user phone
      phone:
          _phoneController.text.isNotEmpty && "$_code${_phoneController.text.trim()}" != context.user.phone
              ? "$_code${_phoneController.text.trim()}"
              : null,

      // Only update country code if phone is being updated
      countryCode:
          _phoneController.text.isNotEmpty && "$_code${_phoneController.text.trim()}" != context.user.phone
              ? _countryCode
              : null,
    );

    if (!params.isValid()) {
      final errors = params.getValidationErrors();
      print('${LocaleKeys.validation_errors.tr()}: ${errors.join(', ')}');
      return;
    }

    try {
      final formData = await params.toFormData();
      log('${LocaleKeys.update_profile_data.tr()}: ${params.toMap()}');
      log('${LocaleKeys.files_count.tr()}: ${params.getFilesCount()}');
      log('${LocaleKeys.total_files_size.tr()}: ${(params.getTotalFilesSize() / 1024).toStringAsFixed(1)} KB');

      await cubit.updateProfile(params);
      context.pop();
    } catch (e) {
      log('${LocaleKeys.error_creating_form_data.tr()}: $e');
    }
  }
}
