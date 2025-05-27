import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final List<Polyline> polylines;
  final List<Marker> markers;

  const MapWidget({
    Key? key,
    required this.mapController,
    required this.polylines,
    required this.markers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: const LatLng(30.0444, 31.2357), // Default to Cairo
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
        PolylineLayer(polylines: polylines),
        // Markers
        MarkerLayer(markers: markers),
        // Attribution
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }
}
