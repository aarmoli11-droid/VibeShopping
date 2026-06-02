import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/store_models.dart';
import 'market_catalog_repository.dart';

class MarketCatalogRepositoryImpl implements VibeMarketCatalogRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<WalmartStoreModel>> listWalmartRefs() async {
    final response = await _supabase.from('products').select().eq('store', 'Walmart');
    return (response as List).map((e) => WalmartStoreModel.fromMap(e)).toList();
  }

  @override
  Future<List<MaxiPaliStoreModel>> listMaxiPaliRefs() async {
    final response = await _supabase.from('products').select().eq('store', 'Maxi Pali');
    return (response as List).map((e) => MaxiPaliStoreModel.fromMap(e)).toList();
  }

  @override
  Future<List<BmStoreModel>> listBmRefs() async {
    final response = await _supabase.from('products').select().eq('store', 'BM');
    return (response as List).map((e) => BmStoreModel.fromMap(e)).toList();
  }

  @override
  Future<List<CoopeagriStoreModel>> listCoopeagriRefs() async {
    final response = await _supabase.from('products').select().eq('store', 'Coopeagri');
    return (response as List).map((e) => CoopeagriStoreModel.fromMap(e)).toList();
  }
}

