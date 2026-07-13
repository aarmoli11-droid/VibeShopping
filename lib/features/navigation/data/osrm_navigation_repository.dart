import 'dart:convert';

import 'package:dio/dio.dart';

import '../domain/navigation_location.dart';
import '../domain/route_cancelled_exception.dart';
import '../domain/route_entity.dart';
import '../domain/transport_mode.dart';
import '../repositories/navigation_repository.dart';

class OsrmNavigationRepository implements NavigationRepository {
  OsrmNavigationRepository({
    Dio? dio,
    String baseUrl = _defaultBaseUrl,
  })  : _dio = dio ?? Dio(),
        _baseUrl = baseUrl;

  static const _defaultBaseUrl = 'https://router.project-osrm.org';
  static const _userAgent = 'VibeShopping/1.0';
  static const _timeout = Duration(seconds: 15);

  final Dio _dio;
  final String _baseUrl;

  @override
  Future<NavigationLocation> getCurrentLocation() {
    throw UnsupportedError(
      'OsrmNavigationRepository no obtiene ubicación. '
      'Use GeolocatorNavigationRepository para obtener ubicación.',
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
    final url = '$_baseUrl/route/v1/${mode.apiValue}'
        '/${origin.longitude},${origin.latitude}'
        ';$destLongitude,$destLatitude'
        '?overview=full&geometries=polyline&steps=false&alternatives=false';

    try {
      final response = await _dio.get<String>(
        url,
        options: Options(
          receiveTimeout: _timeout,
          sendTimeout: _timeout,
          headers: {'User-Agent': _userAgent},
        ),
        cancelToken: cancelToken,
      );

      if (response.statusCode != 200) {
        return _errorRoute(
          storeId: storeId,
          storeName: storeName,
          destLatitude: destLatitude,
          destLongitude: destLongitude,
          mode: mode,
          error: 'Error del servidor OSRM (${response.statusCode})',
        );
      }

      final body = _parseResponseBody(response.data);
      if (body == null) {
        return _errorRoute(
          storeId: storeId,
          storeName: storeName,
          destLatitude: destLatitude,
          destLongitude: destLongitude,
          mode: mode,
          error: 'Respuesta inválida de OSRM',
        );
      }

      final routes = body['routes'] as List?;
      if (routes == null || routes.isEmpty) {
        return _errorRoute(
          storeId: storeId,
          storeName: storeName,
          destLatitude: destLatitude,
          destLongitude: destLongitude,
          mode: mode,
          error: 'No se encontró una ruta entre los puntos',
        );
      }

      final route = routes[0] as Map<String, dynamic>;
      final distance = (route['distance'] as num?)?.toDouble() ?? 0;
      final duration = (route['duration'] as num?)?.toInt() ?? 0;
      final geometry = route['geometry'] as String?;

      List<({double latitude, double longitude})>? routePoints;
      if (geometry != null && geometry.isNotEmpty) {
        routePoints = _decodePolyline(geometry);
      }

      return StoreRoute(
        storeId: storeId,
        storeName: storeName,
        storeLatitude: destLatitude,
        storeLongitude: destLongitude,
        distanceMeters: distance,
        durationSeconds: duration,
        transportMode: mode,
        routePoints: routePoints,
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        throw const RouteCancelledException();
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return _errorRoute(
          storeId: storeId,
          storeName: storeName,
          destLatitude: destLatitude,
          destLongitude: destLongitude,
          mode: mode,
          error: 'Tiempo de espera agotado',
        );
      }
      return _errorRoute(
        storeId: storeId,
        storeName: storeName,
        destLatitude: destLatitude,
        destLongitude: destLongitude,
        mode: mode,
        error: 'Error de conexión',
      );
    } catch (_) {
      return _errorRoute(
        storeId: storeId,
        storeName: storeName,
        destLatitude: destLatitude,
        destLongitude: destLongitude,
        mode: mode,
        error: 'Error inesperado',
      );
    }
  }

  Map<String, dynamic>? _parseResponseBody(dynamic data) {
    if (data == null) return null;
    try {
      if (data is Map<String, dynamic>) return data;
      if (data is String) {
        return jsonDecode(data) as Map<String, dynamic>?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  StoreRoute _errorRoute({
    required String storeId,
    required String storeName,
    required double destLatitude,
    required double destLongitude,
    required TransportMode mode,
    String? error,
  }) {
    throw Exception(error ?? 'Error desconocido al calcular ruta');
  }

  /// Decodes a Google Encoded Polyline into a list of lat/lng points.
  ///
  /// Implements the algorithm from:
  /// https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  List<({double latitude, double longitude})> _decodePolyline(String encoded) {
    final points = <({double latitude, double longitude})>[];
    int index = 0;
    int lat = 0;
    int lng = 0;
    final len = encoded.length;

    while (index < len) {
      int shift = 0;
      int result = 0;
      int byte;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final deltaLat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);
      final deltaLng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += deltaLng;

      points.add((
        latitude: lat / 1e5,
        longitude: lng / 1e5,
      ));
    }

    return points;
  }
}
