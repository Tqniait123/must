import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'parking_timer_state.dart';

class ParkingTimerCubit extends Cubit<ParkingTimerState> with WidgetsBindingObserver {
  final DateTime startTime;
  
  Timer? _timer;
  final List<String> _logs = [];
  DateTime? _lastUpdateTime;
  int _timerTickCount = 0;
  DateTime? _appPausedTime;
  DateTime? _appResumedTime;

  ParkingTimerCubit({required this.startTime}) : super(const ParkingTimerInitial()) {
    _initializeTimer();
  }

  Future<void> _initializeTimer() async {
    emit(const ParkingTimerLoading());
    
    WidgetsBinding.instance.addObserver(this);
    
    await _loadPreviousLogs();
    
    _logEvent("Timer initialized with startTime: $startTime");
    _logEvent("Current time: ${DateTime.now()}");
    _logEvent("Initial duration difference: ${DateTime.now().difference(startTime)}");

    _updateElapsedTime();
    _startTimer();
    
    _logEvent("Timer started successfully");
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) return;
      
      _timerTickCount++;
      _updateElapsedTime();

      // Log every 30 seconds to track timer behavior, and first 10 ticks for debugging
      if (_timerTickCount <= 10 || _timerTickCount % 30 == 0) {
        _logEvent("Timer tick #$_timerTickCount - Current elapsed: ${_getCurrentElapsedTime()}");
        _logEvent("Timer isActive: ${timer.isActive}");
      }

      // Log more frequently in first few minutes to catch early resets
      if (_timerTickCount % 10 == 0 && _timerTickCount <= 300) {
        final now = DateTime.now();
        final actualElapsed = now.difference(startTime);
        _logEvent("Tick $_timerTickCount: displayed=${_getCurrentElapsedTime()}, actual=${_formatDuration(actualElapsed)}");
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    super.didChangeAppLifecycleState(lifecycleState);

    switch (lifecycleState) {
      case AppLifecycleState.paused:
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
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

  void _handleAppPaused() {
    _appPausedTime = DateTime.now();
    _logEvent("App paused at: $_appPausedTime");
    _logEvent("Timer was running for: ${_getCurrentElapsedTime()} when paused");
    
    final currentState = state;
    if (currentState is ParkingTimerRunning) {
      emit(ParkingTimerPaused(
        elapsedTime: currentState.elapsedTime,
        startTime: currentState.startTime,
        pausedAt: _appPausedTime!,
        logs: List.from(_logs),
      ));
    }
  }

  void _handleAppResumed() {
    _appResumedTime = DateTime.now();
    if (_appPausedTime != null) {
      final pauseDuration = _appResumedTime!.difference(_appPausedTime!);
      _logEvent("App resumed at: $_appResumedTime");
      _logEvent("App was paused for: ${_formatDuration(pauseDuration)}");
      _logEvent("Expected elapsed time after resume: ${_formatDuration(DateTime.now().difference(startTime))}");
      _logEvent("Actual displayed time: ${_getCurrentElapsedTime()}");
    }
    
    // Force update after resume and transition back to running state
    _updateElapsedTime();
  }

  void _updateElapsedTime() {
    if (isClosed) return;
    
    final now = DateTime.now();
    final elapsed = now.difference(startTime);
    final newElapsedTime = _formatDuration(elapsed);

    // Log every update for first 2 minutes to catch early issues
    if (elapsed.inMinutes < 2 || _timerTickCount % 10 == 0) {
      _logEvent("Update #$_timerTickCount: now=$now, startTime=$startTime");
      _logEvent("Raw elapsed: ${elapsed.inSeconds}s, formatted: $newElapsedTime");
    }

    // Check for unexpected reset
    if (_lastUpdateTime != null) {
      final expectedElapsed = now.difference(startTime);
      final timeSinceLastUpdate = now.difference(_lastUpdateTime!);

      // If time since last update is more than 2 seconds, log it as unusual
      if (timeSinceLastUpdate.inSeconds > 2) {
        _logEvent("WARNING: Large gap since last update: ${_formatDuration(timeSinceLastUpdate)}");
        _logEvent("Expected elapsed: ${_formatDuration(expectedElapsed)}");
        _logEvent("Previous displayed time: ${_getCurrentElapsedTime()}");
        _logEvent("New displayed time: $newElapsedTime");
      }

      // Check if time appears to have reset
      final previousSeconds = _parseTimeToSeconds(_getCurrentElapsedTime());
      final currentSeconds = elapsed.inSeconds;
      if (currentSeconds < previousSeconds - 5) {
        _logEvent("CRITICAL: Timer appears to have reset!");
        _logEvent("Previous seconds: $previousSeconds");
        _logEvent("Current seconds: $currentSeconds");
        _logEvent("Start time: $startTime");
        _logEvent("Current time: $now");
        _logEvent("Raw difference: ${now.difference(startTime)}");
        _logEvent("Time since last update: ${_formatDuration(timeSinceLastUpdate)}");
        _logEvent("Previous _lastUpdateTime: $_lastUpdateTime");
      }

      // Check if startTime somehow changed
      final startTimeStr = startTime.toString();
      if (!_logs.any((log) => log.contains("startTime verification: $startTimeStr"))) {
        _logEvent("startTime verification: $startTimeStr");
      }
    }

    final currentState = state;
    if (currentState is ParkingTimerRunning) {
      emit(currentState.copyWith(
        elapsedTime: newElapsedTime,
        timerTickCount: _timerTickCount,
        logs: List.from(_logs),
      ));
    } else if (currentState is! ParkingTimerPaused) {
      // Emit running state if not paused
      emit(ParkingTimerRunning(
        elapsedTime: newElapsedTime,
        startTime: startTime,
        timerTickCount: _timerTickCount,
        logs: List.from(_logs),
      ));
    }

    _lastUpdateTime = now;
  }

  String _getCurrentElapsedTime() {
    final currentState = state;
    if (currentState is ParkingTimerRunning) {
      return currentState.elapsedTime;
    } else if (currentState is ParkingTimerPaused) {
      return currentState.elapsedTime;
    }
    return "00:00:00";
  }

  void _logEvent(String event) {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
    final logEntry = "[$timestamp] $event";
    _logs.add(logEntry);
    print("PARKING_TIMER_LOG: $logEntry");

    // Keep only last 1000 logs to prevent memory issues
    if (_logs.length > 1000) {
      _logs.removeRange(0, _logs.length - 1000);
    }

    // Auto-save logs periodically
    if (_logs.length % 10 == 0) {
      _saveLogs();
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

  Duration getElapsedDuration() {
    final now = DateTime.now();
    return now.difference(startTime);
  }

  Future<void> shareLogs() async {
    try {
      _logEvent("User requested to share logs");

      // Add device info to logs
      final deviceInfo = [
        "=== DEVICE INFO ===",
        "Platform: ${Platform.operatingSystem}",
        "Platform Version: ${Platform.operatingSystemVersion}",
        "Start Time: $startTime",
        "Share Time: ${DateTime.now()}",
        "Total Timer Ticks: $_timerTickCount",
        "Current Elapsed: ${_getCurrentElapsedTime()}",
        "Expected Elapsed: ${_formatDuration(DateTime.now().difference(startTime))}",
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

  void onPaymentBottomSheetOpened() {
    _logEvent("Payment bottom sheet opened");
    final elapsed = getElapsedDuration();
    final totalMinutes = elapsed.inMinutes + 1;
    final points = totalMinutes * 5;
    final parkingDuration = _formatDuration(elapsed);
    _logEvent("Payment calculation - Duration: $parkingDuration, Points: $points");
  }

  @override
  Future<void> close() async {
    _logEvent("Timer disposing - Final tick count: $_timerTickCount");
    _logEvent("Final elapsed time: ${_getCurrentElapsedTime()}");
    
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    await _saveLogs();
    
    return super.close();
  }
}
