import 'dart:async';

import 'package:flutter/material.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration pauseDuration;
  final Duration scrollDuration;

  const ScrollingText(
    this.text, {
    super.key,
    required this.style,
    this.pauseDuration = const Duration(seconds: 1),
    this.scrollDuration = const Duration(seconds: 3),
  });

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  Timer? _timer;
  bool _isScrollNeeded = false;
  final GlobalKey _textKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Delay the check to ensure the widget is built and measured
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfScrollingNeeded();
    });
  }

  void _checkIfScrollingNeeded() {
    final RenderBox? renderBox =
        _textKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      final textWidth = renderBox.size.width;
      final containerWidth = context.size?.width ?? 0;

      if (textWidth > containerWidth) {
        setState(() {
          _isScrollNeeded = true;
        });

        // Start scrolling animation after a delay
        _startScrolling();
      }
    }
  }

  void _startScrolling() {
    _timer?.cancel();
    _timer = Timer(widget.pauseDuration, () {
      if (!mounted) return;

      final RenderBox? renderBox =
          _textKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return;

      final textWidth = renderBox.size.width;
      final containerWidth = context.size?.width ?? 0;

      if (textWidth <= containerWidth) return;

      // Calculate how far to scroll
      final maxScrollExtent = textWidth - containerWidth;

      // Animate scrolling to the end
      _scrollController
          .animateTo(
            maxScrollExtent,
            duration: widget.scrollDuration,
            curve: Curves.easeInOut,
          )
          .then((_) {
            // Pause at the end
            return Future.delayed(widget.pauseDuration);
          })
          .then((_) {
            if (!mounted) return;

            // Animate scrolling back to the start
            _scrollController
                .animateTo(
                  0,
                  duration: widget.scrollDuration,
                  curve: Curves.easeInOut,
                )
                .then((_) {
                  // Pause at the start before repeating
                  if (mounted) {
                    _startScrolling();
                  }
                });
          });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      controller: _scrollController,
      child: Text(widget.text, key: _textKey, style: widget.style),
    );
  }
}
