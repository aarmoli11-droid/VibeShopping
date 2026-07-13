import { supabase } from '../../config/supabase';
import { AnalyzedQuery } from '../types/analyzedQuery';
import {
  CatalogProduct,
  CatalogStatistics,
  SearchParams,
  SearchResult,
  StoreInfo,
  mapRowToCatalogProduct,
} from '../types/catalogProduct';

export class AssistantRepository {
  async search(analyzed: AnalyzedQuery): Promise<SearchResult> {
    const params = this._analyzedToSearchParams(analyzed);
    let query = supabase.from('v_products_complete').select('*');

    if (params.query && params.query.length > 0) {
      query = query.ilike('canonical_name', `%${params.query}%`);
    }

    if (params.categoryId && params.categoryId !== 'todo') {
      query = this._applyCategoryFilter(query, params.categoryId);
    }

    if (params.supermarketId) {
      query = query.eq('supermarket_id', params.supermarketId);
    }

    if (params.storeIds && params.storeIds.length > 0) {
      query = params.storeIds.length === 1
        ? query.eq('supermarket_id', params.storeIds[0])
        : query.in('supermarket_id', params.storeIds);
    }

    if (params.minPrice !== undefined) {
      query = query.gte('price', params.minPrice);
    }

    if (params.maxPrice !== undefined) {
      query = query.lte('price', params.maxPrice);
    }

    const { data, error } = await query;

    if (error) {
      throw new Error(`Error al consultar catálogo: ${error.message}`);
    }

    const rows = (data ?? []) as Record<string, unknown>[];
    const products = rows.map(mapRowToCatalogProduct);

    return {
      products,
      stores: this._extractStores(products),
      statistics: this._computeStatistics(products),
    };
  }

  async getProductById(productId: string): Promise<CatalogProduct | null> {
    const { data, error } = await supabase
      .from('v_products_complete')
      .select('*')
      .eq('product_id', productId)
      .single();

    if (error) {
      if (error.code === 'PGRST116') return null;
      throw new Error(`Error al buscar producto: ${error.message}`);
    }

    return mapRowToCatalogProduct(data as Record<string, unknown>);
  }

  async getStores(): Promise<StoreInfo[]> {
    const { data, error } = await supabase
      .from('supermarkets')
      .select('id, name, logo_url')
      .order('name');

    if (error) {
      throw new Error(`Error al consultar tiendas: ${error.message}`);
    }

    return (data ?? []).map((row: Record<string, unknown>) => ({
      storeId: String(row.id ?? ''),
      storeName: String(row.name ?? ''),
      logoUrl: (row.logo_url as string) ?? null,
    }));
  }

  async getStatistics(): Promise<CatalogStatistics> {
    const { data, error } = await supabase
      .from('v_products_complete')
      .select('price');

    if (error) {
      throw new Error(`Error al consultar estadísticas: ${error.message}`);
    }

    const rows = (data ?? []) as Record<string, unknown>[];
    const prices = rows
      .map((r) => (typeof r.price === 'number' ? r.price : 0))
      .filter((p) => p > 0);

    const storeIds = new Set(rows.map((r) => String(r.supermarket_id ?? '')));

    return {
      totalProducts: rows.length,
      totalStores: storeIds.size,
      minPrice: prices.length > 0 ? Math.min(...prices) : 0,
      maxPrice: prices.length > 0 ? Math.max(...prices) : 0,
      averagePrice: prices.length > 0
        ? prices.reduce((a, b) => a + b, 0) / prices.length
        : 0,
    };
  }

  private _analyzedToSearchParams(analyzed: AnalyzedQuery): SearchParams {
    const params: SearchParams = {};

    if (analyzed.entities.products.length > 0) {
      params.query = analyzed.entities.products.join(' ');
    }

    if (analyzed.entities.category) {
      params.categoryId = analyzed.entities.category;
    }

    if (analyzed.entities.priceMin !== null) {
      params.minPrice = analyzed.entities.priceMin;
    }

    if (analyzed.entities.priceMax !== null) {
      params.maxPrice = analyzed.entities.priceMax;
    }

    return params;
  }

  private _applyCategoryFilter(query: any, categoryId: string): any {
    switch (categoryId) {
      case 'abarrotes':
        return query.in('category_id', ['cat_abarrotes', 'cat_granos']);
      case 'lacteos':
        return query.in('category_id', ['cat_lacteos', 'cat_huevos']);
      case 'carnes':
        return query.eq('category_id', 'cat_carnes');
      case 'frutas':
        return query.eq('category_id', 'cat_frutas');
      case 'higiene':
        return query.eq('category_id', 'cat_higiene');
      case 'bebidas':
        return query.eq('category_id', 'cat_bebidas');
      case 'panaderia':
        return query.eq('category_id', 'cat_panaderia');
      case 'congelados':
        return query.eq('category_id', 'cat_congelados');
      case 'enlatados':
        return query.eq('category_id', 'cat_enlatados');
      default:
        return query.eq('category_id', categoryId);
    }
  }

  private _extractStores(products: CatalogProduct[]): StoreInfo[] {
    const seen = new Set<string>();
    const stores: StoreInfo[] = [];

    for (const p of products) {
      if (!seen.has(p.supermarketId)) {
        seen.add(p.supermarketId);
        stores.push({
          storeId: p.supermarketId,
          storeName: p.supermarketName,
          logoUrl: p.supermarketLogoUrl,
        });
      }
    }

    return stores.sort((a, b) => a.storeName.localeCompare(b.storeName));
  }

  private _computeStatistics(products: CatalogProduct[]): CatalogStatistics {
    const prices = products
      .map((p) => p.price)
      .filter((p) => p > 0);

    const storeIds = new Set(products.map((p) => p.supermarketId));

    return {
      totalProducts: products.length,
      totalStores: storeIds.size,
      minPrice: prices.length > 0 ? Math.min(...prices) : 0,
      maxPrice: prices.length > 0 ? Math.max(...prices) : 0,
      averagePrice: prices.length > 0
        ? prices.reduce((a, b) => a + b, 0) / prices.length
        : 0,
    };
  }
}
