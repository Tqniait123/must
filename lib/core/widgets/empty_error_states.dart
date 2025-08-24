// lib/core/widgets/empty_error_states.dart

import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.local_parking_outlined, size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        Text(
          'No parking spots found',
          style: context.bodyMedium.medium.s16.copyWith(color: AppColors.primary.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 8),
        Text(
          'Try a different location',
          style: context.bodySmall.regular.s14.copyWith(color: AppColors.primary.withValues(alpha: 0.5)),
        ),
      ],
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const ErrorStateWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: Colors.red.withValues(alpha: 0.6)),
        const SizedBox(height: 16),
        Text('Something went wrong', style: context.bodyMedium.medium.s16),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
        ],
      ],
    );
  }
}
