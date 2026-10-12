import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database_service.dart';
import '../domain/reminder.dart';

export '../domain/reminder.dart';

class RemindersNotifier extends Notifier<List<AssetReminder>> {
  @override
  List<AssetReminder> build() => LocalDatabaseService.instance.getReminders();

  void addReminder(AssetReminder reminder) {
    state = [reminder, ...state];
    LocalDatabaseService.instance.saveReminders(state);
  }

  void updateReminder(AssetReminder updated) {
    state = state.map((r) => r.id == updated.id ? updated : r).toList();
    LocalDatabaseService.instance.saveReminders(state);
  }

  void removeReminder(String id) {
    state = state.where((r) => r.id != id).toList();
    LocalDatabaseService.instance.saveReminders(state);
  }

  void completeReminder(String id, {DateTime? completedAt}) {
    state = state.map((r) {
      if (r.id != id) return r;
      return r.copyWith(
        status: ReminderStatus.completed,
        completedAt: completedAt ?? DateTime.now(),
      );
    }).toList();
    LocalDatabaseService.instance.saveReminders(state);
  }

  void removeRemindersForAsset(String assetId) {
    state = state.where((r) => r.assetId != assetId).toList();
    LocalDatabaseService.instance.saveReminders(state);
  }
}

final remindersProvider = NotifierProvider<RemindersNotifier, List<AssetReminder>>(
  RemindersNotifier.new,
);
