// lib/core/enums/scroll_ux_option.dart

enum ScrollUXOption {
  enhancedWithFades(1, 'Enhanced with Fades'),
  floatingIndicator(2, 'Floating Indicator'),
  peekEffect(3, 'Peek Effect'),
  animatedHints(4, 'Animated Hints'),
  smartHeight(5, 'Smart Height'),
  pageView(6, 'Page View');

  const ScrollUXOption(this.value, this.label);

  final int value;
  final String label;

  // Get enum by value
  static ScrollUXOption? fromValue(int value) {
    for (ScrollUXOption option in ScrollUXOption.values) {
      if (option.value == value) return option;
    }
    return null;
  }

  // Get all values as list
  static List<int> get allValues => ScrollUXOption.values.map((e) => e.value).toList();
  
  // Get all labels as list
  static List<String> get allLabels => ScrollUXOption.values.map((e) => e.label).toList();
}
