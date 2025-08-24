// lib/core/widgets/scroll_options/page_view_option.dart

import 'package:flutter/material.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:must_invest/features/home/presentation/widgets/parking_widget.dart';
import 'base_scroll_option.dart';
import '../shimmer_card.dart';
import '../empty_error_states.dart';

class PageViewOption extends BaseScrollOption {
  const PageViewOption({
    super.key,
    required super.state,
    required super.onRefresh,
    super.height,
  });

  @override
  Widget buildContent(BuildContext context) {
    if (state is ParkingsLoading) return const ShimmerLoadingWidget();
    if (state is! ParkingsSuccess || (state as ParkingsSuccess).parkings.isEmpty) {
      return const EmptyStateWidget();
    }

    final parkings = (state as ParkingsSuccess).parkings;
    return PageViewScrollOption(parkings: parkings, onRefresh: onRefresh);
  }
}

class PageViewScrollOption extends StatefulWidget {
  final List<dynamic> parkings;
  final RefreshCallback onRefresh;

  const PageViewScrollOption({
    super.key,
    required this.parkings,
    required this.onRefresh,
  });

  @override
  State<PageViewScrollOption> createState() => _PageViewScrollOptionState();
}

class _PageViewScrollOptionState extends State<PageViewScrollOption> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: widget.onRefresh,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.parkings.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: ParkingCard(parking: widget.parkings[index]),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ...List.generate(
                widget.parkings.length > 5 ? 5 : widget.parkings.length,
                (index) {
              bool isActive = index == _currentPage;
              if (widget.parkings.length > 5 && _currentPage >= 3) {
                isActive = index == 4;
              }

              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.3),
                ),
              );
            }),
            if (widget.parkings.length > 5) ...[
              const SizedBox(width: 8),
              Text(
                '${_currentPage + 1}/${widget.parkings.length}',
                style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    fontSize: 12),
              ),
            ],
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
