class StoreModel {
  final String id;
  final String name;
  final String? logoUrl;
  final double? latitude;
  final double? longitude;

  const StoreModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.latitude,
    this.longitude,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) => StoreModel(
        id: json['id'] as String,
        name: json['name'] as String,
        logoUrl: json['logo_url'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  StoreModel copyWith({
    String? id,
    String? name,
    String? logoUrl,
    double? latitude,
    double? longitude,
  }) =>
      StoreModel(
        id: id ?? this.id,
        name: name ?? this.name,
        logoUrl: logoUrl ?? this.logoUrl,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StoreModel &&
          id == other.id &&
          name == other.name &&
          logoUrl == other.logoUrl &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => Object.hash(id, name, logoUrl, latitude, longitude);

  @override
  String toString() => 'StoreModel(id: $id, name: $name, logoUrl: $logoUrl, '
      'latitude: $latitude, longitude: $longitude)';
}
