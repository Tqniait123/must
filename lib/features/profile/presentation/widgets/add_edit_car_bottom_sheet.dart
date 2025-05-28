import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/inputs/custom_form_field.dart';
import 'package:must_invest/features/auth/data/models/user.dart';

class AddEditCarBottomSheet extends StatefulWidget {
  final Car? car;
  final Function(Car) onSave;

  const AddEditCarBottomSheet({super.key, this.car, required this.onSave});

  @override
  State<AddEditCarBottomSheet> createState() => _AddEditCarBottomSheetState();
}

class _AddEditCarBottomSheetState extends State<AddEditCarBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _modelController;
  late TextEditingController _plateNumberController;

  @override
  void initState() {
    super.initState();
    _modelController = TextEditingController(text: widget.car?.model ?? '');
    _plateNumberController = TextEditingController(
      text: widget.car?.plateNumber ?? '',
    );
  }

  @override
  void dispose() {
    _modelController.dispose();
    _plateNumberController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final car = Car(
        id: widget.car?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        model: _modelController.text.trim(),
        plateNumber: _plateNumberController.text.trim(),
      );
      widget.onSave(car);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.car != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: EdgeInsets.only(
        left: 30,
        right: 30,
        top: 30,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isEditing
                  ? LocaleKeys.edit_car.tr()
                  : LocaleKeys.add_new_car.tr(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            CustomTextFormField(
              controller: _modelController,
              title: LocaleKeys.model.tr(),
              hint: LocaleKeys.enter_car_model.tr(),
              margin: 0,

              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return LocaleKeys.enter_car_model.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _plateNumberController,
              title: LocaleKeys.plate_number.tr(),
              hint: LocaleKeys.enter_car_plate_number.tr(),
              margin: 0,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return LocaleKeys.enter_car_plate_number.tr();
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomElevatedButton(
                    isFilled: false,
                    textColor: AppColors.black,
                    onPressed: () => Navigator.pop(context),
                    title: LocaleKeys.cancel.tr(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomElevatedButton(
                    onPressed: _save,

                    title:
                        isEditing
                            ? LocaleKeys.update.tr()
                            : LocaleKeys.save.tr(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
