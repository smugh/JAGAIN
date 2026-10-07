import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/reminder.dart';

export '../domain/reminder.dart';

class RemindersNotifier extends Notifier<List<AssetReminder>> {
  @override
  List<AssetReminder> build() => _initialReminders;

  static final List<AssetReminder> _initialReminders = [
    AssetReminder(
      id: 'rem-1',
      assetId: 'ast-1',
      checklistItemId: 'c1',
      targetType: ReminderTargetType.checklistItem,
      title: 'Jadwal servis berkala & ganti oli',
      dueDate: DateTime.now().add(const Duration(days: 7, hours: 3)),
      recurrence: ReminderRecurrence.monthly,
      status: ReminderStatus.upcoming,
      notificationEnabled: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      notes: 'Servis berkala ke-40.000 km dan ganti oli sintetis.',
    ),
    AssetReminder(
      id: 'rem-2',
      assetId: 'ast-1',
      checklistItemId: 'c2',
      targetType: ReminderTargetType.checklistItem,
      title: 'Bayar pajak tahunan (PKB)',
      dueDate: DateTime.now().add(const Duration(days: 25, hours: 2)),
      recurrence: ReminderRecurrence.yearly,
      status: ReminderStatus.upcoming,
      notificationEnabled: true,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
      notes: 'Perpanjangan STNK tahunan di Samsat atau via Signal.',
    ),
  ];

  void addReminder(AssetReminder reminder) {
    state = [reminder, ...state];
  }

  void updateReminder(AssetReminder updated) {
    state = state.map((r) => r.id == updated.id ? updated : r).toList();
  }

  void removeReminder(String id) {
    state = state.where((r) => r.id != id).toList();
  }

  void completeReminder(String id, {DateTime? completedAt}) {
    state = state.map((r) {
      if (r.id != id) return r;
      return r.copyWith(
        status: ReminderStatus.completed,
        completedAt: completedAt ?? DateTime.now(),
      );
    }).toList();
  }

  void removeRemindersForAsset(String assetId) {
    state = state.where((r) => r.assetId != assetId).toList();
  }
}

final remindersProvider = NotifierProvider<RemindersNotifier, List<AssetReminder>>(
  RemindersNotifier.new,
);
