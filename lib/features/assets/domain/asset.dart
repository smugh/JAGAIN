enum AssetCondition { good, needsAttention, underMaintenance, critical }

enum AssetStatus { active, inactive, disposed }

class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final bool isCompleted;

  ChecklistItem copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class Asset {
  const Asset({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.condition,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.checklist = const [],
    this.brand,
    this.model,
    this.year,
    this.purchaseDate,
    this.identifier,
    this.ownerId,
    this.location,
    this.notes,
    this.imagePath,
  });

  final String id;
  final String name;
  final String categoryId;
  final String? brand;
  final String? model;
  final int? year;
  final DateTime? purchaseDate;
  final String? identifier;
  final String? ownerId;
  final String? location;
  final AssetCondition condition;
  final AssetStatus status;
  final String? notes;
  final String? imagePath;
  final List<ChecklistItem> checklist;
  final DateTime createdAt;
  final DateTime updatedAt;

  int get completedChecklistCount => checklist.where((c) => c.isCompleted).length;
  int get totalChecklistCount => checklist.length;
  bool get hasChecklist => checklist.isNotEmpty;

  Asset copyWith({
    String? id,
    String? name,
    String? categoryId,
    String? brand,
    String? model,
    int? year,
    DateTime? purchaseDate,
    String? identifier,
    String? ownerId,
    String? location,
    AssetCondition? condition,
    AssetStatus? status,
    String? notes,
    String? imagePath,
    List<ChecklistItem>? checklist,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      identifier: identifier ?? this.identifier,
      ownerId: ownerId ?? this.ownerId,
      location: location ?? this.location,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      checklist: checklist ?? this.checklist,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AssetCategory {
  const AssetCategory({
    required this.id,
    required this.name,
    this.icon,
  });

  final String id;
  final String name;
  final String? icon;

  static const defaults = <AssetCategory>[
    AssetCategory(id: 'vehicle', name: 'Kendaraan', icon: 'directions_car'),
    AssetCategory(id: 'electronics', name: 'Elektronik', icon: 'devices'),
    AssetCategory(id: 'property', name: 'Properti', icon: 'home_work'),
    AssetCategory(id: 'personal', name: 'Pribadi', icon: 'watch'),
    AssetCategory(id: 'other', name: 'Lainnya', icon: 'category'),
  ];
}
