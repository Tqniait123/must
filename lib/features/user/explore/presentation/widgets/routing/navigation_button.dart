import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  final bool isLoadingRoute;
  final bool isNavigating;
  final VoidCallback? onStartNavigation;
  final VoidCallback? onStopNavigation;

  const NavigationButton({
    super.key,
    required this.isLoadingRoute,
    required this.isNavigating,
    this.onStartNavigation,
    this.onStopNavigation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isNavigating ? Colors.red : Colors.blue).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap:
              isLoadingRoute
                  ? null
                  : (isNavigating ? onStopNavigation : onStartNavigation),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isLoadingRoute
                        ? [Colors.grey.shade400, Colors.grey.shade500]
                        : isNavigating
                        ? [Colors.red.shade600, Colors.red.shade700]
                        : [Colors.blue.shade600, Colors.blue.shade700],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoadingRoute) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'جاري التحميل...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isNavigating ? Icons.stop : Icons.navigation,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isNavigating ? 'إيقاف التنقل' : 'بدء التنقل',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
