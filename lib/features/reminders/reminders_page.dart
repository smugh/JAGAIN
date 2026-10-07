import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../i18n/app_locale.dart';
import '../../theme/app_theme.dart';
import '../assets/data/assets_provider.dart';
import 'data/reminders_provider.dart';
import 'presentation/add_reminder_sheet.dart';
import 'presentation/execute_reminder_dialog.dart';

class RemindersPage extends ConsumerStatefulWidget {
  const RemindersPage({super.key});

  @override
  ConsumerState<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends ConsumerState<RemindersPage> {
  int _selectedFilterIndex = 0; // 0: Semua, 1: Mendatang, 2: Selesai

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allReminders = ref.watch(remindersProvider);
    final allAssets = ref.watch(assetsProvider);

    final filteredReminders = allReminders.where((r) {
      if (_selectedFilterIndex == 1) {
        return r.status != ReminderStatus.completed;
      } else if (_selectedFilterIndex == 2) {
        return r.status == ReminderStatus.completed;
      }
      return true;
    }).toList();

    final dateFormat = DateFormat('EEE, d MMM yyyy · HH:mm', strings.isId ? 'id_ID' : 'en_US');

    return Scaffold(
      backgroundColor: isDark ? JagainColors.darkBackground : JagainColors.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.navReminders,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.isId
                              ? 'Jadwal servis, pajak, dan perawatan asetmu.'
                              : 'Service, tax, and care schedule for your assets.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => AddReminderSheet.show(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(strings.isId ? 'Tambah' : 'Add'),
                    style: FilledButton.styleFrom(
                      backgroundColor: JagainColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterTab(0, strings.isId ? 'Semua' : 'All', allReminders.length),
                  const SizedBox(width: 8),
                  _buildFilterTab(
                    1,
                    strings.isId ? 'Mendatang' : 'Upcoming',
                    allReminders.where((r) => r.status != ReminderStatus.completed).length,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterTab(
                    2,
                    strings.isId ? 'Selesai' : 'Completed',
                    allReminders.where((r) => r.status == ReminderStatus.completed).length,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Reminders List
            Expanded(
              child: filteredReminders.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDark ? JagainColors.darkSurface : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? JagainColors.darkBorder : JagainColors.border,
                                ),
                              ),
                              child: Icon(
                                Icons.notifications_none_rounded,
                                size: 48,
                                color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              strings.isId ? 'Belum ada pengingat' : 'No reminders yet',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              strings.isId
                                  ? 'Ketuk tombol "+ Tambah" untuk mengatur jadwal pengingat baru.'
                                  : 'Tap "+ Add" to schedule a new reminder.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: filteredReminders.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final reminder = filteredReminders[index];
                        final asset = allAssets.where((a) => a.id == reminder.assetId).firstOrNull;
                        final assetName = asset?.name ?? (strings.isId ? 'Aset' : 'Asset');
                        final isCompleted = reminder.isCompleted;

                        return Container(
                          decoration: BoxDecoration(
                            color: isDark ? JagainColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCompleted
                                  ? (isDark ? Colors.white12 : Colors.black12)
                                  : (isDark ? JagainColors.darkBorder : JagainColors.border),
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              if (!isCompleted) {
                                ExecuteReminderDialog.show(context, reminder);
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Action / Checkbox button
                                  IconButton(
                                    icon: Icon(
                                      isCompleted
                                          ? Icons.check_circle_rounded
                                          : Icons.radio_button_unchecked_rounded,
                                      color: isCompleted
                                          ? const Color(0xFF10B981)
                                          : (isDark ? JagainColors.primaryLight : JagainColors.primary),
                                      size: 24,
                                    ),
                                    onPressed: () {
                                      if (!isCompleted) {
                                        ExecuteReminderDialog.show(context, reminder);
                                      }
                                    },
                                    tooltip: isCompleted
                                        ? (strings.isId ? 'Selesai' : 'Completed')
                                        : strings.executeReminderAction,
                                  ),
                                  const SizedBox(width: 4),

                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Badges: Asset & Target Type
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                              decoration: BoxDecoration(
                                                color: JagainColors.primary.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                assetName,
                                                style: TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: reminder.isChecklistItem
                                                    ? Colors.purple.withValues(alpha: 0.12)
                                                    : Colors.blue.withValues(alpha: 0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                reminder.isChecklistItem
                                                    ? (strings.isId ? '📋 Sub-Item Checklist' : '📋 Checklist')
                                                    : (strings.isId ? '📌 Aset Utama' : '📌 Main Asset'),
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: reminder.isChecklistItem ? Colors.purple : Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),

                                        // Title
                                        Text(
                                          reminder.title,
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.w700,
                                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                                            color: isCompleted
                                                ? (isDark ? JagainColors.darkMuted : JagainColors.muted)
                                                : (isDark ? JagainColors.darkText : JagainColors.ink),
                                          ),
                                        ),
                                        const SizedBox(height: 4),

                                        // Due Date
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time_rounded,
                                              size: 13,
                                              color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${dateFormat.format(reminder.dueDate)} WIB',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Notes if any
                                        if (reminder.notes != null && reminder.notes!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            reminder.notes!,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontStyle: FontStyle.italic,
                                              color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  // Popup Menu (Delete)
                                  PopupMenuButton<String>(
                                    icon: Icon(
                                      Icons.more_vert_rounded,
                                      size: 18,
                                      color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                    ),
                                    onSelected: (val) {
                                      if (val == 'delete') {
                                        ref.read(remindersProvider.notifier).removeReminder(reminder.id);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(strings.isId ? 'Pengingat dihapus' : 'Reminder deleted'),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      }
                                    },
                                    itemBuilder: (ctx) => [
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                                            const SizedBox(width: 8),
                                            Text(
                                              strings.isId ? 'Hapus Pengingat' : 'Delete Reminder',
                                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(int index, String label, int count) {
    final isSelected = _selectedFilterIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectedFilterIndex = index),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? JagainColors.primary.withValues(alpha: isDark ? 0.25 : 0.15)
              : (isDark ? JagainColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? JagainColors.primary : (isDark ? JagainColors.darkBorder : JagainColors.border),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? JagainColors.primaryLight : JagainColors.primaryDark)
                    : (isDark ? JagainColors.darkMuted : JagainColors.muted),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? JagainColors.primary
                    : (isDark ? Colors.white12 : Colors.black12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
