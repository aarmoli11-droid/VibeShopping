import 'transport_mode.dart';

class StoreRoute {
  final String storeId;
  final String storeName;
  final double storeLatitude;
  final double storeLongitude;
  final double distanceMeters;
  final int durationSeconds;
  final TransportMode transportMode;
  final List<({double latitude, double longitude})>? routePoints;

  const StoreRoute({
    required this.storeId,
    required this.storeName,
    required this.storeLatitude,
    required this.storeLongitude,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.transportMode,
    this.routePoints,
  });
}
