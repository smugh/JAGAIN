import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/date_format_helper.dart';
import '../../../i18n/app_locale.dart';
import '../../../theme/app_theme.dart';
import '../../activity/data/activity_provider.dart';
import '../../assets/data/assets_provider.dart';
import '../data/reminders_provider.dart';

class ExecuteReminderDialog extends ConsumerStatefulWidget {
  const ExecuteReminderDialog({
    required this.reminder,
    super.key,
  });

  final AssetReminder reminder;

  static Future<bool?> show(BuildContext context, AssetReminder reminder) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ExecuteReminderDialog(reminder: reminder),
    );
  }

  @override
  ConsumerState<ExecuteReminderDialog> createState() => _ExecuteReminderDialogState();
}

class _ExecuteReminderDialogState extends ConsumerState<ExecuteReminderDialog> {
  final _notesController = TextEditingController();
  bool _saveToHistory = true;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _confirm() {
    final strings = ref.read(stringsProvider);
    final reminder = widget.reminder;

    // 1. Mark reminder as completed
    ref.read(remindersProvider.notifier).completeReminder(reminder.id);

    // 2. If it was linked to a checklist item, toggle/complete that item
    if (reminder.checklistItemId != null) {
      final assets = ref.read(assetsProvider);
      final parentAsset = assets.firstWhere((a) => a.id == reminder.assetId, orElse: () => assets.first);
      final checklistItem = parentAsset.checklist.where((c) => c.id == reminder.checklistItemId).firstOrNull;
      if (checklistItem != null && !checklistItem.isCompleted) {
        ref.read(assetsProvider.notifier).toggleChecklistItem(reminder.assetId, reminder.checklistItemId!);
      }
    }

    // 3. If user opted to save to history / action log
    if (_saveToHistory) {
      final assets = ref.read(assetsProvider);
      final parentAsset = assets.where((a) => a.id == reminder.assetId).firstOrNull;
      final assetName = parentAsset?.name ?? 'Aset';

      String targetLabel = reminder.isChecklistItem
          ? 'Sub-Item Checklist: ${reminder.title}'
          : 'Aset Utama: $assetName';

      final newLog = AssetActivityLog(
        id: 'log_${DateTime.now().millisecondsSinceEpoch}',
        assetId: reminder.assetId,
        reminderId: reminder.id,
        checklistItemId: reminder.checklistItemId,
        title: reminder.title,
        targetName: targetLabel,
        type: ActivityType.reminderExecution,
        timestamp: DateTime.now(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      ref.read(activityLogsProvider.notifier).addLog(newLog);
    }

    Navigator.of(context).pop(true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.reminderExecutedSuccess),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assets = ref.watch(assetsProvider);
    final parentAsset = assets.where((a) => a.id == widget.reminder.assetId).firstOrNull;
    final assetName = parentAsset?.name ?? (strings.isId ? 'Aset' : 'Asset');

    final dateFormat =
        safeDateFormat('EEEE, d MMM yyyy · HH:mm', strings.isId ? 'id_ID' : 'en_US');

    return AlertDialog(
      backgroundColor: isDark ? JagainColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.25 : 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.task_alt_rounded, color: Color(0xFF10B981), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              strings.executeReminderTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reminder Info Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? JagainColors.darkBackground : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? JagainColors.darkBorder : JagainColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.reminder.isChecklistItem
                              ? JagainColors.primary.withValues(alpha: 0.15)
                              : Colors.blue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.reminder.isChecklistItem
                              ? (strings.isId ? '📋 Sub-Item Checklist' : '📋 Checklist Sub-Item')
                              : (strings.isId ? '📌 Aset Utama' : '📌 Main Asset'),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: widget.reminder.isChecklistItem
                                ? JagainColors.primary
                                : Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          assetName,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.reminder.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(widget.reminder.dueDate),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Checkbox: Simpan ke riwayat / log aset
            Container(
              decoration: BoxDecoration(
                color: _saveToHistory
                    ? (isDark ? JagainColors.darkAccentBg : JagainColors.mint)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _saveToHistory ? JagainColors.primary : (isDark ? JagainColors.darkBorder : JagainColors.border),
                ),
              ),
              child: SwitchListTile(
                value: _saveToHistory,
                onChanged: (val) => setState(() => _saveToHistory = val),
                activeColor: JagainColors.primary,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                dense: true,
                title: Text(
                  strings.saveToHistoryOption,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Catatan Tindakan (Opsional)
            if (_saveToHistory) ...[
              Text(
                strings.actionLogNotesLabel,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: strings.actionLogNotesHint,
                  hintStyle: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(strings.cancel),
        ),
        FilledButton.icon(
          onPressed: _confirm,
          icon: const Icon(Icons.check_rounded, size: 16),
          label: Text(strings.confirmAndSaveLog),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
