import '../explorer/domain/store_model.dart';
import '../location_demo/location_demo_data.dart';

// Datos auxiliares del asistente: posición ficticia y distancias.
abstract final class ShoppingAssistantData {
  // Posición ficticia del usuario (centro de San Isidro).
  static const double userLatitude = LocationDemoData.userLatitude;
  static const double userLongitude = LocationDemoData.userLongitude;

  // Distancia en km a una tienda (Haversine), o null sin coordenadas.
  static double? distanceToStore(StoreModel? store) {
    final lat = store?.latitude;
    final lng = store?.longitude;
    if (lat == null || lng == null) return null;

    return LocationDemoData.haversineKm(userLatitude, userLongitude, lat, lng);
  }
}
