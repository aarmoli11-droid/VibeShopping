import 'package:dio/dio.dart';

import '../domain/navigation_location.dart';
import '../domain/route_entity.dart';
import '../domain/transport_mode.dart';
import '../repositories/navigation_repository.dart';

class NavigationService {
  final NavigationRepository _routeRepository;
  final NavigationRepository? _locationRepository;

  NavigationService({
    required NavigationRepository routeRepository,
    NavigationRepository? locationRepository,
  })  : _routeRepository = routeRepository,
        _locationRepository = locationRepository;

  Future<NavigationLocation> getCurrentLocation() {
    if (_locationRepository != null) {
      return _locationRepository!.getCurrentLocation();
    }
    return _routeRepository.getCurrentLocation();
  }

  Future<StoreRoute> calculateRoute({
    required NavigationLocation origin,
    required double destinationLatitude,
    required double destinationLongitude,
    required String storeId,
    required String storeName,
    required TransportMode mode,
    CancelToken? cancelToken,
  }) {
    return _routeRepository.getStoreRoute(
      origin: origin,
      destLatitude: destinationLatitude,
      destLongitude: destinationLongitude,
      storeId: storeId,
      storeName: storeName,
      mode: mode,
      cancelToken: cancelToken,
    );
  }

  String formatDistance(double meters) {
    if (meters >= 1000) {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }

  String formatDuration(int seconds) {
    if (seconds >= 3600) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      if (minutes == 0) return '$hours h';
      return '$hours h $minutes min';
    }
    final minutes = (seconds / 60).round();
    return '$minutes min';
  }
}
