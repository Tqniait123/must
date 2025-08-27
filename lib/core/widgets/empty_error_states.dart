// lib/core/widgets/empty_error_states.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

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
          LocaleKeys.no_parking_spots_found.tr(),
          style: context.bodyMedium.medium.s16.copyWith(color: AppColors.primary.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 8),
        Text(
          LocaleKeys.try_different_location.tr(),
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
        Text(LocaleKeys.something_went_wrong.tr(), style: context.bodyMedium.medium.s16),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: Text(LocaleKeys.try_again.tr())),
        ],
      ],
    );
  }
}
