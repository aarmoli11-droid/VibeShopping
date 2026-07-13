class NavigationLocation {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final DateTime timestamp;

  const NavigationLocation({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    required this.timestamp,
  });
}
