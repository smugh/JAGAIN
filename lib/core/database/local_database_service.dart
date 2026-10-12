import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../features/activity/domain/activity_log.dart';
import '../../features/assets/domain/asset.dart';
import '../../features/categories/domain/category.dart';
import '../../features/reminders/domain/reminder.dart';
import '../../i18n/app_locale.dart';

class LocalDatabaseService {
  LocalDatabaseService._();
  static final LocalDatabaseService instance = LocalDatabaseService._();

  bool _isInitialized = false;
  Directory? _dbDirectory;

  // Cached state for synchronous Riverpod build()
  List<Asset> _cachedAssets = [];
  List<AssetReminder> _cachedReminders = [];
  List<AssetActivityLog> _cachedActivityLogs = [];
  List<CategoryItem> _cachedCategories = [];
  ThemeMode _cachedThemeMode = ThemeMode.dark;
  AppLanguage _cachedLanguage = AppLanguage.id;

  bool get isInitialized => _isInitialized;
  String? get dbPath => _dbDirectory?.path;

  // Initial Seed Data
  static List<Asset> get defaultInitialAssets => [
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

  static List<AssetReminder> get defaultInitialReminders => [
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

  static List<AssetActivityLog> get defaultInitialActivityLogs => [
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

  static List<CategoryItem> get defaultInitialCategories => const [
        CategoryItem(
          id: 'vehicle',
          nameId: 'Kendaraan',
          nameEn: 'Vehicle',
          iconKey: 'car',
        ),
        CategoryItem(
          id: 'electronics',
          nameId: 'Elektronik',
          nameEn: 'Electronics',
          iconKey: 'laptop',
        ),
        CategoryItem(
          id: 'property',
          nameId: 'Properti',
          nameEn: 'Property',
          iconKey: 'house',
        ),
        CategoryItem(
          id: 'personal',
          nameId: 'Pribadi',
          nameEn: 'Personal',
          iconKey: 'watch',
        ),
        CategoryItem(
          id: 'other',
          nameId: 'Lainnya',
          nameEn: 'Other',
          iconKey: 'category',
        ),
      ];

  /// Initialize local database on app start
  Future<void> init({Directory? customDirectory}) async {
    try {
      if (customDirectory != null) {
        _dbDirectory = customDirectory;
      } else if (!kIsWeb) {
        final docDir = await getApplicationDocumentsDirectory();
        _dbDirectory = Directory(p.join(docDir.path, 'jagain_db'));
      }

      if (_dbDirectory != null && !await _dbDirectory!.exists()) {
        await _dbDirectory!.create(recursive: true);
      }

      await _loadOrSeedAll();
      _isInitialized = true;
      debugPrint('[LocalDatabaseService] Successfully initialized at: ${_dbDirectory?.path}');
    } catch (e, stack) {
      debugPrint('[LocalDatabaseService] Init warning: $e\n$stack');
      // Fallback in-memory defaults
      _populateInMemoryDefaults();
      _isInitialized = true;
    }
  }

  void _populateInMemoryDefaults() {
    if (_cachedAssets.isEmpty) _cachedAssets = defaultInitialAssets;
    if (_cachedReminders.isEmpty) _cachedReminders = defaultInitialReminders;
    if (_cachedActivityLogs.isEmpty) _cachedActivityLogs = defaultInitialActivityLogs;
    if (_cachedCategories.isEmpty) _cachedCategories = defaultInitialCategories;
  }

  Future<void> _loadOrSeedAll() async {
    if (_dbDirectory == null) {
      _populateInMemoryDefaults();
      return;
    }

    // 1. Assets
    final assetsFile = File(p.join(_dbDirectory!.path, 'assets.json'));
    if (await assetsFile.exists()) {
      try {
        final raw = await assetsFile.readAsString();
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        _cachedAssets = list.map((e) => Asset.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('[LocalDatabaseService] Error parsing assets.json: $e');
        _cachedAssets = defaultInitialAssets;
        await _atomicWrite(assetsFile, _cachedAssets.map((e) => e.toJson()).toList());
      }
    } else {
      _cachedAssets = defaultInitialAssets;
      await _atomicWrite(assetsFile, _cachedAssets.map((e) => e.toJson()).toList());
    }

    // 2. Reminders
    final remindersFile = File(p.join(_dbDirectory!.path, 'reminders.json'));
    if (await remindersFile.exists()) {
      try {
        final raw = await remindersFile.readAsString();
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        _cachedReminders = list.map((e) => AssetReminder.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('[LocalDatabaseService] Error parsing reminders.json: $e');
        _cachedReminders = defaultInitialReminders;
        await _atomicWrite(remindersFile, _cachedReminders.map((e) => e.toJson()).toList());
      }
    } else {
      _cachedReminders = defaultInitialReminders;
      await _atomicWrite(remindersFile, _cachedReminders.map((e) => e.toJson()).toList());
    }

    // 3. Activity Logs
    final logsFile = File(p.join(_dbDirectory!.path, 'activity_logs.json'));
    if (await logsFile.exists()) {
      try {
        final raw = await logsFile.readAsString();
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        _cachedActivityLogs = list.map((e) => AssetActivityLog.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('[LocalDatabaseService] Error parsing activity_logs.json: $e');
        _cachedActivityLogs = defaultInitialActivityLogs;
        await _atomicWrite(logsFile, _cachedActivityLogs.map((e) => e.toJson()).toList());
      }
    } else {
      _cachedActivityLogs = defaultInitialActivityLogs;
      await _atomicWrite(logsFile, _cachedActivityLogs.map((e) => e.toJson()).toList());
    }

    // 4. Categories
    final categoriesFile = File(p.join(_dbDirectory!.path, 'categories.json'));
    if (await categoriesFile.exists()) {
      try {
        final raw = await categoriesFile.readAsString();
        final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
        _cachedCategories = list.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        debugPrint('[LocalDatabaseService] Error parsing categories.json: $e');
        _cachedCategories = defaultInitialCategories;
        await _atomicWrite(categoriesFile, _cachedCategories.map((e) => e.toJson()).toList());
      }
    } else {
      _cachedCategories = defaultInitialCategories;
      await _atomicWrite(categoriesFile, _cachedCategories.map((e) => e.toJson()).toList());
    }

    // 5. Settings (ThemeMode & Language)
    final settingsFile = File(p.join(_dbDirectory!.path, 'settings.json'));
    if (await settingsFile.exists()) {
      try {
        final raw = await settingsFile.readAsString();
        final Map<String, dynamic> map = jsonDecode(raw) as Map<String, dynamic>;
        if (map['themeMode'] == 'light') {
          _cachedThemeMode = ThemeMode.light;
        } else {
          _cachedThemeMode = ThemeMode.dark;
        }
        if (map['language'] == 'en') {
          _cachedLanguage = AppLanguage.en;
        } else {
          _cachedLanguage = AppLanguage.id;
        }
      } catch (e) {
        debugPrint('[LocalDatabaseService] Error parsing settings.json: $e');
      }
    } else {
      await _atomicWrite(settingsFile, {
        'themeMode': _cachedThemeMode.name,
        'language': _cachedLanguage.name,
      });
    }
  }

  // --- Synchronous Getters for Riverpod Providers ---

  List<Asset> getAssets() {
    if (_cachedAssets.isNotEmpty) return _cachedAssets;
    return defaultInitialAssets;
  }

  List<AssetReminder> getReminders() {
    if (_cachedReminders.isNotEmpty) return _cachedReminders;
    return defaultInitialReminders;
  }

  List<AssetActivityLog> getActivityLogs() {
    if (_cachedActivityLogs.isNotEmpty) return _cachedActivityLogs;
    return defaultInitialActivityLogs;
  }

  List<CategoryItem> getCategories() {
    if (_cachedCategories.isNotEmpty) return _cachedCategories;
    return defaultInitialCategories;
  }

  ThemeMode getThemeMode() => _cachedThemeMode;

  AppLanguage getLanguage() => _cachedLanguage;

  // --- Persistence Save Operations ---

  Future<void> saveAssets(List<Asset> assets) async {
    _cachedAssets = List.from(assets);
    if (_dbDirectory == null) return;
    final file = File(p.join(_dbDirectory!.path, 'assets.json'));
    await _atomicWrite(file, assets.map((e) => e.toJson()).toList());
  }

  Future<void> saveReminders(List<AssetReminder> reminders) async {
    _cachedReminders = List.from(reminders);
    if (_dbDirectory == null) return;
    final file = File(p.join(_dbDirectory!.path, 'reminders.json'));
    await _atomicWrite(file, reminders.map((e) => e.toJson()).toList());
  }

  Future<void> saveActivityLogs(List<AssetActivityLog> logs) async {
    _cachedActivityLogs = List.from(logs);
    if (_dbDirectory == null) return;
    final file = File(p.join(_dbDirectory!.path, 'activity_logs.json'));
    await _atomicWrite(file, logs.map((e) => e.toJson()).toList());
  }

  Future<void> saveCategories(List<CategoryItem> categories) async {
    _cachedCategories = List.from(categories);
    if (_dbDirectory == null) return;
    final file = File(p.join(_dbDirectory!.path, 'categories.json'));
    await _atomicWrite(file, categories.map((e) => e.toJson()).toList());
  }

  Future<void> saveSettings({ThemeMode? themeMode, AppLanguage? language}) async {
    if (themeMode != null) _cachedThemeMode = themeMode;
    if (language != null) _cachedLanguage = language;
    if (_dbDirectory == null) return;
    final file = File(p.join(_dbDirectory!.path, 'settings.json'));
    await _atomicWrite(file, {
      'themeMode': _cachedThemeMode.name,
      'language': _cachedLanguage.name,
    });
  }

  // --- Atomic File Write Helper ---

  Future<void> _atomicWrite(File targetFile, Object data) async {
    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final tempFile = File('${targetFile.path}.tmp');
      await tempFile.writeAsString(jsonString, flush: true);
      if (await targetFile.exists()) {
        await targetFile.delete();
      }
      await tempFile.rename(targetFile.path);
    } catch (e) {
      debugPrint('[LocalDatabaseService] Atomic write fallback: $e');
      try {
        final jsonString = jsonEncode(data);
        await targetFile.writeAsString(jsonString, flush: true);
      } catch (err) {
        debugPrint('[LocalDatabaseService] Write failed: $err');
      }
    }
  }

  // --- Diagnostics & Info ---

  Future<Map<String, dynamic>> getDatabaseInfo() async {
    int totalBytes = 0;
    if (_dbDirectory != null && await _dbDirectory!.exists()) {
      await for (final entity in _dbDirectory!.list(recursive: false)) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }
    }

    return {
      'path': _dbDirectory?.path ?? 'In-Memory',
      'assetsCount': _cachedAssets.length,
      'remindersCount': _cachedReminders.length,
      'activityLogsCount': _cachedActivityLogs.length,
      'categoriesCount': _cachedCategories.length,
      'totalSizeBytes': totalBytes,
      'totalSizeFormatted': '${(totalBytes / 1024).toStringAsFixed(1)} KB',
    };
  }

  /// Export complete local database content as single JSON
  Future<String> exportDatabaseJson() async {
    final exportMap = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'assets': _cachedAssets.map((e) => e.toJson()).toList(),
      'reminders': _cachedReminders.map((e) => e.toJson()).toList(),
      'activityLogs': _cachedActivityLogs.map((e) => e.toJson()).toList(),
      'categories': _cachedCategories.map((e) => e.toJson()).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(exportMap);
  }

  /// Reset local database to default initial state
  Future<void> resetToDefaults() async {
    _cachedAssets = defaultInitialAssets;
    _cachedReminders = defaultInitialReminders;
    _cachedActivityLogs = defaultInitialActivityLogs;
    _cachedCategories = defaultInitialCategories;
    _cachedThemeMode = ThemeMode.dark;
    _cachedLanguage = AppLanguage.id;

    if (_dbDirectory != null) {
      await saveAssets(_cachedAssets);
      await saveReminders(_cachedReminders);
      await saveActivityLogs(_cachedActivityLogs);
      await saveCategories(_cachedCategories);
      await saveSettings();
    }
  }
}
