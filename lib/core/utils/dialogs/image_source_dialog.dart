import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

enum ImageSourceType { camera, gallery }

class ImageSourceDialog {
  /// Shows a bottom sheet with camera and gallery options
  ///
  /// [context] - The build context
  /// [onSourceSelected] - Callback function that receives the selected ImageSourceType
  /// [title] - Optional custom title, defaults to "Select Image Source"
  /// [cameraLabel] - Optional custom camera label, defaults to "Camera"
  /// [galleryLabel] - Optional custom gallery label, defaults to "Gallery"
  static Future<void> show({
    required BuildContext context,
    required Function(ImageSourceType) onSourceSelected,
    String? title,
    String? cameraLabel,
    String? galleryLabel,
  }) async {
    await showModalBottomSheet<ImageSourceType>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder:
          (context) => _ImageSourceBottomSheet(
            title: title ?? LocaleKeys.select_image_source.tr(),
            cameraLabel: cameraLabel ?? LocaleKeys.camera.tr(),
            galleryLabel: galleryLabel ?? LocaleKeys.gallery.tr(),
            onSourceSelected: onSourceSelected,
          ),
    );
  }
}

class _ImageSourceBottomSheet extends StatelessWidget {
  final String title;
  final String cameraLabel;
  final String galleryLabel;
  final Function(ImageSourceType) onSourceSelected;

  const _ImageSourceBottomSheet({
    required this.title,
    required this.cameraLabel,
    required this.galleryLabel,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),

          // Title
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black87)),

          const SizedBox(height: 32),

          // Options
          Row(
            children: [
              Expanded(
                child: _ImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  label: cameraLabel,
                  onTap: () {
                    Navigator.pop(context);
                    onSourceSelected(ImageSourceType.camera);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  label: galleryLabel,
                  onTap: () {
                    Navigator.pop(context);
                    onSourceSelected(ImageSourceType.gallery);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey.shade800)),
          ],
        ),
      ),
    );
  }
}
