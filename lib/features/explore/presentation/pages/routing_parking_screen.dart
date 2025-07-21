import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:must_invest/core/extensions/string_extensions.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/features/explore/data/models/parking.dart';
import 'package:must_invest/features/explore/presentation/widgets/parking_details_card.dart';
import 'package:must_invest/features/explore/presentation/widgets/routing/current_location_marker.dart';
import 'package:must_invest/features/explore/presentation/widgets/routing/loading_indicator.dart';
import 'package:must_invest/features/explore/presentation/widgets/routing/navigation_info_card.dart';
import 'package:must_invest/features/explore/presentation/widgets/routing/parking_location_marker.dart';
import 'package:must_invest/features/explore/presentation/widgets/routing/route_service_widget.dart';

class RoutingParkingScreen extends StatefulWidget {
  final Parking parking;
  const RoutingParkingScreen({super.key, required this.parking});

  @override
  State<RoutingParkingScreen> createState() => _RoutingParkingScreenState();
}

class _RoutingParkingScreenState extends State<RoutingParkingScreen> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final Location _location = Location();
  LocationData? _currentLocation;
  final List<Marker> _markers = [];
  final List<Polyline> _polylines = [];
  List<LatLng> _routePoints = [];
  Timer? _locationTimer;
  StreamSubscription<LocationData>? _locationSubscription;

  // Animation controllers
  late AnimationController _routeAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _markerAnimationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _routeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _markerAnimation;
  late Animation<Offset> _cardSlideAnimation;
  late Animation<double> _cardFadeAnimation;

  bool _isNavigating = false;
  bool _isLoadingRoute = false;
  double _distanceRemaining = 0.0;
  double _estimatedTime = 0.0;
  String _routeDuration = '';

  // OpenRouteService API Key - Get free from openrouteservice.org
  static const String _apiKey = '5b3ce3597851110001cf6248c4040779fe8e41d8ba6f918bf3b007b6';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _requestLocationPermission();
  }

  // Add this method to decode polyline (Google's polyline encoding)
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylineCoordinates;
  }

  Future<void> _getTrafficAwareDirections() async {
    if (_currentLocation == null) return;

    setState(() {
      _isLoadingRoute = true;
    });

    final routeService = RouteServiceWidget(
      parking: widget.parking,
      currentLocation: _currentLocation,
      onRouteFound: _processRouteData,
      onRouteError: _drawStraightLine,
    );

    await routeService.getTrafficAwareDirections();

    setState(() {
      _isLoadingRoute = false;
    });
  }

  // Process route data from any service
  void _processRouteData(List<LatLng> points, Map<String, dynamic> routeInfo) {
    // Extract route information
    double distance = (routeInfo['distance'] ?? 0) / 1000.0; // Convert to km
    double duration = (routeInfo['duration'] ?? 0) / 60.0; // Convert to minutes

    // Determine traffic condition based on duration vs distance ratio
    double speedKmh = distance / (duration / 60.0);
    // String trafficCondition;
    // if (speedKmh > 40) {
    //   trafficCondition = 'ممتازة';
    // } else if (speedKmh > 25) {
    //   trafficCondition = 'جيدة';
    // } else if (speedKmh > 15) {
    //   trafficCondition = 'متوسطة';
    // } else {
    //   trafficCondition = 'مزدحمة';
    // }

    setState(() {
      _routePoints = points;
      _distanceRemaining = distance;
      _estimatedTime = duration;
      _routeDuration = '${duration.toStringAsFixed(0)} دقيقة';
      // _trafficCondition = trafficCondition;
    });

    print(
      'Route processed: ${points.length} points, ${distance.toStringAsFixed(1)}km, ${duration.toStringAsFixed(0)}min',
    );
    _animateRoute();
  }

  // Add this method to validate route points
  bool _validateRoutePoints(List<LatLng> points) {
    if (points.length < 2) return false;

    // Check if points are actually following roads (not just straight line)
    if (points.length == 2) {
      // If only 2 points, it's likely a straight line
      double directDistance = _calculateDistance(
        points[0].latitude,
        points[0].longitude,
        points[1].latitude,
        points[1].longitude,
      );

      // If the route distance is very close to direct distance, it might be a straight line
      return directDistance > 0.1; // At least 100m to be considered valid
    }

    return true;
  }

  // Improved straight line method with better error handling
  void _drawStraightLine() {
    if (_currentLocation == null) return;

    List<LatLng> straightLinePoints = [
      LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      // LatLng(widget.parking.lat, widget.parking.lng),
      LatLng(0, 0),
    ];

    setState(() {
      _routePoints = straightLinePoints;
    });

    _animateRoute();
    _calculateDirectDistance();

    // Show a message to user that we're using direct route
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تعذر الحصول على مسار مفصل، يتم عرض المسار المباشر'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _initializeAnimations() {
    _routeAnimationController = AnimationController(duration: const Duration(seconds: 2), vsync: this);

    _pulseAnimationController = AnimationController(duration: const Duration(seconds: 1), vsync: this)
      ..repeat(reverse: true);

    _markerAnimationController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this)
      ..repeat(reverse: true);

    _cardAnimationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);

    _routeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _routeAnimationController, curve: Curves.easeOutCubic));

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(parent: _pulseAnimationController, curve: Curves.easeInOut));

    _markerAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _markerAnimationController, curve: Curves.easeInOut));

    _cardSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _cardAnimationController, curve: Curves.elasticOut));

    _cardFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _cardAnimationController, curve: Curves.easeIn));
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentLocation = await _location.getLocation();
      if (_currentLocation != null) {
        _updateMarkers();
        _getTrafficAwareDirections();
        _startLocationTracking();
        _centerMapOnRoute();
        _cardAnimationController.forward();
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _startLocationTracking() {
    _locationSubscription = _location.onLocationChanged.listen((LocationData locationData) {
      if (mounted) {
        setState(() {
          _currentLocation = locationData;
        });
        _updateMarkers();
        if (_isNavigating) {
          _updateDistanceAndTime();
        }
      }
    });
  }

  void _updateMarkers() {
    if (_currentLocation == null) return;

    setState(() {
      _markers.clear();

      // Current location marker
      _markers.add(
        Marker(
          point: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          width: 120,
          height: 50,
          child: CurrentLocationMarker(animation: _markerAnimation, isNavigating: _isNavigating),
        ),
      );

      // Parking location marker
      _markers.add(
        Marker(
          // point: LatLng(0, 0),
          point: LatLng(widget.parking.lat.toDouble(), widget.parking.lng.toDouble()),
          width: 80,
          height: 80,
          child: ParkingLocationMarker(parking: widget.parking),
        ),
      );
    });
  }

  void _calculateDirectDistance() {
    if (_currentLocation == null) return;

    double distance = _calculateDistance(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
      // widget.parking.lat,
      // widget.parking.lng,
      0,
      0,
    );

    setState(() {
      _distanceRemaining = distance;
      _estimatedTime = distance * 2; // Rough estimate: 2 minutes per km
      _routeDuration = '${(_estimatedTime).toStringAsFixed(0)} دقيقة';
    });
  }

  void _animateRoute() {
    _routeAnimationController.addListener(() {
      if (mounted) {
        setState(() {
          _updateAnimatedPolyline();
        });
      }
    });
    _routeAnimationController.forward();
  }

  void _updateAnimatedPolyline() {
    if (_routePoints.isEmpty) return;

    int pointsToShow = (_routePoints.length * _routeAnimation.value).round();
    List<LatLng> animatedPoints = _routePoints.take(pointsToShow).toList();

    setState(() {
      _polylines.clear();

      // Shadow polyline for depth
      if (animatedPoints.length > 1) {
        _polylines.add(Polyline(points: animatedPoints, color: Colors.black.withOpacity(0.2), strokeWidth: 8.0));
      }

      // Main route polyline - Changed to AppColors.primary
      _polylines.add(
        Polyline(
          points: animatedPoints,
          color: AppColors.primary, // Changed here
          strokeWidth: 6.0,
        ),
      );

      // Animated gradient effect for navigation mode
      if (_isNavigating && animatedPoints.length > 5) {
        _polylines.add(
          Polyline(points: animatedPoints.take(5).toList(), color: Colors.white.withOpacity(0.8), strokeWidth: 4.0),
        );
      }
    });
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  void _startNavigation() {
    setState(() {
      _isNavigating = true;
    });
    _updateAnimatedPolyline();
    _markerAnimationController.repeat(reverse: true);
  }

  void _stopNavigation() {
    setState(() {
      _isNavigating = false;
    });
    _markerAnimationController.stop();
    Navigator.pop(context);
  }

  void _centerMapOnRoute() {
    if (_currentLocation == null) return;

    LatLng currentPos = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    LatLng parkingPos = LatLng(widget.parking.lat.toDouble(), widget.parking.lng.toDouble());
    // LatLng parkingPos = LatLng();

    LatLngBounds bounds = LatLngBounds(
      LatLng(
        math.min(currentPos.latitude, parkingPos.latitude) - 0.01,
        math.min(currentPos.longitude, parkingPos.longitude) - 0.01,
      ),
      LatLng(
        math.max(currentPos.latitude, parkingPos.latitude) + 0.01,
        math.max(currentPos.longitude, parkingPos.longitude) + 0.01,
      ),
    );

    _mapController.fitCamera(CameraFit.bounds(bounds: bounds));
  }

  void _centerOnCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!), 16.0);
    }
  }

  void _updateDistanceAndTime() {
    if (_currentLocation == null) return;

    double distance = _calculateDistance(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
      // widget.parking.lat,
      // widget.parking.lng,
      0,
      0,
    );

    setState(() {
      _distanceRemaining = distance;
      _estimatedTime = distance * 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [
          // Flutter Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _currentLocation != null
                      ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
                      // : LatLng(widget.parking.lat, widget.parking.lng),
                      : LatLng(0, 0),
              initialZoom: 15.0,
              maxZoom: 18.0,
              minZoom: 5.0,
            ),
            children: [
              // OpenStreetMap tile layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.must_invest',
                maxZoom: 19,
              ),
              // Polylines (routes)
              PolylineLayer(polylines: _polylines),
              // Markers
              MarkerLayer(markers: _markers),
              // Attribution
              const RichAttributionWidget(attributions: [TextSourceAttribution('OpenStreetMap contributors')]),
            ],
          ),

          // Loading indicator
          if (_isLoadingRoute) Positioned(top: 120, left: 20, right: 20, child: RouteLoadingIndicator()),

          // Enhanced Navigation Info Card
          if (_isNavigating && !_isLoadingRoute)
            Positioned(
              top: 120,
              left: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: NavigationInfoCard(
                      distanceRemaining: _distanceRemaining,
                      estimatedTime: _estimatedTime.toString(),
                      pulseAnimation: _pulseAnimation,
                      // estimatedTime: _estimatedTime,
                      // trafficCondition: _trafficCondition,
                    ),
                  );
                },
              ),
            ),

          // Enhanced Parking Info Card
          ParkingDetailsCard(
            slideAnimation: _cardSlideAnimation,
            fadeAnimation: _cardFadeAnimation,
            parking: widget.parking,
            isNavigating: _isNavigating,
            isLoadingRoute: _isLoadingRoute,
            onStartNavigation: () {},
            onStopNavigation: () {},
            currentLocationName: '',
          ),

          // Enhanced Navigation Button
          // Positioned(
          //   bottom: 20,
          //   left: 20,
          //   right: 20,
          //   child:
          // ),
          Positioned(
            top: 40,
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(),
                  Text(''),
                  NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
                ],
              ),
            ).paddingAll(20),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _locationSubscription?.cancel();
    _routeAnimationController.dispose();
    _pulseAnimationController.dispose();
    _markerAnimationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }
}
