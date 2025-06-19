import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:must_invest/features/explore/data/models/parking.dart';

class RouteServiceWidget {
  final Parking parking;
  final LocationData? currentLocation;
  final Function(List<LatLng>, Map<String, dynamic>) onRouteFound;
  final Function() onRouteError;

  // OpenRouteService API Key
  static const String _apiKey =
      '5b3ce3597851110001cf6248c4040779fe8e41d8ba6f918bf3b007b6';

  RouteServiceWidget({
    required this.parking,
    required this.currentLocation,
    required this.onRouteFound,
    required this.onRouteError,
  });

  Future<void> getTrafficAwareDirections() async {
    if (currentLocation == null) return;

    try {
      bool routeFound = false;
      routeFound = await _tryOpenRouteService();
      if (!routeFound) routeFound = await _tryOSRM();
      if (!routeFound) routeFound = await _tryGoogleDirections();
      if (!routeFound) onRouteError();
    } catch (e) {
      onRouteError();
    }
  }

  Future<bool> _tryOpenRouteService() async {
    try {
      final String url =
          'https://api.openrouteservice.org/v2/directions/driving-car';
      final Map<String, dynamic> requestBody = {
        'coordinates': [
          [currentLocation!.longitude, currentLocation!.latitude],
          // [parking.lng, parking.lat],
          [0, 0],
        ],
        'format': 'geojson',
        'instructions': true,
        'geometry': true,
        'preference': 'fastest',
      };

      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': _apiKey,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['features'] != null && data['features'].isNotEmpty) {
          final route = data['features'][0];
          final geometry = route['geometry'];
          final properties = route['properties'];

          if (geometry != null && geometry['coordinates'] != null) {
            List<LatLng> points =
                (geometry['coordinates'] as List)
                    .map(
                      (coord) =>
                          LatLng(coord[1].toDouble(), coord[0].toDouble()),
                    )
                    .toList();

            if (points.length > 2) {
              onRouteFound(points, properties);
              return true;
            }
          }
        }
      }
    } catch (e) {
      print('OpenRouteService Error: $e');
    }
    return false;
  }

  Future<bool> _tryOSRM() async {
    try {
      final String url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${currentLocation!.longitude},${currentLocation!.latitude};'
          // '${parking.lng},${parking.lat}'
          '0,0'
          '?overview=full&geometries=geojson&steps=true';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final geometry = route['geometry'];

          if (geometry != null && geometry['coordinates'] != null) {
            List<LatLng> points =
                (geometry['coordinates'] as List)
                    .map(
                      (coord) =>
                          LatLng(coord[1].toDouble(), coord[0].toDouble()),
                    )
                    .toList();

            if (points.length > 2) {
              Map<String, dynamic> routeInfo = {
                'distance': (route['distance'] ?? 0),
                'duration': (route['duration'] ?? 0),
              };
              onRouteFound(points, routeInfo);
              return true;
            }
          }
        }
      }
    } catch (e) {
      print('OSRM Error: $e');
    }
    return false;
  }

  Future<bool> _tryGoogleDirections() async {
    return false;
  }
}
