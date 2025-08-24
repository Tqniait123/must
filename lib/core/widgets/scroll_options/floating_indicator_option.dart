// lib/core/widgets/scroll_options/floating_indicator_option.dart

import 'package:flutter/material.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:must_invest/features/home/presentation/widgets/parking_widget.dart';
import 'base_scroll_option.dart';
import '../shimmer_card.dart';
import '../empty_error_states.dart';

class FloatingIndicatorOption extends BaseScrollOption {
  const FloatingIndicatorOption({
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
    return FloatingScrollIndicator(
      itemCount: parkings.length,
      parkings: parkings,
      onRefresh: onRefresh,
    );
  }
}

class FloatingScrollIndicator extends StatefulWidget {
  final int itemCount;
  final List<dynamic> parkings;
  final RefreshCallback onRefresh;

  const FloatingScrollIndicator({
    super.key,
    required this.itemCount,
    required this.parkings,
    required this.onRefresh,
  });

  @override
  State<FloatingScrollIndicator> createState() => _FloatingScrollIndicatorState();
}

class _FloatingScrollIndicatorState extends State<FloatingScrollIndicator>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final ScrollController _scrollController = ScrollController();
  bool _showIndicator = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scrollController.addListener(_handleScroll);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _controller.forward();
    });
  }

  void _handleScroll() {
    if (_scrollController.position.pixels > 50 && _showIndicator) {
      setState(() => _showIndicator = false);
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView.separated(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: widget.itemCount,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) =>
                ParkingCard(parking: widget.parkings[index]),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swipe_up, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Scroll up',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
