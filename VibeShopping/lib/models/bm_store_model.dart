import 'store_kind.dart';

/// Modelo de datos para BM (supermercados BM).
class BmStoreModel {
  const BmStoreModel({
    required this.storeId,
    required this.displayName,
    this.regionCode,
  });

  final String storeId;
  final String displayName;
  final String? regionCode;

  static const VibeStoreKind kind = VibeStoreKind.bm;

  Map<String, dynamic> toMap() => {
        'kind': kind.name,
        'storeId': storeId,
        'displayName': displayName,
        'regionCode': regionCode,
      };

  factory BmStoreModel.fromMap(Map<String, dynamic> map) {
    return BmStoreModel(
      storeId: map['storeId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'BM',
      regionCode: map['regionCode'] as String?,
    );
  }
}
