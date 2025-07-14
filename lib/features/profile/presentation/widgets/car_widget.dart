import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
    if (isDetailed) {
      return _buildDetailedView(context);
    } else {
      return _buildCompactView(context);
    }
  }

  Widget _buildCompactView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isSelectable && isSelect ? Border.all(color: AppColors.primary, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 2)),
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
              child:
                  car.carPhoto != null && car.carPhoto!.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          car.carPhoto!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.directions_car, color: AppColors.primary, size: 30);
                          },
                        ),
                      )
                      : Icon(Icons.directions_car, color: AppColors.primary, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    car.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        car.metalPlate,
                        style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                      if (car.color != null && car.color!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          car.color!,
                          style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    car.manufactureYear,
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            // 🧠 Use trailing if provided
            trailing ??
                (isSelectable
                    ? Checkbox(value: isSelect, onChanged: onSelectChanged, activeColor: AppColors.primary)
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

  Widget _buildDetailedView(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Car Image Section
          _buildCarImageSection(),

          // Car Information Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name and actions
                _buildHeaderSection(),
                const SizedBox(height: 16),

                // Car Details Grid
                _buildDetailsGrid(),
                const SizedBox(height: 16),

                // License Images Section
                _buildLicenseImagesSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarImageSection() {
    return GestureDetector(
      onTap: onImageTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          color: Colors.grey[100],
        ),
        child:
            car.carPhoto != null && car.carPhoto!.isNotEmpty
                ? ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    car.carPhoto!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  ),
                )
                : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, size: 60, color: AppColors.primary.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              LocaleKeys.no_image_available.tr(),
              style: TextStyle(color: AppColors.primary.withOpacity(0.7), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(car.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 4),
              Text(
                car.metalPlate,
                style: TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (onEdit != null || onDelete != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onEdit != null)
                CustomIconButton(
                  onPressed: onEdit!,
                  height: 40,
                  width: 40,
                  color: AppColors.primary.withOpacity(0.1),
                  iconColor: AppColors.primary,
                  iconAsset: AppIcons.editIc,
                ),
              if (onEdit != null && onDelete != null) const SizedBox(width: 8),
              if (onDelete != null)
                CustomIconButton(
                  onPressed: onDelete!,
                  height: 40,
                  width: 40,
                  color: AppColors.redD2.withOpacity(0.1),
                  iconColor: AppColors.redD2,
                  iconAsset: AppIcons.removeIc,
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildDetailsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDetailItem(
                icon: Icons.calendar_today,
                title: LocaleKeys.manufacture_year.tr(),
                value: car.manufactureYear,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDetailItem(
                icon: Icons.palette,
                title: LocaleKeys.car_color.tr(),
                value: car.color ?? LocaleKeys.not_specified.tr(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildDetailItem(
          icon: Icons.event_note,
          title: LocaleKeys.license_expiry_date.tr(),
          value: _formatExpiryDate(car.licenseExpiryDate),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.license_documents.tr(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildLicenseImage(title: LocaleKeys.front_license.tr(), imageUrl: car.frontLicense)),
            const SizedBox(width: 12),
            Expanded(child: _buildLicenseImage(title: LocaleKeys.back_license.tr(), imageUrl: car.backLicense)),
          ],
        ),
      ],
    );
  }

  Widget _buildLicenseImage({required String title, String? imageUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.grey[50],
          ),
          child:
              imageUrl != null && imageUrl.isNotEmpty
                  ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildLicenseImagePlaceholder();
                      },
                    ),
                  )
                  : _buildLicenseImagePlaceholder(),
        ),
      ],
    );
  }

  Widget _buildLicenseImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 24, color: Colors.grey[400]),
          const SizedBox(height: 4),
          Text(LocaleKeys.no_image.tr(), style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }

  String _formatExpiryDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      final now = DateTime.now();
      final difference = parsedDate.difference(now).inDays;

      final formattedDate = DateFormat('MMM dd, yyyy').format(parsedDate);

      if (difference < 0) {
        return '$formattedDate (${LocaleKeys.expired.tr()})';
      } else if (difference <= 30) {
        return '$formattedDate (${LocaleKeys.expires_soon.tr()})';
      } else {
        return formattedDate;
      }
    } catch (e) {
      return date;
    }
  }
}
