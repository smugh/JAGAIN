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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetId': assetId,
      'reminderId': reminderId,
      'checklistItemId': checklistItemId,
      'title': title,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'type': type.name,
      'targetName': targetName,
    };
  }

  factory AssetActivityLog.fromJson(Map<String, dynamic> json) {
    return AssetActivityLog(
      id: json['id'] as String? ?? '',
      assetId: json['assetId'] as String? ?? '',
      reminderId: json['reminderId'] as String?,
      checklistItemId: json['checklistItemId'] as String?,
      title: json['title'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      notes: json['notes'] as String?,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.manualLog,
      ),
      targetName: json['targetName'] as String?,
    );
  }
}
