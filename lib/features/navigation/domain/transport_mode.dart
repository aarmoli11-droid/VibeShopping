enum TransportMode {
  walking,
  driving,
  cycling;

  String get label {
    switch (this) {
      case TransportMode.walking:
        return 'Caminando';
      case TransportMode.driving:
        return 'En auto';
      case TransportMode.cycling:
        return 'En bici';
    }
  }

  String get apiValue {
    switch (this) {
      case TransportMode.walking:
        return 'foot';
      case TransportMode.driving:
        return 'driving';
      case TransportMode.cycling:
        return 'cycling';
    }
  }
}
