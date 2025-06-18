import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/text_style_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';

class ResendOtpWidget extends StatefulWidget {
  final String phone;
  final VoidCallback? onResend;

  const ResendOtpWidget({super.key, required this.phone, this.onResend});

  @override
  State<ResendOtpWidget> createState() => _ResendOtpWidgetState();
}

class _ResendOtpWidgetState extends State<ResendOtpWidget> {
  late Timer _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _secondsRemaining = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _handleResend() {
    if (_canResend) {
      widget.onResend?.call();
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LocaleKeys.didnt_receive_code.tr(),
          style: context.bodyMedium.s14.regular,
        ),
        if (!_canResend)
          Text(
            ' (${_secondsRemaining}s)',
            style: context.bodyMedium.s14.regular,
          ),
        if (_canResend)
          Text(LocaleKeys.resend.tr()).clickable(
            onTap: _handleResend,
            padding: 8.0.edgeInsetsAll,
            style: context.titleLarge.s14.bold.copyWith(
              color: AppColors.secondary,
            ),
          ),
      ],
    );
  }
}
