import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class IdUploadWidget extends StatefulWidget {
  final String title;
  final Function(PlatformFile)? onImageSelected;
  final String? initialImagePath;
  final double? height;

  const IdUploadWidget({
    super.key,
    required this.title,
    this.onImageSelected,
    this.initialImagePath,
    this.height = 93,
  });

  @override
  State<IdUploadWidget> createState() => _IdUploadWidgetState();
}

class _IdUploadWidgetState extends State<IdUploadWidget> {
  PlatformFile? _selectedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialImagePath != null &&
        widget.initialImagePath!.isNotEmpty) {
      _selectedImage = PlatformFile(
        path: widget.initialImagePath!,
        name: widget.initialImagePath!.split('/').last,
        size: File(widget.initialImagePath!).lengthSync(),
      );
    }
  }

  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImage = result.files.first;
        });

        if (widget.onImageSelected != null) {
          widget.onImageSelected!(result.files.first);
        }
      }
    } catch (e) {
      // Handle error
      debugPrint('Error picking image: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: context.bodyMedium.s14.semiBold.copyWith(
            color: AppColors.grey,
            fontSize: 12.r,
            fontWeight: FontWeight.w400,
          ),
        ),

        8.gap,
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: widget.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1), // 0.1 * 255 ≈ 26
              borderRadius: BorderRadius.circular(12),
            ),
            child: DashedBorder(
              dashLength: 6,
              dashGap: 3,
              strokeWidth: 1,
              dashColor: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _selectedImage != null
                        ? Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              File(_selectedImage!.path!),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                  if (widget.onImageSelected != null) {
                                    widget.onImageSelected!(
                                      PlatformFile(path: '', name: '', size: 0),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    size: 20,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                        : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              LocaleKeys.upload_image.tr(),
                              style: context.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontSize: 12.r,
                              ),
                            ),
                          ],
                        ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DashedBorder extends StatelessWidget {
  final Widget child;
  final double dashLength;
  final double dashGap;
  final double strokeWidth;
  final Color dashColor;
  final BorderRadius borderRadius;

  const DashedBorder({
    super.key,
    required this.child,
    this.dashLength = 5,
    this.dashGap = 3,
    this.strokeWidth = 1,
    this.dashColor = AppColors.primary,
    this.borderRadius = BorderRadius.zero,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(
        dashLength: dashLength,
        dashGap: dashGap,
        strokeWidth: strokeWidth,
        dashColor: dashColor,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final double dashLength;
  final double dashGap;
  final double strokeWidth;
  final Color dashColor;
  final BorderRadius borderRadius;

  DashedBorderPainter({
    required this.dashLength,
    required this.dashGap,
    required this.strokeWidth,
    required this.dashColor,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = dashColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final Path path =
        Path()..addRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(
              strokeWidth / 2,
              strokeWidth / 2,
              size.width - strokeWidth,
              size.height - strokeWidth,
            ),
            topLeft: borderRadius.topLeft,
            topRight: borderRadius.topRight,
            bottomLeft: borderRadius.bottomLeft,
            bottomRight: borderRadius.bottomRight,
          ),
        );

    final Path dashedPath = Path();
    final metrics = path.computeMetrics().single;
    final dashPathLength = dashLength + dashGap;

    var distance = 0.0;
    while (distance < metrics.length) {
      final extractPath = metrics.extractPath(distance, distance + dashLength);
      dashedPath.addPath(extractPath, Offset.zero);
      distance += dashPathLength;
    }

    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.dashLength != dashLength ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashColor != dashColor ||
        oldDelegate.borderRadius != borderRadius;
  }
}
