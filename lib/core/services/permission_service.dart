import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static bool _isRequesting = false;

  /// Request all essential app permissions on first app launch / installation:
  /// - Local Storage & Media (penyimpanan database aset lokal & lampiran foto)
  /// - Notifications (pengingat & alarm perawatan)
  /// - Camera (foto aset & bukti perawatan)
  /// - Exact Alarms / Reminders (jadwal akurat waktu & tanggal di Android 12+)
  static Future<void> requestInitialPermissions() async {
    if (_isRequesting) return;
    _isRequesting = true;
    try {
      final permissions = <Permission>[
        Permission.storage,
        Permission.photos,
        Permission.notification,
        Permission.camera,
        Permission.scheduleExactAlarm,
      ];
      await permissions.request();
    } catch (e) {
      debugPrint('Error requesting initial permissions: $e');
    } finally {
      _isRequesting = false;
    }
  }

  /// Request local storage permission specifically
  static Future<bool> requestStoragePermission() async {
    try {
      final s1 = await Permission.storage.request();
      final s2 = await Permission.photos.request();
      return s1.isGranted || s2.isGranted;
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Check current status of essential permissions
  static Future<Map<String, bool>> checkPermissionStatuses() async {
    bool storage = false;
    try {
      storage = await Permission.storage.isGranted || await Permission.photos.isGranted;
    } catch (_) {}

    bool camera = false;
    try {
      camera = await Permission.camera.isGranted;
    } catch (_) {}

    bool notification = false;
    try {
      notification = await Permission.notification.isGranted;
    } catch (_) {}

    bool exactAlarm = true;
    try {
      exactAlarm = await Permission.scheduleExactAlarm.isGranted;
    } catch (_) {}

    return {
      'storage': storage,
      'camera': camera,
      'notification': notification,
      'exactAlarm': exactAlarm,
    };
  }

  /// Open system app settings page if user denied permissions
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
