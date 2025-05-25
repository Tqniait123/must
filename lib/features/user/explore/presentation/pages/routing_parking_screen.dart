import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:must_invest/features/user/home/data/models/parking_model.dart';

class RoutingParkingScreen extends StatefulWidget {
  final Parking parking;
  const RoutingParkingScreen({super.key, required this.parking});

  @override
  State<RoutingParkingScreen> createState() => _RoutingParkingScreenState();
}

class _RoutingParkingScreenState extends State<RoutingParkingScreen>
    with TickerProviderStateMixin {
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
  late Animation<double> _routeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _markerAnimation;

  bool _isNavigating = false;
  double _distanceRemaining = 0.0;
  double _estimatedTime = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _requestLocationPermission();
  }

  void _initializeAnimations() {
    _routeAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _markerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _routeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _routeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _markerAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _markerAnimationController,
        curve: Curves.easeInOut,
      ),
    );
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
        _getDirections();
        _startLocationTracking();
        _centerMapOnRoute();
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _startLocationTracking() {
    _locationSubscription = _location.onLocationChanged.listen((
      LocationData locationData,
    ) {
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

      // Current location marker (animated)
      _markers.add(
        Marker(
          point: LatLng(
            _currentLocation!.latitude!,
            _currentLocation!.longitude!,
          ),
          width: 60,
          height: 60,
          child: AnimatedBuilder(
            animation: _markerAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isNavigating ? _markerAnimation.value : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.my_location,
                      color: Colors.blue,
                      size: 30,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Parking location marker
      _markers.add(
        Marker(
          point: LatLng(widget.parking.lat, widget.parking.lng),
          width: 60,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              color:
                  widget.parking.isBusy
                      ? Colors.red.withOpacity(0.2)
                      : Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.local_parking,
                color: widget.parking.isBusy ? Colors.red : Colors.green,
                size: 35,
              ),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _getDirections() async {
    if (_currentLocation == null) return;

    // Using OpenRouteService API (free alternative to Google Directions)
    // You can also use OSRM or Mapbox
    final String apiKey =
        'YOUR_OPENROUTESERVICE_API_KEY'; // Get free key from openrouteservice.org
    final String coordinates =
        '${_currentLocation!.longitude},${_currentLocation!.latitude}|${widget.parking.lng},${widget.parking.lat}';

    final String url =
        'https://api.openrouteservice.org/v2/directions/driving-car?'
        'api_key=$apiKey&start=${_currentLocation!.longitude},${_currentLocation!.latitude}'
        '&end=${widget.parking.lng},${widget.parking.lat}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': apiKey},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'].isNotEmpty) {
          _decodeGeoJsonRoute(data['features'][0]['geometry']['coordinates']);
          _calculateDistanceAndTime(data['features'][0]['properties']);
        }
      } else {
        // Fallback to straight line
        _drawStraightLine();
      }
    } catch (e) {
      print('Error getting directions: $e');
      // Fallback: draw straight line
      _drawStraightLine();
    }
  }

  void _decodeGeoJsonRoute(List<dynamic> coordinates) {
    List<LatLng> points =
        coordinates
            .map((coord) => LatLng(coord[1].toDouble(), coord[0].toDouble()))
            .toList();

    setState(() {
      _routePoints = points;
    });
    _animateRoute();
  }

  void _drawStraightLine() {
    if (_currentLocation == null) return;

    setState(() {
      _routePoints = [
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        LatLng(widget.parking.lat, widget.parking.lng),
      ];
    });
    _animateRoute();
    _calculateDirectDistance();
  }

  void _calculateDirectDistance() {
    if (_currentLocation == null) return;

    double distance = _calculateDistance(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
      widget.parking.lat,
      widget.parking.lng,
    );

    setState(() {
      _distanceRemaining = distance;
      _estimatedTime = distance * 2; // Rough estimate: 2 minutes per km
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
      _polylines.add(
        Polyline(
          points: animatedPoints,
          color: _isNavigating ? Colors.blue : Colors.orange,
          strokeWidth: 5.0,
          // isDotted: !_isNavigating,
        ),
      );

      // Add a shadow polyline for better visibility
      if (animatedPoints.length > 1) {
        _polylines.insert(
          0,
          Polyline(
            points: animatedPoints,
            color: Colors.black.withOpacity(0.3),
            strokeWidth: 7.0,
          ),
        );
      }
    });
  }

  void _calculateDistanceAndTime(Map<String, dynamic> properties) {
    setState(() {
      _distanceRemaining =
          (properties['segments'][0]['distance'] / 1000.0); // Convert to km
      _estimatedTime =
          (properties['segments'][0]['duration'] / 60.0); // Convert to minutes
    });
  }

  void _updateDistanceAndTime() {
    if (_currentLocation == null) return;

    double distance = _calculateDistance(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
      widget.parking.lat,
      widget.parking.lng,
    );

    setState(() {
      _distanceRemaining = distance;
      _estimatedTime = distance * 2; // Rough estimate: 2 minutes per km
    });
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

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

    LatLng currentPos = LatLng(
      _currentLocation!.latitude!,
      _currentLocation!.longitude!,
    );
    LatLng parkingPos = LatLng(widget.parking.lat, widget.parking.lng);

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
      _mapController.move(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.parking.title),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnCurrentLocation,
          ),
          IconButton(
            icon: const Icon(Icons.center_focus_strong),
            onPressed: _centerMapOnRoute,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Flutter Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:
                  _currentLocation != null
                      ? LatLng(
                        _currentLocation!.latitude!,
                        _currentLocation!.longitude!,
                      )
                      : LatLng(widget.parking.lat, widget.parking.lng),
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
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // Navigation Info Card
          if (_isNavigating)
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade600,
                              Colors.blue.shade400,
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${_distanceRemaining.toStringAsFixed(1)} كم',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Text(
                                        'المسافة المتبقية',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(
                                    Icons.navigation,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${_estimatedTime.toStringAsFixed(0)} دقيقة',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Text(
                                        'الوقت المتوقع',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Parking Info Card
          Positioned(
            bottom: 100,
            left: 20,
            right: 20,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey.shade50],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              widget.parking.imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey.shade300,
                                  child: const Icon(Icons.local_parking),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.parking.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.parking.address,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: Colors.blue.shade600,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${widget.parking.distanceInMinutes} دقيقة',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Icon(
                                      Icons.attach_money,
                                      size: 16,
                                      color: Colors.green.shade600,
                                    ),
                                    Text(
                                      '${widget.parking.pricePerHour} ج.م/ساعة',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  widget.parking.isBusy
                                      ? Colors.red
                                      : Colors.green,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: (widget.parking.isBusy
                                          ? Colors.red
                                          : Colors.green)
                                      .withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.parking.isBusy ? 'مشغول' : 'متاح',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Navigation Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: (_isNavigating ? Colors.red : Colors.blue)
                        .withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isNavigating ? _stopNavigation : _startNavigation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isNavigating ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isNavigating ? Icons.stop : Icons.navigation),
                    const SizedBox(width: 8),
                    Text(
                      _isNavigating ? 'إيقاف التنقل' : 'بدء التنقل',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
    super.dispose();
  }
}
