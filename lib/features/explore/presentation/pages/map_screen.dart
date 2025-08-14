import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' hide PermissionStatus;
import 'package:must_invest/core/extensions/string_extensions.dart';
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
import 'package:url_launcher/url_launcher.dart';

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
    _fetchParkingsData();
  }

  void _fetchParkingsData() {
    final exploreCubit = ExploreCubit.get(context);
    exploreCubit.getAllParkings();
  }

  void _refreshData() {
    _fetchParkingsData();
  }

  Widget _getTileLayer() {
    return TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.mustinvest.app',
      maxZoom: 18,
      maxNativeZoom: 19,
    );
  }

  Color _getMarkerColor(bool isBusy) {
    return isBusy ? Colors.red : Colors.green;
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    final status = await Permission.location.status;

    if (status.isGranted) {
      await _getCurrentLocation();
    } else if (status.isDenied) {
      final newStatus = await Permission.location.request();
      if (newStatus.isGranted) {
        await _getCurrentLocation();
      } else if (newStatus.isPermanentlyDenied) {
        _showPermissionPermanentlyDeniedDialog();
      } else {
        _showPermissionDeniedDialog();
      }
    } else if (status.isPermanentlyDenied) {
      _showPermissionPermanentlyDeniedDialog();
    } else if (status.isRestricted) {
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
                  _checkPermissionsAndGetLocation();
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
            maxZoom: 18.0,
            minZoom: 3.0,
          ),
          children: [
            _getTileLayer(),
            MarkerLayer(
              markers: [
                if (_currentLocation != null)
                  Marker(
                    width: 120.0,
                    height: 120.0,
                    point: _currentLocation!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.my_location, color: Colors.white, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'You',
                                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        CustomPaint(size: const Size(16, 10), painter: _TrianglePainter(color: Colors.blue)),
                      ],
                    ),
                  ),

                ...parkings.map((parking) {
                  return Marker(
                    width: 120.0,
                    height: 120.0,
                    point: LatLng(parking.lat.toDouble(), parking.lng.toDouble()),
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
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getMarkerColor(parking.isBusy),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  parking.pricePerHour,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Icon(parking.isBusy ? Icons.block : Icons.local_parking, color: Colors.white, size: 16),
                              ],
                            ),
                          ),
                          CustomPaint(
                            size: const Size(16, 10),
                            painter: _TrianglePainter(color: _getMarkerColor(parking.isBusy)),
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

        Positioned(
          top: 50,
          right: 16,
          child: FloatingActionButton.small(
            heroTag: "refresh",
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
          if (state is ParkingsError) {
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
                color: Colors.black.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
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
                        const SizedBox(height: 6),
                        Text(
                          parking.address,
                          style: TextStyle(fontSize: 14, color: AppColors.primary.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            parking.isBusy
                                ? [Colors.red.shade400, Colors.red.shade600]
                                : [Colors.green.shade400, Colors.green.shade600],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      parking.isBusy ? 'FULL' : 'AVAILABLE',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: parking.gallery.gallery.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        parking.gallery.gallery[index].image,
                        width: 140,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 140,
                            height: 90,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.grey.shade300, Colors.grey.shade400]),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 30),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              CustomElevatedButton(
                isDisabled: _selectedParking?.isBusy ?? false,
                title: _selectedParking?.isBusy == true ? 'Parking Full' : LocaleKeys.start_now.tr(),
                onPressed:
                    _selectedParking?.isBusy == true
                        ? null
                        : () {
                          openGoogleMapsRoute(_selectedParking!.lat.toDouble(), _selectedParking!.lng.toDouble());
                        },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> openGoogleMapsRoute(double lat, double lng) async {
    final Uri googleMapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    // جرب launchUrl باستخدام LaunchMode.externalApplication
    if (!await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Google Maps');
    }
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
