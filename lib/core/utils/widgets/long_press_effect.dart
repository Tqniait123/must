import 'package:flutter/material.dart';

class PressEffectWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Duration duration;

  const PressEffectWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<PressEffectWrapper> createState() => _PressEffectWrapperState();
}

class _PressEffectWrapperState extends State<PressEffectWrapper> {
  double _scale = 1.0;
  double _opacity = 1.0;

  void _onTapDown() {
    setState(() {
      _scale = 0.92;
      _opacity = 0.6;
    });
  }

  void _onTapUp() {
    setState(() {
      _scale = 1.0;
      _opacity = 1.0;
    });
  }

  void _onTapCancel() {
    _onTapUp();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? widget.onLongPress,
      onLongPress: widget.onLongPress ?? widget.onTap,
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: widget.duration,
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: widget.duration,
          child: widget.child,
        ),
      ),
    );
  }
}

extension PressEffect on Widget {
  Widget withPressEffect({VoidCallback? onTap, VoidCallback? onLongPress}) {
    return PressEffectWrapper(
      onTap: onTap,
      onLongPress: onLongPress,
      child: this,
    );
  }
}
