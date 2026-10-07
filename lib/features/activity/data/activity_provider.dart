import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/activity_log.dart';

export '../domain/activity_log.dart';

class ActivityLogsNotifier extends Notifier<List<AssetActivityLog>> {
  @override
  List<AssetActivityLog> build() => _initialLogs;

  static final List<AssetActivityLog> _initialLogs = [
    AssetActivityLog(
      id: 'log-1',
      assetId: 'ast-1',
      checklistItemId: 'c3',
      title: 'Ganti kampas rem depan',
      targetName: 'Sub-Item Checklist',
      type: ActivityType.reminderExecution,
      timestamp: DateTime.now().subtract(const Duration(days: 20)),
      notes: 'Ganti kampas rem depan di bengkel resmi Auto2000. Pengereman normal dan aman.',
    ),
    AssetActivityLog(
      id: 'log-2',
      assetId: 'ast-1',
      checklistItemId: 'c4',
      title: 'Cek tekanan angin ban & aki',
      targetName: 'Sub-Item Checklist',
      type: ActivityType.maintenance,
      timestamp: DateTime.now().subtract(const Duration(days: 35)),
      notes: 'Tekanan ban disetel 33 psi, tegangan aki stabil di 12.6V.',
    ),
  ];

  void addLog(AssetActivityLog log) {
    state = [log, ...state];
  }

  void removeLog(String id) {
    state = state.where((l) => l.id != id).toList();
  }

  void removeLogsForAsset(String assetId) {
    state = state.where((l) => l.assetId != assetId).toList();
  }
}

final activityLogsProvider = NotifierProvider<ActivityLogsNotifier, List<AssetActivityLog>>(
  ActivityLogsNotifier.new,
);
