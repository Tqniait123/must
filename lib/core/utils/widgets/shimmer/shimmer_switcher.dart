import 'package:flutter/material.dart';

class ShimmerSwitcher extends StatelessWidget {
  final bool isLoading;
  final bool isLoaded;
  final bool isError;
  final bool isList;
  final List<dynamic> items; // Default to empty list
  final Widget originalDesign;
  final Widget loadingDesign;
  final Widget errorDesign;
  final Widget? emptyDesign; // Non-nullable

  const ShimmerSwitcher({
    super.key,
    required this.isLoading,
    required this.isLoaded,
    required this.isError,
    this.isList = false,
    List<dynamic>? items,
    required this.originalDesign,
    required this.loadingDesign,
    required this.errorDesign,
    this.emptyDesign,
  }) : items = items ?? const []; // Ensure items is never null

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 1500),
      child: _buildWidgetByState(),
    );
  }

  Widget _buildWidgetByState() {
    if (isLoading) {
      return loadingDesign;
    } else if (isError) {
      return errorDesign;
    } else if (isLoaded) {
      if (isList) {
        return items.isEmpty ? (emptyDesign ?? Container()) : originalDesign;
      } else {
        return originalDesign;
      }
    } else {
      // Fallback widget (you can return an empty container or any other default design)
      return Container();
    }
  }
}
