import 'package:flutter/material.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/features/auth/data/models/user.dart';

class CarWidget extends StatelessWidget {
  final Car car;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CarWidget({
    super.key,
    required this.car,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                color: AppColors.primary.withValues(alpha: 0.1),
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
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconButton(
                  onPressed: onEdit,
                  height: 30,
                  width: 30,

                  color: AppColors.primary.withValues(alpha: 0.1),
                  iconColor: AppColors.primary,
                  iconAsset: AppIcons.editIc,
                ),
                const SizedBox(width: 12),
                CustomIconButton(
                  onPressed: onDelete,
                  height: 30,
                  width: 30,
                  color: AppColors.redD2.withValues(alpha: 0.1),
                  iconColor: AppColors.redD2,
                  iconAsset: AppIcons.removeIc,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
