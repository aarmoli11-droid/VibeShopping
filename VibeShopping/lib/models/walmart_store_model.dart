import 'store_kind.dart';

/// Modelo de datos para Walmart (catálogo / referencia informativa).
class WalmartStoreModel {
  const WalmartStoreModel({
    required this.storeId,
    required this.displayName,
    this.regionCode,
    this.externalCatalogUrl,
  });

  final String storeId;
  final String displayName;
  final String? regionCode;
  final String? externalCatalogUrl;

  static const VibeStoreKind kind = VibeStoreKind.walmart;

  Map<String, dynamic> toMap() => {
        'kind': kind.name,
        'storeId': storeId,
        'displayName': displayName,
        'regionCode': regionCode,
        'externalCatalogUrl': externalCatalogUrl,
      };

  factory WalmartStoreModel.fromMap(Map<String, dynamic> map) {
    return WalmartStoreModel(
      storeId: map['storeId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Walmart',
      regionCode: map['regionCode'] as String?,
      externalCatalogUrl: map['externalCatalogUrl'] as String?,
    );
  }
}
