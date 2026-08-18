// Mapa real de San Isidro de El General con supermercados,
// distancias y tiempos de traslado (flutter_map + OpenStreetMap).

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/vibe_constants.dart';
import 'location_demo_data.dart';
import 'location_demo_details_sheet.dart';
import 'location_demo_map_widgets.dart';

class LocationDemoScreen extends StatefulWidget {
  const LocationDemoScreen({super.key});

  @override
  State<LocationDemoScreen> createState() => _LocationDemoScreenState();
}

class _LocationDemoScreenState extends State<LocationDemoScreen> {
  final MapController _mapController = MapController();

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
            Expanded(child: _buildMap()),
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

  // Marcadores de las tiendas y de la ubicación del usuario.
  List<Marker> _buildMarkers() {
    return [
      for (final store in LocationDemoData.stores)
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
