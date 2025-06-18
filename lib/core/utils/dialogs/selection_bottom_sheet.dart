import 'package:flutter/material.dart';

Future<T?> showSelectionBottomSheet<T>(
  BuildContext context, {
  required List<T> items,
  String Function(T)? itemLabelBuilder, // to customize display of T
  void Function(T)? onSelect,
}) {
  return showModalBottomSheet<T>(
    showDragHandle: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return InkWell(
            onTap: () {
              if (onSelect != null) {
                onSelect(item);
              }
              Navigator.of(context).pop(item);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Text(
                  itemLabelBuilder?.call(item) ?? item.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
