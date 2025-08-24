// lib/core/widgets/scroll_options/enhanced_with_fades_option.dart

import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:must_invest/features/home/presentation/widgets/parking_widget.dart';

import '../empty_error_states.dart';
import '../shimmer_card.dart';
import 'base_scroll_option.dart';

class EnhancedWithFadesOption extends BaseScrollOption {
  const EnhancedWithFadesOption({super.key, required super.state, required super.onRefresh, super.height});

  @override
  Widget buildContent(BuildContext context) {
    if (state is ParkingsLoading) {
      return const ShimmerLoadingWidget();
    } else if (state is ParkingsSuccess) {
      final parkings = (state as ParkingsSuccess).parkings;
      if (parkings.isEmpty) {
        return const EmptyStateWidget();
      }

      return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            Scrollbar(
              thumbVisibility: true,
              thickness: 4,
              radius: const Radius.circular(2),
              child: RefreshIndicator(
                onRefresh: onRefresh,
                color: AppColors.primary,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20, right: 8),
                  itemCount: parkings.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      curve: Curves.easeOutCubic,
                      child: ParkingCard(parking: parkings[index]),
                    );
                  },
                ),
              ),
            ),

            // Top fade
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor,
                      Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom fade with hint
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: Center(
                  child: AnimatedOpacity(
                    opacity: parkings.length > 2 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_arrow_down, color: AppColors.primary.withValues(alpha: 0.6), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Scroll for more',
                          style: context.bodySmall.regular.s12.copyWith(
                            color: AppColors.primary.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return const ErrorStateWidget();
    }
  }
}
