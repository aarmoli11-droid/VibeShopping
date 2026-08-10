class StorePrice {
  final String storeId;
  final String storeName;
  final String? storeLogoUrl;
  final double price;
  final double? latitude;
  final double? longitude;

  const StorePrice({
    required this.storeId,
    required this.storeName,
    this.storeLogoUrl,
    required this.price,
    this.latitude,
    this.longitude,
  });
}
