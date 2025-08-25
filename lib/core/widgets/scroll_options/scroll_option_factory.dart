// lib/core/widgets/scroll_options/scroll_option_factory.dart

import 'package:flutter/material.dart';
import 'package:must_invest/core/enums/scroll_ux_option.dart';

import 'animated_hints_option.dart';
import 'enhanced_with_fades_option.dart';
import 'floating_indicator_option.dart';
import 'page_view_option.dart';
import 'peek_effect_option.dart';
import 'smart_height_option.dart';

class ScrollOptionFactory {
  static Widget create({
    required ScrollUXOption option,
    required dynamic state,
    required RefreshCallback onRefresh,
    double? height,
  }) {
    switch (option) {
      case ScrollUXOption.enhancedWithFades:
        return EnhancedWithFadesOption(state: state, onRefresh: onRefresh, height: height);
      case ScrollUXOption.floatingIndicator:
        return FloatingIndicatorOption(state: state, onRefresh: onRefresh, height: height);
      case ScrollUXOption.peekEffect:
        return PeekEffectOption(state: state, onRefresh: onRefresh, height: height);
      case ScrollUXOption.animatedHints:
        return AnimatedHintsOption(state: state, onRefresh: onRefresh, height: height);
      case ScrollUXOption.smartHeight:
        return SmartHeightOption(state: state, onRefresh: onRefresh, height: height);
      case ScrollUXOption.pageView:
        return PageViewOption(state: state, onRefresh: onRefresh, height: height);
    }
  }
}
