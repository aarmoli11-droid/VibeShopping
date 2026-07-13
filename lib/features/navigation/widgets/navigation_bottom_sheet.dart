import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/vibe_constants.dart';
import '../providers/navigation_provider.dart';
import '../domain/route_entity.dart';
import '../domain/transport_mode.dart';
import 'navigation_map.dart';
import 'route_information_card.dart';
import 'transport_selector.dart';

class NavigationBottomSheet {
  static bool _isShowing = false;

  static void show({
    required BuildContext context,
    required String storeId,
    required String storeName,
    required double latitude,
    required double longitude,
  }) {
    if (_isShowing) return;
    _isShowing = true;

    final provider = context.read<NavigationProvider>();

    provider.requestLocation().then((_) {
      provider.calculateRoute(
        destinationLatitude: latitude,
        destinationLongitude: longitude,
        storeId: storeId,
        storeName: storeName,
      );
    });

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _NavigationSheetBody(
          storeId: storeId,
          storeName: storeName,
          destinationLatitude: latitude,
          destinationLongitude: longitude,
        );
      },
    ).whenComplete(() => _isShowing = false);
  }
}

class _NavigationSheetBody extends StatefulWidget {
  final String storeId;
  final String storeName;
  final double destinationLatitude;
  final double destinationLongitude;

  const _NavigationSheetBody({
    required this.storeId,
    required this.storeName,
    required this.destinationLatitude,
    required this.destinationLongitude,
  });

  @override
  State<_NavigationSheetBody> createState() => _NavigationSheetBodyState();
}

class _NavigationSheetBodyState extends State<_NavigationSheetBody> {
  @override
  Widget build(BuildContext context) {
    final locationState = context.select<NavigationProvider, LocationState>(
      (p) => p.locationState,
    );
    final error = context.select<NavigationProvider, String?>(
      (p) => p.error,
    );
    final isLoading = context.select<NavigationProvider, bool>(
      (p) => p.isLoading,
    );
    final route = context.select<NavigationProvider, StoreRoute?>(
      (p) => p.currentRoute,
    );
    final transportMode = context.select<NavigationProvider, TransportMode>(
      (p) => p.transportMode,
    );
    final formattedDistance = context.select<NavigationProvider, String>(
      (p) => p.formattedDistance,
    );
    final formattedDuration = context.select<NavigationProvider, String>(
      (p) => p.formattedDuration,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Map (reconstruido solo cuando cambian currentLocation o currentRoute)
          const Expanded(
            child: NavigationMap(),
          ),

          // Bottom info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (locationState == LocationState.loading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text(
                    'Obteniendo ubicación...',
                    style: TextStyle(color: VibeColors.navy),
                  ),
                ] else if (locationState == LocationState.permissionDenied ||
                    locationState == LocationState.locationDisabled) ...[
                  const SizedBox(height: 16),
                  Text(
                    error ?? 'Ubicación no disponible',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      context.read<NavigationProvider>().requestLocation();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ] else ...[
                  TransportSelector(
                    selectedMode: transportMode,
                    onModeSelected: (mode) {
                      final p = context.read<NavigationProvider>();
                      p.setTransportMode(mode);
                      p.calculateRoute(
                        destinationLatitude: widget.destinationLatitude,
                        destinationLongitude: widget.destinationLongitude,
                        storeId: widget.storeId,
                        storeName: widget.storeName,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else if (route != null)
                    RouteInformationCard(
                      route: route,
                      formattedDistance: formattedDistance,
                      formattedDuration: formattedDuration,
                    )
                  else if (error != null)
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: route != null
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Navegación externa próximamente'),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.navigation),
                      label: const Text('Iniciar navegación'),
                      style: FilledButton.styleFrom(
                        backgroundColor: VibeColors.navy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
