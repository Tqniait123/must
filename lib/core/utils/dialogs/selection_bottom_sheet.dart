import 'package:flutter/material.dart';

Future<T?> showSelectionBottomSheet<T>(
  BuildContext context, {
  required List<T> items,
  String Function(T)? itemLabelBuilder,
  Widget Function(T)? itemBuilder, // Custom widget builder for more flexibility
  void Function(T)? onSelect,
  String? title,
  EdgeInsets? padding,
  double maxHeight = 0.7, // Max height as fraction of screen
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder:
        (context) => _SelectionBottomSheet<T>(
          items: items,
          itemLabelBuilder: itemLabelBuilder,
          itemBuilder: itemBuilder,
          onSelect: onSelect,
          title: title,
          padding: padding,
          maxHeight: maxHeight,
        ),
  );
}

class _SelectionBottomSheet<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T)? itemLabelBuilder;
  final Widget Function(T)? itemBuilder;
  final void Function(T)? onSelect;
  final String? title;
  final EdgeInsets? padding;
  final double maxHeight;

  const _SelectionBottomSheet({
    required this.items,
    this.itemLabelBuilder,
    this.itemBuilder,
    this.onSelect,
    this.title,
    this.padding,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * maxHeight),
      margin: const EdgeInsets.only(top: 60), // Safe area consideration
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title if provided
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                title!,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Divider(
              height: 1,
              color: colorScheme.outlineVariant.withOpacity(0.5),
            ),
          ],

          // Items list
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: padding ?? const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      onSelect?.call(item);
                      Navigator.of(context).pop(item);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: colorScheme.outlineVariant.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child:
                          itemBuilder?.call(item) ??
                          Text(
                            itemLabelBuilder?.call(item) ?? item.toString(),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                          ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}
