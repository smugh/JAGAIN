import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/category.dart';

export '../domain/category.dart';

class CategoriesNotifier extends Notifier<List<CategoryItem>> {
  @override
  List<CategoryItem> build() => [
        const CategoryItem(
          id: 'vehicle',
          nameId: 'Kendaraan',
          nameEn: 'Vehicle',
          iconKey: 'car',
        ),
        const CategoryItem(
          id: 'electronics',
          nameId: 'Elektronik',
          nameEn: 'Electronics',
          iconKey: 'laptop',
        ),
        const CategoryItem(
          id: 'property',
          nameId: 'Properti',
          nameEn: 'Property',
          iconKey: 'house',
        ),
        const CategoryItem(
          id: 'personal',
          nameId: 'Pribadi',
          nameEn: 'Personal',
          iconKey: 'watch',
        ),
        const CategoryItem(
          id: 'other',
          nameId: 'Lainnya',
          nameEn: 'Other',
          iconKey: 'category',
        ),
      ];

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
  }

  void removeCategory(String id) {
    state = state.where((item) => item.id != id).toList();
  }
}

final categoriesProvider =
    NotifierProvider<CategoriesNotifier, List<CategoryItem>>(
  CategoriesNotifier.new,
);
