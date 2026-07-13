import 'package:flutter/foundation.dart';

abstract final class ApiConfig {
  ApiConfig._();

  static const bool useNodeApi = bool.fromEnvironment(
    'USE_NODE_API',
    defaultValue: false,
  );

  static String get baseUrl {
    if (kReleaseMode) {
      return 'https://api.vibeshopping.app';
    }
    const customUrl = String.fromEnvironment('API_BASE_URL');
    if (customUrl.isNotEmpty) return customUrl;
    return 'http://localhost:3001';
  }
}
