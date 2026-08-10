import 'package:flutter/foundation.dart';
import '../../models/manual_list_entity.dart';

mixin ManualListSearchSortMixin {
  @protected
  List<ManualListEntity> get listsInternal;

  @protected
  String get searchQueryInternal;

  @protected
  set searchQueryInternal(String value);

  @protected
  ListSortMode get sortModeInternal;

  @protected
  set sortModeInternal(ListSortMode value);

  @protected
  bool get sortAscendingInternal;

  @protected
  set sortAscendingInternal(bool value);

  @protected
  ListFilterMode get filterModeInternal;

  @protected
  set filterModeInternal(ListFilterMode value);

  void notifyListeners();

  List<ManualListEntity> get filteredLists {
    var result = listsInternal
        .where((l) => l.status == ManualListStatus.active)
        .toList();
    switch (filterModeInternal) {
      case ListFilterMode.empty:
        result = result.where((l) => l.items.isEmpty).toList();
      case ListFilterMode.hasProducts:
        result = result.where((l) => l.items.isNotEmpty).toList();
      case ListFilterMode.all:
        break;
    }
    if (searchQueryInternal.isNotEmpty) {
      final q = searchQueryInternal.toLowerCase();
      result = result
          .where((l) =>
              l.name.toLowerCase().contains(q) ||
              (l.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    switch (sortModeInternal) {
      case ListSortMode.name:
        result.sort((a, b) => sortAscendingInternal
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
      case ListSortMode.createdAt:
        result.sort((a, b) => sortAscendingInternal
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
      case ListSortMode.updatedAt:
        result.sort((a, b) => sortAscendingInternal
            ? a.updatedAt.compareTo(b.updatedAt)
            : b.updatedAt.compareTo(a.updatedAt));
      case ListSortMode.totalPrice:
        result.sort((a, b) => sortAscendingInternal
            ? a.estimatedTotal.compareTo(b.estimatedTotal)
            : b.estimatedTotal.compareTo(a.estimatedTotal));
      case ListSortMode.itemCount:
        result.sort((a, b) => sortAscendingInternal
            ? a.totalItems.compareTo(b.totalItems)
            : b.totalItems.compareTo(a.totalItems));
    }
    return result;
  }

  void setSearchQuery(String query) {
    searchQueryInternal = query;
    notifyListeners();
  }

  void setSortMode(ListSortMode mode, {bool? ascending}) {
    sortModeInternal = mode;
    if (ascending != null) sortAscendingInternal = ascending;
    notifyListeners();
  }

  void setFilterMode(ListFilterMode mode) {
    filterModeInternal = mode;
    notifyListeners();
  }
}
