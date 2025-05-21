import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

String currentCurrency(BuildContext context) {
  if (context.locale.toString() == 'en') {
    return 'SAR';
  } else {
    return 'ر.س';
  }
}

String moneyText(BuildContext context, double price) {
  return '${price.toStringAsFixed(2)} ${currentCurrency(context)}';
}
