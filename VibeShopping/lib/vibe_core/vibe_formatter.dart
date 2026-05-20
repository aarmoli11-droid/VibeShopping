/// Utilidades para formatear datos visuales en toda la aplicación.
abstract final class VibeFormatter {
  /// Formatea un precio según las reglas de la aplicación:
  /// - Precio < 1.000: ₡price
  /// - Precio >= 1.000: ₡miles.residuo
  static String formatPrice(dynamic price) {
    print('DEBUG 2 - Entrada Formateador: $price');
    int intPrice = 0;
    if (price is String) {
      intPrice = int.tryParse(price) ?? 0;
    } else if (price is double) {
      intPrice = price.toInt();
    } else if (price is int) {
      intPrice = price;
    }

    if (intPrice < 1000) {
      return '₡$intPrice';
    }

    final int thousands = intPrice ~/ 1000;
    final int remainder = intPrice % 1000;

    final result = '₡$thousands.${remainder.toString().padLeft(3, '0')}';
    print('DEBUG 3 - Salida Formateador: $result');
    return result;
  }
}
