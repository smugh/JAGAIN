import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request all essential app permissions on first app launch / installation:
  /// - Local Storage & Media (penyimpanan database aset lokal & lampiran foto)
  /// - Notifications (pengingat & alarm perawatan)
  /// - Camera (foto aset & bukti perawatan)
  /// - Exact Alarms / Reminders (jadwal akurat waktu & tanggal di Android 12+)
  static Future<void> requestInitialPermissions() async {
    try {
      // 1. Request Local Storage permission (Android 12 and below)
      try {
        final storageStatus = await Permission.storage.status;
        if (!storageStatus.isGranted) {
          await Permission.storage.request();
        }
      } catch (e) {
        debugPrint('Storage permission error: $e');
      }

      // 2. Request Media / Photos permission (Android 13+ READ_MEDIA_IMAGES)
      try {
        final photosStatus = await Permission.photos.status;
        if (!photosStatus.isGranted) {
          await Permission.photos.request();
        }
      } catch (e) {
        debugPrint('Photos permission error: $e');
      }

      // 3. Request Notification permission
      try {
        final notifStatus = await Permission.notification.status;
        if (!notifStatus.isGranted) {
          await Permission.notification.request();
        }
      } catch (e) {
        debugPrint('Notification permission error: $e');
      }

      // 4. Request Camera permission
      try {
        final cameraStatus = await Permission.camera.status;
        if (!cameraStatus.isGranted) {
          await Permission.camera.request();
        }
      } catch (e) {
        debugPrint('Camera permission error: $e');
      }

      // 5. Request Exact Alarm permission (Android 12+ for exact time & date reminders)
      try {
        final alarmStatus = await Permission.scheduleExactAlarm.status;
        if (!alarmStatus.isGranted) {
          await Permission.scheduleExactAlarm.request();
        }
      } catch (e) {
        debugPrint('Schedule exact alarm not applicable on this platform: $e');
      }
    } catch (e) {
      debugPrint('Error requesting initial permissions: $e');
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
