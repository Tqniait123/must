import 'package:flutter/material.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/features/auth/data/models/user.dart';

class CarWidget extends StatelessWidget {
  final Car car;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  final bool isSelectable;
  final bool isSelect;
  final ValueChanged<bool?>? onSelectChanged;

  final Widget? trailing;

  // 🔐 Private base constructor
  const CarWidget._({
    super.key,
    required this.car,
    this.onEdit,
    this.onDelete,
    this.isSelectable = false,
    this.isSelect = false,
    this.onSelectChanged,
    this.trailing,
  });

  /// 🛠 Editable version with edit/delete buttons
  factory CarWidget.editable({
    Key? key,
    required Car car,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return CarWidget._(key: key, car: car, onEdit: onEdit, onDelete: onDelete);
  }

  /// ✅ Selectable version with checkbox
  factory CarWidget.selectable({
    Key? key,
    required Car car,
    required bool isSelect,
    required ValueChanged<bool?> onSelectChanged,
  }) {
    return CarWidget._(
      key: key,
      car: car,
      isSelectable: true,
      isSelect: isSelect,
      onSelectChanged: onSelectChanged,
    );
  }

  /// 🔧 Custom version with any trailing widget
  factory CarWidget.custom({
    Key? key,
    required Car car,
    required Widget trailing,
    
  }) {
    return CarWidget._(key: key, car: car, trailing: trailing);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            isSelectable && isSelect
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.directions_car,
                color: AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.model,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    car.plateNumber,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // 🧠 Use trailing if provided
            trailing ??
                (isSelectable
                    ? Checkbox(
                      value: isSelect,
                      onChanged: onSelectChanged,
                      activeColor: AppColors.primary,
                    )
                    : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconButton(
                          onPressed: onEdit ?? () {},
                          height: 30,
                          width: 30,
                          color: AppColors.primary.withOpacity(0.1),
                          iconColor: AppColors.primary,
                          iconAsset: AppIcons.editIc,
                        ),
                        const SizedBox(width: 12),
                        CustomIconButton(
                          onPressed: onDelete ?? () {},
                          height: 30,
                          width: 30,
                          color: AppColors.redD2.withOpacity(0.1),
                          iconColor: AppColors.redD2,
                          iconAsset: AppIcons.removeIc,
                        ),
                      ],
                    )),
          ],
        ),
      ),
    );
  }
}
