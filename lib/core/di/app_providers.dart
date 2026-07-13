import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/services/supabase_auth_service.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/categories/domain/repositories/category_repository.dart';
import '../../features/categories/data/repositories/supabase_category_repository.dart';
import '../../features/categories/services/category_service.dart';
import '../../features/categories/providers/category_provider.dart';
import '../repositories/product_repository.dart';
import '../data/supabase/supabase_product_repository.dart';
import '../../features/products/services/product_service.dart';
import '../../features/products/providers/product_provider.dart';
import '../../features/explorer/services/explorer_service.dart';
import '../../features/explorer/providers/explorer_provider.dart';
import '../../features/assistant/services/assistant_service.dart';
import '../../features/assistant/providers/assistant_provider.dart';
import '../../features/manual_lists/providers/manual_list_provider.dart';
import '../../features/comparison/providers/comparison_provider.dart';
import '../../features/navigation/repositories/navigation_repository.dart';
import '../../features/navigation/data/osrm_navigation_repository.dart';
import '../../features/navigation/data/geolocator_navigation_repository.dart';
import '../../features/navigation/services/navigation_service.dart';
import '../../features/navigation/providers/navigation_provider.dart';
import '../api_client.dart';

class AppProviders {
  static List<dynamic> get providers => [
        // ——— Auth ———
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: SupabaseAuthService(Supabase.instance.client),
          ),
        ),

        // ——— Products ———
        Provider(
          create: (_) => SupabaseProductRepository(
            supabase: Supabase.instance.client,
          ) as ProductRepository,
        ),
        Provider(
          create: (_) => ProductService(
            repository: _.read<ProductRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(
            service: _.read<ProductService>(),
          ),
        ),

        // ——— Categories ———
        Provider(
          create: (_) => SupabaseCategoryRepository(
            supabase: Supabase.instance.client,
          ) as CategoryRepository,
        ),
        Provider(
          create: (_) => CategoryService(
            repository: _.read<CategoryRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(
            service: _.read<CategoryService>(),
          ),
        ),

        // ——— Explorer ———
        Provider(create: (_) => ExplorerService()),
        ChangeNotifierProvider(
          create: (_) => ExplorerProvider(
            service: _.read<ExplorerService>(),
            productProvider: _.read<ProductProvider>(),
            categoryProvider: _.read<CategoryProvider>(),
          ),
        ),

        // ——— Assistant (IA) ———
        Provider(
          create: (_) => AssistantService(
            apiClient: ApiClient.instance,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AssistantProvider(
            service: _.read<AssistantService>(),
          ),
        ),

        // ——— Comparison ———
        ChangeNotifierProvider(
          create: (_) => ComparisonProvider(
            productProvider: _.read<ProductProvider>(),
          ),
        ),

        // ——— Manual Lists (Hive) ———
        ChangeNotifierProvider(
          create: (_) => ManualListProvider(
            productProvider: _.read<ProductProvider>(),
          ),
        ),

        // ——— Navigation (Mapa) ———
        ChangeNotifierProvider(
          create: (_) {
            final routeRepo =
                OsrmNavigationRepository() as NavigationRepository;
            final locationRepo =
                GeolocatorNavigationRepository() as NavigationRepository;
            return NavigationProvider(
              service: NavigationService(
                routeRepository: routeRepo,
                locationRepository: locationRepo,
              ),
            );
          },
        ),
      ];
}
