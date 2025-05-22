import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/features/user/home/data/models/parking_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Parking> _parkings = [];
  bool _isLoading = true;
  Parking? _selectedParking;

  @override
  void initState() {
    super.initState();
    _simulateLoadingAndFetch();
  }

  Future<void> _simulateLoadingAndFetch() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _parkings = Parking.getFakeArabicParkingList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(30.0444, 31.2357),
                      initialZoom: 12.0,
                      keepAlive: true,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        rotate: false,
                        markers:
                            _parkings.map((parking) {
                              return Marker(
                                rotate: false,
                                width: 100.0,
                                height: 100.0,
                                point: LatLng(parking.lat, parking.lng),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedParking = parking;
                                    });
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 9,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              parking.isBusy
                                                  ? const Color(0xffE60A0E)
                                                  : const Color(0xff1DD76E),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '${parking.pricePerHour} EGP',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      CustomPaint(
                                        size: const Size(14, 8),
                                        painter: _TrianglePainter(
                                          color:
                                              parking.isBusy
                                                  ? const Color(0xffE60A0E)
                                                  : const Color(0xff1DD76E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                  if (_selectedParking != null)
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: _buildParkingDetails(_selectedParking!),
                    ),
                ],
              ),
    );
  }

  Widget _buildParkingDetails(Parking parking) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomBackButton(),
            CustomIconButton(
              color: Color(0xffEAEAF3),
              iconAsset: AppIcons.currentLocationIc,
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.all(21),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(parking.title, style: context.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        parking.address,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E4FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${parking.distanceInMinutes} ${LocaleKeys.min.tr()}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2B3085),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: parking.gallery.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        parking.gallery[index],
                        width: 129,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              CustomElevatedButton(
                isDisabled: _selectedParking?.isBusy ?? false,
                title: LocaleKeys.start_now.tr(),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill
          ..strokeWidth = 1;

    final path = ui.Path();
    path.moveTo(size.width / 2, size.height); // Start from bottom middle
    path.lineTo(size.width, 0); // Line to top right
    path.lineTo(0, 0); // Line to top left
    path.close(); // Close the path

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
