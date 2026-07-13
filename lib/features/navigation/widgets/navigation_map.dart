import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../providers/navigation_provider.dart';
import '../domain/navigation_location.dart';
import '../domain/route_entity.dart';
import 'user_location_marker.dart';
import 'store_marker.dart';
import 'route_polyline.dart';

class NavigationMap extends StatelessWidget {
  const NavigationMap({super.key});

  @override
  Widget build(BuildContext context) {
    final location = context.select<NavigationProvider, NavigationLocation?>(
      (p) => p.currentLocation,
    );
    final route = context.select<NavigationProvider, StoreRoute?>(
      (p) => p.currentRoute,
    );

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(
            location?.latitude ?? 9.9281,
            location?.longitude ?? -84.0907,
          ),
          initialZoom: 14,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          if (location != null)
            MarkerLayer(markers: [
              buildUserLocationMarker(location),
            ]),
          if (route != null)
            MarkerLayer(markers: [
              buildStoreMarker(route),
            ]),
          if (location != null && route != null)
            PolylineLayer(polylines: [
              buildRoutePolyline(route, location),
            ]),
        ],
      ),
    );
  }
}
