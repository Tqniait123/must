import 'package:flutter/material.dart';

void showChoicesBottomSheet<T>(
  BuildContext context, {
  required List<T> choices,
  required String Function(T) getName,
  required int Function(T) getId,
  required Function(int id, String name) onSelect,
}) {
  showModalBottomSheet(
    showDragHandle: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Column(
            children: choices
                .map(
                  (choice) => Column(
                    children: [
                      ListTile(
                        title: Center(
                          child: Text(
                            getName(choice),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        onTap: () {
                          final id = getId(choice);
                          final name = getName(choice);
                          onSelect(id, name);
                          Navigator.pop(context);
                        },
                      ),
                      Divider(
                        height: 1,
                        indent: 30,
                        endIndent: 30,
                        color: Colors.grey.withOpacity(0.3),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      );
    },
  );
}
