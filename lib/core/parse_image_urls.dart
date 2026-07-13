// ======================================================
// Archivo: core/parse_image_urls.dart
// Responsabilidad: Normalizar URLs de imágenes
// Qué hace: Convierte un valor dinámico (List, String o
//   null) en una lista de strings con URLs válidas
// Cuándo se utiliza: En ProductEntity al construir desde la DB
// Quién lo utiliza: product.dart
//
// Supabase devuelve image_url como string único
// Esta función lo normaliza a List<String>
// ======================================================

List<String> parseImageUrls(dynamic rawImageUrls) {
  if (rawImageUrls is List) {
    return rawImageUrls
        .map((item) => item.toString().trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
  if (rawImageUrls is String && rawImageUrls.isNotEmpty) {
    return [rawImageUrls.trim()];
  }
  return [];
}
