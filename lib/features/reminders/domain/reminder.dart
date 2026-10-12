enum ReminderRecurrence {
  once,
  monthly,
  everyThreeMonths,
  everySixMonths,
  yearly,
}

enum ReminderStatus { upcoming, dueToday, overdue, completed }

enum ReminderTargetType {
  asset, // Melekat pada 1 aset utama
  checklistItem, // Melekat pada sub item (check list)
}

class AssetReminder {
  const AssetReminder({
    required this.id,
    required this.assetId,
    this.checklistItemId,
    required this.targetType,
    required this.title,
    required this.dueDate,
    this.recurrence = ReminderRecurrence.once,
    this.status = ReminderStatus.upcoming,
    this.notificationEnabled = true,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  final String id;
  final String assetId;
  final String? checklistItemId;
  final ReminderTargetType targetType;
  final String title;
  final DateTime dueDate;
  final ReminderRecurrence recurrence;
  final ReminderStatus status;
  final bool notificationEnabled;
  final DateTime? completedAt;
  final DateTime createdAt;
  final String? notes;

  bool get isChecklistItem => targetType == ReminderTargetType.checklistItem && checklistItemId != null;
  bool get isCompleted => status == ReminderStatus.completed;

  AssetReminder copyWith({
    String? id,
    String? assetId,
    String? checklistItemId,
    ReminderTargetType? targetType,
    String? title,
    DateTime? dueDate,
    ReminderRecurrence? recurrence,
    ReminderStatus? status,
    bool? notificationEnabled,
    DateTime? completedAt,
    DateTime? createdAt,
    String? notes,
  }) {
    return AssetReminder(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      checklistItemId: checklistItemId ?? this.checklistItemId,
      targetType: targetType ?? this.targetType,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      recurrence: recurrence ?? this.recurrence,
      status: status ?? this.status,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'checklistItemId': checklistItemId,
      'targetType': targetType.name,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'recurrence': recurrence.name,
      'status': status.name,
      'notificationEnabled': notificationEnabled,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory AssetReminder.fromJson(Map<String, dynamic> json) {
    return AssetReminder(
      id: json['id'] as String? ?? '',
      assetId: json['assetId'] as String? ?? '',
      checklistItemId: json['checklistItemId'] as String?,
      targetType: ReminderTargetType.values.firstWhere(
        (e) => e.name == json['targetType'],
        orElse: () => ReminderTargetType.asset,
      ),
      title: json['title'] as String? ?? '',
      dueDate: DateTime.tryParse(json['dueDate'] as String? ?? '') ?? DateTime.now(),
      recurrence: ReminderRecurrence.values.firstWhere(
        (e) => e.name == json['recurrence'],
        orElse: () => ReminderRecurrence.once,
      ),
      status: ReminderStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReminderStatus.upcoming,
      ),
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      notes: json['notes'] as String?,
    );
  }
}
