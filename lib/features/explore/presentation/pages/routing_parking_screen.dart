import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:must_invest/core/extensions/string_extensions.dart';
import 'package:must_invest/core/extensions/widget_extensions.dart';
import 'package:must_invest/core/theme/colors.dart';
import 'package:must_invest/core/utils/widgets/buttons/custom_back_button.dart';
import 'package:must_invest/core/utils/widgets/buttons/notifications_button.dart';
import 'package:must_invest/features/explore/data/models/parking.dart';
import 'package:must_invest/features/explore/presentation/pages/map_screen.dart';
import 'package:must_invest/features/explore/presentation/widgets/parking_details_card.dart';
import 'package:must_invest/features/explore/presentation/widgets/routing/current_location_marker.dart';
import 'package:must_invest/features/explore/presentation/widgets/routing/loading_indicator.dart';
import 'package:must_invest/features/explore/presentation/widgets/routing/navigation_info_card.dart';
import 'package:must_invest/features/explore/presentation/widgets/routing/parking_location_marker.dart';
import 'package:url_launcher/url_launcher.dart';

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

  double _distanceRemaining = 0.0;
  double _estimatedTime = 0.0;
  String _routeDuration = '';

  // OpenRouteService API Key - Get free from openrouteservice.org
  static const String _apiKey = '5b3ce3597851110001cf6248c4040779fe8e41d8ba6f918bf3b007b6';

  // Geocoding service for location detection
  Future<LocationData?> _getLocationViaGeocoding() async {
    debugPrint('🌍 _getLocationViaGeocoding: Attempting to get location via geocoding');

    try {
      // Try multiple geocoding services
      LocationData? location = await _tryIPGeolocation();
      if (location != null) return location;

      location = await _tryGeocodeAPI();
      if (location != null) return location;

      // Fallback to Egypt default location (Cairo)
      debugPrint('⚠️ _getLocationViaGeocoding: Using fallback location (Cairo, Egypt)');
      return LocationData.fromMap({
        'latitude': 30.0444,
        'longitude': 31.2357,
        'accuracy': 1000.0,
        'altitude': 0.0,
        'speed': 0.0,
        'speedAccuracy': 0.0,
        'heading': 0.0,
        'time': DateTime.now().millisecondsSinceEpoch.toDouble(),
      });
    } catch (e) {
      debugPrint('❌ _getLocationViaGeocoding: Error getting location via geocoding: $e');
      return null;
    }
  }

  // Try IP-based geolocation
  Future<LocationData?> _tryIPGeolocation() async {
    debugPrint('🌐 _tryIPGeolocation: Trying IP-based geolocation');

    try {
      final response = await http
          .get(Uri.parse('http://ip-api.com/json/?fields=status,lat,lon,city,country'))
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          double lat = (data['lat'] as num).toDouble();
          double lng = (data['lon'] as num).toDouble();

          debugPrint('✅ _tryIPGeolocation: Success - lat: $lat, lng: $lng');
          debugPrint('🌍 _tryIPGeolocation: Location: ${data['city']}, ${data['country']}');

          return LocationData.fromMap({
            'latitude': lat,
            'longitude': lng,
            'accuracy': 5000.0, // IP geolocation is less accurate
            'altitude': 0.0,
            'speed': 0.0,
            'speedAccuracy': 0.0,
            'heading': 0.0,
            'time': DateTime.now().millisecondsSinceEpoch.toDouble(),
          });
        }
      }
    } catch (e) {
      debugPrint('❌ _tryIPGeolocation: Failed - $e');
    }

    return null;
  }

  // Try geocoding API
  Future<LocationData?> _tryGeocodeAPI() async {
    debugPrint('🗺️ _tryGeocodeAPI: Trying OpenStreetMap Nominatim geocoding');

    try {
      // Use Nominatim (OpenStreetMap) for geocoding
      final response = await http
          .get(
            Uri.parse('https://nominatim.openstreetmap.org/search?q=Egypt&format=json&limit=1'),
            headers: {'User-Agent': 'MustInvestApp/1.0'},
          )
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          double lat = double.parse(data[0]['lat']);
          double lng = double.parse(data[0]['lon']);

          debugPrint('✅ _tryGeocodeAPI: Success - lat: $lat, lng: $lng');

          return LocationData.fromMap({
            'latitude': lat,
            'longitude': lng,
            'accuracy': 10000.0, // Country-level accuracy
            'altitude': 0.0,
            'speed': 0.0,
            'speedAccuracy': 0.0,
            'heading': 0.0,
            'time': DateTime.now().millisecondsSinceEpoch.toDouble(),
          });
        }
      }
    } catch (e) {
      debugPrint('❌ _tryGeocodeAPI: Failed - $e');
    }

    return null;
  }

  // Helper method to validate and auto-correct coordinates
  bool _areValidCoordinates(double lat, double lng) {
    return lat >= -90.0 && lat <= 90.0 && lng >= -180.0 && lng <= 180.0;
  }

  // Auto-correct common coordinate format issues
  double _correctCoordinate(double value, bool isLatitude) {
    debugPrint('🔧 _correctCoordinate: Attempting to correct $value (isLatitude: $isLatitude)');

    // If value is too large, likely missing decimal point
    if (value > 1000) {
      String str = value.toString();
      debugPrint('🔧 _correctCoordinate: Original string: $str');

      // For latitude like 2353465 -> 23.53465
      if (isLatitude && str.length >= 6) {
        String corrected = '${str.substring(0, 2)}.${str.substring(2)}';
        double parsed = double.tryParse(corrected) ?? value;
        debugPrint('🔧 _correctCoordinate: Corrected latitude $value -> $parsed');
        return parsed;
      }

      // For longitude, try different patterns
      if (!isLatitude && str.length >= 6) {
        String corrected = '${str.substring(0, 2)}.${str.substring(2)}';
        double parsed = double.tryParse(corrected) ?? value;
        debugPrint('🔧 _correctCoordinate: Corrected longitude $value -> $parsed');
        return parsed;
      }
    }

    debugPrint('🔧 _correctCoordinate: No correction needed for $value');
    return value;
  }

  // Get corrected parking coordinates
  LatLng _getCorrectedParkingLocation() {
    double rawLat = widget.parking.lat.toDouble();
    double rawLng = widget.parking.lng.toDouble();

    double correctedLat = _correctCoordinate(rawLat, true);
    double correctedLng = _correctCoordinate(rawLng, false);

    return LatLng(correctedLat, correctedLng);
  }

  void _calculateDirectDistance() {
    debugPrint('📏 _calculateDirectDistance: Calculating direct distance to parking');

    if (_currentLocation == null) {
      debugPrint('❌ _calculateDirectDistance: Current location is null, cannot calculate distance');
      return;
    }

    LatLng parkingLocation = _getCorrectedParkingLocation();

    // Use valid coordinates or return 0 distance
    if (!_areValidCoordinates(parkingLocation.latitude, parkingLocation.longitude)) {
      debugPrint('⚠️ _calculateDirectDistance: Invalid parking coordinates, setting distance to 0');
      setState(() {
        _distanceRemaining = 0.0;
        _estimatedTime = 0.0;
        _routeDuration = '0 دقيقة';
      });
      return;
    }

    debugPrint('📏 _calculateDirectDistance: From (${_currentLocation!.latitude}, ${_currentLocation!.longitude})');
    debugPrint('📏 _calculateDirectDistance: To (${parkingLocation.latitude}, ${parkingLocation.longitude})');

    double distance = _calculateDistance(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
      parkingLocation.latitude,
      parkingLocation.longitude,
    );

    debugPrint('📏 _calculateDirectDistance: Calculated distance: ${distance.toStringAsFixed(3)}km');

    setState(() {
      _distanceRemaining = distance;
      _estimatedTime = distance * 2; // Rough estimate: 2 minutes per km
      _routeDuration = '${(_estimatedTime).toStringAsFixed(0)} دقيقة';
    });

    debugPrint(
      '📏 _calculateDirectDistance: Updated state - distance: ${distance.toStringAsFixed(3)}km, time: ${_estimatedTime.toStringAsFixed(1)}min',
    );
  }

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 RoutingParkingScreen: initState called');

    // ALWAYS initialize animations first to prevent LateInitializationError
    _initializeAnimations();

    // VALIDATE AND AUTO-CORRECT PARKING COORDINATES
    double rawLat = widget.parking.lat.toDouble();
    double rawLng = widget.parking.lng.toDouble();

    debugPrint('🔍 RoutingParkingScreen: Raw parking coordinates - lat: $rawLat, lng: $rawLng');

    // Try to auto-correct coordinates
    double correctedLat = _correctCoordinate(rawLat, true);
    double correctedLng = _correctCoordinate(rawLng, false);

    debugPrint('🔧 RoutingParkingScreen: Corrected coordinates - lat: $correctedLat, lng: $correctedLng');

    if (!_areValidCoordinates(correctedLat, correctedLng)) {
      debugPrint('❌ RoutingParkingScreen: INVALID COORDINATES DETECTED EVEN AFTER CORRECTION!');
      debugPrint('❌ RoutingParkingScreen: Latitude must be between -90 and 90, got: $correctedLat');
      debugPrint('❌ RoutingParkingScreen: Longitude must be between -180 and 180, got: $correctedLng');

      // Show error to user after widget is built
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   if (mounted) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(
      //         content: Text('خطأ في إحداثيات موقف السيارات: lat=$correctedLat, lng=$correctedLng'),
      //         backgroundColor: Colors.red,
      //         duration: Duration(seconds: 5),
      //       ),
      //     );
      //   }
      // });

      // Still start card animation even with invalid coordinates
      _cardAnimationController.forward();
      return;
    }

    debugPrint('✅ RoutingParkingScreen: Parking coordinates are valid after correction');
    debugPrint('🏁 RoutingParkingScreen: Final parking destination - lat: $correctedLat, lng: $correctedLng');

    // Store corrected coordinates back to parking object if possible
    // Note: This is a temporary fix. You should fix the data source.

    _requestLocationPermission();
  }

  // Add this method to decode polyline (Google's polyline encoding)
  List<LatLng> _decodePolyline(String encoded) {
    debugPrint('🗺️ _decodePolyline: Starting to decode polyline with length: ${encoded.length}');

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

    debugPrint('✅ _decodePolyline: Successfully decoded ${polylineCoordinates.length} coordinate points');
    return polylineCoordinates;
  }

  // Current route info
  RouteInfo? _currentRouteInfo;
  bool _isRouteLoading = false;
  bool _showRoute = false;

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
            _distanceRemaining = distance;
            _estimatedTime = duration;
            _routeDuration = '${duration.toStringAsFixed(0)} دقيقة';
          });

          _animateRoute();
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

  // Calculate estimated cost based on distance and duration
  double _calculateEstimatedCost(double distance, double duration) {
    // Simple calculation: assume 1 EGP per km + time factor
    const double fuelCostPerKm = 1.0;
    const double timeCostPerMinute = 0.5;
    return (distance * fuelCostPerKm) + (duration * timeCostPerMinute);
  }

  // Create straight line route as fallback
  void _createStraightLineRoute(LatLng start, LatLng end) {
    debugPrint('📏 _createStraightLineRoute: Creating fallback straight line route');

    List<LatLng> straightLinePoints = [start, end];
    double distance = _calculateDistance(start.latitude, start.longitude, end.latitude, end.longitude);
    double duration = distance * 2; // Rough estimate: 2 minutes per km

    setState(() {
      _routePoints = straightLinePoints;
      _currentRouteInfo = RouteInfo(
        distance: distance,
        duration: duration,
        estimatedCost: _calculateEstimatedCost(distance, duration),
      );
      _isRouteLoading = false;
      _showRoute = true;
      _distanceRemaining = distance;
      _estimatedTime = duration;
      _routeDuration = '${duration.toStringAsFixed(0)} دقيقة';
    });

    _animateRoute();

    // // Show fallback message
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('تعذر الحصول على مسار مفصل، يتم عرض المسار المباشر'),
    //     duration: Duration(seconds: 3),
    //   ),
    // );
  }

  Future<void> _getTrafficAwareDirections() async {
    debugPrint('🛣️ _getTrafficAwareDirections: Starting route calculation');

    if (_currentLocation == null) {
      debugPrint('❌ _getTrafficAwareDirections: Current location is null, aborting');
      return;
    }

    debugPrint(
      '📍 _getTrafficAwareDirections: Current location - lat: ${_currentLocation!.latitude}, lng: ${_currentLocation!.longitude}',
    );

    LatLng start = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    LatLng end = _getCorrectedParkingLocation();

    // Use the OSRM function instead of RouteServiceWidget
    await _getRouteFromOSRM(start, end);
  }

  // Add this method to validate route points
  bool _validateRoutePoints(List<LatLng> points) {
    debugPrint('🔍 _validateRoutePoints: Validating ${points.length} route points');

    if (points.length < 2) {
      debugPrint('❌ _validateRoutePoints: Insufficient points (${points.length} < 2)');
      return false;
    }

    // Check if points are actually following roads (not just straight line)
    if (points.length == 2) {
      debugPrint('⚠️ _validateRoutePoints: Only 2 points detected, checking if it\'s a straight line');

      // If only 2 points, it's likely a straight line
      double directDistance = _calculateDistance(
        points[0].latitude,
        points[0].longitude,
        points[1].latitude,
        points[1].longitude,
      );

      debugPrint('📏 _validateRoutePoints: Direct distance between 2 points: ${directDistance.toStringAsFixed(3)}km');

      // If the route distance is very close to direct distance, it might be a straight line
      bool isValid = directDistance > 0.1; // At least 100m to be considered valid
      debugPrint('✅ _validateRoutePoints: Route validation result: $isValid');
      return isValid;
    }

    debugPrint('✅ _validateRoutePoints: Route has ${points.length} points - valid');
    return true;
  }

  // Improved straight line method with better error handling
  // Replace all instances of LatLng(0, 0) with proper parking coordinates

  void _drawStraightLine() {
    debugPrint('📏 _drawStraightLine: Drawing straight line route as fallback');

    if (_currentLocation == null) {
      debugPrint('❌ _drawStraightLine: Current location is null, aborting');
      return;
    }

    LatLng parkingLocation = _getCorrectedParkingLocation();

    // Use valid coordinates or fallback
    if (!_areValidCoordinates(parkingLocation.latitude, parkingLocation.longitude)) {
      debugPrint('⚠️ _drawStraightLine: Invalid parking coordinates, using current location as destination');
      parkingLocation = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    }

    debugPrint(
      '📍 _drawStraightLine: From current location (${_currentLocation!.latitude}, ${_currentLocation!.longitude})',
    );
    debugPrint('📍 _drawStraightLine: To parking location (${parkingLocation.latitude}, ${parkingLocation.longitude})');

    List<LatLng> straightLinePoints = [
      LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
      parkingLocation,
    ];

    debugPrint('📏 _drawStraightLine: Created straight line with ${straightLinePoints.length} points');

    setState(() {
      _routePoints = straightLinePoints;
    });

    debugPrint('🎬 _drawStraightLine: Starting route animation');
    _animateRoute();

    debugPrint('📊 _drawStraightLine: Calculating direct distance');
    _calculateDirectDistance();

    // Show a message to user that we're using direct route
    debugPrint('📱 _drawStraightLine: Showing fallback message to user');
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('تعذر الحصول على مسار مفصل، يتم عرض المسار المباشر'),
    //     duration: Duration(seconds: 3),
    //   ),
    // );
  }

  void _initializeAnimations() {
    debugPrint('🎬 _initializeAnimations: Initializing all animation controllers');

    _routeAnimationController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    debugPrint('🎬 _initializeAnimations: Route animation controller created');

    _pulseAnimationController = AnimationController(duration: const Duration(seconds: 1), vsync: this)
      ..repeat(reverse: true);
    debugPrint('🎬 _initializeAnimations: Pulse animation controller created and started');

    _markerAnimationController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this)
      ..repeat(reverse: true);
    debugPrint('🎬 _initializeAnimations: Marker animation controller created and started');

    _cardAnimationController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    debugPrint('🎬 _initializeAnimations: Card animation controller created');

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

    debugPrint('✅ _initializeAnimations: All animations initialized successfully');
  }

  Future<void> _requestLocationPermission() async {
    debugPrint('🔐 _requestLocationPermission: Requesting location permissions');

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    debugPrint('🔐 _requestLocationPermission: Checking if location service is enabled');
    serviceEnabled = await _location.serviceEnabled();
    debugPrint('🔐 _requestLocationPermission: Location service enabled: $serviceEnabled');

    if (!serviceEnabled) {
      debugPrint('⚠️ _requestLocationPermission: Location service disabled, requesting to enable');
      serviceEnabled = await _location.requestService();
      debugPrint('🔐 _requestLocationPermission: Location service request result: $serviceEnabled');
      if (!serviceEnabled) {
        debugPrint('❌ _requestLocationPermission: User denied location service request');
        return;
      }
    }

    debugPrint('🔐 _requestLocationPermission: Checking location permissions');
    permissionGranted = await _location.hasPermission();
    debugPrint('🔐 _requestLocationPermission: Current permission status: $permissionGranted');

    if (permissionGranted == PermissionStatus.denied) {
      debugPrint('⚠️ _requestLocationPermission: Permission denied, requesting permission');
      permissionGranted = await _location.requestPermission();
      debugPrint('🔐 _requestLocationPermission: Permission request result: $permissionGranted');
      if (permissionGranted != PermissionStatus.granted) {
        debugPrint('❌ _requestLocationPermission: User denied location permission');
        return;
      }
    }

    debugPrint('✅ _requestLocationPermission: All permissions granted, getting current location');
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    debugPrint('📍 _getCurrentLocation: Attempting to get current location');

    try {
      // First try GPS with a shorter timeout
      debugPrint('📡 _getCurrentLocation: Trying GPS first...');
      _currentLocation = await _location.getLocation().timeout(
        Duration(seconds: 5), // Reduced timeout for GPS
        onTimeout: () {
          debugPrint('⏰ _getCurrentLocation: GPS timed out, trying geocoding...');
          throw TimeoutException('GPS timeout', Duration(seconds: 5));
        },
      );

      if (_currentLocation != null) {
        debugPrint('✅ _getCurrentLocation: GPS location obtained successfully');
        debugPrint('📡 _getCurrentLocation: GPS - Latitude: ${_currentLocation!.latitude}');
        debugPrint('📡 _getCurrentLocation: GPS - Longitude: ${_currentLocation!.longitude}');
        debugPrint('📡 _getCurrentLocation: GPS - Accuracy: ${_currentLocation!.accuracy}m');

        await _processLocationSuccess('GPS');
        return;
      }
    } on TimeoutException catch (e) {
      debugPrint('⏰ _getCurrentLocation: GPS timeout, falling back to geocoding');
    } catch (e) {
      debugPrint('❌ _getCurrentLocation: GPS error: $e, falling back to geocoding');
    }

    // Fallback to geocoding
    try {
      debugPrint('🌍 _getCurrentLocation: Trying geocoding fallback...');
      _currentLocation = await _getLocationViaGeocoding();

      if (_currentLocation != null) {
        debugPrint('✅ _getCurrentLocation: Geocoding location obtained successfully');
        debugPrint('🌍 _getCurrentLocation: Geocoding - Latitude: ${_currentLocation!.latitude}');
        debugPrint('🌍 _getCurrentLocation: Geocoding - Longitude: ${_currentLocation!.longitude}');
        debugPrint('🌍 _getCurrentLocation: Geocoding - Accuracy: ${_currentLocation!.accuracy}m');

        await _processLocationSuccess('Geocoding');
        return;
      }
    } catch (e) {
      debugPrint('❌ _getCurrentLocation: Geocoding error: $e');
    }

    // If all fails
    debugPrint('❌ _getCurrentLocation: All location methods failed');
    _showLocationError('Unable to determine location using GPS or geocoding');
  }

  Future<void> _processLocationSuccess(String method) async {
    debugPrint('✅ _processLocationSuccess: Processing location from $method');

    // Validate current location coordinates
    if (!_areValidCoordinates(_currentLocation!.latitude!, _currentLocation!.longitude!)) {
      debugPrint('❌ _processLocationSuccess: Invalid coordinates received from $method');
      _showLocationError('Invalid coordinates received from $method');
      return;
    }

    debugPrint('🎯 _processLocationSuccess: Updating markers');
    _updateMarkers();

    debugPrint('🛣️ _processLocationSuccess: Getting traffic-aware directions');
    _getTrafficAwareDirections();

    debugPrint('📡 _processLocationSuccess: Starting location tracking');
    _startLocationTracking();

    debugPrint('🗺️ _processLocationSuccess: Centering map on route');
    _centerMapOnRoute();

    debugPrint('🎬 _processLocationSuccess: Starting card animation');
    _cardAnimationController.forward();

    // Show success message to user
    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(
    //       content: Text('تم تحديد الموقع باستخدام $method'),
    //       backgroundColor: Colors.green,
    //       duration: Duration(seconds: 2),
    //     ),
    //   );
    // }
  }

  void _showLocationError(String message) {
    debugPrint('🚨 _showLocationError: $message');
    if (mounted) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(message),
      //     backgroundColor: Colors.red,
      //     duration: Duration(seconds: 5),
      //     action: SnackBarAction(
      //       label: 'Retry',
      //       textColor: Colors.white,
      //       onPressed: () {
      //         debugPrint('🔄 _showLocationError: User requested retry');
      //         _getCurrentLocation();
      //       },
      //     ),
      //   ),
      // );
    }
  }

  void _startLocationTracking() {
    debugPrint('📡 _startLocationTracking: Starting continuous location tracking');

    _locationSubscription = _location.onLocationChanged.listen((LocationData locationData) {
      debugPrint('📡 _startLocationTracking: Location update received');
      debugPrint(
        '📍 _startLocationTracking: New location - lat: ${locationData.latitude}, lng: ${locationData.longitude}',
      );
      debugPrint('📍 _startLocationTracking: Accuracy: ${locationData.accuracy}m, Speed: ${locationData.speed}m/s');

      if (mounted) {
        debugPrint('🔄 _startLocationTracking: Widget is mounted, updating location');
        setState(() {
          _currentLocation = locationData;
        });

        debugPrint('🎯 _startLocationTracking: Updating markers with new location');
        _updateMarkers();

        if (_isNavigating) {
          debugPrint('🧭 _startLocationTracking: Navigation active, updating distance and time');
          _updateDistanceAndTime();
        }
      } else {
        debugPrint('⚠️ _startLocationTracking: Widget not mounted, ignoring location update');
      }
    });

    debugPrint('✅ _startLocationTracking: Location tracking subscription established');
  }

  void _updateMarkers() {
    debugPrint('🎯 _updateMarkers: Updating map markers');

    if (_currentLocation == null) {
      debugPrint('❌ _updateMarkers: Current location is null, cannot update markers');
      return;
    }

    debugPrint('🎯 _updateMarkers: Clearing existing markers (count: ${_markers.length})');

    setState(() {
      _markers.clear();

      // Current location marker
      debugPrint('📍 _updateMarkers: Adding current location marker');
      _markers.add(
        Marker(
          point: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          width: 120,
          height: 50,
          child: CurrentLocationMarker(animation: _markerAnimation, isNavigating: _isNavigating),
        ),
      );

      // Parking location marker (only if coordinates are valid)
      LatLng parkingLocation = _getCorrectedParkingLocation();

      if (_areValidCoordinates(parkingLocation.latitude, parkingLocation.longitude)) {
        debugPrint(
          '🅿️ _updateMarkers: Adding parking location marker at (${parkingLocation.latitude}, ${parkingLocation.longitude})',
        );
        _markers.add(
          Marker(point: parkingLocation, width: 80, height: 80, child: ParkingLocationMarker(parking: widget.parking)),
        );
      } else {
        debugPrint('⚠️ _updateMarkers: Skipping parking marker due to invalid coordinates');
      }
    });

    debugPrint('✅ _updateMarkers: Markers updated successfully (total: ${_markers.length})');
  }

  // void _calculateDirectDistance() {
  //   debugPrint('📏 _calculateDirectDistance: Calculating direct distance to parking');

  //   if (_currentLocation == null) {
  //     debugPrint('❌ _calculateDirectDistance: Current location is null, cannot calculate distance');
  //     return;
  //   }

  //   debugPrint('📏 _calculateDirectDistance: From (${_currentLocation!.latitude}, ${_currentLocation!.longitude})');
  //   debugPrint('📏 _calculateDirectDistance: To (0, 0)'); // Note: Using 0,0 as in original code

  //   double distance = _calculateDistance(
  //     _currentLocation!.latitude!,
  //     _currentLocation!.longitude!,
  //     0, // Using 0 as in original code
  //     0, // Using 0 as in original code
  //   );

  //   debugPrint('📏 _calculateDirectDistance: Calculated distance: ${distance.toStringAsFixed(3)}km');

  //   setState(() {
  //     _distanceRemaining = distance;
  //     _estimatedTime = distance * 2; // Rough estimate: 2 minutes per km
  //     _routeDuration = '${(_estimatedTime).toStringAsFixed(0)} دقيقة';
  //   });

  //   debugPrint(
  //     '📏 _calculateDirectDistance: Updated state - distance: ${distance.toStringAsFixed(3)}km, time: ${_estimatedTime.toStringAsFixed(1)}min',
  //   );
  // }

  void _animateRoute() {
    debugPrint('🎬 _animateRoute: Starting route animation');

    _routeAnimationController.addListener(() {
      if (mounted) {
        debugPrint('🎬 _animateRoute: Animation progress: ${(_routeAnimation.value * 100).toStringAsFixed(1)}%');
        setState(() {
          _updateAnimatedPolyline();
        });
      }
    });

    debugPrint('▶️ _animateRoute: Starting animation controller');
    _routeAnimationController.forward();
  }

  void _updateAnimatedPolyline() {
    if (_routePoints.isEmpty) {
      return;
    }

    int pointsToShow = (_routePoints.length * _routeAnimation.value).round();
    List<LatLng> animatedPoints = _routePoints.take(pointsToShow).toList();

    // Add this safety check
    if (animatedPoints.length < 2) {
      return;
    }

    setState(() {
      _polylines.clear();

      // Shadow polyline for depth
      if (animatedPoints.length > 1) {
        debugPrint('🎨 _updateAnimatedPolyline: Adding shadow polyline');
        _polylines.add(Polyline(points: animatedPoints, color: Colors.black.withOpacity(0.2), strokeWidth: 8.0));
      }

      // Main route polyline - Changed to AppColors.primary
      debugPrint('🎨 _updateAnimatedPolyline: Adding main route polyline');
      _polylines.add(Polyline(points: animatedPoints, color: AppColors.primary, strokeWidth: 6.0));

      // Animated gradient effect for navigation mode
      if (_isNavigating && animatedPoints.length > 5) {
        debugPrint('🎨 _updateAnimatedPolyline: Adding navigation gradient effect');
        _polylines.add(
          Polyline(points: animatedPoints.take(5).toList(), color: Colors.white.withOpacity(0.8), strokeWidth: 4.0),
        );
      }
    });

    debugPrint('✅ _updateAnimatedPolyline: Polylines updated (total: ${_polylines.length})');
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    debugPrint('📐 _calculateDistance: Calculating distance between ($lat1, $lon1) and ($lat2, $lon2)');

    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) * math.cos(_degreesToRadians(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    double distance = earthRadius * c;

    debugPrint('📐 _calculateDistance: Result: ${distance.toStringAsFixed(3)}km');
    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  // void _startNavigation() {
  //   debugPrint('🧭 _startNavigation: Starting navigation mode');

  //   setState(() {
  //     _isNavigating = true;
  //   });

  //   debugPrint('🧭 _startNavigation: Navigation state updated to true');
  //   debugPrint('🎬 _startNavigation: Updating polyline for navigation mode');
  //   _updateAnimatedPolyline();

  //   debugPrint('🎬 _startNavigation: Starting marker pulse animation');
  //   _markerAnimationController.repeat(reverse: true);

  //   debugPrint('✅ _startNavigation: Navigation started successfully');
  // }

  void _startNavigation() {
    debugPrint('🧭 _startNavigation: Opening Google Maps for navigation');

    if (_currentLocation == null) {
      debugPrint('❌ _startNavigation: Current location is null, cannot navigate');
      return;
    }

    LatLng parkingLocation = _getCorrectedParkingLocation();

    if (!_areValidCoordinates(parkingLocation.latitude, parkingLocation.longitude)) {
      debugPrint('❌ _startNavigation: Invalid parking coordinates');
      return;
    }

    _launchGoogleMaps(parkingLocation);
  }

  Future<void> _launchGoogleMaps(LatLng destination) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1'
        '&origin=${_currentLocation!.latitude},${_currentLocation!.longitude}'
        '&destination=${destination.latitude},${destination.longitude}'
        '&travelmode=driving';

    final Uri uri = Uri.parse(googleMapsUrl);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        debugPrint('✅ _launchGoogleMaps: Successfully opened Google Maps');
      } else {
        debugPrint('❌ _launchGoogleMaps: Cannot launch Google Maps URL');
        _showErrorMessage('Unable to open Google Maps');
      }
    } catch (e) {
      debugPrint('❌ _launchGoogleMaps: Error launching Google Maps: $e');
      _showErrorMessage('Error opening Google Maps: $e');
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red, duration: Duration(seconds: 3)));
    }
  }

  void _stopNavigation() {
    debugPrint('🛑 _stopNavigation: Stopping navigation mode');

    setState(() {
      _isNavigating = false;
    });

    debugPrint('🛑 _stopNavigation: Navigation state updated to false');
    debugPrint('🎬 _stopNavigation: Stopping marker animation');
    _markerAnimationController.stop();

    debugPrint('🔙 _stopNavigation: Navigating back to previous screen');
    Navigator.pop(context);
  }

  void _centerMapOnRoute() {
    debugPrint('🗺️ _centerMapOnRoute: Centering map to show full route');

    if (_currentLocation == null) {
      debugPrint('❌ _centerMapOnRoute: Current location is null, cannot center map');
      return;
    }

    LatLng currentPos = LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);

    LatLng parkingLocation = _getCorrectedParkingLocation();

    // Use current location as fallback if parking coordinates are invalid
    if (!_areValidCoordinates(parkingLocation.latitude, parkingLocation.longitude)) {
      debugPrint('⚠️ _centerMapOnRoute: Invalid parking coordinates, centering on current location only');
      _mapController.move(currentPos, 16.0);
      return;
    }

    LatLng parkingPos = parkingLocation;

    debugPrint('🗺️ _centerMapOnRoute: Current position: (${currentPos.latitude}, ${currentPos.longitude})');
    debugPrint('🗺️ _centerMapOnRoute: Parking position: (${parkingPos.latitude}, ${parkingPos.longitude})');

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

    debugPrint('🗺️ _centerMapOnRoute: Calculated bounds: ${bounds.southWest} to ${bounds.northEast}');
    debugPrint('🗺️ _centerMapOnRoute: Fitting camera to bounds');
    _mapController.fitCamera(CameraFit.bounds(bounds: bounds));

    debugPrint('✅ _centerMapOnRoute: Map centered successfully');
  }

  void _centerOnCurrentLocation() {
    debugPrint('🎯 _centerOnCurrentLocation: Centering map on current location');

    if (_currentLocation != null) {
      debugPrint(
        '🎯 _centerOnCurrentLocation: Moving to (${_currentLocation!.latitude}, ${_currentLocation!.longitude}) at zoom 16',
      );
      _mapController.move(LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!), 16.0);
      debugPrint('✅ _centerOnCurrentLocation: Map centered on current location');
    } else {
      debugPrint('❌ _centerOnCurrentLocation: Current location is null');
    }
  }

  void _updateDistanceAndTime() {
    debugPrint('⏱️ _updateDistanceAndTime: Updating navigation distance and time');

    if (_currentLocation == null) {
      debugPrint('❌ _updateDistanceAndTime: Current location is null');
      return;
    }

    LatLng parkingLocation = _getCorrectedParkingLocation();

    // Use valid coordinates or return early
    if (!_areValidCoordinates(parkingLocation.latitude, parkingLocation.longitude)) {
      debugPrint('⚠️ _updateDistanceAndTime: Invalid parking coordinates, skipping update');
      return;
    }

    double distance = _calculateDistance(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
      parkingLocation.latitude,
      parkingLocation.longitude,
    );

    debugPrint('⏱️ _updateDistanceAndTime: New distance: ${distance.toStringAsFixed(3)}km');

    setState(() {
      _distanceRemaining = distance;
      _estimatedTime = distance * 2;
    });

    debugPrint(
      '✅ _updateDistanceAndTime: Navigation info updated - distance: ${distance.toStringAsFixed(3)}km, time: ${_estimatedTime.toStringAsFixed(1)}min',
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️ build: Building RoutingParkingScreen widget');
    // debugPrint('🏗️ build: Current state - isNavigating: $_isNavigating, isLoadingRoute: $_isLoadingRoute');
    debugPrint(
      '🏗️ build: Route points: ${_routePoints.length}, Markers: ${_markers.length}, Polylines: ${_polylines.length}',
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Flutter Map
          // debugPrint('🗺️ build: Rendering FlutterMap') != null ? Container() :
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _currentLocation != null
                      ? LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!)
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
          if (_isRouteLoading)
            Builder(
              builder: (context) {
                debugPrint('⏳ build: Rendering loading indicator');
                return Positioned(top: 120, left: 20, right: 20, child: RouteLoadingIndicatorMinimal());
              },
            ),

          // Enhanced Navigation Info Card
          if (_isNavigating && !_isRouteLoading)
            Builder(
              builder: (context) {
                debugPrint('🧭 build: Rendering navigation info card');
                return Positioned(
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
                        ),
                      );
                    },
                  ),
                );
              },
            ),

          // Enhanced Parking Info Card
          Builder(
            builder: (context) {
              debugPrint('🅿️ build: Rendering parking details card');
              return ParkingDetailsCard(
                slideAnimation: _cardSlideAnimation,
                fadeAnimation: _cardFadeAnimation,
                parking: widget.parking,
                isNavigating: _isNavigating,
                isLoadingRoute: _isRouteLoading,
                onStartNavigation: () {
                  debugPrint('▶️ build: Start navigation button pressed');
                  _startNavigation();
                },
                onStopNavigation: () {
                  debugPrint('⏹️ build: Stop navigation button pressed');
                  _stopNavigation();
                },
                currentLocationName: '',
              );
            },
          ),

          // Enhanced Navigation Button and Top Bar
          Positioned(
            top: 40,
            child: Builder(
              builder: (context) {
                debugPrint('🔝 build: Rendering top navigation bar');
                return SizedBox(
                  width: MediaQuery.of(context).size.width - 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          debugPrint('🔙 build: Back button pressed');
                          Navigator.pop(context);
                        },
                        child: CustomBackButton(),
                      ),
                      Text(''),
                      GestureDetector(
                        onTap: () {
                          debugPrint('🔔 build: Notifications button pressed');
                        },
                        child: NotificationsButton(color: Color(0xffEAEAF3), iconColor: AppColors.primary),
                      ),
                    ],
                  ),
                ).paddingAll(20);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('🗑️ dispose: Starting cleanup of RoutingParkingScreen');

    debugPrint('🗑️ dispose: Cancelling location timer');
    _locationTimer?.cancel();

    debugPrint('🗑️ dispose: Cancelling location subscription');
    _locationSubscription?.cancel();

    debugPrint('🗑️ dispose: Disposing animation controllers');
    _routeAnimationController.dispose();
    _pulseAnimationController.dispose();
    _markerAnimationController.dispose();
    _cardAnimationController.dispose();

    debugPrint('✅ dispose: RoutingParkingScreen cleanup completed');
    super.dispose();
  }
}
