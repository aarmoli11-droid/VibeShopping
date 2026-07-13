import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../domain/navigation_location.dart';
import '../domain/route_cancelled_exception.dart';
import '../domain/route_entity.dart';
import '../domain/transport_mode.dart';
import '../services/navigation_service.dart';

enum LocationState { loading, permissionDenied, locationDisabled, ready, error }

class NavigationProvider extends ChangeNotifier {
  NavigationProvider({required NavigationService service}) : _service = service;

  final NavigationService _service;

  NavigationLocation? _currentLocation;
  StoreRoute? _currentRoute;
  TransportMode _transportMode = TransportMode.driving;
  bool _isLoading = false;
  String? _error;
  String _currentStoreId = '';
  String _currentStoreName = '';
  LocationState _locationState = LocationState.loading;

  CancelToken? _cancelToken;
  int _requestSequence = 0;

  NavigationLocation? get currentLocation => _currentLocation;
  StoreRoute? get currentRoute => _currentRoute;
  TransportMode get transportMode => _transportMode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentStoreId => _currentStoreId;
  String get currentStoreName => _currentStoreName;
  LocationState get locationState => _locationState;

  String get formattedDistance {
    if (_currentRoute == null) return '';
    return _service.formatDistance(_currentRoute!.distanceMeters);
  }

  String get formattedDuration {
    if (_currentRoute == null) return '';
    return _service.formatDuration(_currentRoute!.durationSeconds);
  }

  Future<void> requestLocation() async {
    _locationState = LocationState.loading;
    _error = null;
    notifyListeners();

    try {
      _currentLocation = await _service.getCurrentLocation();
      _locationState = LocationState.ready;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('desactivado')) {
        _locationState = LocationState.locationDisabled;
        _error = 'El servicio de ubicación está desactivado';
      } else if (msg.contains('denegado permanentemente')) {
        _locationState = LocationState.permissionDenied;
        _error = 'Permiso de ubicación denegado permanentemente';
      } else if (msg.contains('denegado')) {
        _locationState = LocationState.permissionDenied;
        _error = 'Permiso de ubicación denegado';
      } else {
        _locationState = LocationState.error;
        _error = 'Error al obtener ubicación';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> calculateRoute({
    required double destinationLatitude,
    required double destinationLongitude,
    required String storeId,
    required String storeName,
  }) async {
    if (_currentLocation == null) {
      _error = 'Primero debes permitir la ubicación';
      notifyListeners();
      return;
    }

    _requestSequence++;
    final currentSeq = _requestSequence;

    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    _currentStoreId = storeId;
    _currentStoreName = storeName;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final route = await _service.calculateRoute(
        origin: _currentLocation!,
        destinationLatitude: destinationLatitude,
        destinationLongitude: destinationLongitude,
        storeId: storeId,
        storeName: storeName,
        mode: _transportMode,
        cancelToken: _cancelToken,
      );

      if (currentSeq != _requestSequence) return;

      _currentRoute = route;
    } on RouteCancelledException {
      return;
    } catch (e) {
      if (currentSeq != _requestSequence) return;
      _error = 'Error al calcular ruta';
    } finally {
      if (currentSeq == _requestSequence) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void setTransportMode(TransportMode mode) {
    _transportMode = mode;
    notifyListeners();
  }

  void reset() {
    _currentRoute = null;
    _error = null;
    _locationState = LocationState.loading;
    notifyListeners();
  }
}
