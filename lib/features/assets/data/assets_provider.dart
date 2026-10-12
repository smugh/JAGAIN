import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_database_service.dart';
import '../domain/asset.dart';

export '../domain/asset.dart';

class AssetsNotifier extends Notifier<List<Asset>> {
  @override
  List<Asset> build() => LocalDatabaseService.instance.getAssets();

  void addAsset(Asset asset) {
    state = [asset, ...state];
    LocalDatabaseService.instance.saveAssets(state);
  }

  void updateAsset(Asset updated) {
    state = state.map((item) => item.id == updated.id ? updated : item).toList();
    LocalDatabaseService.instance.saveAssets(state);
  }

  void removeAsset(String id) {
    state = state.where((item) => item.id != id).toList();
    LocalDatabaseService.instance.saveAssets(state);
  }

  void toggleChecklistItem(String assetId, String itemId) {
    state = state.map((asset) {
      if (asset.id != assetId) return asset;
      final updatedChecklist = asset.checklist.map((c) {
        if (c.id != itemId) return c;
        return c.copyWith(isCompleted: !c.isCompleted);
      }).toList();
      return asset.copyWith(checklist: updatedChecklist, updatedAt: DateTime.now());
    }).toList();
    LocalDatabaseService.instance.saveAssets(state);
  }

  void addChecklistItem(String assetId, String title) {
    if (title.trim().isEmpty) return;
    state = state.map((asset) {
      if (asset.id != assetId) return asset;
      final newItem = ChecklistItem(
        id: 'chk_${DateTime.now().millisecondsSinceEpoch}',
        title: title.trim(),
        isCompleted: false,
      );
      return asset.copyWith(
        checklist: [...asset.checklist, newItem],
        updatedAt: DateTime.now(),
      );
    }).toList();
    LocalDatabaseService.instance.saveAssets(state);
  }

  void removeChecklistItem(String assetId, String itemId) {
    state = state.map((asset) {
      if (asset.id != assetId) return asset;
      final updatedChecklist = asset.checklist.where((c) => c.id != itemId).toList();
      return asset.copyWith(checklist: updatedChecklist, updatedAt: DateTime.now());
    }).toList();
    LocalDatabaseService.instance.saveAssets(state);
  }
}

final assetsProvider = NotifierProvider<AssetsNotifier, List<Asset>>(
  AssetsNotifier.new,
);
