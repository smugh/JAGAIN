import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jagain/core/database/local_database_service.dart';
import 'package:jagain/features/activity/data/activity_provider.dart';
import 'package:jagain/features/assets/data/assets_provider.dart';
import 'package:jagain/features/categories/data/categories_provider.dart';
import 'package:jagain/features/reminders/data/reminders_provider.dart';

void main() {
  group('LocalDatabaseService Persistence & Bug Fix Verification', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('jagain_test_db_');
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('Initializes and seeds database files on device storage if empty', () async {
      final db = LocalDatabaseService.instance;
      await db.init(customDirectory: tempDir);

      expect(db.isInitialized, true);
      expect(File('${tempDir.path}/assets.json').existsSync(), true);
      expect(File('${tempDir.path}/reminders.json').existsSync(), true);
      expect(File('${tempDir.path}/activity_logs.json').existsSync(), true);
      expect(File('${tempDir.path}/categories.json').existsSync(), true);
      expect(File('${tempDir.path}/settings.json').existsSync(), true);

      final assets = db.getAssets();
      expect(assets.isNotEmpty, true);
      expect(assets.first.name, 'Toyota Avanza');
    });

    test('Persists newly added asset across simulated app close and restart', () async {
      final db = LocalDatabaseService.instance;
      await db.init(customDirectory: tempDir);

      final container = ProviderContainer();
      final notifier = container.read(assetsProvider.notifier);

      final newAsset = Asset(
        id: 'ast-motor-99',
        name: 'Yamaha NMAX 155',
        categoryId: 'vehicle',
        condition: AssetCondition.good,
        status: AssetStatus.active,
        brand: 'Yamaha',
        model: 'NMAX',
        year: 2023,
        location: 'Garasi Samping',
        notes: 'Motor harian kantor',
        checklist: const [
          ChecklistItem(id: 'chk-1', title: 'Ganti oli mesin Tiap 2000 km', isCompleted: false),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      notifier.addAsset(newAsset);
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Verify file content on disk has the new asset
      final rawAssets = await File('${tempDir.path}/assets.json').readAsString();
      expect(rawAssets.contains('Yamaha NMAX 155'), true);

      // SIMULATE APP CLOSE AND REOPEN
      // Create a fresh container and re-init from the same directory
      await db.init(customDirectory: tempDir);
      final restartedContainer = ProviderContainer();
      final reloadedAssets = restartedContainer.read(assetsProvider);

      expect(reloadedAssets.any((a) => a.id == 'ast-motor-99'), true);
      final loadedNmax = reloadedAssets.firstWhere((a) => a.id == 'ast-motor-99');
      expect(loadedNmax.name, 'Yamaha NMAX 155');
      expect(loadedNmax.brand, 'Yamaha');
      expect(loadedNmax.checklist.length, 1);
      expect(loadedNmax.checklist.first.title, 'Ganti oli mesin Tiap 2000 km');
    });

    test('Persists checklist item toggle across app restart', () async {
      final db = LocalDatabaseService.instance;
      await db.init(customDirectory: tempDir);

      final container = ProviderContainer();
      final notifier = container.read(assetsProvider.notifier);

      // Toggle first checklist item of Avanza (c1)
      notifier.toggleChecklistItem('ast-1', 'c1');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Simulating app restart
      await db.init(customDirectory: tempDir);
      final restartedContainer = ProviderContainer();
      final assets = restartedContainer.read(assetsProvider);
      final avanza = assets.firstWhere((a) => a.id == 'ast-1');
      final c1 = avanza.checklist.firstWhere((c) => c.id == 'c1');

      expect(c1.isCompleted, true);
    });

    test('Persists reminders and activity logs across app restart', () async {
      final db = LocalDatabaseService.instance;
      await db.init(customDirectory: tempDir);

      final container = ProviderContainer();
      final reminderNotifier = container.read(remindersProvider.notifier);
      final logNotifier = container.read(activityLogsProvider.notifier);

      final customReminder = AssetReminder(
        id: 'rem-custom-1',
        assetId: 'ast-1',
        targetType: ReminderTargetType.asset,
        title: 'Cek Aki Bulanan',
        dueDate: DateTime.now().add(const Duration(days: 14)),
        createdAt: DateTime.now(),
        notes: 'Cek voltase aki basah',
      );
      reminderNotifier.addReminder(customReminder);

      final customLog = AssetActivityLog(
        id: 'log-custom-1',
        assetId: 'ast-1',
        reminderId: 'rem-custom-1',
        title: 'Servis Ringan Selesai',
        timestamp: DateTime.now(),
        notes: 'Pemeriksaan rutin berjalan lancar',
      );
      logNotifier.addLog(customLog);

      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Simulate app restart
      await db.init(customDirectory: tempDir);
      final restartedContainer = ProviderContainer();

      final loadedReminders = restartedContainer.read(remindersProvider);
      final loadedLogs = restartedContainer.read(activityLogsProvider);

      expect(loadedReminders.any((r) => r.id == 'rem-custom-1'), true);
      expect(loadedReminders.firstWhere((r) => r.id == 'rem-custom-1').title, 'Cek Aki Bulanan');

      expect(loadedLogs.any((l) => l.id == 'log-custom-1'), true);
      expect(loadedLogs.firstWhere((l) => l.id == 'log-custom-1').notes, 'Pemeriksaan rutin berjalan lancar');
    });

    test('Persists custom categories across app restart', () async {
      final db = LocalDatabaseService.instance;
      await db.init(customDirectory: tempDir);

      final container = ProviderContainer();
      final catNotifier = container.read(categoriesProvider.notifier);

      catNotifier.addCategory(name: 'Koleksi Seni', iconKey: 'brush');
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Simulate app restart
      await db.init(customDirectory: tempDir);
      final restartedContainer = ProviderContainer();
      final categories = restartedContainer.read(categoriesProvider);

      expect(categories.any((c) => c.nameId == 'Koleksi Seni'), true);
    });

    test('Database info report contains correct statistics', () async {
      final db = LocalDatabaseService.instance;
      await db.init(customDirectory: tempDir);

      final info = await db.getDatabaseInfo();
      expect(info['path'], tempDir.path);
      expect(info['assetsCount'], greaterThanOrEqualTo(1));
      expect(info['remindersCount'], greaterThanOrEqualTo(2));
      expect(info['activityLogsCount'], greaterThanOrEqualTo(2));
      expect(info['categoriesCount'], greaterThanOrEqualTo(5));
      expect(info['totalSizeBytes'], greaterThan(0));
    });
  });
}
