import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/vibe_constants.dart';
import '../../navigation/providers/navigation_provider.dart';
import '../../explorer/providers/explorer_provider.dart';
import '../widgets/nearby_store_block.dart';

class LocationView extends StatelessWidget {
  const LocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final explorerProvider = context.watch<ExplorerProvider>();
    final navProvider = context.watch<NavigationProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Ubicación',
          style: TextStyle(color: VibeColors.navy),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationCard(context, navProvider),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Supermercados cercanos',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: VibeColors.navy,
                ),
              ),
            ),
            NearbyStoreBlock(stores: explorerProvider.stores),
            _buildMapPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(
      BuildContext context, NavigationProvider navProvider) {
    final String statusText;
    final IconData statusIcon;
    final Color statusColor;

    switch (navProvider.locationState) {
      case LocationState.ready:
        statusText = 'Ubicación disponible';
        statusIcon = Icons.my_location;
        statusColor = Colors.green;
      case LocationState.loading:
        statusText = 'Obteniendo ubicación\u2026';
        statusIcon = Icons.location_searching;
        statusColor = Colors.orange;
      case LocationState.permissionDenied:
        statusText = 'Permiso denegado';
        statusIcon = Icons.location_off;
        statusColor = Colors.red;
      case LocationState.locationDisabled:
        statusText = 'Ubicación desactivada';
        statusIcon = Icons.location_off;
        statusColor = Colors.red;
      case LocationState.error:
        statusText = 'Error al obtener ubicación';
        statusIcon = Icons.error_outline;
        statusColor = Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: VibeColors.navy),
                  SizedBox(width: 8),
                  Text(
                    'Mi ubicación',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: VibeColors.navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(statusIcon, size: 14, color: statusColor),
                  const SizedBox(width: 6),
                  Text(
                    statusText,
                    style: TextStyle(fontSize: 13, color: statusColor),
                  ),
                ],
              ),
              if (navProvider.currentLocation != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${navProvider.currentLocation!.latitude.toStringAsFixed(4)}, '
                      '${navProvider.currentLocation!.longitude.toStringAsFixed(4)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: VibeColors.navy.withValues(alpha: 0.5),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: navProvider.locationState == LocationState.loading
                      ? null
                      : () =>
                          context.read<NavigationProvider>().requestLocation(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Actualizar ubicación'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: VibeColors.navy,
                    side: BorderSide(
                      color: VibeColors.navy.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'Mapa (próximamente)',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
