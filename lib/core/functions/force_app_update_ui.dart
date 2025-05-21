import 'package:flutter/material.dart';

/// The `forceAppUpdate` function in Dart ensures the app is updated by reassembling the Flutter engine.
Future<void> forceAppUpdate() async {
  final engine = WidgetsFlutterBinding.ensureInitialized();
  await engine.performReassemble();
}
