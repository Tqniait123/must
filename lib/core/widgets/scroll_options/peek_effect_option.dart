// lib/core/widgets/scroll_options/peek_effect_option.dart

import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:must_invest/features/home/presentation/widgets/parking_widget.dart';

import '../empty_error_states.dart';
import '../shimmer_card.dart';
import 'base_scroll_option.dart';

class PeekEffectOption extends BaseScrollOption {
  const PeekEffectOption({super.key, required super.state, required super.onRefresh, super.height});

  @override
  Widget buildContent(BuildContext context) {
    if (state is ParkingsLoading) return const ShimmerLoadingWidget();
    if (state is! ParkingsSuccess || (state as ParkingsSuccess).parkings.isEmpty) {
      return const EmptyStateWidget();
    }

    final parkings = (state as ParkingsSuccess).parkings;
    const double itemHeight = 120.0;
    const double separatorHeight = 16.0;
    const double visibleItems = 2.3;
    final double listHeight = (visibleItems * itemHeight) + ((visibleItems - 1) * separatorHeight);

    return SizedBox(
      height: listHeight,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: parkings.length,
                itemBuilder: (context, index) {
                  return Container(
                    height: itemHeight,
                    margin: const EdgeInsets.only(bottom: separatorHeight),
                    child: ParkingCard(parking: parkings[index]),
                  );
                },
              ),
            ),
          ),
          if (parkings.length > 2)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...List.generate(3, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '${parkings.length} places',
                    style: context.bodySmall.regular.s12.copyWith(color: AppColors.primary.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
