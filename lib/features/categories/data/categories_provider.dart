import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database_service.dart';
import '../domain/category.dart';

export '../domain/category.dart';

class CategoriesNotifier extends Notifier<List<CategoryItem>> {
  @override
  List<CategoryItem> build() => LocalDatabaseService.instance.getCategories();

  void addCategory({
    required String name,
    required String iconKey,
  }) {
    final id = 'cat_${DateTime.now().millisecondsSinceEpoch}';
    final newItem = CategoryItem(
      id: id,
      nameId: name,
      nameEn: name,
      iconKey: iconKey,
    );
    state = [...state, newItem];
    LocalDatabaseService.instance.saveCategories(state);
  }

  void removeCategory(String id) {
    state = state.where((item) => item.id != id).toList();
    LocalDatabaseService.instance.saveCategories(state);
  }
}

final categoriesProvider =
    NotifierProvider<CategoriesNotifier, List<CategoryItem>>(
  CategoriesNotifier.new,
);
