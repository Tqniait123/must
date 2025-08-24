import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/scrolling_text.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

// Design 2: Minimalist Card with Accent (for Timer)
class ParkingTimerCard extends StatefulWidget {
  final DateTime startTime;

  const ParkingTimerCard({super.key, required this.startTime});

  @override
  State<ParkingTimerCard> createState() => _ParkingTimerCardState();
}

class _ParkingTimerCardState extends State<ParkingTimerCard> with WidgetsBindingObserver {
  late Timer _timer;
  String _elapsedTime = "00:00:00";
  List<String> _logs = [];
  DateTime? _lastUpdateTime;
  int _timerTickCount = 0;
  DateTime? _appPausedTime;
  DateTime? _appResumedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _logEvent("Timer initialized with startTime: ${widget.startTime}");
    _logEvent("Current time: ${DateTime.now()}");
    _logEvent("Initial duration difference: ${DateTime.now().difference(widget.startTime)}");

    _updateElapsedTime();
          _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timerTickCount++;
      _updateElapsedTime();

      // Log every 30 seconds to track timer behavior, and first 10 ticks for debugging
      if (_timerTickCount <= 10 || _timerTickCount % 30 == 0) {
        _logEvent("Timer tick #$_timerTickCount - Current elapsed: $_elapsedTime");
        _logEvent("Timer isActive: ${timer.isActive}");
      }

      // Log more frequently in first few minutes to catch early resets
      if (_timerTickCount % 10 == 0 && _timerTickCount <= 300) { // First 5 minutes
        final now = DateTime.now();
        final actualElapsed = now.difference(widget.startTime);
        _logEvent("Tick $_timerTickCount: displayed=$_elapsedTime, actual=${_formatDuration(actualElapsed)}");
      }
    });

    _logEvent("Timer started successfully");
  }

  @override
  void dispose() {
    _logEvent("Timer disposing - Final tick count: $_timerTickCount");
    _logEvent("Final elapsed time: $_elapsedTime");
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
        _appPausedTime = DateTime.now();
        _logEvent("App paused at: $_appPausedTime");
        _logEvent("Timer was running for: $_elapsedTime when paused");
        break;
      case AppLifecycleState.resumed:
        _appResumedTime = DateTime.now();
        if (_appPausedTime != null) {
          final pauseDuration = _appResumedTime!.difference(_appPausedTime!);
          _logEvent("App resumed at: $_appResumedTime");
          _logEvent("App was paused for: ${_formatDuration(pauseDuration)}");
          _logEvent("Expected elapsed time after resume: ${_formatDuration(DateTime.now().difference(widget.startTime))}");
          _logEvent("Actual displayed time: $_elapsedTime");
        }
        // Force update after resume
        _updateElapsedTime();
        break;
      case AppLifecycleState.detached:
        _logEvent("App detached at: ${DateTime.now()}");
        break;
      case AppLifecycleState.inactive:
        _logEvent("App inactive at: ${DateTime.now()}");
        break;
      case AppLifecycleState.hidden:
        _logEvent("App hidden at: ${DateTime.now()}");
        break;
    }
  }

  void _logEvent(String event) {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final logEntry = "[$timestamp] $event";
    _logs.add(logEntry);
    print("PARKING_TIMER_LOG: $logEntry"); // Also print to console

    // Keep only last 1000 logs to prevent memory issues
    if (_logs.length > 1000) {
      _logs.removeRange(0, _logs.length - 1000);
    }
  }

  Future<void> _loadPreviousLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedLogs = prefs.getStringList('parking_timer_logs') ?? [];
      _logs.addAll(storedLogs);

      // Load session count to track app restarts
      final sessionCount = prefs.getInt('parking_timer_sessions') ?? 0;
      await prefs.setInt('parking_timer_sessions', sessionCount + 1);
      _logEvent("Session #${sessionCount + 1} started");

      if (storedLogs.isNotEmpty) {
        _logEvent("Loaded ${storedLogs.length} previous log entries");
      }
    } catch (e) {
      _logEvent("ERROR loading previous logs: $e");
    }
  }

  Future<void> _saveLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('parking_timer_logs', _logs);
    } catch (e) {
      _logEvent("ERROR saving logs: $e");
    }
  }

  void _updateElapsedTime() {
    final now = DateTime.now();
    final elapsed = now.difference(widget.startTime);
    final newElapsedTime = _formatDuration(elapsed);

    // Log every update for first 2 minutes to catch early issues
    if (elapsed.inMinutes < 2 || _timerTickCount % 10 == 0) {
      _logEvent("Update #$_timerTickCount: now=$now, startTime=${widget.startTime}");
      _logEvent("Raw elapsed: ${elapsed.inSeconds}s, formatted: $newElapsedTime");
    }

    // Check for unexpected reset
    if (_lastUpdateTime != null) {
      final expectedElapsed = now.difference(widget.startTime);
      final timeSinceLastUpdate = now.difference(_lastUpdateTime!);

      // If time since last update is more than 2 seconds, log it as unusual
      if (timeSinceLastUpdate.inSeconds > 2) {
        _logEvent("WARNING: Large gap since last update: ${_formatDuration(timeSinceLastUpdate)}");
        _logEvent("Expected elapsed: ${_formatDuration(expectedElapsed)}");
        _logEvent("Previous displayed time: $_elapsedTime");
        _logEvent("New displayed time: $newElapsedTime");
      }

      // Check if time appears to have reset
      final previousSeconds = _parseTimeToSeconds(_elapsedTime);
      final currentSeconds = elapsed.inSeconds;
      if (currentSeconds < previousSeconds - 5) { // 5 second tolerance
        _logEvent("CRITICAL: Timer appears to have reset!");
        _logEvent("Previous seconds: $previousSeconds");
        _logEvent("Current seconds: $currentSeconds");
        _logEvent("Start time: ${widget.startTime}");
        _logEvent("Current time: $now");
        _logEvent("Raw difference: ${now.difference(widget.startTime)}");
        _logEvent("Time since last update: ${_formatDuration(timeSinceLastUpdate)}");
        _logEvent("Previous _lastUpdateTime: $_lastUpdateTime");
      }

      // Check if startTime somehow changed (this would be very unusual)
      final startTimeStr = widget.startTime.toString();
      if (!_logs.any((log) => log.contains("startTime verification: $startTimeStr"))) {
        _logEvent("startTime verification: $startTimeStr");
      }
    }

    setState(() {
      _elapsedTime = newElapsedTime;
    });

    _lastUpdateTime = now;
  }

  int _parseTimeToSeconds(String timeString) {
    final parts = timeString.split(':');
    if (parts.length == 3) {
      return int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60 + int.parse(parts[2]);
    }
    return 0;
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

  Future<void> _shareLogs() async {
    try {
      _logEvent("User requested to share logs");

      // Add device info to logs
      final deviceInfo = [
        "=== DEVICE INFO ===",
        "Platform: ${Platform.operatingSystem}",
        "Platform Version: ${Platform.operatingSystemVersion}",
        "Start Time: ${widget.startTime}",
        "Share Time: ${DateTime.now()}",
        "Total Timer Ticks: $_timerTickCount",
        "Current Elapsed: $_elapsedTime",
        "Expected Elapsed: ${_formatDuration(DateTime.now().difference(widget.startTime))}",
        "=== LOGS ===",
      ];

      final allLogs = [...deviceInfo, ..._logs];
      final logContent = allLogs.join('\n');

      // Create temporary file
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/parking_timer_logs_${DateTime.now().millisecondsSinceEpoch}.txt');
      await file.writeAsString(logContent);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Parking Timer Debug Logs',
        subject: 'Parking Timer Issue Report',
      );

      _logEvent("Logs shared successfully");
    } catch (e) {
      _logEvent("ERROR sharing logs: $e");
      // Fallback to sharing as text
      final logContent = _logs.join('\n');
      await Share.share(logContent, subject: 'Parking Timer Debug Logs');
    }
  }

  void _showPaymentBottomSheet() {
    _logEvent("Payment bottom sheet opened");
    final elapsed = _getElapsedDuration();
    final totalMinutes = elapsed.inMinutes + 1;
    final points = totalMinutes * 5;
    final parkingDuration = _formatDuration(elapsed);
    _logEvent("Payment calculation - Duration: $parkingDuration, Points: $points");

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

                // Share logs button for debugging
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _shareLogs();
                    },
                    icon: const Icon(Icons.bug_report, size: 18),
                    label: const Text("Share Debug Logs"),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),

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
                    ScrollingText(
                      LocaleKeys.active_parking.tr(),
                      // maxLines: 1,
                      // overflow: TextOverflow.ellipsis,
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
                        8.gap,
                        // Small debug indicator
                        GestureDetector(
                          onTap: _shareLogs,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.bug_report,
                              size: 16,
                              color: Colors.grey,
                            ),
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
                    LocaleKeys.details.tr(),
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
