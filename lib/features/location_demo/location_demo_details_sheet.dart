// Hoja inferior con el detalle completo de la tienda seleccionada.

import 'package:flutter/material.dart';

import '../../core/vibe_constants.dart';
import '../../core/vibe_transport.dart';
import 'location_demo_data.dart';
import 'location_demo_store.dart';

// Muestra la hoja inferior con los datos de la tienda.
void showStoreDetails(BuildContext context, DemoStore store) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: VibeColors.backgroundWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _StoreDetailsSheet(store: store),
  );
}

class _StoreDetailsSheet extends StatelessWidget {
  const _StoreDetailsSheet({required this.store});

  final DemoStore store;

  @override
  Widget build(BuildContext context) {
    final distance = LocationDemoData.distanceTo(store);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: VibeColors.mint,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: VibeColors.navy),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: VibeColors.navy,
                        ),
                      ),
                      Text(
                        store.address,
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: VibeColors.navy,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 28),
            Text(
              'Desde tu ubicación de referencia',
              style: TextStyle(
                fontSize: 12,
                color: VibeColors.navy.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DetailItem(
                  icon: Icons.straighten_rounded,
                  label: 'Distancia',
                  value: '${distance.toStringAsFixed(1)} km',
                ),
                _DetailItem(
                  icon: Icons.directions_car_rounded,
                  label: 'Auto',
                  value: VibeTransport.formatMinutes(
                      VibeTransport.travelMinutes(distance, VibeTransport.carKmh)),
                ),
                _DetailItem(
                  icon: Icons.two_wheeler_rounded,
                  label: 'Moto',
                  value: VibeTransport.formatMinutes(VibeTransport.travelMinutes(
                      distance, VibeTransport.motoKmh)),
                ),
                _DetailItem(
                  icon: Icons.directions_bike_rounded,
                  label: 'Bicicleta',
                  value: VibeTransport.formatMinutes(
                      VibeTransport.travelMinutes(distance, VibeTransport.bikeKmh)),
                ),
                _DetailItem(
                  icon: Icons.directions_walk_rounded,
                  label: 'Caminando',
                  value: VibeTransport.formatMinutes(VibeTransport.travelMinutes(
                      distance, VibeTransport.walkingKmh)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Los tiempos son estimaciones de referencia del prototipo.',
              style: TextStyle(
                fontSize: 11,
                color: VibeColors.navy.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Item de detalle con ícono, etiqueta y valor.
class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22, color: VibeColors.navy),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: VibeColors.navy,
          ),
        ),
      ],
    );
  }
}
