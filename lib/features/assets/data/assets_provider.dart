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
    Asset(
      id: 'ast-2',
      name: 'MacBook Pro M2',
      categoryId: 'electronics',
      condition: AssetCondition.good,
      status: AssetStatus.active,
      brand: 'Apple',
      model: '14-inch M2 Pro',
      year: 2023,
      location: 'Meja Kerja',
      imagePath: 'assets/images/laptop.png',
      notes: 'Garansi resmi terdaftar.',
      checklist: const [
        ChecklistItem(id: 'c5', title: 'Backup mingguan Time Machine', isCompleted: true),
        ChecklistItem(id: 'c6', title: 'Bersihkan sirkulasi & keyboard', isCompleted: false),
        ChecklistItem(id: 'c7', title: 'Cek battery health cycle', isCompleted: true),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Asset(
      id: 'ast-3',
      name: 'Rumah Tinggal',
      categoryId: 'property',
      condition: AssetCondition.good,
      status: AssetStatus.active,
      year: 2018,
      location: 'Jakarta Selatan',
      imagePath: 'assets/images/house.png',
      notes: 'Servis rutin AC setiap 3 bulan.',
      checklist: const [
        ChecklistItem(id: 'c8', title: 'Cuci & servis AC berkala', isCompleted: false),
        ChecklistItem(id: 'c9', title: 'Bayar PBB & Iuran keamanan', isCompleted: true),
        ChecklistItem(id: 'c10', title: 'Cek talang air & rembesan', isCompleted: false),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 90)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    Asset(
      id: 'ast-4',
      name: 'Honda Vario 160',
      categoryId: 'vehicle',
      condition: AssetCondition.good,
      status: AssetStatus.active,
      brand: 'Honda',
      model: 'Vario 160 CBS',
      year: 2022,
      location: 'Garasi Samping',
      imagePath: 'assets/images/motor.png',
      notes: 'Ganti oli gardan & mesin teratur.',
      checklist: const [
        ChecklistItem(id: 'c11', title: 'Ganti oli mesin & oli gardan', isCompleted: false),
        ChecklistItem(id: 'c12', title: 'Cek v-belt & roller CVT', isCompleted: true),
        ChecklistItem(id: 'c13', title: 'Perpanjang masa berlaku STNK', isCompleted: false),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
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
