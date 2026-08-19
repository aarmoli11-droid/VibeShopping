// Velocidades promedio de transporte (km/h) y cálculo de tiempos de traslado.
// Única fuente para toda la aplicación (mapa de Ubicación y asistente).

abstract final class VibeTransport {
  // Velocidades en km/h (estimaciones de referencia del prototipo).
  static const double carKmh = 30;
  static const double busKmh = 20;
  static const double motoKmh = 35;
  static const double bikeKmh = 15;
  static const double walkingKmh = 5;

  // Tiempo estimado de traslado en minutos (redondeo hacia arriba,
  // igual que el asistente) a partir de la distancia en km.
  static int travelMinutes(double distanceKm, double speedKmh) {
    if (speedKmh <= 0) return 0;
    return (distanceKm / speedKmh * 60).ceil();
  }

  static String formatMinutes(int minutes) => '$minutes min';
}