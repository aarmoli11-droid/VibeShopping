import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../domain/navigation_location.dart';

Marker buildUserLocationMarker(NavigationLocation location) {
  return Marker(
    point: LatLng(location.latitude, location.longitude),
    child: const Icon(
      Icons.my_location,
      color: Color(0xFF2C3E50),
      size: 28,
    ),
  );
}
