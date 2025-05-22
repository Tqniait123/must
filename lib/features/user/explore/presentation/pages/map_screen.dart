import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/features/user/home/data/models/parking_model.dart';
import 'package:permission_handler/permission_handler.dart'
    hide PermissionStatus;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Parking> _parkings = [];
  bool _isLoading = true;
  Parking? _selectedParking;
  LatLng? _currentLocation;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _simulateLoadingAndFetch();
    _checkPermissionsAndGetLocation();
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    // First check current permission status
    final status = await Permission.location.status;

    if (status.isGranted) {
      // Permission already granted, get location
      await _getCurrentLocation();
    } else if (status.isDenied) {
      // Permission denied but not permanently, request it
      final newStatus = await Permission.location.request();

      if (newStatus.isGranted) {
        await _getCurrentLocation();
      } else if (newStatus.isPermanentlyDenied) {
        _showPermissionPermanentlyDeniedDialog();
      } else {
        _showPermissionDeniedDialog();
      }
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, show settings dialog
      _showPermissionPermanentlyDeniedDialog();
    } else if (status.isRestricted) {
      // Permission restricted (iOS)
      _showPermissionRestrictedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'This app needs location permission to show your current position on the map.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _checkPermissionsAndGetLocation(); // Retry permission request
                },
                child: const Text('Retry'),
              ),
            ],
          ),
    );
  }

  void _showPermissionPermanentlyDeniedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'Location permission has been permanently denied. Please enable it in app settings to use this feature.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  void _showPermissionRestrictedDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Access Restricted'),
            content: const Text(
              'Location access is restricted on this device. Please check your device settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location service is enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Location service is disabled. Please enable it in device settings.',
                ),
              ),
            );
          }
          return;
        }
      }

      // Check location permission using the location package as well
      PermissionStatus locationPermission = await _location.hasPermission();
      if (locationPermission == PermissionStatus.denied) {
        locationPermission = await _location.requestPermission();
        if (locationPermission != PermissionStatus.granted) {
          return;
        }
      }

      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: ${e.toString()}')),
        );
      }
    }
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
                      initialCenter:
                          _currentLocation ?? LatLng(30.0444, 31.2357),
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
                        markers: [
                          if (_currentLocation != null)
                            Marker(
                              rotate: false,
                              width: 100.0,
                              height: 100.0,
                              point: _currentLocation!,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.directions_car,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  CustomPaint(
                                    size: const Size(14, 8),
                                    painter: _TrianglePainter(
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ..._parkings.map((parking) {
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
                                        borderRadius: BorderRadius.circular(10),
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
                          }),
                        ],
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
              color: const Color(0xffEAEAF3),
              iconAsset: AppIcons.currentLocationIc,
              onPressed: _checkPermissionsAndGetLocation,
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
    path.moveTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
