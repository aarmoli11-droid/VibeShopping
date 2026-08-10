import 'store_location.dart';

// Supermercado derivado de los precios del catálogo.
class StoreModel {
  final String id;
  final String name;
  final String? logoUrl;
  final List<StoreLocation> locations;

  const StoreModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.locations = const [],
  });

  double? get latitude =>
      locations.isNotEmpty ? locations.first.latitude : null;
  double? get longitude =>
      locations.isNotEmpty ? locations.first.longitude : null;
}
