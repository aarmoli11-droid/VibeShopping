// ======================================================
// Archivo: core/vibe_formatter.dart
// Responsabilidad: Formatear datos para mostrarlos en UI
// Qué hace: Convierte números en precios con formato
//   costarricense (₡1.000, ₡25.500, etc.)
// Cuándo se utiliza: En tarjetas de producto, lista de
//   compras, detalle de producto
// Quién lo utiliza: ProductDisplayHelper, ManualListsView
// ======================================================

abstract final class VibeFormatter {
  // ======================================================
  // Función: formatPrice
  // Recibe: un valor numérico (int, double) o string
  // Devuelve: string con formato "₡1.500"
  //
  // Reglas:
  // - Precio < 1.000 → ₡price
  // - Precio >= 1.000 → ₡miles.residuo (punto como separador)
  // ======================================================
  static String formatPrice(dynamic price) {
    int integerPrice = 0;

    // Convertir el valor recibido a entero
    if (price is num) {
      integerPrice = price.toInt();
    } else if (price is String) {
      integerPrice = double.tryParse(price)?.toInt() ?? 0;
    }

    // Agregar separador de miles con regex
    String formatted = integerPrice.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]}.',
        );

    return '₡$formatted';
  }
}
