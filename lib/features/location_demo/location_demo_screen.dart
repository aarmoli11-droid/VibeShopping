// Mapa real de San Isidro de El General con supermercados,
// distancias y tiempos de traslado (flutter_map + OpenStreetMap).
// Las tiendas se cargan desde Supabase (tabla `supermarkets`).

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../core/data/supabase/supabase_product_repository.dart';
import '../../core/vibe_constants.dart';
import 'location_demo_data.dart';
import 'location_demo_details_sheet.dart';
import 'location_demo_map_widgets.dart';
import 'location_demo_stores.dart';
import 'location_demo_store.dart';

class LocationDemoScreen extends StatefulWidget {
  const LocationDemoScreen({super.key});

  @override
  State<LocationDemoScreen> createState() => _LocationDemoScreenState();
}

class _LocationDemoScreenState extends State<LocationDemoScreen> {
  final MapController _mapController = MapController();

  List<DemoStore> _stores = const [];
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStores());
  }

  // Carga las tiendas desde Supabase (misma fuente que el asistente).
  // Si la consulta REST devuelve 0 (permisos RLS en Web autenticado), usa
  // los datos locales de respaldo para que el mapa siempre muestre marcadores.
  Future<void> _loadStores() async {
    try {
      final supermarkets =
          await context.read<SupabaseProductRepository>().listSupermarkets();
      if (!mounted) return;

      final loaded = <DemoStore>[];
      for (final store in supermarkets) {
        final lat = store.latitude;
        final lng = store.longitude;
        if (lat == null || lng == null) continue;
        loaded.add(DemoStore(
          name: store.name,
          address: store.locations.isNotEmpty
              ? store.locations.first.address ?? ''
              : '',
          latitude: lat,
          longitude: lng,
        ));
      }

      setState(() {
        _stores = loaded.isEmpty ? LocationDemoStores.stores : loaded;
        _loading = false;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _stores = LocationDemoStores.stores;
        _loading = false;
        _hasError = false;
      });
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VibeColors.backgroundWhite,
      appBar: AppBar(
        title: const Text('Ubicación'),
        backgroundColor: VibeColors.backgroundWhite,
        foregroundColor: VibeColors.navy,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                'Consulta la distancia hasta tus supermercados',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cloud_off_rounded,
                                    size: 40, color: Colors.grey),
                                SizedBox(height: 12),
                                Text(
                                  'No se pudieron cargar los supermercados.\n'
                                  'Verifica tu conexión e inténtalo de nuevo.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _buildMap(),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                'Selecciona una tienda para consultar su distancia y tiempo de viaje.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mapa real con marcadores y controles de zoom sobrepuestos.
  Widget _buildMap() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(
                  LocationDemoData.userLatitude,
                  LocationDemoData.userLongitude,
                ),
                initialZoom: LocationDemoData.initialZoom,
                minZoom: LocationDemoData.minZoom,
                maxZoom: LocationDemoData.maxZoom,
                backgroundColor: VibeColors.backgroundMint,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: LocationDemoData.tileUrlTemplate,
                  userAgentPackageName: LocationDemoData.userAgentPackageName,
                  maxNativeZoom: 19,
                ),
                MarkerLayer(markers: _buildMarkers()),
                const SimpleAttributionWidget(
                  source: Text(LocationDemoData.attribution),
                ),
              ],
            ),
            ZoomControls(
              onZoomIn: () => _changeZoom(1),
              onZoomOut: () => _changeZoom(-1),
            ),
          ],
        ),
      ),
    );
  }

  // Marcadores de las tiendas (desde Supabase) y de la ubicación del usuario.
  List<Marker> _buildMarkers() {
    return [
      for (final store in _stores)
        Marker(
          point: LatLng(store.latitude, store.longitude),
          width: 120,
          height: 40,
          alignment: Alignment.topCenter,
          child: StoreMarker(
            store: store,
            onTap: () => showStoreDetails(context, store),
          ),
        ),
      Marker(
        point: const LatLng(
          LocationDemoData.userLatitude,
          LocationDemoData.userLongitude,
        ),
        width: 130,
        height: 40,
        alignment: Alignment.topCenter,
        child: const UserMarker(),
      ),
    ];
  }

  // Aplica un cambio de zoom al centro actual del mapa.
  void _changeZoom(double delta) {
    final camera = _mapController.camera;
    final zoom = (camera.zoom + delta)
        .clamp(LocationDemoData.minZoom, LocationDemoData.maxZoom);
    _mapController.move(camera.center, zoom.toDouble());
  }
}
