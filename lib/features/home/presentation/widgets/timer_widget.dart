import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/scrolling_text.dart';

import '../cubit/parking_timer_cubit.dart';
import '../cubit/parking_timer_state.dart';

// Stateless widget using Cubit for state management
class ParkingTimerCard extends StatelessWidget {
  final DateTime startTime;

  const ParkingTimerCard({super.key, required this.startTime});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => ParkingTimerCubit(startTime: startTime), child: const _ParkingTimerView());
  }
}

class _ParkingTimerView extends StatelessWidget {
  const _ParkingTimerView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ParkingTimerCubit, ParkingTimerState>(
      builder: (context, state) {
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
          child: Column(children: [_buildTimerContent(context, state), 20.gap, _buildActionButton(context, state)]),
        );
      },
    );
  }

  Widget _buildTimerContent(BuildContext context, ParkingTimerState state) {
    final elapsedTime = _getElapsedTimeFromState(state);
    final isRunning = state is ParkingTimerRunning;

    return Row(
      children: [
        Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [isRunning ? AppColors.primary : Colors.orange, isRunning ? AppColors.primary : Colors.orange],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        16.gap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScrollingText(
                _getStatusText(state),
                style: context.bodyMedium.s14.copyWith(
                  color: isRunning ? AppColors.primary : Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
              4.gap,
              Row(
                children: [
                  Text(
                    elapsedTime,
                    style: context.bodyMedium.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isRunning ? AppColors.primary : Colors.orange,
                    ),
                  ),
                  // 8.gap,
                  // _buildDebugButton(context),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDebugButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ParkingTimerCubit>().shareLogs(),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
        child: const Icon(Icons.bug_report, size: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ParkingTimerState state) {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: state is ParkingTimerRunning ? AppColors.primary : Colors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: state is ParkingTimerRunning ? () => _showPaymentBottomSheet(context) : null,
          child: Center(
            child: Text(
              LocaleKeys.details.tr(),
              style: context.bodyMedium.s14.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  String _getElapsedTimeFromState(ParkingTimerState state) {
    return switch (state) {
      ParkingTimerRunning() => state.elapsedTime,

      ParkingTimerLoading() => "00:00:00",
      ParkingTimerError() => "00:00:00",
      ParkingTimerInitial() => "00:00:00",
      _ => "00:00:00", // Default case for exhaustiveness
    };
  }

  String _getStatusText(ParkingTimerState state) {
    return switch (state) {
      ParkingTimerRunning() => LocaleKeys.active_parking.tr(),

      ParkingTimerLoading() => "Loading...", // You might want to add this to LocaleKeys
      ParkingTimerError() => "Error", // You might want to add this to LocaleKeys
      ParkingTimerInitial() => LocaleKeys.active_parking.tr(),
      _ => LocaleKeys.active_parking.tr(), // Default case for exhaustiveness
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
    return Container(
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

          // const SizedBox(height: 24),

          // // Share logs button for debugging
          // SizedBox(
          //   width: double.infinity,
          //   height: 44,
          //   child: OutlinedButton.icon(
          //     onPressed: onShareLogs,
          //     icon: const Icon(Icons.bug_report, size: 18),
          //     label: const Text("Share Debug Logs"),
          //     style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          //   ),
          // ),
        ],
      ),
    );
  }
}
