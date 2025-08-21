import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class RouteLoadingIndicator extends StatefulWidget {
  const RouteLoadingIndicator({super.key});

  @override
  State<RouteLoadingIndicator> createState() => _RouteLoadingIndicatorState();
}

class _RouteLoadingIndicatorState extends State<RouteLoadingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeIn));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        isDark
                            ? [Colors.blue.shade800.withOpacity(0.9), Colors.blue.shade600.withOpacity(0.9)]
                            : [Colors.white, Colors.blue.shade50],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade200.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.8),
                      blurRadius: 4,
                      spreadRadius: -2,
                      offset: const Offset(0, -2),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Colors.blue.shade700.withOpacity(0.5) : Colors.blue.shade100,
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated loading indicator
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(colors: [Colors.blue.shade600, Colors.blue.shade400]),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation(isDark ? Colors.white : Colors.white),
                              backgroundColor: Colors.transparent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Route icon with animation
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(milliseconds: 1200),
                          builder: (context, value, child) {
                            return Transform.rotate(
                              angle: value * 0.1,
                              child: Icon(
                                Icons.route_outlined,
                                color: isDark ? Colors.blue.shade200 : Colors.blue.shade600,
                                size: 20,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),

                        // Loading text
                        Flexible(
                          child: Text(
                            LocaleKeys.route_loading_message.tr(),
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.blue.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                              letterSpacing: 0.2,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Alternative minimal version for better performance
class RouteLoadingIndicatorMinimal extends StatelessWidget {
  const RouteLoadingIndicatorMinimal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDark ? Colors.grey.shade900.withOpacity(0.95) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.4) : Colors.grey.withOpacity(0.2),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: isDark ? Colors.grey.shade700 : Colors.grey.shade200, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(theme.primaryColor),
              ),
            ),
            const SizedBox(width: 14),
            Icon(Icons.navigation_outlined, color: theme.primaryColor, size: 18),
            const SizedBox(width: 12),
            Text(
              LocaleKeys.route_loading_message.tr(),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
