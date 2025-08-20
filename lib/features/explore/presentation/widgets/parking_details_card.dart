import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/features/explore/data/models/parking.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/features/explore/presentation/widgets/custom_clipper.dart';

class ParkingDetailsCard extends StatelessWidget {
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final String currentLocationName;
  final Parking parking;
  final bool isNavigating;
  final bool isLoadingRoute;
  final VoidCallback onStartNavigation;
  final VoidCallback onStopNavigation;

  const ParkingDetailsCard({
    super.key,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.parking,
    required this.isNavigating,
    required this.isLoadingRoute,
    required this.onStartNavigation,
    required this.onStopNavigation,
    required this.currentLocationName,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: ClipPath(
            clipper: CurveCustomClipper(isReversed: true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey.shade50],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                parking.nameAr,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                parking.address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  // _infoChip(
                                  //   icon: Icons.access_time,
                                  //   text: '${parking.distanceInMinutes} ${LocaleKeys.minutes.tr()}',
                                  //   background: Colors.blue.shade50,
                                  //   iconColor: Colors.blue.shade600,
                                  //   textColor: Colors.blue.shade700,
                                  // ),
                                  const SizedBox(width: 8),
                                  _infoChip(
                                    icon: Icons.attach_money,
                                    text: '${parking.pricePerHour} ${LocaleKeys.egp_per_hour.tr()}',
                                    background: Colors.green.shade50,
                                    iconColor: Colors.green.shade600,
                                    textColor: Colors.green.shade700,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //     horizontal: 16,
                        //     vertical: 8,
                        //   ),
                        //   decoration: BoxDecoration(
                        //     color: parking.isBusy ? Colors.red : Colors.green,
                        //     borderRadius: BorderRadius.circular(25),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: (parking.isBusy
                        //                 ? Colors.red
                        //                 : Colors.green)
                        //             .withOpacity(0.3),
                        //         blurRadius: 8,
                        //         offset: const Offset(0, 4),
                        //       ),
                        //     ],
                        //   ),
                        //   child: Text(
                        //     parking.isBusy ? LocaleKeys.busy.tr() : LocaleKeys.available.tr(),
                        //     style: const TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    20.gap,
                    CustomElevatedButton(
                      title: isNavigating ? LocaleKeys.stop_navigation.tr() : LocaleKeys.start_navigation.tr(),
                      onPressed:
                          isLoadingRoute
                              ? null
                              : (isNavigating
                                  ? onStopNavigation
                                  : onStartNavigation),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String text,
    required Color background,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
