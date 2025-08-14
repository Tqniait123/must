import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/num_extension.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/features/explore/data/models/parking.dart';

class ParkingCard extends StatelessWidget {
  final Parking parking;

  const ParkingCard({super.key, required this.parking});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(Routes.parkingDetails, extra: parking);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: const Color(0xFFF4F4FA), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            // Parking Image
            if (parking.gallery.gallery.isNotEmpty)
              Hero(
                tag: '${parking.id}-${parking.gallery.gallery[0].image}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    parking.gallery.gallery[0].image,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        height: 90,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(width: 12),

            // Parking Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    parking.nameEn,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2B3085)),
                  ),
                  const SizedBox(height: 4),

                  // Address
                  Text(
                    parking.address,
                    style: TextStyle(fontSize: 14, color: const Color(0xFF2B3085).withOpacity(0.5)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // if (parking.durationTime != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Flexible(
                          //   child: CustomDetailsInfo(
                          //     title: parking.startPoint ?? '',
                          //   ),
                          // ),
                          // 5.gap,
                          // Flexible(
                          //   child: CustomDetailsInfo(
                          //     title: parking.endPoint ?? '',
                          //   ),
                          // ),
                        ],
                      ),
                      5.gap,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CustomDetailsInfo(
                          //   title: parking.durationTime ?? '',
                          // ),
                          5.gap,
                          // CustomDetailsInfo(
                          //   icon: AppIcons.outlinedPriceIc,
                          //   title: "${parking.pricePerHour}  = ${parking.points} ${LocaleKeys.points.tr()}",
                          // ),
                        ],
                      ),
                    ],
                  ),
                  // ] else ...[
                  // Price per hour
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: parking.pricePerHour,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2B3085),
                              ),
                            ),
                            TextSpan(
                              text: "/${LocaleKeys.hour.tr()}",
                              style: TextStyle(fontSize: 14, color: Color(0xFF2B3085)),
                            ),
                          ],
                        ),
                      ),
                      // const SizedBox(height: 4),
                      // Text(
                      //   "${parking.pricePerHour}  = ${(parking.pricePerHour)} ${LocaleKeys.points.tr()}",
                      //   style: TextStyle(fontSize: 12, color: Color(0xFF2B3085).withOpacity(0.7)),
                      // ),
                    ],
                  ),
                  // ],
                ],
              ),
            ),

            // if (parking.durationTime == null)
            //   // Distance from me
            //   Column(
            //     crossAxisAlignment: CrossAxisAlignment.end,
            //     children: [
            //       Container(
            //         padding: const EdgeInsets.symmetric(
            //           horizontal: 8,
            //           vertical: 4,
            //         ),
            //         decoration: BoxDecoration(
            //           color: const Color(0xFFE2E4FF),
            //           borderRadius: BorderRadius.circular(10),
            //         ),
            //         child: Text(
            //           "${parking.distanceInMinutes} ${LocaleKeys.min.tr()}",
            //           style: const TextStyle(
            //             fontSize: 12,
            //             fontWeight: FontWeight.bold,
            //             color: Color(0xFF2B3085),
            //           ),
            //         ),
            //       ),
            //     ],
            //   ),
          ],
        ),
      ),
    );
  }
}
