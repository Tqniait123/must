import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:must_invest/core/theme/colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: SpinKitWave(
          key: ValueKey('loading'),
          color: AppColors.primary,
          size: 20,
          type: SpinKitWaveType.start,
        ),
      ),
    );
  }
}
