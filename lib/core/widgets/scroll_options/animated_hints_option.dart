// lib/core/widgets/scroll_options/animated_hints_option.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:must_invest/features/home/presentation/widgets/parking_widget.dart';

import '../empty_error_states.dart';
import '../shimmer_card.dart';
import 'base_scroll_option.dart';

class AnimatedHintsOption extends BaseScrollOption {
  const AnimatedHintsOption({super.key, required super.state, required super.onRefresh, super.height});

  @override
  Widget buildContent(BuildContext context) {
    if (state is ParkingsLoading) return const ShimmerLoadingWidget();
    if (state is! ParkingsSuccess || (state as ParkingsSuccess).parkings.isEmpty) {
      return const EmptyStateWidget();
    }

    final parkings = (state as ParkingsSuccess).parkings;
    return _AnimatedHintsWithScrollDetection(parkings: parkings, onRefresh: onRefresh);
  }
}

class _AnimatedHintsWithScrollDetection extends StatefulWidget {
  final List parkings;
  final Future<void> Function() onRefresh;

  const _AnimatedHintsWithScrollDetection({required this.parkings, required this.onRefresh});

  @override
  State<_AnimatedHintsWithScrollDetection> createState() => _AnimatedHintsWithScrollDetectionState();
}

class _AnimatedHintsWithScrollDetectionState extends State<_AnimatedHintsWithScrollDetection> {
  late ScrollController _scrollController;
  bool _showScrollHint = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      // Check if we're near the end of the scroll view
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // Hide hint when user is within 100 pixels of the bottom
      final threshold = 100.0;
      final shouldShow = (maxScroll - currentScroll) > threshold;

      if (_showScrollHint != shouldShow) {
        setState(() {
          _showScrollHint = shouldShow;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      alignment: Alignment.topCenter,
      children: [
        RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.only(bottom: 20, right: 8),
            physics: const BouncingScrollPhysics(),
            itemCount: widget.parkings.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              return ParkingCard(parking: widget.parkings[index]);
            },
          ),
        ),
        if (widget.parkings.length > 2)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _showScrollHint ? 40 : -60, // Hide by moving off-screen
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showScrollHint ? 1.0 : 0.0,
              child: const Center(child: AnimatedScrollHint()),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
}

// Rest of your AnimatedScrollHint classes remain the same...
class AnimatedScrollHint extends StatefulWidget {
  const AnimatedScrollHint({super.key});

  @override
  State<AnimatedScrollHint> createState() => _AnimatedScrollHintState();
}

class _AnimatedScrollHintState extends State<AnimatedScrollHint> with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _pulseController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Bounce animation - optimized duration
    _bounceController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);

    // Pulse animation for glass effect
    _pulseController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);

    _bounceAnimation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOutSine, // Smoother curve for better performance
      ),
    );

    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Start animations
    _bounceController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);

    // Auto-stop after 6 seconds
    // Future.delayed(const Duration(seconds: 6), () {
    //   if (mounted) {
    //     _bounceController.stop();
    //     _pulseController.stop();
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceAnimation, _pulseAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                // Outer glow
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
                // Inner shadow for depth
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.1),
                  blurRadius: 1,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    // Liquid glass gradient
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: _pulseAnimation.value * 0.25),
                        AppColors.primary.withValues(alpha: _pulseAnimation.value * 0.15),
                        AppColors.primary.withValues(alpha: _pulseAnimation.value * 0.08),
                      ],
                    ),
                    // Glass border
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: _pulseAnimation.value * 0.4),
                      width: 0.8,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Container(
                    // Inner highlight for glass effect
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShaderMask(
                          shaderCallback:
                              (bounds) => LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.9),
                                  AppColors.primary.withValues(alpha: 0.7),
                                ],
                              ).createShader(bounds),
                          child: Icon(Icons.keyboard_double_arrow_down, color: Colors.white, size: 18),
                        ),
                        const SizedBox(height: 2),
                        // ShaderMask(
                        //   shaderCallback:
                        //       (bounds) => LinearGradient(
                        //         colors: [
                        //           AppColors.primary.withValues(alpha: 0.9),
                        //           AppColors.primary.withValues(alpha: 0.7),
                        //         ],
                        //       ).createShader(bounds),
                        //   child: Text(
                        //     LocaleKeys.scroll_to_see_more.tr(),
                        //     style: TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 9.5,
                        //       fontWeight: FontWeight.w600,
                        //       letterSpacing: 0.3,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

// // Performance-optimized version for lower-end devices
// class AnimatedScrollHintLite extends StatefulWidget {
//   const AnimatedScrollHintLite({super.key});

//   @override
//   State<AnimatedScrollHintLite> createState() => _AnimatedScrollHintLiteState();
// }

// class _AnimatedScrollHintLiteState extends State<AnimatedScrollHintLite> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _bounceAnimation;
//   late Animation<double> _opacityAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);

//     _bounceAnimation = Tween<double>(
//       begin: 0.0,
//       end: 8.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeInOutSine)));

//     _opacityAnimation = Tween<double>(
//       begin: 0.4,
//       end: 0.7,
//     ).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeInOut)));

//     _controller.repeat(reverse: true);

//     Future.delayed(const Duration(seconds: 6), () {
//       if (mounted) _controller.stop();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: Offset(0, _bounceAnimation.value),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               color: AppColors.primary.withValues(alpha: 0.12),
//               border: Border.all(color: AppColors.primary.withValues(alpha: _opacityAnimation.value * 0.5), width: 0.8),
//               boxShadow: [
//                 BoxShadow(color: AppColors.primary.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2)),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   Icons.keyboard_double_arrow_down,
//                   color: AppColors.primary.withValues(alpha: _opacityAnimation.value),
//                   size: 18,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   LocaleKeys.scroll_to_see_more.tr(),
//                   style: TextStyle(
//                     color: AppColors.primary.withValues(alpha: _opacityAnimation.value),
//                     fontSize: 9.5,
//                     fontWeight: FontWeight.w600,
//                     letterSpacing: 0.3,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
// }
