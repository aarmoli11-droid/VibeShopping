import 'vibe_store_kind.dart';

/// Modelo de datos para Maxi Palí.
class MaxiPaliStoreModel {
  const MaxiPaliStoreModel({
    required this.storeId,
    required this.displayName,
    this.regionCode,
    this.branchName,
  });

  final String storeId;
  final String displayName;
  final String? regionCode;
  final String? branchName;

  static const VibeStoreKind kind = VibeStoreKind.maxiPali;

  Map<String, dynamic> toMap() => {
        'kind': kind.name,
        'storeId': storeId,
        'displayName': displayName,
        'regionCode': regionCode,
        'branchName': branchName,
      };

  factory MaxiPaliStoreModel.fromMap(Map<String, dynamic> map) {
    return MaxiPaliStoreModel(
      storeId: map['storeId'] as String? ?? '',
      displayName: map['displayName'] as String? ?? 'Maxi Palí',
      regionCode: map['regionCode'] as String?,
      branchName: map['branchName'] as String?,
    );
  }
}
