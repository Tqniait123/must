import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/dialogs/error_toast.dart';
import 'package:must_invest/core/utils/dialogs/image_source_dialog.dart';
import 'package:must_invest/features/home/presentation/widgets/unified_card_widget.dart';

import '../cubit/parking_timer_cubit.dart';
import '../cubit/parking_timer_state.dart';

class UnifiedParkingTimerCard extends StatelessWidget {
  final DateTime startTime;
  final bool isCollapsed;

  const UnifiedParkingTimerCard({super.key, required this.startTime, this.isCollapsed = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ParkingTimerCubit(startTime: startTime),
      child: _UnifiedParkingTimerView(isCollapsed: isCollapsed),
    );
  }
}

class _UnifiedParkingTimerView extends StatelessWidget {
  final bool isCollapsed;

  const _UnifiedParkingTimerView({required this.isCollapsed});

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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => _PaymentBottomSheet(
            parkingDuration: parkingDuration,
            points: points,
            onShareLogs: () {
              Navigator.pop(context);
              cubit.shareLogs();
            },
            onImageSelected: (PlatformFile? image) {
              log('Image selected: $image');
            },
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
  final VoidCallback onShareLogs;
  final PlatformFile? carParkingImage;
  final Function(PlatformFile?) onImageSelected;

  const _PaymentBottomSheet({
    required this.parkingDuration,
    required this.points,
    required this.onShareLogs,
    this.carParkingImage,
    required this.onImageSelected,
  });

  @override
  State<_PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<_PaymentBottomSheet> {
  // Show dialog to select image source
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

  // Handle image picking from different sources
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
          widget.onImageSelected(platformFile);
        }
      } else {
        final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
        if (result != null && result.files.isNotEmpty) {
          widget.onImageSelected(result.files.first);
        }
      }
    } catch (e) {
      showErrorToast(context, LocaleKeys.error_picking_image.tr());
      log('Error picking parking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.7,
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
                // Drag handle
                Container(
                  width: 48,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),

                // Parking duration
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
                const SizedBox(height: 16),

                // Points to pay
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          LocaleKeys.points_to_pay.tr(),
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
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
                ),
                const SizedBox(height: 16),

                // Car parking image section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.directions_car, size: 18, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          LocaleKeys.car_parking_location.tr(),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      LocaleKeys.upload_image_to_remember_location.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 12),

                    // Image upload/preview box
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        height: 120,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              widget.carParkingImage == null
                                  ? Theme.of(context).colorScheme.surfaceContainerHighest
                                  : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3), width: 1.5),
                        ),
                        child:
                            widget.carParkingImage == null
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 40,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      LocaleKeys.tap_to_upload_image.tr(),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                                    ),
                                  ],
                                )
                                : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.memory(widget.carParkingImage!.bytes!, fit: BoxFit.cover),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                                            onPressed: _showImageSourceDialog,
                                            padding: const EdgeInsets.all(8),
                                            constraints: const BoxConstraints(),
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
                const SizedBox(height: 20),

                // Points rate info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        LocaleKeys.points_rate_info.tr(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
