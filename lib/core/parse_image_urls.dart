// Normaliza el valor de image_url (List, String o null) a List<String>.

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
