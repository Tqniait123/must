import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' hide PermissionStatus, LocationAccuracy;
import 'package:must_invest/core/extensions/string_extensions.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
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

  // Route management
  List<LatLng> _routePoints = [];
  bool _isRouteLoading = false;
  bool _showRoute = false;
  RouteInfo? _currentRouteInfo;

  // UI State
  bool _showRouteDetails = false;

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

  // Distance calculation using Haversine formula
  double _calculateDistance(LatLng start, LatLng end) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double lat1Rad = start.latitude * pi / 180;
    double lat2Rad = end.latitude * pi / 180;
    double deltaLatRad = (end.latitude - start.latitude) * pi / 180;
    double deltaLngRad = (end.longitude - start.longitude) * pi / 180;

    double a =
        sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLngRad / 2) * sin(deltaLngRad / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  // Get route from OSRM API
  Future<void> _getRouteFromOSRM(LatLng start, LatLng end) async {
    setState(() {
      _isRouteLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};'
          '${end.longitude},${end.latitude}?overview=full&geometries=geojson&steps=true',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0];
        final geometry = route['geometry'];

        if (geometry != null && geometry['coordinates'] != null) {
          final routePoints =
              (geometry['coordinates'] as List)
                  .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
                  .toList();

          final distance = (route['distance'] as num).toDouble() / 1000; // Convert to km
          final duration = (route['duration'] as num).toDouble() / 60; // Convert to minutes

          setState(() {
            _routePoints = routePoints;
            _currentRouteInfo = RouteInfo(
              distance: distance,
              duration: duration,
              estimatedCost: _calculateEstimatedCost(distance, duration),
            );
            _isRouteLoading = false;
            _showRoute = true;
          });
        }
      } else {
        // Fallback to straight line
        _createStraightLineRoute(start, end);
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
      // Fallback to straight line
      _createStraightLineRoute(start, end);
    }
  }

  void _createStraightLineRoute(LatLng start, LatLng end) {
    final distance = _calculateDistance(start, end);
    final estimatedDuration = distance * 2; // Rough estimate: 2 minutes per km

    setState(() {
      _routePoints = [start, end];
      _currentRouteInfo = RouteInfo(
        distance: distance,
        duration: estimatedDuration,
        estimatedCost: _calculateEstimatedCost(distance, estimatedDuration),
      );
      _isRouteLoading = false;
      _showRoute = true;
    });
  }

  double _calculateEstimatedCost(double distanceKm, double durationMinutes) {
    // Simple cost calculation - you can adjust this logic
    return (distanceKm * 10) + (durationMinutes * 2);
  }

  void _clearRoute() {
    setState(() {
      _routePoints = [];
      _showRoute = false;
      _currentRouteInfo = null;
      _showRouteDetails = false;
    });
  }

  void _showRouteToParking() {
    if (_currentLocation != null && _selectedParking != null) {
      final parkingLocation = LatLng(_selectedParking!.lat.toDouble(), _selectedParking!.lng.toDouble());
      _getRouteFromOSRM(_currentLocation!, parkingLocation);
      setState(() {
        _showRouteDetails = true;
      });
    }
  }

  String _formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).toInt()}m';
    } else {
      return '${distance.toStringAsFixed(1)}km';
    }
  }

  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.toInt()}min';
    } else {
      final hours = minutes / 60;
      return '${hours.toStringAsFixed(1)}h';
    }
  }

  // Check if parking has tags
  bool _isMostPopular(Parking parking) {
    return parking.mostPopular.toLowerCase() == 'yes';
  }

  bool _isMostWanted(Parking parking) {
    return parking.mostWanted.toLowerCase() == 'yes';
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationServiceDisabledDialog();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDeniedDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionPermanentlyDeniedDialog();
      return;
    }

    await _getCurrentLocation();
  }

  void _showLocationServiceDisabledDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Service Disabled'),
            content: const Text('Please enable location services on your device.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Geolocator.openLocationSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not get current location')));
      }
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

            // Route polyline layer
            if (_showRoute && _routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                    borderStrokeWidth: 2.0,
                    borderColor: Colors.white,
                  ),
                ],
              ),

            MarkerLayer(
              markers: [
                // Current location marker
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

                // Parking markers
                ...parkings.map((parking) {
                  final parkingLocation = LatLng(parking.lat.toDouble(), parking.lng.toDouble());
                  final distance =
                      _currentLocation != null ? _calculateDistance(_currentLocation!, parkingLocation) : 0.0;

                  return Marker(
                    width: 140.0,
                    height: 140.0,
                    point: parkingLocation,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedParking = parking;
                          _clearRoute(); // Clear any existing route
                        });
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Tags container
                          if (_isMostPopular(parking) || _isMostWanted(parking))
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_isMostPopular(parking))
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Popular',
                                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  if (_isMostPopular(parking) && _isMostWanted(parking)) const SizedBox(width: 4),
                                  if (_isMostWanted(parking))
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.purple,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Wanted',
                                        style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                          // Main marker
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _getMarkerColor(parking.isBusy),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  _selectedParking?.id == parking.id ? Border.all(color: Colors.white, width: 3) : null,
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
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_currentLocation != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    _formatDistance(distance),
                                    style: const TextStyle(fontSize: 10, color: Colors.white),
                                  ),
                                ],
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

        // Route loading indicator
        if (_isRouteLoading)
          const Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Calculating route...'),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Parking details panel (using original design)
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

  // Original design parking details with new functionality
  Widget _buildParkingDetails(Parking parking) {
    final distance =
        _currentLocation != null
            ? _calculateDistance(_currentLocation!, LatLng(parking.lat.toDouble(), parking.lng.toDouble()))
            : 0.0;

    return Column(
      children: [
        // Original style navigation buttons
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
              // Header section with distance info
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
                        // NEW: Distance display
                        if (_currentLocation != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '📍 ${_formatDistance(distance)} away',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.primary.withValues(alpha: 0.7),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

              // NEW: Tags row for Most Popular/Most Wanted
              if (_isMostPopular(parking) || _isMostWanted(parking)) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (_isMostPopular(parking))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.orange.shade400, Colors.orange.shade600]),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Most Popular',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    if (_isMostPopular(parking) && _isMostWanted(parking)) const SizedBox(width: 8),
                    if (_isMostWanted(parking))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.purple.shade600]),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Most Wanted',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // NEW: Route information panel (when route is shown)
              if (_showRouteDetails && _currentRouteInfo != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.route, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Text(
                            'Route Information',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(Icons.straighten, _formatDistance(_currentRouteInfo!.distance), 'Distance'),
                          _buildInfoItem(Icons.access_time, _formatDuration(_currentRouteInfo!.duration), 'Duration'),
                          _buildInfoItem(
                            Icons.monetization_on,
                            '${_currentRouteInfo!.estimatedCost.toInt()}pts',
                            'Est. Cost',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Original image gallery (when not showing route)
                SizedBox(
                  height: 90,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: parking.gallery.gallery.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showImageGallery(context, parking.gallery.gallery, index),
                        child: ClipRRect(
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
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Updated button logic with original CustomElevatedButton style
              if (!_showRouteDetails) ...[
                // Show route and details buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        title: 'Show Route',
                        onPressed: _currentLocation != null ? _showRouteToParking : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomElevatedButton(
                        title: 'Details',
                        onPressed: () {
                          // Navigate to parking details screen
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => ParkingDetailsScreen(parking: parking)));
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Start navigation and clear route buttons
                Row(
                  children: [
                    Expanded(
                      child: CustomElevatedButton(
                        isDisabled: parking.isBusy,
                        title: parking.isBusy ? 'Parking Full' : 'Start Navigation',
                        onPressed:
                            parking.isBusy
                                ? null
                                : () => openGoogleMapsRoute(parking.lat.toDouble(), parking.lng.toDouble()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: CustomElevatedButton(title: 'Clear Route', onPressed: _clearRoute)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade600, size: 20),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.blue.shade600)),
      ],
    );
  }

  void _showImageGallery(BuildContext context, List<dynamic> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ImageGalleryScreen(
              images: images.map((img) => img.image.toString()).toList(),
              initialIndex: initialIndex,
            ),
      ),
    );
  }

  Future<void> openGoogleMapsRoute(double lat, double lng) async {
    final Uri googleMapsUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    if (!await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch Google Maps');
    }
  }
}

// Route information model
class RouteInfo {
  final double distance; // in km
  final double duration; // in minutes
  final double estimatedCost; // in points

  RouteInfo({required this.distance, required this.duration, required this.estimatedCost});
}

// Triangle painter for map markers
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

// Full screen image gallery
class ImageGalleryScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageGalleryScreen({super.key, required this.images, required this.initialIndex});

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image page view
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade800,
                        child: const Center(child: Icon(Icons.image_not_supported, color: Colors.white, size: 64)),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value:
                              loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),

          // Close button
          Positioned(
            top: 50,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),

          // Image counter
          if (widget.images.length > 1)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),

          // Navigation arrows for multiple images
          if (widget.images.length > 1) ...[
            // Previous button
            if (_currentIndex > 0)
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),

            // Next button
            if (_currentIndex < widget.images.length - 1)
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
