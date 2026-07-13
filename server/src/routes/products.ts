// ======================================================
// Archivo: server/src/routes/products.ts
// Responsabilidad: Endpoints de consulta de productos
// Qué hace: Expone GET /api/v1/products con filtros por
//   categoría, tienda o texto de búsqueda. Lee desde la
//   VIEW v_products_complete y transforma las filas a
//   ProductEntity
// Quién lo utiliza: routes/index.ts (lo registra como
//   plugin), Flutter → ProductService (consume los
//   endpoints)
// Cuándo se ejecuta: Cuando el usuario navega en el
//   market explorer o busca productos por texto
//
// Flujo dentro de la aplicación:
//   Flutter → GET /api/v1/products?categoryId=lácteos
//     → Zod valida query params
//     → _findAllProducts() construye query sobre VIEW
//     → Supabase devuelve filas planas desde la VIEW
//     → _mapViewRowToProduct() convierte a camelCase
//     → JSON con ProductEntity[]
//
// Fuente de datos: v_products_complete (VIEW)
//   La VIEW reemplaza los JOINs manuales entre
//   products, product_master y supermarkets.
//   Un solo punto de definición de esquema.
// ======================================================

import { FastifyInstance } from 'fastify';
import { z } from 'zod';
import { supabase } from '../config/supabase';

// ======================================================
// Interfaces del dominio
// ======================================================

// ======================================================
// Interfaz: ProductPrice
// Representa: El precio de un producto en una tienda
//   específica
// Por qué existe: Un producto puede venderse en varias
//   tiendas con diferentes precios. Cada combinación
//   producto-tienda es un ProductPrice
// Cuándo se crea: En _mapDatabaseRowToProduct() al
//   procesar el JOIN con la tabla supermarkets
// ======================================================
export interface ProductPrice {
  storeId: string;
  storeName: string;
  price: number;
  currency: string;
  logoUrl?: string;
  latitude?: number;
  longitude?: number;
}

export interface ProductEntity {
  id: string;
  categoryId: string;
  subcategory: string | null;
  name: string;
  imageUrls: string[];
  prices: ProductPrice[];
  createdAt: string;
  masterProductId?: string;
}

// ======================================================
// Interfaz: ProductQueryParams
// Representa: Los filtros que el cliente puede enviar
//   como query parameters en GET /api/v1/products
// Uso interno: Solo se usa dentro de este archivo para
//   tipar los parámetros de _findAllProducts()
// ======================================================
interface ProductQueryParams {
  categoryId?: string;
  storeId?: string;
  search?: string;
  storeIds?: string[];
}

// ======================================================
// Schemas de validación con Zod
// ------------------------------------------------
// Zod valida los datos que llegan del cliente ANTES
// de que toquen la base de datos. Si algo no es válido,
// el error handler global devuelve un 400 automático
// ======================================================

const listProductsQuerySchema = z.object({
  categoryId: z.string().optional(),
  storeId: z.string().optional(),
  search: z.string().max(100).optional(),
  // storeIds llega como string "id1,id2,id3" y Zod lo
  // transforma a un array con split
  storeIds: z.string().optional().transform((value) => (value ? value.split(',') : undefined)),
});

const productIdParamsSchema = z.object({
  id: z.string().uuid('ID de producto inválido'),
});

// ======================================================
// Funciones auxiliares
// ======================================================

// ======================================================
// Función: _parseImageUrls
// Recibe: un valor desconocido (de la base de datos)
// Devuelve: string[] (lista de URLs de imágenes)
//
// Supabase devuelve image_url como string único
// Esta función lo normaliza a string[]
// ======================================================
function _parseImageUrls(rawImageUrls: unknown): string[] {
  if (Array.isArray(rawImageUrls)) {
    return rawImageUrls
      .map((item) => String(item).trim())
      .filter(Boolean);
  }
  if (typeof rawImageUrls === 'string' && rawImageUrls.length > 0) {
    return [rawImageUrls.trim()];
  }
  return [];
}

// ======================================================
// Función: _buildCategoryFilter
// Recibe: una consulta de Supabase y un categoryId
// Devuelve: la misma consulta con el filtro aplicado
//
// Algunas categorías agrupan múltiples category_id
// en Supabase. Por ejemplo, "abarrotes" incluye
// "cat_abarrotes" y "cat_granos"
// ======================================================
function _buildCategoryFilter(query: any, categoryId: string): any {
  switch (categoryId) {
    case 'abarrotes':
      return query.inFilter('category_id', ['cat_abarrotes', 'cat_granos']);
    case 'lacteos':
      return query.inFilter('category_id', ['cat_lacteos', 'cat_huevos']);
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

// ======================================================
// Función: _mapViewRowToProduct
// Recibe: una fila de la VIEW v_products_complete (plana)
// Devuelve: un objeto ProductEntity listo para enviar al frontend
//
// La VIEW ya resuelve los JOINs entre product_master,
// products y supermarkets en una estructura plana.
// Ya no necesita leer objetos anidados ni hacer fallback.
// ======================================================
function _mapViewRowToProduct(row: Record<string, unknown>): ProductEntity {
  const price = typeof row.price === 'number' ? row.price : 0;
  const hasPrice = row.price !== undefined && row.price !== null;

  const prices: ProductPrice[] = hasPrice
    ? [{
        storeId: String(row.supermarket_id ?? ''),
        storeName: String(row.supermarket_name ?? 'Desconocida'),
        price,
        currency: 'CRC',
        logoUrl: row.supermarket_logo_url as string | undefined,
        latitude: row.supermarket_latitude as number | undefined,
        longitude: row.supermarket_longitude as number | undefined,
      }]
    : [];

  return {
    id: String(row.product_id),
    categoryId: String(row.category_id ?? ''),
    subcategory: (row.subcategory as string) ?? null,
    name: String(row.canonical_name ?? 'Producto'),
    imageUrls: _parseImageUrls(row.image_url),
    prices,
    createdAt: String(row.master_created_at ?? ''),
    masterProductId: row.master_product_id as string | undefined,
  };
}

// ======================================================
// Funciones de acceso a datos (consultan Supabase)
// ======================================================

// ======================================================
// Función: _findAllProducts
// Recibe: filtros opcionales (categoría, tienda, texto)
// Devuelve: lista de ProductEntity
//
// Construye una consulta Supabase dinámica aplicando
// SOLO los filtros que el cliente envió
// ======================================================
async function _findAllProducts(filters?: ProductQueryParams): Promise<ProductEntity[]> {
  // Paso 1: Consultar la VIEW oficial (v_products_complete)
  let query = supabase.from('v_products_complete').select('*');

  // Paso 2: Aplicar filtro por categoría (si viene)
  if (filters?.categoryId && filters.categoryId !== 'todo') {
    query = _buildCategoryFilter(query, filters.categoryId);
  }

  // Paso 3: Aplicar búsqueda por texto (si viene)
  // Busca sobre canonical_name (product_master) en la VIEW
  if (filters?.search) {
    query = query.ilike('canonical_name', `%${filters.search}%`);
  }

  // Paso 4: Aplicar filtro por tiendas (si viene)
  if (filters?.storeIds && filters.storeIds.length > 0) {
    query = filters.storeIds.length === 1
      ? query.eq('supermarket_id', filters.storeIds[0])
      : query.in('supermarket_id', filters.storeIds);
  }

  // Paso 5: Aplicar filtro por tienda individual (si viene)
  if (filters?.storeId) {
    query = query.eq('supermarket_id', filters.storeId);
  }

  // Paso 6: Ejecutar la consulta
  const { data, error } = await query;
  if (error) throw new Error(`Error al consultar productos: ${error.message}`);

  // Paso 7: Convertir las filas a objetos ProductEntity
  return ((data ?? []) as Record<string, unknown>[])
    .map(_mapViewRowToProduct);
}

// ======================================================
// Función: _findProductById
// Recibe: id (string UUID)
// Devuelve: ProductEntity o null si no existe
// ======================================================
async function _findProductById(id: string): Promise<ProductEntity | null> {
  const { data, error } = await supabase
    .from('v_products_complete')
    .select('*')
    .eq('product_id', id)
    .single();

  if (error) {
    // PGRST116 = "no se encontraron filas" (código de Supabase)
    if (error.code === 'PGRST116') return null;
    throw new Error(`Error al buscar producto: ${error.message}`);
  }

  return _mapViewRowToProduct(data as Record<string, unknown>);
}

// ======================================================
// Registro de rutas
// ======================================================

export async function productsRoutes(app: FastifyInstance): Promise<void> {
  // ======================================================
  // GET /api/v1/products
  // Query params: categoryId, storeId, search, storeIds
  // Devuelve: lista de productos (filtrada o completa)
  // ======================================================
  app.get('/products', async (request, reply) => {
    const queryParameters = listProductsQuerySchema.parse(request.query);
    request.log.debug({ queryParameters }, 'GET /api/v1/products');

    const products = await _findAllProducts(queryParameters);
    reply.send({ success: true, data: products });
  });

  // ======================================================
  // GET /api/v1/products/:id
  // Path params: id (UUID del producto)
  // Devuelve: un producto o 404 si no existe
  // ======================================================
  app.get('/products/:id', async (request, reply) => {
    const { id } = productIdParamsSchema.parse(request.params);
    request.log.debug({ productId: id }, 'GET /api/v1/products/:id');

    const product = await _findProductById(id);
    if (!product) {
      reply.status(404).send({
        success: false,
        code: 'PRODUCT_NOT_FOUND',
        message: 'Producto no encontrado',
      });
      return;
    }
    reply.send({ success: true, data: product });
  });
}
