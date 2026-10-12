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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'brand': brand,
      'model': model,
      'year': year,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'identifier': identifier,
      'ownerId': ownerId,
      'location': location,
      'condition': condition.name,
      'status': status.name,
      'notes': notes,
      'imagePath': imagePath,
      'checklist': checklist.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? 'other',
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.tryParse(json['purchaseDate'] as String)
          : null,
      identifier: json['identifier'] as String?,
      ownerId: json['ownerId'] as String?,
      location: json['location'] as String?,
      condition: AssetCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => AssetCondition.good,
      ),
      status: AssetStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AssetStatus.active,
      ),
      notes: json['notes'] as String?,
      imagePath: json['imagePath'] as String?,
      checklist: (json['checklist'] as List<dynamic>? ?? [])
          .map((c) => ChecklistItem.fromJson(c as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
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
