// Datos locales de respaldo de los supermercados del mapa.
// Mismos valores que la tabla `supermarkets` de Supabase (coordenadas reales).
// Se usan cuando la consulta REST devuelve 0 registros (por permisos RLS en
// Web con sesión autenticada). No cambian coordenadas ni nombres.

import 'location_demo_store.dart';

abstract final class LocationDemoStores {
  static const List<DemoStore> stores = [
    DemoStore(
      name: 'Buen Día',
      address: 'Cerca de Maxi Palí San Isidro',
      latitude: 9.3675,
      longitude: -83.6964,
    ),
    DemoStore(
      name: 'Súper Ahorro',
      address: 'Cerca de Walmart San Isidro',
      latitude: 9.3503,
      longitude: -83.6744,
    ),
    DemoStore(
      name: 'Super Vida Saludable',
      address: 'Sector Plaza Monte General',
      latitude: 9.3414,
      longitude: -83.6734,
    ),
    DemoStore(
      name: 'Mi Súper',
      address: 'Cerca de CoopeAgri San Isidro (Avenida 6, Blanco)',
      latitude: 9.3719084,
      longitude: -83.7048317,
    ),
  ];
}