// Datos del mapa de supermercados de San Isidro de El General.
// Coordenadas de referencia obtenidas de OpenStreetMap (prototipo).

import 'dart:math' as math;

import 'location_demo_store.dart';

abstract final class LocationDemoData {
  // Tiles de OpenStreetMap (sin API key).
  static const String tileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  // User-Agent de las peticiones de tiles (buena práctica de OSM).
  static const String userAgentPackageName = 'com.example.vibeshopping';

  // Atribución requerida por la política de OSM.
  static const String attribution = '© OpenStreetMap contributors';

  // Posición de referencia del usuario (centro de San Isidro).
  // En una versión real esto se reemplaza por la ubicación del GPS.
  static const double userLatitude = 9.3760;
  static const double userLongitude = -83.7025;

  // Zoom inicial para ver el usuario y todas las tiendas.
  static const double initialZoom = 13.5;

  // Límites de zoom del mapa.
  static const double minZoom = 10;
  static const double maxZoom = 18;

  // Supermercados reales de San Isidro de El General.
  static const List<DemoStore> stores = [
    DemoStore(
      name: 'BM Bostón', 
      address: 'Alameda Venegas, El Prado',
      latitude: 9.3808282,
      longitude: -83.7061450,
    ),
    DemoStore(
      name: 'CoopeAgri San Luis',
      address: 'Calle 14, Barrio San Luis',
      latitude: 9.3857375,
      longitude: -83.7065238,
    ),
    DemoStore(
      name: 'Maxi Palí',
      address: 'Vía 242, Barrio Sinaí',
      latitude: 9.3675409,
      longitude: -83.6964465,
    ),
    DemoStore(
      name: 'Mega Súper',
      address: 'Calle 1, España, San Isidro',
      latitude: 9.3710061,
      longitude: -83.7032739,
    ),
  ];

  // Radio promedio de la Tierra en kilómetros.
  static const double _earthRadiusKm = 6371.0;

  // Distancia en línea recta entre dos coordenadas (Haversine).
  static double haversineKm(
      double lat1, double lon1, double lat2, double lon2) {
    double toRad(double deg) => deg * math.pi / 180;

    final dLat = toRad(lat2 - lat1);
    final dLon = toRad(lon2 - lon1);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(toRad(lat1)) *
            math.cos(toRad(lat2)) *
            math.pow(math.sin(dLon / 2), 2);

    return 2 * _earthRadiusKm * math.asin(math.sqrt(a));
  }

  // Distancia del usuario a una tienda (kilómetros).
  static double distanceTo(DemoStore store) =>
      haversineKm(userLatitude, userLongitude, store.latitude, store.longitude);

  // Tiempo de traslado en minutos según la velocidad (km/h).
  static String travelTime(DemoStore store, double speedKmh) {
    final minutes = (distanceTo(store) / speedKmh * 60).round();
    return '$minutes min';
  }

  // Velocidades promedio (estimaciones de referencia del prototipo).
  static const double walkSpeedKmh = 5;
  static const double bikeSpeedKmh = 15;
  static const double motoSpeedKmh = 35;
  static const double carSpeedKmh = 40;
}
