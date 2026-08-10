// Formatea precios al estilo costarricense (₡1.500, ₡25.500).

abstract final class VibeFormatter {
  static String formatPrice(dynamic price) {
    int integerPrice = 0;

    if (price is num) {
      integerPrice = price.toInt();
    } else if (price is String) {
      integerPrice = double.tryParse(price)?.toInt() ?? 0;
    }

    final formatted = integerPrice.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]}.',
        );

    return '₡$formatted';
  }
}
