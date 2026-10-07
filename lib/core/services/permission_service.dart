import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request all essential app permissions on first app launch:
  /// - Notifications (pengingat & alarm perawatan)
  /// - Camera (foto aset & bukti perawatan)
  /// - Exact Alarms / Reminders (jadwal akurat waktu & tanggal di Android 12+)
  static Future<void> requestInitialPermissions() async {
    try {
      // 1. Request Notification permission
      final notifStatus = await Permission.notification.status;
      if (!notifStatus.isGranted) {
        await Permission.notification.request();
      }

      // 2. Request Camera permission
      final cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        await Permission.camera.request();
      }

      // 3. Request Exact Alarm permission (Android 12+ for exact time & date reminders)
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

  /// Check current status of essential permissions
  static Future<Map<String, bool>> checkPermissionStatuses() async {
    final camera = await Permission.camera.isGranted;
    final notification = await Permission.notification.isGranted;
    bool exactAlarm = true;
    try {
      exactAlarm = await Permission.scheduleExactAlarm.isGranted;
    } catch (_) {}

    return {
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
