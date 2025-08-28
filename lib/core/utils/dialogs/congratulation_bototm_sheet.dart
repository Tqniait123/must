import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';

class CongratulationsBottomSheet extends StatelessWidget {
  final String message;
  final int points;
  final VoidCallback? onContinue;

  const CongratulationsBottomSheet({super.key, required this.message, required this.points, this.onContinue});

  static void show(BuildContext context, {required String message, required int points, VoidCallback? onContinue}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (context) => CongratulationsBottomSheet(message: message, points: points, onContinue: onContinue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              children: [
                // Success Icon with Points
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 40),
                ),
                24.gap,

                // Points Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.amber.shade400, Colors.amber.shade600]),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.amber.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded, color: Colors.white, size: 18),
                      6.gap,
                      Text(
                        '+$points ${LocaleKeys.points.tr()}',
                        style: context.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                20.gap,

                // Success Message
                Text(
                  LocaleKeys.congratulations.tr(),
                  style: context.titleLarge.copyWith(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                8.gap,

                Text(
                  message,
                  style: context.bodyMedium.copyWith(fontSize: 14, color: Colors.grey.shade600, height: 1.4),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Action Button
          Container(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
              ],
            ),
            child: SafeArea(
              child: CustomElevatedButton(
                title: LocaleKeys.continue_to_home.tr(),
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  if (onContinue != null) {
                    onContinue!();
                  } else {
                    context.go(Routes.homeUser);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
