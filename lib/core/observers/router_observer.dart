// Importing necessary packages
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

// Custom NavigatorObserver class for logging route changes
class GoRouterObserver extends NavigatorObserver {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // Number of method calls to be displayed
      errorMethodCount: 5, // Number of method calls if stacktrace is provided
      lineLength: 100, // width of the output
      colors: true, // Enable color

      // printTime: true, // Include timestamp in logs
    ),
  );

  // Called when a new route is pushed onto the navigator
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PageRoute) {
      debugPrint("Route Pushed: ${route.settings.name}");
    }
  }

  // Called when the current route is popped off the navigator
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _log(LogLevel.info, 'Route Popped', route);
  }

  // Called when a route is removed from the navigator
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _log(LogLevel.error, 'Route Removed', route);
  }

  // Called when a route is replaced with a new route
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _log(LogLevel.info, 'Route Replaced', newRoute);
  }

  // Helper function to log route changes
  void _log(LogLevel level, String action, Route<dynamic>? route) {
    if (route == null) return;

    // Check if the route is a PageRoute before casting
    final String name = route.settings.name ?? 'Unnamed Route';
    final String duration = route is PageRoute
        ? route.transitionDuration.toString()
        : 'N/A (Not a PageRoute)';

    switch (level) {
      case LogLevel.debug:
        _logger.d(
            '[Routing] => [ $action] Name: $name, Duration: $duration   |⬆|');
        break;
      case LogLevel.info:
        _logger.i(
            '[Routing] => [ $action] Name: $name, Duration: $duration   |⬆|');
        break;
      case LogLevel.warning:
        _logger.w(
            '[Routing] => [ $action] Name: $name, Duration: $duration   |⬆|');
        break;
      case LogLevel.error:
        _logger.e(
            '[Routing] => [ $action] Name: $name, Duration: $duration   |⬆|');
        break;
      case LogLevel.wtf:
        _logger.wtf(
            '[Routing] => [ $action] Name: $name, Duration: $duration   |⬆|');
        break;
    }
  }
}

// Enum for different log levels
enum LogLevel {
  debug,
  info,
  warning,
  error,
  wtf,
}
