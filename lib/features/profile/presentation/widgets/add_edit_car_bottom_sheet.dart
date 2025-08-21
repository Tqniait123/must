import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/image_source_dialog.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/profile/data/datasources/cars_remote_data_source.dart';
import 'package:must_invest/features/profile/presentation/cubit/cars_cubit.dart';

class AddEditCarBottomSheet extends StatefulWidget {
  final Car? car;
  final VoidCallback? onSuccess;

  const AddEditCarBottomSheet({super.key, this.car, this.onSuccess});

  @override
  State<AddEditCarBottomSheet> createState() => _AddEditCarBottomSheetState();
}

class _AddEditCarBottomSheetState extends State<AddEditCarBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Text controllers
  late TextEditingController _nameController;
  late TextEditingController _plateNumberController;
  late TextEditingController _manufactureYearController;
  late TextEditingController _licenseExpiryDateController;
  late TextEditingController _colorController;

  // Image files
  File? _carPhoto;
  File? _frontLicense;
  File? _backLicense;

  // Date picker
  DateTime? _selectedExpiryDate;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.car?.name ?? '');
    _plateNumberController = TextEditingController(text: widget.car?.metalPlate ?? '');
    _manufactureYearController = TextEditingController(text: widget.car?.manufactureYear ?? '');
    _colorController = TextEditingController(text: widget.car?.color ?? '');

    // Initialize the license expiry date controller first
    _licenseExpiryDateController = TextEditingController();

    // Parse existing expiry date if editing and data exists
    if (widget.car?.licenseExpiryDate != null && widget.car!.licenseExpiryDate.isNotEmpty) {
      try {
        // Parse the date (assuming it's already in YYYY-MM-DD format or can be parsed)
        _selectedExpiryDate = _parseToDateTime(widget.car!.licenseExpiryDate);
        if (_selectedExpiryDate != null) {
          // Always display in user-friendly format but store as YYYY-MM-DD
          _licenseExpiryDateController.text = DateFormat('dd/MM/yyyy').format(_selectedExpiryDate!);
        }
      } catch (e) {
        _selectedExpiryDate = null;
        _licenseExpiryDateController.text = '';
      }
    }
    // If no existing date or if it's a new car, _selectedExpiryDate remains null
    // and _licenseExpiryDateController.text remains empty
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateNumberController.dispose();
    _manufactureYearController.dispose();
    _licenseExpiryDateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  // Show image source selection using reusable dialog
  Future<void> _showImageSourceDialog(ImageType type) async {
    await ImageSourceDialog.show(
      context: context,
      title: LocaleKeys.select_image_source.tr(),
      onSourceSelected: (ImageSourceType sourceType) {
        _pickImageFromSource(type, sourceType);
      },
    );
  }

  // Handle image picking from different sources
  Future<void> _pickImageFromSource(ImageType type, ImageSourceType sourceType) async {
    try {
      final ImageSource imageSource = sourceType == ImageSourceType.camera ? ImageSource.camera : ImageSource.gallery;

      final pickedFile = await _picker.pickImage(
        source: imageSource,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          switch (type) {
            case ImageType.carPhoto:
              _carPhoto = File(pickedFile.path);
              break;
            case ImageType.frontLicense:
              _frontLicense = File(pickedFile.path);
              break;
            case ImageType.backLicense:
              _backLicense = File(pickedFile.path);
              break;
          }
        });
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(LocaleKeys.error_picking_image.tr()), backgroundColor: Colors.red));
    }
  }

  // Updated method to parse various date formats and always return DateTime
  DateTime? _parseToDateTime(String dateText) {
    if (dateText.isEmpty) return null;

    try {
      List<String> formats = [
        'yyyy-MM-dd', // 2025-07-12 (target format)
        'dd/MM/yyyy', // 12/07/2025
        'd/M/yyyy', // 12/7/2025
        'MM/dd/yyyy', // 07/12/2025
        'M/d/yyyy', // 7/12/2025
        'yyyy/MM/dd', // 2025/07/12
        'dd-MM-yyyy', // 12-07-2025
      ];

      for (String format in formats) {
        try {
          return DateFormat(format).parseStrict(dateText);
        } catch (e) {
          continue;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Method to format DateTime to YYYY-MM-DD for storage
  String _formatForStorage(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Method to format DateTime for user display
  String _formatForDisplay(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _selectExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExpiryDate ?? DateTime.now().add(Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365 * 10)),
      // Add these properties to disable manual input
      initialEntryMode: DatePickerEntryMode.calendarOnly, // Start with calendar view
      helpText: '', // Remove help text
      cancelText: LocaleKeys.cancel.tr(),
      confirmText: LocaleKeys.confirm.tr(), // Add confirm button text
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            // Disable the input mode button to prevent switching to manual input
            datePickerTheme: DatePickerThemeData(
              inputDecorationTheme: InputDecorationTheme(
                // This will style the input field if it's shown
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Wrap in a custom widget to completely disable input mode
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // Force calendar-only mode
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedExpiryDate = picked;
        // Display in user-friendly format
        _licenseExpiryDateController.text = _formatForDisplay(picked);
      });
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.car != null;

      // Always store date in YYYY-MM-DD format
      final licenseExpiryDateForStorage = _selectedExpiryDate != null ? _formatForStorage(_selectedExpiryDate!) : '';

      if (isEditing) {
        // Update existing car
        final updateRequest = UpdateCarRequest(
          name: _nameController.text.trim(),
          metalPlate: _plateNumberController.text.trim(),
          manufactureYear: _manufactureYearController.text.trim(),
          licenseExpiryDate: licenseExpiryDateForStorage, // YYYY-MM-DD format
          color: _colorController.text.trim(),
          carPhoto: _carPhoto,
          frontLicense: _frontLicense,
          backLicense: _backLicense,
        );

        CarCubit.get(context).updateCar(widget.car!.id, updateRequest);
      } else {
        // Add new car
        if (_carPhoto == null || _frontLicense == null || _backLicense == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(LocaleKeys.please_select_all_images.tr()), backgroundColor: Colors.red),
          );
          return;
        }

        final addRequest = AddCarRequest(
          name: _nameController.text.trim(),
          carPhoto: _carPhoto!,
          frontLicense: _frontLicense!,
          backLicense: _backLicense!,
          metalPlate: _plateNumberController.text.trim(),
          manufactureYear: _manufactureYearController.text.trim(),
          licenseExpiryDate: licenseExpiryDateForStorage, // YYYY-MM-DD format
          color: _colorController.text.trim(),
        );

        CarCubit.get(context).addCar(addRequest);
      }
    }
  }

  Widget _buildImagePicker({
    required String title,
    required ImageType type,
    required File? selectedImage,
    required String? networkImage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700])),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showImageSourceDialog(type), // Uses reusable dialog
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[50],
            ),
            child:
                selectedImage != null
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(selectedImage, fit: BoxFit.cover),
                    )
                    : networkImage != null && networkImage.isNotEmpty
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        networkImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    )
                    : _buildImagePlaceholder(),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
        SizedBox(height: 8),
        Text(LocaleKeys.tap_to_select_image.tr(), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.car != null;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: EdgeInsets.only(left: 30, right: 30, top: 30, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
      child: BlocConsumer<CarCubit, CarState>(
        listener: (context, state) {
          if (state is AddCarSuccess) {
            Navigator.pop(context);
            widget.onSuccess?.call();
          } else if (state is UpdateCarSuccess) {
            Navigator.pop(context);
            widget.onSuccess?.call();
          } else if (state is AddCarError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          } else if (state is UpdateCarError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          final isLoading = state is AddCarLoading || state is UpdateCarLoading;

          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isEditing ? LocaleKeys.edit_car.tr() : LocaleKeys.add_new_car.tr(),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),

                  // Car Name
                  CustomTextFormField(
                    controller: _nameController,
                    title: LocaleKeys.car_name.tr(),
                    hint: LocaleKeys.enter_car_name.tr(),
                    margin: 0,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return LocaleKeys.please_enter_car_name.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Metal Plate
                  CustomTextFormField(
                    controller: _plateNumberController,
                    title: LocaleKeys.metal_plate.tr(),
                    hint: LocaleKeys.enter_metal_plate.tr(),
                    margin: 0,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return LocaleKeys.please_enter_metal_plate.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Manufacture Year
                  CustomTextFormField(
                    controller: _manufactureYearController,
                    title: LocaleKeys.manufacture_year.tr(),
                    hint: LocaleKeys.enter_manufacture_year.tr(),
                    margin: 0,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return LocaleKeys.please_enter_manufacture_year.tr();
                      }
                      final year = int.tryParse(value);
                      final currentYear = DateTime.now().year;
                      if (year == null || year < 1900 || year > currentYear + 1) {
                        return LocaleKeys.please_enter_valid_year.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Car Color
                  CustomTextFormField(
                    controller: _colorController,
                    title: LocaleKeys.car_color.tr(),
                    hint: LocaleKeys.enter_car_color.tr(),
                    margin: 0,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return LocaleKeys.please_enter_car_color.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // License Expiry Date
                  GestureDetector(
                    onTap: _selectExpiryDate,
                    child: CustomTextFormField(
                      onTap: _selectExpiryDate,
                      controller: _licenseExpiryDateController,
                      title: LocaleKeys.license_expiry_date.tr(),
                      hint: LocaleKeys.select_expiry_date.tr(),
                      margin: 0,
                      readonly: true,
                      suffixIC: Icon(Icons.calendar_today, color: AppColors.primary),
                      validator: (value) {
                        if (_selectedExpiryDate == null) {
                          return LocaleKeys.please_select_expiry_date.tr();
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Car Photo
                  _buildImagePicker(
                    title: LocaleKeys.car_photo.tr(),
                    type: ImageType.carPhoto,
                    selectedImage: _carPhoto,
                    networkImage: widget.car?.carPhoto,
                  ),
                  const SizedBox(height: 16),

                  // Front License
                  _buildImagePicker(
                    title: LocaleKeys.front_license.tr(),
                    type: ImageType.frontLicense,
                    selectedImage: _frontLicense,
                    networkImage: widget.car?.frontLicense,
                  ),
                  const SizedBox(height: 16),

                  // Back License
                  _buildImagePicker(
                    title: LocaleKeys.back_license.tr(),
                    type: ImageType.backLicense,
                    selectedImage: _backLicense,
                    networkImage: widget.car?.backLicense,
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: CustomElevatedButton(
                          isFilled: false,
                          textColor: AppColors.black,
                          onPressed: isLoading ? null : () => Navigator.pop(context),
                          title: LocaleKeys.cancel.tr(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomElevatedButton(
                          onPressed: isLoading ? null : _save,
                          loading: isLoading,
                          title:
                              isLoading
                                  ? LocaleKeys.loading.tr()
                                  : (isEditing ? LocaleKeys.update.tr() : LocaleKeys.save.tr()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

enum ImageType { carPhoto, frontLicense, backLicense }
