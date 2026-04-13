import '../models/models.dart';

/// Contrato para obtener referencias de tiendas/cadenas (solo lectura / informativo).
abstract class VibeMarketCatalogRepository {
  Future<List<WalmartStoreModel>> listWalmartRefs();
  Future<List<MaxiPaliStoreModel>> listMaxiPaliRefs();
  Future<List<BmStoreModel>> listBmRefs();
  Future<List<CoopeagriStoreModel>> listCoopeagriRefs();
}
