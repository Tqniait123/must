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
  final bool isSelectDesign; // New flag for select-specific design

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
    this.isSelectDesign = false,
  });

  /// 🛠 Editable version with edit/delete buttons
  factory CarWidget.editable({Key? key, required Car car, VoidCallback? onEdit, VoidCallback? onDelete}) {
    return CarWidget._(key: key, car: car, onEdit: onEdit, onDelete: onDelete);
  }

  /// ✅ Selectable version with checkbox (original design)
  factory CarWidget.selectable({
    Key? key,
    required Car car,
    required bool isSelect,
    required ValueChanged<bool?> onSelectChanged,
  }) {
    return CarWidget._(key: key, car: car, isSelectable: true, isSelect: isSelect, onSelectChanged: onSelectChanged);
  }

  /// 🎯 NEW: Select version with custom design and select button
  factory CarWidget.selectDesign({
    Key? key,
    required Car car,
    required bool isSelect,
    required ValueChanged<bool?> onSelectChanged,
    VoidCallback? onImageTap,
  }) {
    return CarWidget._(
      key: key,
      car: car,
      isSelectable: true,
      isSelect: isSelect,
      onSelectChanged: onSelectChanged,
      onImageTap: onImageTap,
      isSelectDesign: true,
    );
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
    if (isSelectDesign) {
      return _buildSelectDesign(context);
    } else {
      return _buildDefaultDesign(context);
    }
  }

  Widget _buildDefaultDesign(BuildContext context) {
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
        ],
      ),
    );
  }

  Widget _buildSelectDesign(BuildContext context) {
    return AnimatedContainer(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isSelect ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: isSelect ? AppColors.primary.withOpacity(0.1) : Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: isSelect ? 15 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car Image Section for select design
          _buildSelectCarImageSection(),

          // Car Information Section
          _buildSelectCarInfoSection(),

          // Select Button Section
          _buildSelectButtonSection(),
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
                      color: const Color(0xffE41F2D),
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

  Widget _buildSelectCarImageSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Stack(
        children: [
          // Car Image
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: GestureDetector(
              onTap: onImageTap,
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child:
                    car.carPhoto != null && car.carPhoto!.isNotEmpty
                        ? Image.network(
                          car.carPhoto!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildSelectImagePlaceholder();
                          },
                        )
                        : _buildSelectImagePlaceholder(),
              ),
            ),
          ),

          // Selection indicator overlay
          if (isSelect)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
            ),

          // Check mark for selected state
          if (isSelect)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
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
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(14)),
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

  Widget _buildSelectImagePlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(14)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 6),
            Text(LocaleKeys.no_image_available.tr(), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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

          // Car Details Row
          Row(
            children: [
              // License Plate
              CarDetailsWidget(title: car.metalPlate),
              const SizedBox(width: 12),
              CarDetailsWidget(title: car.manufactureYear),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectCarInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car Name
          Text(car.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),

          const SizedBox(height: 12),

          // Car Details Row
          Row(
            children: [
              // License Plate with primary color
              CarDetailsWidget(title: car.metalPlate),

              const SizedBox(width: 12),

              // Manufacture Year with gray color
              CarDetailsWidget(title: car.manufactureYear),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectButtonSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton(
          onPressed: isSelectable && onSelectChanged != null ? () => onSelectChanged!(!isSelect) : null,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: isSelect ? AppColors.primary : Colors.grey[300]!, width: 1.5),
            backgroundColor: isSelect ? AppColors.primary.withOpacity(0.1) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            isSelect ? LocaleKeys.selected.tr() : LocaleKeys.select.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isSelect ? AppColors.primary : Colors.grey[700],
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
