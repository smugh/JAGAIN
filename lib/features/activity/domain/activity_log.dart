enum ActivityType {
  reminderExecution,
  maintenance,
  service,
  inspection,
  manualLog,
}

class AssetActivityLog {
  const AssetActivityLog({
    required this.id,
    required this.assetId,
    this.reminderId,
    this.checklistItemId,
    required this.title,
    required this.timestamp,
    this.notes,
    this.type = ActivityType.reminderExecution,
    this.targetName,
  });

  final String id;
  final String assetId;
  final String? reminderId;
  final String? checklistItemId;
  final String title;
  final DateTime timestamp;
  final String? notes;
  final ActivityType type;
  final String? targetName;

  AssetActivityLog copyWith({
    String? id,
    String? assetId,
    String? reminderId,
    String? checklistItemId,
    String? title,
    DateTime? timestamp,
    String? notes,
    ActivityType? type,
    String? targetName,
  }) {
    return AssetActivityLog(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      reminderId: reminderId ?? this.reminderId,
      checklistItemId: checklistItemId ?? this.checklistItemId,
      title: title ?? this.title,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      type: type ?? this.type,
      targetName: targetName ?? this.targetName,
    );
  }
}
