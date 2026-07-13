export interface CatalogProduct {
  productId: string;
  masterProductId: string;
  canonicalName: string;
  brand: string | null;
  categoryId: string;
  subcategory: string | null;
  imageUrl: string | null;
  price: number;
  supermarketId: string;
  supermarketName: string;
  supermarketLogoUrl: string | null;
}

export interface StoreInfo {
  storeId: string;
  storeName: string;
  logoUrl: string | null;
}

export interface CatalogStatistics {
  totalProducts: number;
  totalStores: number;
  minPrice: number;
  maxPrice: number;
  averagePrice: number;
}

export interface SearchParams {
  query?: string;
  categoryId?: string;
  supermarketId?: string;
  storeIds?: string[];
  minPrice?: number;
  maxPrice?: number;
}

export interface SearchResult {
  products: CatalogProduct[];
  stores: StoreInfo[];
  statistics: CatalogStatistics;
}

export function mapRowToCatalogProduct(row: Record<string, unknown>): CatalogProduct {
  return {
    productId: String(row.product_id ?? ''),
    masterProductId: String(row.master_product_id ?? ''),
    canonicalName: String(row.canonical_name ?? ''),
    brand: (row.brand as string) ?? null,
    categoryId: String(row.category_id ?? ''),
    subcategory: (row.subcategory as string) ?? null,
    imageUrl: (row.image_url as string) ?? null,
    price: typeof row.price === 'number' ? row.price : 0,
    supermarketId: String(row.supermarket_id ?? ''),
    supermarketName: String(row.supermarket_name ?? ''),
    supermarketLogoUrl: (row.supermarket_logo_url as string) ?? null,
  };
}
