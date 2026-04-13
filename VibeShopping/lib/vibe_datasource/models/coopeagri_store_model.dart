import 'vibe_store_kind.dart';

/// Modelo de datos para Coopeagri.
class CoopeagriStoreModel {
  const CoopeagriStoreModel({
    required this.storeId,
    required this.displayName,
    this.cooperativeZone,
  });

  final String storeId;
  final String displayName;
  final String? cooperativeZone;

  static const VibeStoreKind kind = VibeStoreKind.coopeagri;

  Map<String, dynamic> toMap() => {
        'kind': kind.name,
        'storeId': storeId,
        'displayName': displayName,
        'cooperativeZone': cooperativeZone,
      };

  factory CoopeagriStoreModel.fromMap(Map<String, dynamic> map) {
    return CoopeagriStoreModel(
      storeId: map['storeId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Coopeagri',
      cooperativeZone: map['cooperativeZone'] as String?,
    );
  }
}
