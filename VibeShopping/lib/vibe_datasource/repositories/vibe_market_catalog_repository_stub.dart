import '../../models/models.dart';
import 'vibe_market_catalog_repository.dart';

/// Implementación temporal en memoria — sustituir por Firestore u otra fuente.
class VibeMarketCatalogRepositoryStub implements VibeMarketCatalogRepository {
  @override
  Future<List<BmStoreModel>> listBmRefs() async {
    return const [
      BmStoreModel(storeId: 'bm-001', displayName: 'BM'),
    ];
  }

  @override
  Future<List<CoopeagriStoreModel>> listCoopeagriRefs() async {
    return const [
      CoopeagriStoreModel(storeId: 'coopeagri-001', displayName: 'Coopeagri'),
    ];
  }

  @override
  Future<List<MaxiPaliStoreModel>> listMaxiPaliRefs() async {
    return const [
      MaxiPaliStoreModel(storeId: 'maxi-001', displayName: 'Maxi Palí'),
    ];
  }

  @override
  Future<List<WalmartStoreModel>> listWalmartRefs() async {
    return const [
      WalmartStoreModel(storeId: 'wal-001', displayName: 'Walmart'),
    ];
  }
}
