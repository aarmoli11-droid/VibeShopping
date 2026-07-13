class StoreCoordinate {
  final double latitude;
  final double longitude;

  const StoreCoordinate({
    required this.latitude,
    required this.longitude,
  });
}

class RoutePreparation {
  final List<String> storeIds;
  final Map<String, StoreCoordinate> storeCoordinates;
  final double? estimatedDistance;
  final double? estimatedTravelTime;
  final List<String> bestVisitOrder;

  const RoutePreparation({
    required this.storeIds,
    required this.storeCoordinates,
    this.estimatedDistance,
    this.estimatedTravelTime,
    this.bestVisitOrder = const [],
  });
}
