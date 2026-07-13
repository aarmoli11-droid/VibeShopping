import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import '../domain/navigation_location.dart';
import '../domain/route_entity.dart';
import '../domain/transport_mode.dart';
import '../repositories/navigation_repository.dart';

class GeolocatorNavigationRepository implements NavigationRepository {
  @override
  Future<NavigationLocation> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('El servicio de ubicación está desactivado');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permiso de ubicación denegado');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Permiso de ubicación denegado permanentemente',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    return NavigationLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
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
  }) {
    throw UnsupportedError(
      'GeolocatorNavigationRepository no calcula rutas. '
      'Use OsrmNavigationRepository para rutas reales.',
    );
  }
}
