import 'package:dio/dio.dart';

import '../domain/navigation_location.dart';
import '../domain/route_entity.dart';
import '../domain/transport_mode.dart';
import '../repositories/navigation_repository.dart';

class FakeNavigationRepository implements NavigationRepository {
  @override
  Future<NavigationLocation> getCurrentLocation() async {
    return NavigationLocation(
      latitude: 9.9281,
      longitude: -84.0907,
      accuracy: 10,
      timestamp: DateTime.now(),
    );
  }

  @override
  Future<StoreRoute> getStoreRoute({
    required NavigationLocation origin,
    required double destLatitude,
    required double destLongitude,
    required String storeId,
    required String storeName,
    required TransportMode mode,
    CancelToken? cancelToken,
  }) async {
    final latDiff = (destLatitude - origin.latitude).abs();
    final lngDiff = (destLongitude - origin.longitude).abs();

    final roughDistanceMeters = (latDiff + lngDiff) * 111000.0;
    final speedMs = switch (mode) {
      TransportMode.walking => 1.4,
      TransportMode.driving => 13.9,
      TransportMode.cycling => 5.6,
    };
    final durationSeconds = (roughDistanceMeters / speedMs).round();

    return StoreRoute(
      storeId: storeId,
      storeName: storeName,
      storeLatitude: destLatitude,
      storeLongitude: destLongitude,
      distanceMeters: roughDistanceMeters.round().toDouble(),
      durationSeconds: durationSeconds,
      transportMode: mode,
    );
  }
}
