// ======================================================
// Archivo: core/api_client.dart
// Responsabilidad: Cliente HTTP para el backend Node.js
// Qué hacer: Envuelve Dio con configuración compartida
//   (timeout, headers, interceptors JWT)
// Cuándo se utiliza: Cuando la app usa el backend Node.js
//   en lugar de Supabase directo
// Quién lo utiliza: ProductService, AssistantService
//
// Interceptors:
// 1. Agrega el token JWT a cada petición automáticamente
// 2. Si el servidor responde 401, intenta refrescar el token
//    y re-intenta la petición original
// ======================================================

import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  // Inicializa el cliente con la URL del backend.
  // Se llama desde main.dart al arrancar la app,
  // antes de que cualquier servicio use la API
  void init({required String baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      // Interceptor que agrega el token JWT a cada petición
      onRequest: (options, handler) async {
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          options.headers['Authorization'] = 'Bearer ${session.accessToken}';
        }
        handler.next(options);
      },
      // Interceptor que refresca el token si el servidor
      // responde 401 (token expirado) y re-intenta
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          try {
            final refreshed =
                await Supabase.instance.client.auth.refreshSession();
            if (refreshed.session != null) {
              final retryOptions = error.requestOptions;
              retryOptions.headers['Authorization'] =
                  'Bearer ${refreshed.session!.accessToken}';
              final retryResponse = await _dio.fetch(retryOptions);
              handler.resolve(retryResponse);
              return;
            }
          } catch (_) {
            // Si falla el refresh, el AuthProvider redirigirá al login
          }
        }
        handler.next(error);
      },
    ));
  }

  // Métodos HTTP estándar
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path, {dynamic data}) {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(String path, {dynamic data}) {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> patch<T>(String path, {dynamic data}) {
    return _dio.patch<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return _dio.delete<T>(path);
  }

  // ======================================================
  // Método estático: unwrapData
  // Recibe: la respuesta del backend
  // Devuelve: el campo "data" del body
  //
  // El backend responde siempre con:
  //   { success: true, data: ... }
  //
  // Si success es false, lanza una excepción con el
  // código y mensaje que devolvió el backend
  // ======================================================
  static dynamic unwrapData(Response response) {
    final body = response.data as Map<String, dynamic>?;
    if (body == null) throw Exception('Respuesta vacía del servidor');
    if (body['success'] != true) {
      final code = body['code'] as String? ?? 'UNKNOWN';
      final message = body['message'] as String? ?? 'Error desconocido';
      throw Exception('[$code] $message');
    }
    return body['data'];
  }
}
