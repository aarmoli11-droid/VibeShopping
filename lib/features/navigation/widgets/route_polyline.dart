import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../domain/navigation_location.dart';
import '../domain/route_entity.dart';

Polyline buildRoutePolyline(StoreRoute route, NavigationLocation origin) {
  final points = route.routePoints
          ?.map(
            (p) => LatLng(p.latitude, p.longitude),
          )
          .toList() ??
      [
        LatLng(origin.latitude, origin.longitude),
        LatLng(route.storeLatitude, route.storeLongitude),
      ];

  return Polyline(
    points: points,
    color: const Color(0xFFA8D5BA),
    strokeWidth: 4,
  );
}
