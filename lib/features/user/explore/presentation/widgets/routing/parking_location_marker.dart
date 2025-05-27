import 'package:flutter/material.dart';
import 'package:must_invest/core/theme/colors.dart'; // Make sure to import your colors
import 'package:must_invest/features/user/home/data/models/parking_model.dart';

class ParkingLocationMarker extends StatelessWidget {
  final Parking parking;

  const ParkingLocationMarker({super.key, required this.parking});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pin shadow
        Transform.translate(
          offset: const Offset(0, 15),
          child: Container(
            width: 20,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        // Pin point
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pin head
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.local_parking_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            // Pin needle
            Container(
              width: 4,
              height: 25,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(2),
                ),
              ),
            ),
          ],
        ),
        // Status indicator
        Positioned(
          top: 2,
          right: 2,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: parking.isBusy ? Colors.red : Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              parking.isBusy ? Icons.close : Icons.check,
              color: Colors.white,
              size: 8,
            ),
          ),
        ),
      ],
    );
  }
}
