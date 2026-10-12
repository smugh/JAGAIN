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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameId': nameId,
      'nameEn': nameEn,
      'iconKey': iconKey,
    };
  }

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as String? ?? '',
      nameId: json['nameId'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      iconKey: json['iconKey'] as String? ?? 'category',
    );
  }
}
