import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class AIThinkingWidget extends StatefulWidget {
  final String? searchQuery;
  final bool isNearestSelected;

  const AIThinkingWidget({super.key, this.searchQuery, this.isNearestSelected = false});

  @override
  State<AIThinkingWidget> createState() => _AIThinkingWidgetState();
}

class _AIThinkingWidgetState extends State<AIThinkingWidget> with TickerProviderStateMixin {
  late AnimationController _mainOrb;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _progressController;

  late Animation<double> _orbAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _progressAnimation;

  String _currentThinkingText = "Initializing neural pathways...";
  int _currentStepIndex = 0;
  int _dotCount = 0;
  double _overallProgress = 0.0;

  List<String> get _thinkingSteps {
    if (widget.isNearestSelected) {
      return [
        LocaleKeys.activating_spatial_intelligence.tr(),
        LocaleKeys.processing_geospatial_vectors.tr(),
        LocaleKeys.optimizing_proximity_algorithms.tr(),
        LocaleKeys.computing_route_intelligence.tr(),
        LocaleKeys.synthesizing_location_insights.tr(),
      ];
    } else if (widget.searchQuery?.isNotEmpty == true) {
      return [
        LocaleKeys.parsing_natural_language.tr(),
        LocaleKeys.accessing_knowledge_networks.tr(),
        LocaleKeys.cross_referencing_data_sources.tr(),
        LocaleKeys.applying_contextual_reasoning.tr(),
        LocaleKeys.generating_intelligent_responses.tr(),
      ];
    } else {
      return [
        LocaleKeys.initializing_neural_networks.tr(),
        LocaleKeys.processing_cognitive_patterns.tr(),
        LocaleKeys.analyzing_behavioral_data.tr(),
        LocaleKeys.computing_personalized_insights.tr(),
        LocaleKeys.optimizing_recommendations.tr(),
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _setupAdvancedAnimations();
    _startIntelligentSequence();
    _startTypingAnimation();
  }

  void _setupAdvancedAnimations() {
    // Main orb breathing and morphing
    _mainOrb = AnimationController(duration: const Duration(seconds: 4), vsync: this);
    _orbAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _mainOrb, curve: Curves.easeInOutSine));

    // Pulse rings emanating from center
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));

    // Sophisticated wave patterns
    _waveController = AnimationController(duration: const Duration(seconds: 6), vsync: this);
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));

    // Smooth text transitions
    _textController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeInOutCubic));

    // Intelligent particle system
    _particleController = AnimationController(duration: const Duration(seconds: 12), vsync: this);
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _particleController, curve: Curves.linear));

    // Dynamic glow effects
    _glowController = AnimationController(duration: const Duration(seconds: 3), vsync: this);
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine));

    // Overall progress tracking
    _progressController = AnimationController(duration: const Duration(seconds: 15), vsync: this);
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _progressController, curve: Curves.easeInOutQuart));

    // Start all animations
    _mainOrb.repeat(reverse: true);
    _pulseController.repeat();
    _waveController.repeat();
    _particleController.repeat();
    _glowController.repeat(reverse: true);
    _progressController.forward();
    _textController.forward();
  }

  void _startIntelligentSequence() {
    _updateIntelligentText();
  }

  void _startTypingAnimation() {
    Timer.periodic(const Duration(milliseconds: 300), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _dotCount = (_dotCount + 1) % 4;
        _overallProgress = _progressAnimation.value;
      });
    });
  }

  void _updateIntelligentText() {
    if (!mounted) return;

    _textController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _currentStepIndex = (_currentStepIndex + 1) % _thinkingSteps.length;
          _currentThinkingText = _thinkingSteps[_currentStepIndex];
        });

        _textController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 2500), () {
            _updateIntelligentText();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _mainOrb.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        // gradient: RadialGradient(
        //   center: Alignment.center,
        //   radius: 1.5,
        //   colors:
        //       isDark
        //           ? [const Color(0xFF0B0B0F), const Color(0xFF1A1A2E), const Color(0xFF16213E), const Color(0xFF0F0F23)]
        //           : [
        //             const Color(0xFFFCFCFF),
        //             const Color(0xFFF8FAFF),
        //             const Color(0xFFF0F4FF),
        //             const Color(0xFFE8F0FE),
        //           ],
        // ),
      ),
      child: Stack(
        children: [
          // Advanced particle system
          ..._buildIntelligentParticles(isDark),

          // Ambient lighting effects
          _buildAmbientLighting(isDark),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Main AI consciousness orb
                _buildConsciousnessOrb(isDark),
                const SizedBox(height: 60),

                // Intelligent thinking text
                _buildIntelligentText(isDark),

                const SizedBox(height: 40),

                // Progress indicator
                _buildProgressIndicator(isDark),

                const SizedBox(height: 30),

                // Neural wave patterns
                // _buildNeuralWaves(isDark),
                // const SizedBox(height: 50),

                // AI branding with status
                // _buildAdvancedBranding(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsciousnessOrb(bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([_orbAnimation, _glowAnimation, _pulseAnimation]),
      builder: (context, child) {
        return SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulse rings
              ..._buildPulseRings(isDark),

              // Main consciousness orb
              _buildMainOrb(isDark),

              // Inner energy core
              // _buildEnergyCore(isDark),

              // Floating data points
              // ..._buildDataPoints(isDark),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildPulseRings(bool isDark) {
    return List.generate(3, (index) {
      final delay = index * 0.3;
      final size = 200.0 + (index * 40);
      final opacity = (1.0 - _pulseAnimation.value) * (0.4 - index * 0.1);

      return Transform.scale(
        scale: 0.5 + (_pulseAnimation.value * 1.5),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: (isDark ? const Color(0xFF4F46E5) : const Color(0xFF6366F1)).withOpacity(opacity),
              width: 2,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMainOrb(bool isDark) {
    return Transform.scale(
      scale: 1.0 + (_orbAnimation.value * 0.1),
      child: Container(
        width: 180,
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors:
                isDark
                    ? [
                      const Color(0xFF6366F1).withOpacity(0.8),
                      const Color(0xFF4F46E5).withOpacity(0.6),
                      const Color(0xFF3730A3).withOpacity(0.4),
                      const Color(0xFF1E1B4B).withOpacity(0.2),
                    ]
                    : [
                      const Color(0xFF8B5CF6).withOpacity(0.7),
                      const Color(0xFF6366F1).withOpacity(0.5),
                      const Color(0xFF4F46E5).withOpacity(0.3),
                      const Color(0xFF3730A3).withOpacity(0.1),
                    ],
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? const Color(0xFF4F46E5) : const Color(0xFF6366F1)).withOpacity(
                _glowAnimation.value * 0.5,
              ),
              blurRadius: 40,
              spreadRadius: 10,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(90),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [Colors.white.withOpacity(0.2), Colors.transparent, Colors.white.withOpacity(0.1)]
                          : [Colors.white.withOpacity(0.4), Colors.transparent, Colors.white.withOpacity(0.2)],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnergyCore(bool isDark) {
    return AnimatedBuilder(
      animation: _waveAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: EnergyCoreePainter(progress: _waveAnimation.value, orbProgress: _orbAnimation.value, isDark: isDark),
          size: const Size(180, 180),
        );
      },
    );
  }

  List<Widget> _buildDataPoints(bool isDark) {
    return List.generate(8, (index) {
      final angle = (index * math.pi * 2 / 8) + (_orbAnimation.value * math.pi * 2);
      final radius = 100 + math.sin(_orbAnimation.value * math.pi * 2 + index) * 20;
      final x = 150 + radius * math.cos(angle);
      final y = 150 + radius * math.sin(angle);

      return Positioned(
        left: x - 6,
        top: y - 6,
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDark ? const Color(0xFF06B6D4) : const Color(0xFF0EA5E9)).withOpacity(0.8),
            boxShadow: [
              BoxShadow(
                color: (isDark ? const Color(0xFF06B6D4) : const Color(0xFF0EA5E9)).withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildIntelligentText(bool isDark) {
    final dots = "." * _dotCount;

    return AnimatedBuilder(
      animation: _textFadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _textFadeAnimation.value,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors:
                        isDark
                            ? [const Color(0xFF1F2937).withOpacity(0.8), const Color(0xFF111827).withOpacity(0.6)]
                            : [Colors.white.withOpacity(0.8), const Color(0xFFF9FAFB).withOpacity(0.6)],
                  ),
                  border: Border.all(
                    color: (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)).withOpacity(0.5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(isDark ? 0.3 : 0.1), blurRadius: 20, spreadRadius: 0),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _currentThinkingText + dots,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF1F2937),
                        letterSpacing: 0.3,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Advanced AI • Processing ${(_overallProgress * 100).toInt()}%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: (isDark ? const Color(0xFF06B6D4) : const Color(0xFF0EA5E9)).withOpacity(0.9),
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: 200,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)).withOpacity(0.3),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200 * _progressAnimation.value,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF06B6D4)]),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.4), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeuralWaves(bool isDark) {
    return SizedBox(
      width: 320,
      height: 100,
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: NeuralWavePainter(
              progress: _waveAnimation.value,
              glowIntensity: _glowAnimation.value,
              isDark: isDark,
            ),
            size: const Size(320, 100),
          );
        },
      ),
    );
  }

  Widget _buildAdvancedBranding(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          colors:
              isDark
                  ? [const Color(0xFF1F2937).withOpacity(0.6), const Color(0xFF111827).withOpacity(0.4)]
                  : [Colors.white.withOpacity(0.7), const Color(0xFFF9FAFB).withOpacity(0.5)],
        ),
        border: Border.all(
          color: (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)).withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 15, spreadRadius: 0)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF10B981).withOpacity(_glowAnimation.value),
                      const Color(0xFF059669).withOpacity(_glowAnimation.value * 0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withOpacity(_glowAnimation.value * 0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Text(
            "Powered by Next-Gen AI",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFF3F4F6) : const Color(0xFF374151),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [const Color(0xFF6366F1).withOpacity(0.2), const Color(0xFF8B5CF6).withOpacity(0.2)],
              ),
            ),
            child: Text(
              "GPT-5",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientLighting(bool isDark) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors:
                    isDark
                        ? [const Color(0xFF4F46E5).withOpacity(_glowAnimation.value * 0.1), Colors.transparent]
                        : [const Color(0xFF6366F1).withOpacity(_glowAnimation.value * 0.05), Colors.transparent],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildIntelligentParticles(bool isDark) {
    return List.generate(12, (index) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      return AnimatedBuilder(
        animation: _particleAnimation,
        builder: (context, child) {
          final progress = (_particleAnimation.value + index * 0.08) % 1.0;
          final x = (screenWidth * 0.2) + (screenWidth * 0.6 * math.sin(progress * math.pi * 2 + index));
          final y = (screenHeight * 0.3) + (screenHeight * 0.4 * math.cos(progress * math.pi * 1.5 + index * 0.7));

          final opacity = (math.sin(progress * math.pi * 2) + 1) / 2 * 0.4;
          final size = 8.0 + math.sin(progress * math.pi * 4 + index) * 4;

          return Positioned(
            left: x,
            top: y,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (isDark ? const Color(0xFF06B6D4) : const Color(0xFF0EA5E9)).withOpacity(opacity),
                    (isDark ? const Color(0xFF8B5CF6) : const Color(0xFF6366F1)).withOpacity(opacity * 0.5),
                    Colors.transparent,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? const Color(0xFF06B6D4) : const Color(0xFF0EA5E9)).withOpacity(opacity * 0.6),
                    blurRadius: size * 2,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

// Enhanced energy core painter
class EnergyCoreePainter extends CustomPainter {
  final double progress;
  final double orbProgress;
  final bool isDark;

  EnergyCoreePainter({required this.progress, required this.orbProgress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw flowing energy streams
    for (int i = 0; i < 6; i++) {
      final path = Path();
      final angle = (progress * math.pi * 2) + (i * math.pi * 2 / 6);
      final baseRadius = 25.0;

      for (double t = 0; t <= math.pi * 2; t += 0.05) {
        final radiusVariation = math.sin(t * 4 + angle) * 8;
        final pulseVariation = math.sin(orbProgress * math.pi * 2) * 5;
        final r = baseRadius + radiusVariation + pulseVariation;

        final x = center.dx + r * math.cos(t + angle * 0.5);
        final y = center.dy + r * math.sin(t + angle * 0.5);

        if (t == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();

      // Apply sophisticated gradient
      final colors =
          isDark
              ? [const Color(0xFF6366F1), const Color(0xFF8B5CF6), const Color(0xFF06B6D4), const Color(0xFF10B981)]
              : [const Color(0xFF8B5CF6), const Color(0xFF6366F1), const Color(0xFF0EA5E9), const Color(0xFF059669)];

      paint.shader = ui.Gradient.radial(center, baseRadius + 15, [
        colors[i % colors.length].withOpacity(0.6),
        colors[i % colors.length].withOpacity(0.3),
        colors[i % colors.length].withOpacity(0.1),
        Colors.transparent,
      ]);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Neural wave painter with advanced patterns
class NeuralWavePainter extends CustomPainter {
  final double progress;
  final double glowIntensity;
  final bool isDark;

  NeuralWavePainter({required this.progress, required this.glowIntensity, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2);

    // Draw multiple sophisticated wave layers
    for (int layer = 0; layer < 5; layer++) {
      final path = Path();
      final amplitude = 15.0 - (layer * 2);
      final frequency = 2.0 + layer * 0.3;
      final phase = progress * math.pi * 2 + (layer * math.pi / 3);
      final yCenter = size.height / 2 + (layer - 2) * 8;

      path.moveTo(0, yCenter);

      for (double x = 0; x <= size.width; x += 1) {
        final normalizedX = x / size.width;

        // Complex wave calculation
        final wave1 = amplitude * math.sin(normalizedX * frequency * math.pi * 2 + phase);
        final wave2 = (amplitude * 0.3) * math.sin(normalizedX * frequency * 6 + phase * 1.7);
        final wave3 = (amplitude * 0.15) * math.sin(normalizedX * frequency * 12 + phase * 2.3);

        final y = yCenter + wave1 + wave2 + wave3;
        path.lineTo(x, y);
      }

      // Apply gradient stroke
      final colors =
          isDark
              ? [
                const Color(0xFF6366F1),
                const Color(0xFF8B5CF6),
                const Color(0xFF06B6D4),
                const Color(0xFF10B981),
                const Color(0xFFF59E0B),
              ]
              : [
                const Color(0xFF8B5CF6),
                const Color(0xFF6366F1),
                const Color(0xFF0EA5E9),
                const Color(0xFF059669),
                const Color(0xFFD97706),
              ];

      paint.color = colors[layer].withOpacity(0.6 * glowIntensity);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
