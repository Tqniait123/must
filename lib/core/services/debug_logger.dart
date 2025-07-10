import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class DebugLogger {
  static final DebugLogger _instance = DebugLogger._internal();
  static DebugLogger get instance => _instance;

  DebugLogger._internal();

  File? _logFile;
  bool _isInitialized = false;
  final List<String> _logBuffer = [];

  // Initialize the logger
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final logsDir = Directory('${directory.path}/debug_logs');

      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      _logFile = File('${logsDir.path}/biometric_debug_$timestamp.txt');

      // Write initial device info
      await _writeDeviceInfo();

      _isInitialized = true;

      // Write buffered logs
      for (String log in _logBuffer) {
        await _writeToFile(log);
      }
      _logBuffer.clear();

      log('DebugLogger', 'Debug logger initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize debug logger: $e');
    }
  }

  // Write device information to log
  Future<void> _writeDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      final deviceData = <String, dynamic>{};

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceData.addAll({
          'platform': 'Android',
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'product': androidInfo.product,
          'androidVersion': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'fingerprint': androidInfo.fingerprint,
          'hardware': androidInfo.hardware,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        });
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceData.addAll({
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        });
      }

      deviceData.addAll({
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await _writeToFile('=== DEVICE INFORMATION ===');
      await _writeToFile(const JsonEncoder.withIndent('  ').convert(deviceData));
      await _writeToFile('=== END DEVICE INFORMATION ===\n');
    } catch (e) {
      await _writeToFile('Failed to get device info: $e');
    }
  }

  // Main logging method
  Future<void> log(
    String tag,
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = _formatLogEntry(timestamp, tag, message, level, error, stackTrace);

    // Print to console in debug mode
    if (kDebugMode) {
      debugPrint(logEntry);
    }

    if (_isInitialized) {
      await _writeToFile(logEntry);
    } else {
      _logBuffer.add(logEntry);
    }
  }

  // Format log entry
  String _formatLogEntry(
    String timestamp,
    String tag,
    String message,
    LogLevel level,
    Object? error,
    StackTrace? stackTrace,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('[$timestamp] [${level.name.toUpperCase()}] [$tag] $message');

    if (error != null) {
      buffer.writeln('ERROR: $error');
    }

    if (stackTrace != null) {
      buffer.writeln('STACK TRACE:');
      buffer.writeln(stackTrace.toString());
    }

    return buffer.toString();
  }

  // Write to file
  Future<void> _writeToFile(String content) async {
    try {
      if (_logFile != null) {
        await _logFile!.writeAsString('$content\n', mode: FileMode.append);
      }
    } catch (e) {
      debugPrint('Failed to write to log file: $e');
    }
  }

  // Biometric specific logging methods
  Future<void> logBiometricInit() async {
    await log('BiometricInit', 'Starting biometric initialization');
  }

  Future<void> logBiometricStatus(String status, Map<String, dynamic> details) async {
    await log('BiometricStatus', 'Status: $status, Details: ${jsonEncode(details)}');
  }

  Future<void> logBiometricAuthentication(String type, bool success, String? error) async {
    await log('BiometricAuth', 'Type: $type, Success: $success, Error: $error');
  }

  Future<void> logCredentialsSave(bool success, String? error) async {
    await log('CredentialsSave', 'Success: $success, Error: $error');
  }

  Future<void> logCredentialsLoad(bool found, String? error) async {
    await log('CredentialsLoad', 'Found: $found, Error: $error');
  }

  Future<void> logSecureStorage(String operation, bool success, String? error) async {
    await log('SecureStorage', 'Operation: $operation, Success: $success, Error: $error');
  }

  Future<void> logLoginAttempt(String method, bool success, String? error) async {
    await log('LoginAttempt', 'Method: $method, Success: $success, Error: $error');
  }

  Future<void> logError(String tag, String message, Object error, StackTrace? stackTrace) async {
    await log(tag, message, level: LogLevel.error, error: error, stackTrace: stackTrace);
  }

  // Share logs method
  Future<void> shareLogs() async {
    try {
      if (_logFile == null || !await _logFile!.exists()) {
        throw Exception('Log file not found');
      }

      final result = await Share.shareXFiles(
        [XFile(_logFile!.path)],
        text: 'Biometric Debug Logs - ${DateTime.now().toIso8601String()}',
        subject: 'Biometric Debug Logs',
      );

      await log('LogShare', 'Share result: ${result.status.name}');
    } catch (e) {
      await log('LogShare', 'Failed to share logs: $e', level: LogLevel.error);
    }
  }

  // Get current log file path
  String? get logFilePath => _logFile?.path;

  // Clear logs
  Future<void> clearLogs() async {
    try {
      if (_logFile != null && await _logFile!.exists()) {
        await _logFile!.delete();
      }
      await initialize(); // Reinitialize with new file
      await log('LogClear', 'Logs cleared and reinitialized');
    } catch (e) {
      await log('LogClear', 'Failed to clear logs: $e', level: LogLevel.error);
    }
  }

  // Get logs content as string
  Future<String> getLogsContent() async {
    try {
      if (_logFile != null && await _logFile!.exists()) {
        return await _logFile!.readAsString();
      }
      return 'No logs available';
    } catch (e) {
      return 'Failed to read logs: $e';
    }
  }
}

enum LogLevel { debug, info, warning, error }
