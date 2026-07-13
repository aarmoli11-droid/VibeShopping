import 'package:dio/dio.dart';

import '../domain/navigation_location.dart';
import '../domain/route_entity.dart';
import '../domain/transport_mode.dart';

abstract class NavigationRepository {
  Future<NavigationLocation> getCurrentLocation();
  Future<StoreRoute> getStoreRoute({
    required NavigationLocation origin,
    required double destLatitude,
    required double destLongitude,
    required String storeId,
    required String storeName,
    required TransportMode mode,
    CancelToken? cancelToken,
  });
}
