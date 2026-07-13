import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/vibe_constants.dart';
import '../domain/route_entity.dart';

Marker buildStoreMarker(StoreRoute route) {
  return Marker(
    point: LatLng(route.storeLatitude, route.storeLongitude),
    child: const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.store, color: VibeColors.mint, size: 32),
        Icon(Icons.location_on, color: VibeColors.mint, size: 16),
      ],
    ),
  );
}
