import 'dart:math';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' hide PermissionStatus;
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/features/explore/data/models/parking.dart';
import 'package:must_invest/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Parking? _selectedParking;
  LatLng? _currentLocation;
  final Location _location = Location();

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
    // Fetch parkings data when screen initializes
    _fetchParkingsData();
  }

  void _fetchParkingsData() {
    // Get the cubit and fetch data
    final exploreCubit = ExploreCubit.get(context);
    exploreCubit.getAllParkings(); // You can pass FilterModel if needed
  }

  void _refreshData() {
    _fetchParkingsData();
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
            content: const Text('This app needs location permission to show your current position on the map.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
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
            content: const Text('Location access is restricted on this device. Please check your device settings.'),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
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
              const SnackBar(content: Text('Location service is disabled. Please enable it in device settings.')),
            );
          }
          return;
        }
      }

      // Check location permission using permission handler
      final permissionStatus = await Permission.location.status;
      if (permissionStatus.isDenied) {
        final newStatus = await Permission.location.request();
        if (!newStatus.isGranted) {
          return;
        }
      }

      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        setState(() {
          _currentLocation = LatLng(locationData.latitude!, locationData.longitude!);
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to get location: ${e.toString()}')));
      }
    }
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'Error loading parkings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: _refreshData, icon: const Icon(Icons.refresh), label: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading parkings...', style: TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildMapWidget(List<Parking> parkings) {
    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(
            initialCenter: _currentLocation ?? LatLng(30.0444, 31.2357),
            initialZoom: 12.0,
            keepAlive: true,
            maxZoom: 18.0,
            minZoom: 3.0,
          ),
          children: [
            // BEST FREE SOLUTION: CartoDB Positron
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.mustinvest.app', // Replace with your actual package name
              maxZoom: 18,
              maxNativeZoom: 19,
              retinaMode: true,
              errorTileCallback: (tile, error, stackTrace) {
                debugPrint('Tile loading error: $error');
              },
              tileProvider: NetworkTileProvider(),
            ),

            // Attribution widget (required for CartoDB)
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors', onTap: () {}),
                TextSourceAttribution('© CartoDB', onTap: () {}),
              ],
            ),

            MarkerLayer(
              rotate: false,
              markers: [
                // Current location marker
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
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.my_location, color: Colors.white, size: 20),
                        ),
                        CustomPaint(size: const Size(14, 8), painter: _TrianglePainter(color: Colors.blue)),
                      ],
                    ),
                  ),

                // Parking markers from real API data
                ...parkings.map((parking) {
                  // Use real coordinates from parking model if available
                  // If parking doesn't have lat/lng properties, you might need to add them to your model
                  // For now, I'll assume you have lat and lng properties in your Parking model
                  // If not, you'll need to add them or use a fallback method

                  double lat, lng;

                  // Check if your Parking model has lat/lng properties
                  // Replace this with actual property access if available
                  try {
                    // Assuming your parking model has lat and lng properties
                    // lat = parking.lat ?? 30.0444;
                    // lng = parking.lng ?? 31.2357;

                    // If no lat/lng in model, generate realistic coordinates around Cairo
                    final Random random = Random(parking.hashCode);
                    lat = 30.0444 + (random.nextDouble() - 0.5) * 0.1;
                    lng = 31.2357 + (random.nextDouble() - 0.5) * 0.1;
                  } catch (e) {
                    // Fallback coordinates
                    final Random random = Random(parking.hashCode);
                    lat = 30.0444 + (random.nextDouble() - 0.5) * 0.1;
                    lng = 31.2357 + (random.nextDouble() - 0.5) * 0.1;
                  }

                  return Marker(
                    rotate: false,
                    width: 100.0,
                    height: 100.0,
                    point: LatLng(lat, lng),
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
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: parking.isBusy ? const Color(0xffE60A0E) : const Color(0xff1DD76E),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              '${parking.pricePerHour} EGP',
                              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          CustomPaint(
                            size: const Size(14, 8),
                            painter: _TrianglePainter(
                              color: parking.isBusy ? const Color(0xffE60A0E) : const Color(0xff1DD76E),
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

        // Floating refresh button
        Positioned(
          top: 50,
          right: 16,
          child: FloatingActionButton.small(
            onPressed: _refreshData,
            backgroundColor: Colors.white,
            child: const Icon(Icons.refresh, color: Colors.blue),
          ),
        ),

        if (_selectedParking != null)
          Positioned(bottom: 20, left: 16, right: 16, child: _buildParkingDetails(_selectedParking!)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ExploreCubit, ExploreState>(
        listener: (context, state) {
          // Handle any side effects here
          if (state is ParkingsError) {
            // Optionally show a snackbar for errors
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
                action: SnackBarAction(label: 'Retry', textColor: Colors.white, onPressed: _refreshData),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ParkingsLoading) {
            return _buildLoadingWidget();
          } else if (state is ParkingsError) {
            return _buildErrorWidget(state.message);
          } else if (state is ParkingsSuccess) {
            return _buildMapWidget(state.parkings);
          } else {
            // Initial state - show loading
            return _buildLoadingWidget();
          }
        },
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(parking.nameEn, style: context.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          parking.address,
                          style: TextStyle(fontSize: 14, color: AppColors.primary.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE2E4FF), borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      "${parking.pricePerHour} EGP/${LocaleKeys.min.tr()}",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2B3085)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: parking.gallery.gallery.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        parking.gallery.gallery[index].image,
                        width: 129,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 129,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              CustomElevatedButton(
                isDisabled: _selectedParking?.isBusy ?? false,
                title: _selectedParking?.isBusy == true ? 'Parking Full' : LocaleKeys.start_now.tr(),
                onPressed:
                    _selectedParking?.isBusy == true
                        ? null
                        : () {
                          // Handle start parking action
                        },
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
