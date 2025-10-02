import 'dart:developer';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/services/di.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/dialogs/image_source_dialog.dart';
import 'package:must_invest/features/home/presentation/widgets/unified_card_widget.dart';
import 'package:must_invest/features/profile/presentation/cubit/profile_cubit.dart';

import '../cubit/parking_timer_cubit.dart';
import '../cubit/parking_timer_state.dart';

class UnifiedParkingTimerCard extends StatelessWidget {
  final DateTime startTime;
  final bool isCollapsed;
  final int? parkingId;

  const UnifiedParkingTimerCard({super.key, required this.startTime, this.isCollapsed = false, this.parkingId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ParkingTimerCubit(startTime: startTime)),
        BlocProvider(create: (context) => ProfileCubit(sl())),
      ],
      child: _UnifiedParkingTimerView(isCollapsed: isCollapsed, parkingId: parkingId),
    );
  }
}

class _UnifiedParkingTimerView extends StatelessWidget {
  final bool isCollapsed;
  final int? parkingId;

  const _UnifiedParkingTimerView({required this.isCollapsed, this.parkingId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParkingTimerCubit, ParkingTimerState>(
      builder: (context, state) {
        final elapsedTime = _getElapsedTimeFromState(state);
        final isRunning = state is ParkingTimerRunning;
        final accentColor = isRunning ? AppColors.primary : Colors.orange;

        return UnifiedCard(
          isCollapsed: isCollapsed,
          aspectRatio: isCollapsed ? null : 1.1.r,
          backgroundColor: Colors.white,
          child: UnifiedCardContent(
            isCollapsed: isCollapsed,
            title: _getStatusText(state),
            mainText: elapsedTime,
            accentColor: accentColor,
            icon: Icons.timer,
            actionButton:
                !isCollapsed && isRunning
                    ? Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(color: accentColor, borderRadius: BorderRadius.circular(12)),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _showPaymentBottomSheet(context),
                          child: Center(
                            child: Text(
                              LocaleKeys.details.tr(),
                              style: context.bodyMedium.copyWith(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    )
                    : null,
          ),
        );
      },
    );
  }

  String _getElapsedTimeFromState(ParkingTimerState state) {
    return switch (state) {
      ParkingTimerRunning(:final elapsedTime) => elapsedTime,
      _ => "00:00:00",
    };
  }

  String _getStatusText(ParkingTimerState state) {
    return switch (state) {
      ParkingTimerRunning() => LocaleKeys.active_parking.tr(),
      ParkingTimerLoading() => LocaleKeys.loading.tr(),
      ParkingTimerError() => LocaleKeys.error.tr(),
      _ => LocaleKeys.active_parking.tr(),
    };
  }

  void _showPaymentBottomSheet(BuildContext context) {
    final cubit = context.read<ParkingTimerCubit>();
    cubit.onPaymentBottomSheetOpened();

    final elapsed = cubit.getElapsedDuration();
    final totalMinutes = elapsed.inMinutes + 1;
    final points = totalMinutes * 5;
    final parkingDuration = _formatDuration(elapsed);

    // Get ProfileCubit from the current context before showing bottom sheet
    final profileCubit = context.read<ProfileCubit>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (bottomSheetContext) => BlocProvider.value(
            value: profileCubit,
            child: _PaymentBottomSheet(
              parkingDuration: parkingDuration,
              points: points,
              parkingId: parkingId,
              onShareLogs: () {
                Navigator.pop(bottomSheetContext);
                cubit.shareLogs();
              },
            ),
          ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}

class _PaymentBottomSheet extends StatefulWidget {
  final String parkingDuration;
  final int points;
  final int? parkingId;
  final VoidCallback onShareLogs;

  const _PaymentBottomSheet({
    required this.parkingDuration,
    required this.points,
    required this.onShareLogs,
    this.parkingId,
  });

  @override
  State<_PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<_PaymentBottomSheet> {
  PlatformFile? _carParkingImage;
  bool _isUploading = false;

  Future<void> _showImageSourceDialog() async {
    await ImageSourceDialog.show(
      context: context,
      title: LocaleKeys.select_image_source.tr(),
      cameraLabel: LocaleKeys.take_photo.tr(),
      galleryLabel: LocaleKeys.choose_from_gallery.tr(),
      onSourceSelected: (ImageSourceType sourceType) {
        _pickImageFromSource(sourceType);
      },
    );
  }

  Future<void> _pickImageFromSource(ImageSourceType sourceType) async {
    try {
      if (sourceType == ImageSourceType.camera) {
        final ImagePicker picker = ImagePicker();
        final XFile? image = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
          maxWidth: 1024,
          maxHeight: 1024,
        );
        if (image != null) {
          final bytes = await image.readAsBytes();
          final platformFile = PlatformFile(
            name: '${DateTime.now().millisecondsSinceEpoch}_parking.jpg',
            size: bytes.length,
            bytes: bytes,
            path: image.path,
          );
          setState(() {
            _carParkingImage = platformFile;
          });
          _uploadImage(platformFile);
        }
      } else {
        final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
        if (result != null && result.files.isNotEmpty) {
          setState(() {
            _carParkingImage = result.files.first;
          });
          _uploadImage(result.files.first);
        }
      }
    } catch (e) {
      showErrorToast(context, LocaleKeys.error_picking_image.tr());
      log('Error picking parking image: $e');
    }
  }

  Future<void> _uploadImage(PlatformFile image) async {
    // if (widget.parkingId == null) {
    //   showErrorToast(context, LocaleKeys.parking_id_not_found.tr());
    //   return;
    // }

    setState(() {
      _isUploading = true;
    });

    final profileCubit = context.read<ProfileCubit>();
    await profileCubit.uploadCarParkingImage(widget.parkingId ?? 0, image);

    if (mounted) {
      final state = profileCubit.state;
      if (state is UploadCarImageSuccess) {
        showSuccessToast(context, LocaleKeys.image_uploaded_successfully.tr());
      } else if (state is UploadCarImageError) {
        showErrorToast(context, state.message);
        setState(() {
          _carParkingImage = null;
        });
      }
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.75,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        LocaleKeys.parking_duration.tr(),
                        style: Theme.of(context).textTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        widget.parkingDuration,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        LocaleKeys.points_to_pay.tr(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${widget.points} ${LocaleKeys.points_unit.tr()}",
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.directions_car, size: 20, color: Theme.of(context).colorScheme.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaleKeys.car_parking_location.tr(),
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                LocaleKeys.upload_image_to_remember_location.tr(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _isUploading ? null : _showImageSourceDialog,
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              _carParkingImage == null
                                  ? Theme.of(context).colorScheme.primary.withOpacity(0.03)
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child:
                            _isUploading
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                                      const SizedBox(height: 12),
                                      Text(
                                        LocaleKeys.uploading.tr(),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                                      ),
                                    ],
                                  ),
                                )
                                : _carParkingImage == null
                                ? CustomPaint(
                                  painter: DashedBorderPainter(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                                    strokeWidth: 2,
                                    dashWidth: 8,
                                    dashSpace: 6,
                                    borderRadius: 16,
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.cloud_upload_outlined,
                                            size: 36,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          LocaleKeys.tap_to_upload_image.tr(),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          LocaleKeys.supported_formats.tr(),
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.memory(_carParkingImage!.bytes!, fit: BoxFit.cover),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(10),
                                              onTap: _showImageSourceDialog,
                                              child: Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Theme.of(context).colorScheme.primary,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 12,
                                        left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.check_circle, color: Colors.white, size: 16),
                                              const SizedBox(width: 6),
                                              Text(
                                                LocaleKeys.uploaded.tr(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          LocaleKeys.points_rate_info.tr(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke;

    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(borderRadius)),
        );

    final dashPath = _createDashedPath(path);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = dashWidth;
        final double end = distance + length;
        dest.addPath(metric.extractPath(distance, end.clamp(0.0, metric.length)), Offset.zero);
        distance = end + dashSpace;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace ||
        oldDelegate.borderRadius != borderRadius;
  }
}
