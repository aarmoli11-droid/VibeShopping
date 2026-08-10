// Coordenadas (y dirección opcional) de un supermercado.
class StoreLocation {
  final double latitude;
  final double longitude;
  final String? address;

  const StoreLocation({
    required this.latitude,
    required this.longitude,
    this.address,
  });
}
