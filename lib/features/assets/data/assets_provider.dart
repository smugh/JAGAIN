import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/asset.dart';

export '../domain/asset.dart';

class AssetsNotifier extends Notifier<List<Asset>> {
  @override
  List<Asset> build() => _initialAssets;

  static final List<Asset> _initialAssets = [
    Asset(
      id: 'ast-1',
      name: 'Toyota Avanza',
      categoryId: 'vehicle',
      condition: AssetCondition.needsAttention,
      status: AssetStatus.active,
      brand: 'Toyota',
      model: 'Avanza G 1.5',
      year: 2021,
      location: 'Garasi Depan',
      imagePath: 'assets/images/car.png',
      notes: 'Pajak tahunan dan servis oli bulan ini.',
      checklist: const [
        ChecklistItem(id: 'c1', title: 'Jadwal servis berkala & ganti oli', isCompleted: false),
        ChecklistItem(id: 'c2', title: 'Bayar pajak tahunan (PKB)', isCompleted: false),
        ChecklistItem(id: 'c3', title: 'Ganti kampas rem depan', isCompleted: true),
        ChecklistItem(id: 'c4', title: 'Cek tekanan angin ban & aki', isCompleted: true),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  void addAsset(Asset asset) {
    state = [asset, ...state];
  }

  void updateAsset(Asset updated) {
    state = state.map((item) => item.id == updated.id ? updated : item).toList();
  }

  void removeAsset(String id) {
    state = state.where((item) => item.id != id).toList();
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
  }

  void removeChecklistItem(String assetId, String itemId) {
    state = state.map((asset) {
      if (asset.id != assetId) return asset;
      final updatedChecklist = asset.checklist.where((c) => c.id != itemId).toList();
      return asset.copyWith(checklist: updatedChecklist, updatedAt: DateTime.now());
    }).toList();
  }
}

final assetsProvider = NotifierProvider<AssetsNotifier, List<Asset>>(
  AssetsNotifier.new,
);
