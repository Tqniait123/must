// lib/core/widgets/scroll_options/base_scroll_option.dart

import 'package:flutter/material.dart';

/// Base class for all scroll option widgets
abstract class BaseScrollOption extends StatelessWidget {
  const BaseScrollOption({super.key, required this.state, required this.onRefresh, this.height});

  final dynamic state; // ExploreState
  final RefreshCallback onRefresh;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final defaultHeight = screenHeight * 0.35;

    return SizedBox(height: height ?? defaultHeight, child: buildContent(context));
  }

  Widget buildContent(BuildContext context);
}
