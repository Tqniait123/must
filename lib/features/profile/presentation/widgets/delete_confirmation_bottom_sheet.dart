import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/features/auth/data/models/user.dart';

class DeleteConfirmationBottomSheet extends StatelessWidget {
  final Car car;
  final VoidCallback onDelete;

  const DeleteConfirmationBottomSheet({
    super.key,
    required this.car,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.delete_outline, size: 40, color: Colors.red),
          ),
          const SizedBox(height: 20),
          Text(
            LocaleKeys.delete_car.tr(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            LocaleKeys.delete_confirmation.tr(
              namedArgs: {'carModel': car.model},
            ),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            LocaleKeys.cannot_be_undone.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 32),
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
                  onPressed: () {
                    onDelete();
                    Navigator.pop(context);
                  },
                  backgroundColor: Colors.red,
                  title: LocaleKeys.delete_car.tr(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
