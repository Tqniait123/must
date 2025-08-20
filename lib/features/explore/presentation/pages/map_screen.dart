import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' hide PermissionStatus, LocationAccuracy;
import 'package:must_invest/config/routes/routes.dart';
import 'package:must_invest/core/extensions/string_extensions.dart';
import 'package:must_invest/core/extensions/string_to_icon.dart';
import 'package:must_invest/core/extensions/theme_extension.dart';
import 'package:must_invest/core/static/app_assets.dart';
import 'package:must_invest/core/static/icons.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/translations/locale_keys.g.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_elevated_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_icon_button.dart';
import 'package:must_invest/features/auth/data/models/user.dart';
import 'package:must_invest/features/explore/data/models/parking.dart';
import 'package:must_invest/features/explore/presentation/cubit/explore_cubit.dart';
import 'package:must_invest/features/home/presentation/widgets/home_user_header_widget.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
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

  // NEW: Animation and scroll controllers for parking list
  late AnimationController _listAnimationController;
  late Animation<double> _listSlideAnimation;
  final ScrollController _parkingListController = ScrollController();
  final MapController _mapController = MapController();

  // NEW: List view state
  bool _isListExpanded = true;
  double _listHeight = 220.0; // Reduced base height

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
    _fetchParkingsData();

    // NEW: Initialize animation controller
    _listAnimationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _listSlideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _listAnimationController, curve: Curves.easeInOut));

    // Start the animation when screen loads
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    _parkingListController.dispose();
    super.dispose();
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

  // NEW: Navigate to parking from list
  void _navigateToParkingFromList(Parking parking) {
    setState(() {
      if (_selectedParking == null) {
        _isListExpanded = false;
        _listHeight = _isListExpanded ? 220.0 : 160.0;
      } else {
        _selectedParking = null;
        _isListExpanded = true;
        // _clearRoute();
        _listHeight = _isListExpanded ? 220.0 : 160.0;
      }
    });
    final parkingLocation = LatLng(parking.lat.toDouble(), parking.lng.toDouble());

    // Clear any existing route
    _clearRoute();

    // Set selected parking
    // setState(() {
    //   _selectedParking = parking;
    // });

    // Animate map to parking location
    _mapController.move(parkingLocation, 16.0);
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
      return '${(distance * 1000).toInt()}${LocaleKeys.map_unit_meters.tr()}';
    } else {
      return '${distance.toStringAsFixed(1)}${LocaleKeys.map_unit_kilometers.tr()}';
    }
  }

  String _formatDuration(double minutes) {
    if (minutes < 60) {
      return '${minutes.toInt()}${LocaleKeys.map_unit_minutes.tr()}';
    } else {
      final hours = minutes / 60;
      return '${hours.toStringAsFixed(1)}${LocaleKeys.map_unit_hours.tr()}';
    }
  }

  // Check if parking has tags
  bool _isMostPopular(Parking parking) {
    return parking.mostPopular;
  }

  bool _isMostWanted(Parking parking) {
    return parking.mostWanted;
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
            title: Text(LocaleKeys.map_dialog_location_disabled_title.tr()),
            content: Text(LocaleKeys.map_dialog_location_disabled_content.tr()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(LocaleKeys.common_cancel.tr())),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Geolocator.openLocationSettings();
                },
                child: Text(LocaleKeys.common_open_settings.tr()),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(LocaleKeys.map_error_location_failed.tr())));
      }
    }
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(LocaleKeys.map_dialog_permission_required_title.tr()),
            content: Text(LocaleKeys.map_dialog_permission_required_content.tr()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(LocaleKeys.common_cancel.tr())),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _checkPermissionsAndGetLocation();
                },
                child: Text(LocaleKeys.common_retry.tr()),
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
            title: Text(LocaleKeys.map_dialog_permission_required_title.tr()),
            content: Text(LocaleKeys.map_dialog_permission_permanently_denied_content.tr()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(LocaleKeys.common_cancel.tr())),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: Text(LocaleKeys.common_open_settings.tr()),
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
            LocaleKeys.map_error_loading_parkings.tr(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Text(error, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: Text(LocaleKeys.common_retry.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(LocaleKeys.map_loading_parkings.tr(), style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  // NEW: Build parking list widget
  Widget _buildParkingListView(List<Parking> parkings) {
    return AnimatedBuilder(
      animation: _listSlideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _listSlideAnimation.value)),
          child: Opacity(
            opacity: _listSlideAnimation.value,
            child: Container(
              height: _listHeight,
              margin: const EdgeInsets.only(top: 100), // Account for status bar and back button
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,

                children: [
                  // Header with title and expand/collapse button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isListExpanded = !_isListExpanded;
                              _listHeight = _isListExpanded ? 220.0 : 160.0;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isListExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Parking cards list
                  Expanded(
                    child: ListView.separated(
                      controller: _parkingListController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: parkings.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final parking = parkings[index];
                        final distance =
                            _currentLocation != null
                                ? _calculateDistance(
                                  _currentLocation!,
                                  LatLng(parking.lat.toDouble(), parking.lng.toDouble()),
                                )
                                : 0.0;
                        final isSelected = _selectedParking?.id == parking.id;

                        return _buildParkingCard(parking, distance, isSelected, _isListExpanded);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // NEW: Build individual parking card
  Widget _buildParkingCard(Parking parking, double distance, bool isSelected, bool isListExpanded) {
    return GestureDetector(
      onTap: () => _navigateToParkingFromList(parking),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 280,
        margin: EdgeInsets.only(bottom: isSelected ? 4 : 8, top: isSelected ? 4 : 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isSelected
                    ? [AppColors.primary, AppColors.primary.withOpacity(0.8)]
                    : [Colors.white, Colors.grey.shade50],
          ),
          borderRadius: BorderRadius.circular(20),
          border:
              isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : Border.all(color: Colors.grey.shade200, width: 1),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.primary.withOpacity(0.4) : Colors.black.withOpacity(0.1),
              spreadRadius: isSelected ? 3 : 1,
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and tags
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: parking.isBusy ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      parking.isBusy ? LocaleKeys.map_status_full.tr() : LocaleKeys.map_status_available.tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Tags
                  Row(
                    children: [
                      if (_isMostPopular(parking))
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppImages.popular.toImage(width: 12, height: 12),
                        ),
                      if (_isMostPopular(parking) && _isMostWanted(parking)) const SizedBox(width: 4),
                      if (_isMostWanted(parking))
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: AppImages.wanted.toImage(width: 12, height: 12),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Parking name
              Text(
                parking.nameEn,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Address
              if (isListExpanded) ...[
                Text(
                  parking.address,
                  style: TextStyle(fontSize: 12, color: isSelected ? Colors.white70 : Colors.grey.shade600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const Spacer(),

                // Distance and navigation button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentLocation != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on, size: 12, color: isSelected ? Colors.white : AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              _formatDistance(distance),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Navigate button
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.2) : AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.navigation, size: 16, color: isSelected ? Colors.white : Colors.white),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapWidget(List<Parking> parkings) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
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
                    color: AppColors.primary,
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
                    width: 200.0,
                    height: 120.0,
                    point: _currentLocation!,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                              Text(
                                'My Car',
                                style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: AppIcons.carIc.icon(width: 10),
                              ),
                            ],
                          ),
                        ),
                        CustomPaint(size: const Size(16, 10), painter: _TrianglePainter(color: Colors.white)),
                      ],
                    ),
                  ),

                // Parking markers with improved tags design
                ...parkings.map((parking) {
                  final parkingLocation = LatLng(parking.lat.toDouble(), parking.lng.toDouble());
                  final distance =
                      _currentLocation != null ? _calculateDistance(_currentLocation!, parkingLocation) : 0.0;

                  return Marker(
                    width: 200.0,
                    height: 150.0,
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
                          // Enhanced Tags container with better design
                          if (_isMostPopular(parking) || _isMostWanted(parking))
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Most Popular Tag
                                  if (_isMostPopular(parking))
                                    _buildTag(
                                      image: AppImages.popular,
                                      backgroundColor: const Color(0xFFFF6B6B),
                                      shadowColor: const Color(0xFFFF6B6B).withOpacity(0.3),
                                      isSelected: _selectedParking?.id == parking.id,
                                    ),

                                  // Spacing between tags
                                  if (_isMostPopular(parking) && _isMostWanted(parking)) const SizedBox(width: 6),

                                  // Most Wanted Tag
                                  if (_isMostWanted(parking))
                                    _buildTag(
                                      image: AppImages.wanted,
                                      backgroundColor: const Color(0xFF4ECDC4),
                                      shadowColor: const Color(0xFF4ECDC4).withOpacity(0.3),
                                      isSelected: _selectedParking?.id == parking.id,
                                    ),
                                ],
                              ),
                            ),

                          // Main marker with selection container
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Price container
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: _selectedParking?.id == parking.id ? 12 : 10,
                                    vertical: _selectedParking?.id == parking.id ? 14 : 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: parking.isBusy ? Colors.red : Colors.green,
                                    borderRadius: BorderRadius.circular(18),
                                    // border:
                                    //     _selectedParking?.id == parking.id
                                    //         ? Border.all(color: Colors.white, width: 2)
                                    //         : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        spreadRadius: _selectedParking?.id == parking.id ? 3 : 1,
                                        blurRadius: _selectedParking?.id == parking.id ? 12 : 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Car icon when selected
                                      if (_selectedParking?.id == parking.id) ...[
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: AppIcons.carIc.icon(color: AppColors.primary),
                                        ),
                                        const SizedBox(width: 8),
                                      ],

                                      // Price text
                                      AnimatedDefaultTextStyle(
                                        duration: const Duration(milliseconds: 300),
                                        style: TextStyle(
                                          fontSize: _selectedParking?.id == parking.id ? 15 : 13,
                                          color: Colors.white,
                                          fontWeight:
                                              _selectedParking?.id == parking.id ? FontWeight.w700 : FontWeight.w600,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withOpacity(0.3),
                                              offset: const Offset(0, 1),
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Text(parking.nameEn),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Enhanced Triangle pointer
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            height: _selectedParking?.id == parking.id ? 16 : 12,
                            width: _selectedParking?.id == parking.id ? 24 : 20,
                            child: CustomPaint(
                              size: Size(
                                _selectedParking?.id == parking.id ? 24 : 20,
                                _selectedParking?.id == parking.id ? 16 : 12,
                              ),
                              painter: _TrianglePainter(
                                color: parking.isBusy ? Colors.red : Colors.green,
                                // hasBorder: _selectedParking?.id == parking.id,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),

            // Route loading indicator
            if (_isRouteLoading)
              Positioned(
                top: 120,
                left: 0,
                right: 0,
                child: Center(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                          const SizedBox(width: 12),
                          Text(LocaleKeys.map_calculating_route.tr()),
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
        ),

        // NEW: Parking list overlay
        _buildParkingListView(parkings),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocConsumer<ExploreCubit, ExploreState>(
            listener: (context, state) {
              if (state is ParkingsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${LocaleKeys.common_error.tr()}: ${state.message}'),
                    backgroundColor: Colors.red,
                    action: SnackBarAction(
                      label: LocaleKeys.common_retry.tr(),
                      textColor: Colors.white,
                      onPressed: _refreshData,
                    ),
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

          // Navigation back button at top of screen
          PositionedDirectional(top: 60, start: 16, child: CustomBackButton()),
        ],
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
        // Close details button and current location button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomIconButton(
              color: Colors.white,
              iconAsset: AppIcons.closeIc,
              onPressed: () {
                setState(() {
                  _selectedParking = null;
                  _clearRoute();
                });
              },
            ),
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
                            '📍 ${_formatDistance(distance)} ${LocaleKeys.map_away.tr()}',
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
                      parking.isBusy ? LocaleKeys.map_status_full.tr() : LocaleKeys.map_status_available.tr(),
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
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade400, Colors.orange.shade600.withValues(alpha: 0.2)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppImages.popular.toImage(),
                            // const Icon(Icons.star, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              LocaleKeys.map_tag_most_popular.tr(),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    if (_isMostPopular(parking) && _isMostWanted(parking)) const SizedBox(width: 8),
                    if (_isMostWanted(parking))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.purple.shade400, Colors.purple.shade600.withValues(alpha: 0.2)],
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppImages.wanted.toImage(),
                            // const Icon(Icons.favorite, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              LocaleKeys.map_tag_most_wanted.tr(),
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
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
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.route, color: AppColors.primary.withValues(alpha: 0.7), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            LocaleKeys.map_route_information.tr(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(
                            Icons.straighten,
                            _formatDistance(_currentRouteInfo!.distance),
                            LocaleKeys.map_route_distance.tr(),
                          ),
                          _buildInfoItem(
                            Icons.access_time,
                            _formatDuration(_currentRouteInfo!.duration),
                            LocaleKeys.map_route_duration.tr(),
                          ),
                          _buildInfoItem(
                            Icons.monetization_on,
                            '${_currentRouteInfo!.estimatedCost.toInt()}${LocaleKeys.map_unit_points.tr()}',
                            LocaleKeys.map_route_estimated_cost.tr(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Original image gallery (when not showing route)
                if (parking.gallery.gallery.isNotEmpty)
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
                        title: LocaleKeys.map_button_show_route.tr(),
                        onPressed: _currentLocation != null ? _showRouteToParking : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomElevatedButton(
                        title: LocaleKeys.map_button_details.tr(),
                        onPressed: () {
                          context.push(Routes.parkingDetails, extra: parking);
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
                        title:
                            parking.isBusy
                                ? LocaleKeys.map_button_parking_full.tr()
                                : LocaleKeys.map_button_start_navigation.tr(),
                        onPressed:
                            parking.isBusy
                                ? null
                                : () {
                                  _showCarSelectionForNavigation();
                                  openGoogleMapsRoute(
                                    _selectedParking!.lat.toDouble(),
                                    _selectedParking!.lng.toDouble(),
                                  );
                                },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomElevatedButton(
                        title: LocaleKeys.map_button_clear_route.tr(),
                        onPressed: _clearRoute,
                      ),
                    ),
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
        Icon(icon, color: AppColors.primary.withValues(alpha: 0.7), size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary.withValues(alpha: 0.7)),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: AppColors.primary.withValues(alpha: 0.7))),
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

  void _showCarSelectionForNavigation() {
    showAllCarsBottomSheet(
      context,
      title: LocaleKeys.select_car_for_navigation.tr(), // You might need to add this translation key
      onChooseCar: (Car selectedCar) {
        // Navigate to Google Maps
        // openGoogleMapsRoute(_selectedParking!.lat.toDouble(), _selectedParking!.lng.toDouble());

        // After navigation, show QR code for the selected car
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.push(Routes.myQrCode, extra: selectedCar);
          }
        });
      },
    );
  }

  // Helper method to build enhanced tags
  Widget _buildTag({
    required String image,
    required Color backgroundColor,
    required Color shadowColor,
    required bool isSelected,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(horizontal: isSelected ? 10 : 8, vertical: isSelected ? 6 : 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isSelected ? Border.all(color: Colors.white, width: 1.5) : null,
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            spreadRadius: isSelected ? 2 : 1,
            blurRadius: isSelected ? 8 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: isSelected ? 1.05 : 1.0,
        child: image.toImage(width: isSelected ? 16 : 14, height: isSelected ? 16 : 14),
      ),
    );
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
          ..style = PaintingStyle.fill;

    final path = ui.Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);

    // // Add border if selected
    // if (hasBorder) {
    //   final borderPaint =
    //       Paint()
    //         ..color = Colors.white
    //         ..style = PaintingStyle.stroke
    //         ..strokeWidth = 2;

    // canvas.drawPath(path, borderPaint);
    // }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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
                        child: Center(child: Icon(Icons.image_not_supported, color: Colors.white, size: 64)),
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
