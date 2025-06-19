import 'package:flutter/material.dart';
import 'package:must_invest/core/theme/colors.dart';

class CustomLoadingWidget extends StatelessWidget {
  final Color? color;
  const CustomLoadingWidget({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.white),
      ),
    );
  }
}
