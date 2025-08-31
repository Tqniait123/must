import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
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

class _PaymentBottomSheet extends StatelessWidget {
  final String parkingDuration;
  final int points;
  final VoidCallback onShareLogs;

  const _PaymentBottomSheet({required this.parkingDuration, required this.points, required this.onShareLogs});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.6,
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
                  margin: const EdgeInsets.only(bottom: 16),
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
                        parkingDuration,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                          "$points ${LocaleKeys.points_unit.tr()}",
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
                const SizedBox(height: 24),
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
