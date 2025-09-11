import 'dart:async';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

/// Enum representing different connection states
enum InternetStatus { disconnected, weak, connected }

/// Configuration class for the Internet Service
class InternetConfig {
  final String testUrl;
  final Duration timeout;
  final Duration weakConnectionThreshold;
  final Duration checkInterval;
  final bool enablePeriodicChecks;
  final bool enableLogging;

  const InternetConfig({
    this.testUrl = 'https://www.google.com',
    this.timeout = const Duration(seconds: 10),
    this.weakConnectionThreshold = const Duration(seconds: 3),
    this.checkInterval = const Duration(seconds: 3),
    this.enablePeriodicChecks = true,
    this.enableLogging = false,
  });
}

/// Main Internet Connectivity Service
class InternetService {
  static final InternetService _instance = InternetService._internal();
  factory InternetService() => _instance;
  InternetService._internal();

  // Private variables
  late Dio _dio;
  late Connectivity _connectivity;
  final StreamController<InternetStatus> _statusController = StreamController<InternetStatus>.broadcast();

  InternetStatus _currentStatus = InternetStatus.disconnected;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _periodicTimer;
  InternetConfig _config = const InternetConfig();
  bool _isInitialized = false;

  // Public getters
  InternetStatus get currentStatus => _currentStatus;
  bool get isConnected => _currentStatus != InternetStatus.disconnected;
  bool get hasWeakConnection => _currentStatus == InternetStatus.weak;
  bool get hasStrongConnection => _currentStatus == InternetStatus.connected;
  Stream<InternetStatus> get statusStream => _statusController.stream;

  /// Initialize the service with optional configuration
  Future<void> initialize([InternetConfig? config]) async {
    if (_isInitialized) return;

    _config = config ?? const InternetConfig();
    _dio = Dio(BaseOptions(connectTimeout: _config.timeout, receiveTimeout: _config.timeout));
    _connectivity = Connectivity();

    await _checkInitialConnection();
    _startConnectivityListener();

    if (_config.enablePeriodicChecks) {
      _startPeriodicChecks();
    }

    _isInitialized = true;
    _log('Internet Service initialized');
  }

  /// Check current internet connectivity
  Future<InternetStatus> checkConnectivity() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();

      // Check if device has network connection
      final hasNetworkConnection = connectivityResults.any(
        (result) =>
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.ethernet,
      );

      if (!hasNetworkConnection) {
        _updateStatus(InternetStatus.disconnected);
        return InternetStatus.disconnected;
      }

      // Test actual internet connectivity
      return await _testInternetConnection();
    } catch (e) {
      _log('Error checking connectivity: $e');
      _updateStatus(InternetStatus.disconnected);
      return InternetStatus.disconnected;
    }
  }

  /// Test actual internet connection quality
  Future<InternetStatus> _testInternetConnection() async {
    try {
      final stopwatch = Stopwatch()..start();
      final response = await _dio.get(_config.testUrl);
      stopwatch.stop();

      if (response.statusCode == 200) {
        final responseTime = Duration(milliseconds: stopwatch.elapsedMilliseconds);
        final status = responseTime > _config.weakConnectionThreshold ? InternetStatus.weak : InternetStatus.connected;

        _updateStatus(status);
        return status;
      } else {
        _updateStatus(InternetStatus.disconnected);
        return InternetStatus.disconnected;
      }
    } catch (e) {
      _log('Internet test failed: $e');
      _updateStatus(InternetStatus.disconnected);
      return InternetStatus.disconnected;
    }
  }

  /// Start listening to connectivity changes
  void _startConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      await checkConnectivity();
    });
  }

  /// Start periodic connectivity checks
  void _startPeriodicChecks() {
    _periodicTimer = Timer.periodic(_config.checkInterval, (_) {
      checkConnectivity();
    });
  }

  /// Check initial connection state
  Future<void> _checkInitialConnection() async {
    await checkConnectivity();
  }

  /// Update connection status and notify listeners
  void _updateStatus(InternetStatus newStatus) {
    if (_currentStatus != newStatus) {
      final oldStatus = _currentStatus;
      _currentStatus = newStatus;
      _statusController.add(newStatus);
      _log('Status changed: $oldStatus -> $newStatus');
    }
  }

  /// Log messages if logging is enabled
  void _log(String message) {
    if (_config.enableLogging) {
      log('[InternetService] $message');
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _periodicTimer?.cancel();
    _statusController.close();
    _isInitialized = false;
    _log('Internet Service disposed');
  }
}

/// Extension methods for easy usage with BuildContext
extension InternetContextExtension on BuildContext {
  /// Quick check if internet is available
  Future<bool> get hasInternet async {
    final service = InternetService();
    if (!service._isInitialized) await service.initialize();
    final status = await service.checkConnectivity();
    return status != InternetStatus.disconnected;
  }

  /// Get current internet status
  Future<InternetStatus> get internetStatus async {
    final service = InternetService();
    if (!service._isInitialized) await service.initialize();
    return await service.checkConnectivity();
  }

  /// Show internet status message
  void showInternetMessage({
    String? connectedMessage,
    String? weakMessage,
    String? disconnectedMessage,
    Duration duration = const Duration(seconds: 3),
    Color? connectedColor,
    Color? weakColor,
    Color? disconnectedColor,
  }) async {
    final status = await internetStatus;

    String message;
    Color color;
    IconData icon;

    switch (status) {
      case InternetStatus.connected:
        message = connectedMessage ?? 'Back Online!';
        color = connectedColor ?? const Color(0xFF00C853);
        icon = Icons.wifi;
        break;
      case InternetStatus.weak:
        message = weakMessage ?? 'Connection is slow';
        color = weakColor ?? const Color(0xFFFF9800);
        icon = Icons.signal_wifi_statusbar_connected_no_internet_4;
        break;
      case InternetStatus.disconnected:
        message = disconnectedMessage ?? 'No Internet Connection';
        color = disconnectedColor ?? const Color(0xFFE53E3E);
        icon = Icons.wifi_off;
        break;
    }

    if (mounted) {
      ScaffoldMessenger.of(this).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: color,
          duration: duration,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      );
    }
  }

  /// Show internet dialog
  void showInternetDialog({
    String? title,
    String? message,
    String? retryButtonText,
    VoidCallback? onRetry,
    bool barrierDismissible = false,
  }) async {
    final status = await internetStatus;

    if (status == InternetStatus.disconnected && mounted) {
      showDialog(
        context: this,
        barrierDismissible: barrierDismissible,
        builder:
            (context) => ModernInternetDialog(
              title: title,
              message: message,
              retryButtonText: retryButtonText,
              onRetry: onRetry,
            ),
      );
    }
  }
}

/// Widget that automatically shows/hides based on internet connectivity
class InternetListener extends StatefulWidget {
  final Widget child;
  final Widget? disconnectedWidget;
  final Widget? weakConnectionWidget;
  final bool showWeakConnectionOverlay;
  final bool showDisconnectedOverlay;
  final Function(InternetStatus)? onStatusChanged;

  const InternetListener({
    super.key,
    required this.child,
    this.disconnectedWidget,
    this.weakConnectionWidget,
    this.showWeakConnectionOverlay = false,
    this.showDisconnectedOverlay = true,
    this.onStatusChanged,
  });

  @override
  State<InternetListener> createState() => _InternetListenerState();
}

class _InternetListenerState extends State<InternetListener> with TickerProviderStateMixin {
  final InternetService _service = InternetService();
  InternetStatus _currentStatus = InternetStatus.disconnected;
  StreamSubscription<InternetStatus>? _subscription;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _service.initialize();
    _currentStatus = _service.currentStatus;

    _subscription = _service.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _currentStatus = status;
        });

        if (status == InternetStatus.disconnected) {
          _animationController.forward();
        } else {
          _animationController.reverse();
          // Show reconnection message
          if (status == InternetStatus.connected) {
            context.showInternetMessage(connectedMessage: "Connection restored!", duration: const Duration(seconds: 2));
          }
        }

        widget.onStatusChanged?.call(status);
      }
    });

    // Check initial status
    await _service.checkConnectivity();
    if (_currentStatus == InternetStatus.disconnected) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Weak connection overlay
        if (widget.showWeakConnectionOverlay && _currentStatus == InternetStatus.weak)
          widget.weakConnectionWidget ?? const ModernWeakConnectionWidget(),

        // Disconnected overlay with animation
        if (widget.showDisconnectedOverlay && _currentStatus == InternetStatus.disconnected)
          FadeTransition(opacity: _fadeAnimation, child: widget.disconnectedWidget ?? const ModernDisconnectedWidget()),
      ],
    );
  }
}

/// Modern widget for weak connection
class ModernWeakConnectionWidget extends StatefulWidget {
  const ModernWeakConnectionWidget({super.key});

  @override
  State<ModernWeakConnectionWidget> createState() => _ModernWeakConnectionWidgetState();
}

class _ModernWeakConnectionWidgetState extends State<ModernWeakConnectionWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: [BoxShadow(color: Colors.black12, offset: Offset(0, 2), blurRadius: 4)],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _pulseAnimation.value,
                      child: const Icon(
                        Icons.signal_wifi_statusbar_connected_no_internet_4,
                        color: Colors.white,
                        size: 20,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Slow connection detected',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern widget for no connection
class ModernDisconnectedWidget extends StatefulWidget {
  const ModernDisconnectedWidget({super.key});

  @override
  State<ModernDisconnectedWidget> createState() => _ModernDisconnectedWidgetState();
}

class _ModernDisconnectedWidgetState extends State<ModernDisconnectedWidget> with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _scaleController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _rotationController, curve: Curves.linear));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _retry() async {
    if (_isRetrying) return;

    setState(() => _isRetrying = true);
    _rotationController.repeat();
    _scaleController.forward().then((_) => _scaleController.reverse());

    try {
      final service = InternetService();
      await service.checkConnectivity();

      // Add a small delay for better UX
      await Future.delayed(const Duration(milliseconds: 800));
    } finally {
      if (mounted) {
        _rotationController.stop();
        _rotationController.reset();
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
      ),
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: const Color(0xFFE53E3E).withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.wifi_off_rounded, size: 48, color: Color(0xFFE53E3E)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Internet Connection',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Please check your connection and try again',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.4),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isRetrying ? null : _retry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      disabledBackgroundColor: Colors.grey[300],
                    ),
                    child:
                        _isRetrying
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: AnimatedBuilder(
                                    animation: _rotationAnimation,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _rotationAnimation.value * 2 * 3.14159,
                                        child: const Icon(Icons.refresh_rounded, size: 20),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text('Checking...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            )
                            : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh_rounded, size: 20),
                                SizedBox(width: 12),
                                Text('Try Again', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Modern Internet Dialog
class ModernInternetDialog extends StatefulWidget {
  final String? title;
  final String? message;
  final String? retryButtonText;
  final VoidCallback? onRetry;

  const ModernInternetDialog({super.key, this.title, this.message, this.retryButtonText, this.onRetry});

  @override
  State<ModernInternetDialog> createState() => _ModernInternetDialogState();
}

class _ModernInternetDialogState extends State<ModernInternetDialog> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() => _isRetrying = true);
    _animationController.repeat();

    try {
      final service = InternetService();
      final status = await service.checkConnectivity();

      await Future.delayed(const Duration(milliseconds: 800));

      if (status != InternetStatus.disconnected && mounted) {
        Navigator.of(context).pop();
      }

      widget.onRetry?.call();
    } finally {
      if (mounted) {
        _animationController.stop();
        _animationController.reset();
        setState(() => _isRetrying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFE53E3E).withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.wifi_off_rounded, color: Color(0xFFE53E3E), size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              widget.title ?? 'Connection Error',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 12),
            Text(
              widget.message ?? 'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isRetrying ? null : _handleRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child:
                    _isRetrying
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: AnimatedBuilder(
                                animation: _animationController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _animationController.value * 2 * 3.14159,
                                    child: const Icon(Icons.refresh, size: 16),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Checking...'),
                          ],
                        )
                        : Text(widget.retryButtonText ?? 'Try Again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Utility class for global internet operations
class InternetUtils {
  /// Execute a function only if internet is available
  static Future<T?> executeIfConnected<T>(Future<T> Function() function, {VoidCallback? onDisconnected}) async {
    final service = InternetService();
    if (!service._isInitialized) await service.initialize();

    final status = await service.checkConnectivity();
    if (status != InternetStatus.disconnected) {
      return await function();
    } else {
      onDisconnected?.call();
      return null;
    }
  }

  /// Wait for internet connection
  static Future<void> waitForConnection({Duration timeout = const Duration(minutes: 5)}) async {
    final service = InternetService();
    if (!service._isInitialized) await service.initialize();

    final completer = Completer<void>();
    late StreamSubscription subscription;

    // Set timeout
    Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('Connection timeout', timeout));
      }
    });

    subscription = service.statusStream.listen((status) {
      if (status != InternetStatus.disconnected && !completer.isCompleted) {
        subscription.cancel();
        completer.complete();
      }
    });

    // Check current status
    if (service.currentStatus != InternetStatus.disconnected) {
      subscription.cancel();
      return;
    }

    return completer.future;
  }
}
