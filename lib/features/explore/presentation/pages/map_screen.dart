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

enum MapType { satellite, streetMap, darkMode, terrain, artistic }

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Parking? _selectedParking;
  LatLng? _currentLocation;
  final Location _location = Location();
  MapType _currentMapType = MapType.satellite; // Default to beautiful satellite view
  bool _showMapTypeSelector = false;

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

  // Map tile configurations for different beautiful map types
  Widget _getTileLayer() {
    switch (_currentMapType) {
      case MapType.satellite:
        // ESRI World Imagery - Beautiful satellite view
        return TileLayer(
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.mustinvest.app',
          maxZoom: 18,
          maxNativeZoom: 19,
          retinaMode: true,
        );

      case MapType.streetMap:
        // ESRI World Street Map - Clean, professional street map
        return TileLayer(
          urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.mustinvest.app',
          maxZoom: 18,
          maxNativeZoom: 19,
          retinaMode: true,
        );

      case MapType.darkMode:
        // CartoDB Dark Matter - Sleek dark theme
        return TileLayer(
          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.mustinvest.app',
          maxZoom: 18,
          maxNativeZoom: 19,
          retinaMode: true,
        );

      case MapType.terrain:
        // OpenTopoMap - Beautiful topographic view
        return TileLayer(
          urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.mustinvest.app',
          maxZoom: 17,
          maxNativeZoom: 17,
          retinaMode: true,
        );

      case MapType.artistic:
        // Stamen Watercolor - Artistic, unique style
        return TileLayer(
          urlTemplate: 'https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.mustinvest.app',
          maxZoom: 16,
          maxNativeZoom: 16,
          retinaMode: true,
        );
    }
  }

  Widget _getAttributionWidget() {
    switch (_currentMapType) {
      case MapType.satellite:
      case MapType.streetMap:
        return RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© Esri', onTap: () {}),
            TextSourceAttribution('© World Imagery', onTap: () {}),
          ],
        );
      case MapType.darkMode:
        return RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© OpenStreetMap contributors', onTap: () {}),
            TextSourceAttribution('© CartoDB', onTap: () {}),
          ],
        );
      case MapType.terrain:
        return RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© OpenStreetMap contributors', onTap: () {}),
            TextSourceAttribution('© OpenTopoMap', onTap: () {}),
          ],
        );
      case MapType.artistic:
        return RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© Stamen Design', onTap: () {}),
            TextSourceAttribution('© OpenStreetMap contributors', onTap: () {}),
          ],
        );
    }
  }

  Color _getMarkerColor(bool isBusy) {
    switch (_currentMapType) {
      case MapType.satellite:
        return isBusy ? const Color(0xffFF1744) : const Color(0xff00E676);
      case MapType.darkMode:
        return isBusy ? const Color(0xffFF5252) : const Color(0xff69F0AE);
      case MapType.streetMap:
        return isBusy ? const Color(0xffE60A0E) : const Color(0xff1DD76E);
      case MapType.terrain:
        return isBusy ? const Color(0xffD32F2F) : const Color(0xff388E3C);
      case MapType.artistic:
        return isBusy ? const Color(0xff8E24AA) : const Color(0xff43A047);
    }
  }

  Color _getCurrentLocationMarkerColor() {
    switch (_currentMapType) {
      case MapType.satellite:
        return const Color(0xff2196F3);
      case MapType.darkMode:
        return const Color(0xff64B5F6);
      case MapType.streetMap:
        return const Color(0xff1976D2);
      case MapType.terrain:
        return const Color(0xff0277BD);
      case MapType.artistic:
        return const Color(0xff7B1FA2);
    }
  }

  Widget _buildMapTypeSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 1, blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Map Style', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showMapTypeSelector = false;
                    });
                  },
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...MapType.values.map((mapType) {
            final isSelected = _currentMapType == mapType;
            return ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: 2),
                ),
                child: ClipRRect(borderRadius: BorderRadius.circular(6), child: _getMapTypePreview(mapType)),
              ),
              title: Text(_getMapTypeName(mapType)),
              subtitle: Text(_getMapTypeDescription(mapType)),
              trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blue) : null,
              onTap: () {
                setState(() {
                  _currentMapType = mapType;
                  _showMapTypeSelector = false;
                });
              },
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _getMapTypePreview(MapType mapType) {
    switch (mapType) {
      case MapType.satellite:
        return Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xff4CAF50), Color(0xff2196F3)])),
          child: const Icon(Icons.satellite_alt, color: Colors.white, size: 20),
        );
      case MapType.streetMap:
        return Container(color: const Color(0xffF5F5F5), child: const Icon(Icons.map, color: Colors.grey, size: 20));
      case MapType.darkMode:
        return Container(
          color: const Color(0xff212121),
          child: const Icon(Icons.dark_mode, color: Colors.white, size: 20),
        );
      case MapType.terrain:
        return Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xff8BC34A), Color(0xff795548)])),
          child: const Icon(Icons.terrain, color: Colors.white, size: 20),
        );
      case MapType.artistic:
        return Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xff9C27B0), Color(0xffE91E63)])),
          child: const Icon(Icons.palette, color: Colors.white, size: 20),
        );
    }
  }

  String _getMapTypeName(MapType mapType) {
    switch (mapType) {
      case MapType.satellite:
        return 'Satellite';
      case MapType.streetMap:
        return 'Street Map';
      case MapType.darkMode:
        return 'Dark Mode';
      case MapType.terrain:
        return 'Terrain';
      case MapType.artistic:
        return 'Artistic';
    }
  }

  String _getMapTypeDescription(MapType mapType) {
    switch (mapType) {
      case MapType.satellite:
        return 'High-resolution satellite imagery';
      case MapType.streetMap:
        return 'Clean street map with labels';
      case MapType.darkMode:
        return 'Sleek dark theme for night use';
      case MapType.terrain:
        return 'Topographic view with elevation';
      case MapType.artistic:
        return 'Watercolor artistic style';
    }
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
            keepAlive: true,
            maxZoom: 18.0,
            minZoom: 3.0,
          ),
          children: [
            _getTileLayer(),
            _getAttributionWidget(),
            MarkerLayer(
              rotate: false,
              markers: [
                // Enhanced current location marker
                if (_currentLocation != null)
                  Marker(
                    rotate: false,
                    width: 120.0,
                    height: 120.0,
                    point: _currentLocation!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: _getCurrentLocationMarkerColor(),
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
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.my_location, color: Colors.white, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                'You',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        CustomPaint(
                          size: const Size(16, 10),
                          painter: _TrianglePainter(color: _getCurrentLocationMarkerColor()),
                        ),
                      ],
                    ),
                  ),

                // Enhanced parking markers
                ...parkings.map((parking) {
                  final Random random = Random(parking.hashCode);
                  final double lat = 30.0444 + (random.nextDouble() - 0.5) * 0.1;
                  final double lng = 31.2357 + (random.nextDouble() - 0.5) * 0.1;

                  return Marker(
                    rotate: false,
                    width: 120.0,
                    height: 120.0,
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
                                  '${parking.pricePerHour} EGP',
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

        // Enhanced floating controls
        Positioned(
          top: 50,
          right: 16,
          child: Column(
            children: [
              // Map type selector button
              FloatingActionButton.small(
                heroTag: "mapType",
                onPressed: () {
                  setState(() {
                    _showMapTypeSelector = !_showMapTypeSelector;
                  });
                },
                backgroundColor: Colors.white,
                child: const Icon(Icons.layers, color: Colors.blue),
              ),
              const SizedBox(height: 8),
              // Refresh button
              FloatingActionButton.small(
                heroTag: "refresh",
                onPressed: _refreshData,
                backgroundColor: Colors.white,
                child: const Icon(Icons.refresh, color: Colors.blue),
              ),
            ],
          ),
        ),

        // Map type selector overlay
        if (_showMapTypeSelector) Positioned(top: 50, left: 16, right: 80, child: _buildMapTypeSelector()),

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
