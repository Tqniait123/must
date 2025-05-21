import 'package:flutter/material.dart';

void dismissKeyboard() {
  final focus = FocusManager.instance.primaryFocus;
  if (focus != null) focus.unfocus();
}
