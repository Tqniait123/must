# Scroll Options Architecture

This directory contains reusable scroll option widgets that implement different UX patterns for displaying lists of items.

## Structure

### Base Classes
- **`BaseScrollOption`**: Abstract base class that all scroll options inherit from
- **`ScrollOptionFactory`**: Factory class to create scroll option widgets

### Scroll Options
1. **`EnhancedWithFadesOption`**: List with fade gradients and scrollbar
2. **`FloatingIndicatorOption`**: List with floating scroll indicator
3. **`PeekEffectOption`**: List with partial visibility (peek) effect
4. **`AnimatedHintsOption`**: List with animated scroll hints
5. **`SmartHeightOption`**: List with smart height showing partial next item
6. **`PageViewOption`**: PageView implementation with indicators

### Helper Widgets
- **`ShimmerCard`**: Loading placeholder with shimmer effect
- **`EmptyStateWidget`**: Empty state UI
- **`ErrorStateWidget`**: Error state UI with retry option

## Usage

```dart
// Using the factory
ScrollOptionFactory.create(
  option: ScrollUXOption.enhancedWithFades,
  state: exploreState,
  onRefresh: refreshCallback,
)

// Or directly instantiate
EnhancedWithFadesOption(
  state: exploreState,
  onRefresh: refreshCallback,
  height: 300, // optional custom height
)
```

## Adding New Options

1. Create a new widget extending `BaseScrollOption`
2. Implement the `buildContent` method
3. Add the new option to `ScrollUXOption` enum
4. Update `ScrollOptionFactory.create()` switch statement
5. Export in `index.dart`

## Benefits

- **Modular**: Each scroll option is self-contained
- **Reusable**: Can be used anywhere in the app
- **Type-safe**: Enum-based selection prevents errors
- **Maintainable**: Easy to add/remove/modify options
- **Consistent**: All options follow the same base structure
