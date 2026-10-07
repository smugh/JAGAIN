import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jagain/features/activity/data/activity_provider.dart';
import 'package:jagain/features/assets/data/assets_provider.dart';
import 'package:jagain/features/reminders/data/reminders_provider.dart';

void main() {
  group('Reminders & Activity Logs Tests', () {
    test('Initial reminders contains dummy reminders for Avanza', () {
      final container = ProviderContainer();
      final reminders = container.read(remindersProvider);

      expect(reminders.isNotEmpty, true);
      expect(reminders.any((r) => r.assetId == 'ast-1'), true);
      expect(reminders.any((r) => r.targetType == ReminderTargetType.checklistItem), true);
    });

    test('Add asset-level reminder and complete it', () {
      final container = ProviderContainer();
      final notifier = container.read(remindersProvider.notifier);

      final newReminder = AssetReminder(
        id: 'rem-test-1',
        assetId: 'ast-1',
        targetType: ReminderTargetType.asset,
        title: 'Servis Berkala Avanza',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        createdAt: DateTime.now(),
      );

      notifier.addReminder(newReminder);
      var reminders = container.read(remindersProvider);
      expect(reminders.any((r) => r.id == 'rem-test-1'), true);

      notifier.completeReminder('rem-test-1');
      reminders = container.read(remindersProvider);
      final completed = reminders.firstWhere((r) => r.id == 'rem-test-1');
      expect(completed.status, ReminderStatus.completed);
      expect(completed.completedAt != null, true);
    });

    test('Add activity log linked to asset and reminder execution', () {
      final container = ProviderContainer();
      final logNotifier = container.read(activityLogsProvider.notifier);

      final log = AssetActivityLog(
        id: 'log-test-1',
        assetId: 'ast-1',
        reminderId: 'rem-test-1',
        title: 'Ganti oli transmisi',
        targetName: 'Sub-Item Checklist: Ganti oli',
        type: ActivityType.reminderExecution,
        timestamp: DateTime.now(),
        notes: 'Biaya Rp 350.000 di bengkel resmi',
      );

      logNotifier.addLog(log);
      final logs = container.read(activityLogsProvider);
      expect(logs.any((l) => l.id == 'log-test-1'), true);
      final found = logs.firstWhere((l) => l.id == 'log-test-1');
      expect(found.notes, 'Biaya Rp 350.000 di bengkel resmi');
    });

    test('Asset checklist item toggle updates completion', () {
      final container = ProviderContainer();
      final assetNotifier = container.read(assetsProvider.notifier);

      final initialAvanza = container.read(assetsProvider).firstWhere((a) => a.id == 'ast-1');
      final c1 = initialAvanza.checklist.firstWhere((c) => c.id == 'c1');
      expect(c1.isCompleted, false);

      assetNotifier.toggleChecklistItem('ast-1', 'c1');
      final updatedAvanza = container.read(assetsProvider).firstWhere((a) => a.id == 'ast-1');
      final updatedC1 = updatedAvanza.checklist.firstWhere((c) => c.id == 'c1');
      expect(updatedC1.isCompleted, true);
    });
  });
}
