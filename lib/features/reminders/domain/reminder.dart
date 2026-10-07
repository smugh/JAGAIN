enum ReminderRecurrence {
  once,
  monthly,
  everyThreeMonths,
  everySixMonths,
  yearly,
}

enum ReminderStatus { upcoming, dueToday, overdue, completed }

class AssetReminder {
  const AssetReminder({
    required this.id,
    required this.assetId,
    required this.title,
    required this.dueDate,
    required this.recurrence,
    required this.status,
    required this.notificationEnabled,
    required this.createdAt,
    this.completedAt,
  });

  final String id;
  final String assetId;
  final String title;
  final DateTime dueDate;
  final ReminderRecurrence recurrence;
  final ReminderStatus status;
  final bool notificationEnabled;
  final DateTime? completedAt;
  final DateTime createdAt;
}
