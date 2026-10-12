import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database_service.dart';
import '../domain/activity_log.dart';

export '../domain/activity_log.dart';

class ActivityLogsNotifier extends Notifier<List<AssetActivityLog>> {
  @override
  List<AssetActivityLog> build() => LocalDatabaseService.instance.getActivityLogs();

  void addLog(AssetActivityLog log) {
    state = [log, ...state];
    LocalDatabaseService.instance.saveActivityLogs(state);
  }

  void removeLog(String id) {
    state = state.where((l) => l.id != id).toList();
    LocalDatabaseService.instance.saveActivityLogs(state);
  }

  void removeLogsForAsset(String assetId) {
    state = state.where((l) => l.assetId != assetId).toList();
    LocalDatabaseService.instance.saveActivityLogs(state);
  }
}

final activityLogsProvider = NotifierProvider<ActivityLogsNotifier, List<AssetActivityLog>>(
  ActivityLogsNotifier.new,
);
