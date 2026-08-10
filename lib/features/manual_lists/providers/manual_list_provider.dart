import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../products/providers/product_provider.dart';
import '../models/manual_list_entity.dart';
import 'parts/manual_list_crud.dart';
import 'parts/manual_list_search_sort.dart';

class ManualListProvider extends ChangeNotifier
    with ManualListCrudMixin, ManualListSearchSortMixin {
  static const _boxName = 'manual_lists';
  static const _key = 'lists';

  final ProductProvider? productProvider;

  List<ManualListEntity> _lists = [];
  bool _loaded = false;
  String _searchQuery = '';
  ListSortMode _sortMode = ListSortMode.updatedAt;
  bool _sortAscending = false;
  ListFilterMode _filterMode = ListFilterMode.all;

  List<ManualListEntity> get lists => _lists;
  bool get loaded => _loaded;
  String get searchQuery => _searchQuery;
  ListSortMode get sortMode => _sortMode;
  bool get sortAscending => _sortAscending;
  ListFilterMode get filterMode => _filterMode;

  ManualListProvider({this.productProvider});

  Future<void> load() async {
    final box = await Hive.openBox<String>(_boxName);
    final raw = box.get(_key);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _lists = decoded
          .map((e) => ManualListEntity.fromJson(e as Map<String, dynamic>))
          .toList();
      for (final list in _lists) {
        recalculateStats(list);
      }
    }
    _loaded = true;
    notifyListeners();
  }

  // --- Protected accessors for mixins ---

  @protected
  List<ManualListEntity> get listsInternal => _lists;

  @protected
  String get searchQueryInternal => _searchQuery;

  @protected
  set searchQueryInternal(String value) => _searchQuery = value;

  @protected
  ListSortMode get sortModeInternal => _sortMode;

  @protected
  set sortModeInternal(ListSortMode value) => _sortMode = value;

  @protected
  bool get sortAscendingInternal => _sortAscending;

  @protected
  set sortAscendingInternal(bool value) => _sortAscending = value;

  @protected
  ListFilterMode get filterModeInternal => _filterMode;

  @protected
  set filterModeInternal(ListFilterMode value) => _filterMode = value;

  @protected
  void recalculateStats(ManualListEntity list) {
    list.totalItems = list.items.length;
    list.totalQuantity = list.items.fold(0, (sum, item) => sum + item.quantity);
    list.estimatedTotal =
        list.items.fold(0.0, (sum, item) => sum + item.subtotal);
  }

  @protected
  Future<void> persist() async {
    final box = await Hive.openBox<String>(_boxName);
    final encoded = jsonEncode(_lists.map((e) => e.toJson()).toList());
    await box.put(_key, encoded);
  }

  ManualListEntity? getListById(String id) {
    try {
      return _lists.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }
}
