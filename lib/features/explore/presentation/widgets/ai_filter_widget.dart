import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/features/explore/presentation/widgets/custom_clipper.dart';

class AIFilterOptionWidget extends StatefulWidget {
  final String title;
  final int id;
  final bool isSelected;
  final bool isAIThinking;
  final VoidCallback? onTap;

  const AIFilterOptionWidget({
    super.key,
    required this.title,
    required this.id,
    required this.isSelected,
    this.isAIThinking = false,
    this.onTap,
  });

  @override
  State<AIFilterOptionWidget> createState() => _AIFilterOptionWidgetState();
}

class _AIFilterOptionWidgetState extends State<AIFilterOptionWidget> with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _pulseController;
  late AnimationController _thinkingController;
  late AnimationController _sparkleController;

  late Animation<double> _gradientAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _thinkingAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startThinkingSimulation();
  }

  void _setupAnimations() {
    // Gradient animation for AI effect
    _gradientController = AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _gradientAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _gradientController, curve: Curves.easeInOut));

    // Pulse animation for selection
    _pulseController = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Thinking animation
    _thinkingController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _thinkingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _thinkingController, curve: Curves.easeInOut));

    // Sparkle animation
    _sparkleController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut));

    if (widget.isSelected) {
      _gradientController.repeat();
      _pulseController.repeat(reverse: true);
      _sparkleController.repeat();
    }
  }

  void _startThinkingSimulation() {
    if (widget.isAIThinking) {
      _thinkingController.repeat();
    }
  }

  @override
  void didUpdateWidget(AIFilterOptionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _gradientController.repeat();
        _pulseController.repeat(reverse: true);
        _sparkleController.repeat();
      } else {
        _gradientController.stop();
        _pulseController.stop();
        _sparkleController.stop();
      }
    }

    if (widget.isAIThinking != oldWidget.isAIThinking) {
      if (widget.isAIThinking) {
        _thinkingController.repeat();
        _startThinkingSimulation();
      } else {
        _thinkingController.stop();
      }
    }
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    _thinkingController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fixed: Wrap content in Flexible to prevent overflow
            Flexible(
              child: AnimatedBuilder(
                animation: Listenable.merge([
                  _gradientAnimation,
                  _pulseAnimation,
                  _thinkingAnimation,
                  _sparkleAnimation,
                ]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: widget.isSelected ? _pulseAnimation.value : 1.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // AI Glow Effect Background
                        if (widget.isSelected || widget.isAIThinking)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                // Removed problematic BoxShadow
                              ],
                            ),
                            child: const SizedBox(width: 120, height: 100),
                          ),

                        // Main Container with AI Gradient
                        ClipPath(
                          clipper: CurveCustomClipper(),
                          child: Container(
                            width: 120, // Fixed: Explicitly set width
                            height: 70, // Fixed: Explicitly set height
                            decoration: BoxDecoration(
                              gradient: widget.isSelected || widget.isAIThinking ? _buildAIGradient() : null,
                              color: widget.isSelected || widget.isAIThinking ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                // Animated gradient overlay for AI effect
                                if (widget.isSelected || widget.isAIThinking)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.white.withOpacity(0.2),
                                            Colors.transparent,
                                            Colors.white.withOpacity(0.1),
                                          ],
                                          stops:
                                              [
                                                _gradientAnimation.value - 0.3,
                                                _gradientAnimation.value,
                                                _gradientAnimation.value + 0.3,
                                              ].map((e) => e.clamp(0.0, 1.0)).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                // Content - Fixed: Use Positioned.fill to constrain content
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                                      children: [
                                        Flexible(
                                          // Fixed: Make text flexible to prevent overflow
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  widget.title,
                                                  style: context.bodyMedium.s14.regular.copyWith(
                                                    color:
                                                        widget.isSelected
                                                            ? AppColors.white
                                                            : AppColors.primary.withValues(alpha: 0.4),
                                                  ),
                                                  softWrap: true,
                                                  overflow: TextOverflow.visible,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.purple.withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'AI',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: widget.isSelected ? Colors.white : Colors.transparent,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Sparkle Effects
                                if (widget.isSelected && !widget.isAIThinking) ..._buildSparkles(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Fixed: Remove extra SizedBox that could cause overflow
            // const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Gradient _buildAIGradient() {
    if (widget.isAIThinking) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.purple.shade600, Colors.blue.shade600, Colors.cyan.shade500, Colors.purple.shade600],
        stops: [
          (_gradientAnimation.value - 0.3).clamp(0.0, 1.0),
          _gradientAnimation.value.clamp(0.0, 1.0),
          (_gradientAnimation.value + 0.3).clamp(0.0, 1.0),
          (_gradientAnimation.value + 0.6).clamp(0.0, 1.0),
        ],
      );
    } else {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.blue.shade600, Colors.blue.shade700, Colors.indigo.shade600],
      );
    }
  }

  List<Widget> _buildSparkles() {
    return [
      Positioned(
        top: 10 + math.sin(_sparkleAnimation.value * math.pi * 2) * 5,
        right: 15 + math.cos(_sparkleAnimation.value * math.pi * 2) * 3,
        child: Opacity(
          opacity: (math.sin(_sparkleAnimation.value * math.pi * 4) + 1) / 2,
          child: Icon(Icons.auto_awesome, size: 12, color: Colors.white.withOpacity(0.8)),
        ),
      ),
      Positioned(
        bottom: 15 + math.cos(_sparkleAnimation.value * math.pi * 3) * 4,
        left: 10 + math.sin(_sparkleAnimation.value * math.pi * 3) * 2,
        child: Opacity(
          opacity: (math.cos(_sparkleAnimation.value * math.pi * 3) + 1) / 2,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), borderRadius: BorderRadius.circular(3)),
          ),
        ),
      ),
    ];
  }
}
