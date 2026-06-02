/// Utilidades para formatear datos visuales en toda la aplicación.
abstract final class VibeFormatter {
  /// Formatea un precio según las reglas de la aplicación:
  /// - Precio < 1.000: ₡price
  /// - Precio >= 1.000: ₡miles.residuo
  static String formatPrice(dynamic price) {
    int intPrice = 0;
    if (price is num) {
      intPrice = price.toInt();
    } else if (price is String) {
      intPrice = double.tryParse(price)?.toInt() ?? 0;
    }

    String formatted = intPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.'
    );
    return '₡$formatted';
  }
}
