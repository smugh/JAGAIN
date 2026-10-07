class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.nameId,
    required this.nameEn,
    required this.iconKey,
  });

  final String id;
  final String nameId;
  final String nameEn;
  final String iconKey;

  String localizedName(bool isId) => isId ? nameId : nameEn;
}
