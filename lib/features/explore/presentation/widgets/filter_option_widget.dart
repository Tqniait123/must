import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/features/explore/presentation/widgets/custom_clipper.dart';

class FilterOptionWidget extends StatefulWidget {
  final String title;
  final int id;
  final bool isSelected;

  const FilterOptionWidget({
    super.key,
    required this.title,
    required this.id,
    required this.isSelected,
  });

  @override
  State createState() => _FilterOptionWidgetState();
}

class _FilterOptionWidgetState extends State<FilterOptionWidget> {
  final GlobalKey _containerKey = GlobalKey();
  double _containerWidth = 0;

  @override
  void initState() {
    super.initState();
    // Schedule a post-frame callback to measure the container
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureContainer();
    });
  }

  @override
  void didUpdateWidget(FilterOptionWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-measure if the widget is updated
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureContainer();
    });
  }

  void _measureContainer() {
    if (_containerKey.currentContext != null) {
      final RenderBox box =
          _containerKey.currentContext!.findRenderObject() as RenderBox;
      if (mounted && box.hasSize) {
        setState(() {
          _containerWidth = box.size.width;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Using Stack to overlap the triangle with the container
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Main container
              ClipPath(
                clipper: CurveCustomClipper(),
                child: CustomPaint(
                  // size: Size(_containerWidth, 100),
                  // painter: RPSCustomPainter(isSelected: widget.isSelected),
                  // clipper: CurveClipper(),
                  child: AnimatedContainer(
                    key: _containerKey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    decoration: BoxDecoration(
                      color:
                          widget.isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    duration: const Duration(milliseconds: 300),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
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
                        5.gap,
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color:
                                widget.isSelected
                                    ? AppColors.white
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        5.gap,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          10.gap,
        ],
      ),
    );
  }
}
