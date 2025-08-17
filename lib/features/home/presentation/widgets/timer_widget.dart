import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

// Design 2: Minimalist Card with Accent (for Timer)
class ParkingTimerCard extends StatefulWidget {
  final DateTime startTime;

  const ParkingTimerCard({super.key, required this.startTime});

  @override
  State<ParkingTimerCard> createState() => _ParkingTimerCardState();
}

class _ParkingTimerCardState extends State<ParkingTimerCard> {
  late Timer _timer;
  String _elapsedTime = "00:00:00";

  @override
  void initState() {
    super.initState();
    _updateElapsedTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateElapsedTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateElapsedTime() {
    final now = DateTime.now();
    final elapsed = now.difference(widget.startTime);
    setState(() {
      _elapsedTime = _formatDuration(elapsed);
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  Duration _getElapsedDuration() {
    final now = DateTime.now();
    return now.difference(widget.startTime);
  }

  void _showPaymentBottomSheet() {
    final elapsed = _getElapsedDuration();
    final totalMinutes = elapsed.inMinutes + 1;
    final points = totalMinutes * 5;
    final parkingDuration = _formatDuration(elapsed);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(24),
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

                // Parking duration info
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(LocaleKeys.parking_duration.tr(), style: Theme.of(context).textTheme.bodyLarge),
                    Text(
                      parkingDuration,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
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
                      children: [
                        Text(LocaleKeys.points_to_pay.tr(), style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 4),
                        Text(
                          "$points ${LocaleKeys.points_unit.tr()}",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Rate info
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      LocaleKeys.points_rate_info.tr(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // // Action button
                // SizedBox(
                //   width: double.infinity,
                //   height: 44,
                //   child: ElevatedButton(
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Theme.of(context).colorScheme.primary,
                //       shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(12)),
                //     ),
                //     onPressed: () => Navigator.pop(context),
                //     child: Text(
                //       LocaleKeys.continue_parking.tr(),
                //       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                //             color: Colors.white,
                //             fontWeight: FontWeight.w600,
                //           ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.primary, AppColors.primary],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              16.gap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LocaleKeys.active_parking.tr(),
                      style: context.bodyMedium.s14.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500),
                    ),
                    4.gap,
                    Row(
                      children: [
                        Text(
                          _elapsedTime,
                          style: context.bodyMedium.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          20.gap,
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _showPaymentBottomSheet,
                child: Center(
                  child: Text(
                    LocaleKeys.check_payment.tr(),
                    style: context.bodyMedium.s14.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
