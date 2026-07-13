import 'dart:convert';
import '../../products/models/product.dart';
import '../models/manual_list_entity.dart';
import '../models/manual_list_summary.dart';

class ManualListSerializer {
  Map<String, dynamic> toGeminiObject(
    ManualListEntity list,
    ManualListSummary summary,
    List<ProductEntity> catalogProducts,
  ) {
    final productMap = <String, ProductEntity>{};
    for (final p in catalogProducts) {
      productMap[p.id] = p;
    }

    final productsList = list.items.map((item) {
      final product = productMap[item.productId];
      return {
        'productId': item.productId,
        'productName': product?.name ?? 'Producto',
        'quantity': item.quantity,
        'unitPrice': item.unitPriceSnapshot,
        'subtotal': item.subtotal,
        'storeName': item.storeNameSnapshot,
      };
    }).toList();

    final storesList = summary.storesInvolved;
    final categoriesList = summary.categoriesInvolved;

    return {
      'name': list.name,
      'description': list.description ?? '',
      'status': list.status.name,
      'totalItems': summary.totalItems,
      'totalQuantity': summary.totalQuantity,
      'estimatedTotal': summary.estimatedTotal,
      'averageProductPrice': summary.averageProductPrice,
      'products': productsList,
      'supermarkets': storesList,
      'categories': categoriesList,
      'lastUpdated': list.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toExportMap(
    ManualListEntity list,
    ManualListSummary summary,
  ) {
    return {
      'id': list.id,
      'name': list.name,
      'description': list.description,
      'status': list.status.name,
      'createdAt': list.createdAt.toIso8601String(),
      'updatedAt': list.updatedAt.toIso8601String(),
      'summary': {
        'totalItems': summary.totalItems,
        'totalQuantity': summary.totalQuantity,
        'estimatedTotal': summary.estimatedTotal,
        'averageProductPrice': summary.averageProductPrice,
        'mostExpensiveProduct': summary.mostExpensiveProduct != null
            ? {
                'productId': summary.mostExpensiveProduct!.productId,
                'productName': summary.mostExpensiveProduct!.productName,
                'price': summary.mostExpensiveProduct!.price,
                'storeName': summary.mostExpensiveProduct!.storeName,
                'quantity': summary.mostExpensiveProduct!.quantity,
              }
            : null,
        'cheapestProduct': summary.cheapestProduct != null
            ? {
                'productId': summary.cheapestProduct!.productId,
                'productName': summary.cheapestProduct!.productName,
                'price': summary.cheapestProduct!.price,
                'storeName': summary.cheapestProduct!.storeName,
                'quantity': summary.cheapestProduct!.quantity,
              }
            : null,
        'storesInvolved': summary.storesInvolved,
        'categoriesInvolved': summary.categoriesInvolved,
      },
      'items': list.items.map((item) {
        return {
          'id': item.id,
          'productId': item.productId,
          'storeId': item.storeId,
          'storeName': item.storeNameSnapshot,
          'quantity': item.quantity,
          'unitPrice': item.unitPriceSnapshot,
          'subtotal': item.subtotal,
          'addedAt': item.addedAt.toIso8601String(),
        };
      }).toList(),
    };
  }

  String toJson(
    ManualListEntity list,
    ManualListSummary summary,
  ) {
    return jsonEncode(toExportMap(list, summary));
  }
}
