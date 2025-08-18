import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/features/auth/data/models/user.dart';

class CarWidget extends StatelessWidget {
  final Car car;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onImageTap;

  final bool isSelectable;
  final bool isSelect;
  final ValueChanged<bool?>? onSelectChanged;

  final Widget? trailing;
  final bool isDetailed;

  // 🔐 Private base constructor
  const CarWidget._({
    super.key,
    required this.car,
    this.onEdit,
    this.onDelete,
    this.onImageTap,
    this.isSelectable = false,
    this.isSelect = false,
    this.onSelectChanged,
    this.trailing,
    this.isDetailed = false,
  });

  /// 🛠 Editable version with edit/delete buttons
  factory CarWidget.editable({Key? key, required Car car, VoidCallback? onEdit, VoidCallback? onDelete}) {
    return CarWidget._(key: key, car: car, onEdit: onEdit, onDelete: onDelete);
  }

  /// ✅ Selectable version with checkbox
  factory CarWidget.selectable({
    Key? key,
    required Car car,
    required bool isSelect,
    required ValueChanged<bool?> onSelectChanged,
  }) {
    return CarWidget._(key: key, car: car, isSelectable: true, isSelect: isSelect, onSelectChanged: onSelectChanged);
  }

  /// 🔧 Custom version with any trailing widget
  factory CarWidget.custom({Key? key, required Car car, required Widget trailing}) {
    return CarWidget._(key: key, car: car, trailing: trailing);
  }

  /// 📋 Detailed version with full car information and images
  factory CarWidget.detailed({
    Key? key,
    required Car car,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
    VoidCallback? onImageTap,
  }) {
    return CarWidget._(
      key: key,
      car: car,
      onEdit: onEdit,
      onDelete: onDelete,
      onImageTap: onImageTap,
      isDetailed: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car Image Section with floating buttons
          Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20), child: _buildCarImageSection()),

          // Car Information Section
          _buildCarInfoSection(),

          // Select Button Section
          // _buildSelectButtonSection(),
        ],
      ),
    );
  }

  Widget _buildCarImageSection() {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        children: [
          // Car Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: GestureDetector(
              onTap: onImageTap,
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child:
                    car.carPhoto != null && car.carPhoto!.isNotEmpty
                        ? Image.network(
                          car.carPhoto!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildImagePlaceholder();
                          },
                        )
                        : _buildImagePlaceholder(),
              ),
            ),
          ),

          // Floating Action Buttons
          if (onEdit != null || onDelete != null)
            Positioned(
              top: 12,
              right: 12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onEdit != null) ...[
                    CustomIconButton(
                      width: 37,
                      height: 37,
                      color: AppColors.primary,
                      iconAsset: AppIcons.updateIc,
                      onPressed: onEdit!,
                    ),

                    5.gap,
                  ],
                  if (onDelete != null) ...[
                    CustomIconButton(
                      width: 37,
                      height: 37,
                      color: Color(0xffE41F2D),
                      iconAsset: AppIcons.deleteIc,
                      onPressed: onDelete!,
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(LocaleKeys.no_image_available.tr(), style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildCarInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car Name
          Text(car.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),

          const SizedBox(height: 8),

          // // Car Address/Location
          // Text(
          //   car.metalPlate, // Assuming this contains address info like "123 Dhaka Street"
          //   style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w400),
          // ),

          // const SizedBox(height: 12),

          // Car Details Row
          Row(
            children: [
              // License Plate
              CarDetailsWidget(title: car.metalPlate),
              // CarDetailsWidget(car: car),

              // _buildDetailChip(
              //   text: car.metalPlate.split(' ').last, // Extract plate number
              //   backgroundColor: const Color(0xFFE8E5FF),
              //   textColor: const Color(0xFF4F46E5),
              // ),
              const SizedBox(width: 12),

              CarDetailsWidget(title: car.manufactureYear),

              // // Manufacture Year
              // _buildDetailChip(
              //   text: car.manufactureYear,
              //   backgroundColor: Colors.grey[100]!,
              //   textColor: Colors.grey[700]!,
              // ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip({required String text, required Color backgroundColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColor)),
    );
  }

  Widget _buildSelectButtonSection() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: OutlinedButton(
          onPressed:
              isSelectable && onSelectChanged != null
                  ? () => onSelectChanged!(true)
                  : () {}, // Default action or callback
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: isSelect ? const Color(0xFF4F46E5) : Colors.grey[300]!, width: 1.5),
            backgroundColor: isSelect ? const Color(0xFF4F46E5).withOpacity(0.1) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            isSelect ? LocaleKeys.selected.tr() : LocaleKeys.select.tr(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelect ? const Color(0xFF4F46E5) : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}

class CarDetailsWidget extends StatelessWidget {
  const CarDetailsWidget({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(color: const Color(0xFFE2E4FF), borderRadius: BorderRadius.circular(10)),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2B3085))),
    );
  }
}
