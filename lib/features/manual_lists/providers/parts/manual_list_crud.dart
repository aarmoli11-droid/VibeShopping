import 'package:flutter/foundation.dart';
import '../../models/manual_list_entity.dart';

mixin ManualListCrudMixin {
  @protected
  List<ManualListEntity> get listsInternal;

  @protected
  void recalculateStats(ManualListEntity list);

  @protected
  Future<void> persist();

  @protected
  ManualListEntity? getListById(String id);

  void notifyListeners();

  Future<ManualListEntity> createList({
    required String name,
    String? description,
    ManualListItemEntity? initialItem,
    int? colorValue,
    int? iconCodePoint,
  }) async {
    final list = ManualListEntity(
      id: ManualListEntity.generateId(),
      name: name,
      description: description,
      items: initialItem != null ? [initialItem] : [],
      status: ManualListStatus.active,
      colorValue: colorValue ?? VibeDefaultColors.navy,
      iconCodePoint: iconCodePoint ?? VibeDefaultIcons.cart,
    );
    recalculateStats(list);
    listsInternal.add(list);
    await persist();
    notifyListeners();
    return list;
  }

  Future<void> updateList(
    String listId, {
    String? name,
    String? description,
    int? colorValue,
    int? iconCodePoint,
  }) async {
    final index = listsInternal.indexWhere((l) => l.id == listId);
    if (index == -1) return;
    if (name != null) listsInternal[index].name = name;
    if (description != null) listsInternal[index].description = description;
    if (colorValue != null) listsInternal[index].colorValue = colorValue;
    if (iconCodePoint != null)
      listsInternal[index].iconCodePoint = iconCodePoint;
    listsInternal[index].updatedAt = DateTime.now();
    await persist();
    notifyListeners();
  }

  Future<void> updateListName(String listId, String newName) async {
    final index = listsInternal.indexWhere((l) => l.id == listId);
    if (index == -1) return;
    listsInternal[index].name = newName;
    listsInternal[index].updatedAt = DateTime.now();
    await persist();
    notifyListeners();
  }

  Future<void> updateListDescription(
      String listId, String? newDescription) async {
    final index = listsInternal.indexWhere((l) => l.id == listId);
    if (index == -1) return;
    listsInternal[index].description = newDescription;
    listsInternal[index].updatedAt = DateTime.now();
    await persist();
    notifyListeners();
  }

  Future<void> deleteList(String listId) async {
    listsInternal.removeWhere((l) => l.id == listId);
    await persist();
    notifyListeners();
  }

  Future<ManualListEntity> duplicateList(String listId) async {
    final original = getListById(listId);
    if (original == null) throw Exception('Lista no encontrada');
    final newList = ManualListEntity(
      id: ManualListEntity.generateId(),
      name: 'Copia de ${original.name}',
      description: original.description,
      items: original.items
          .map((item) => ManualListItemEntity(
                productId: item.productId,
                storeId: item.storeId,
                storeNameSnapshot: item.storeNameSnapshot,
                unitPriceSnapshot: item.unitPriceSnapshot,
                quantity: item.quantity,
              ))
          .toList(),
      status: ManualListStatus.active,
    );
    recalculateStats(newList);
    listsInternal.add(newList);
    await persist();
    notifyListeners();
    return newList;
  }

  Future<void> clearList(String listId) async {
    final index = listsInternal.indexWhere((l) => l.id == listId);
    if (index == -1) return;
    listsInternal[index].items.clear();
    listsInternal[index].updatedAt = DateTime.now();
    recalculateStats(listsInternal[index]);
    await persist();
    notifyListeners();
  }

  Future<void> addItemToList(String listId, ManualListItemEntity item) async {
    final index = listsInternal.indexWhere((l) => l.id == listId);
    if (index == -1) return;
    listsInternal[index].items.add(item);
    listsInternal[index].updatedAt = DateTime.now();
    recalculateStats(listsInternal[index]);
    await persist();
    notifyListeners();
  }

  Future<void> updateItemQuantity(
      String listId, String productId, int newQuantity) async {
    final listIndex = listsInternal.indexWhere((l) => l.id == listId);
    if (listIndex == -1) return;
    final itemIndex = listsInternal[listIndex]
        .items
        .indexWhere((i) => i.productId == productId);
    if (itemIndex == -1) return;
    listsInternal[listIndex].items[itemIndex].quantity = newQuantity;
    listsInternal[listIndex].updatedAt = DateTime.now();
    recalculateStats(listsInternal[listIndex]);
    await persist();
    notifyListeners();
  }

  Future<void> removeItemFromList(String listId, String productId) async {
    final listIndex = listsInternal.indexWhere((l) => l.id == listId);
    if (listIndex == -1) return;
    listsInternal[listIndex].items.removeWhere((i) => i.productId == productId);
    listsInternal[listIndex].updatedAt = DateTime.now();
    recalculateStats(listsInternal[listIndex]);
    await persist();
    notifyListeners();
  }
}
