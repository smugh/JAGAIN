import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../i18n/app_locale.dart';
import '../../theme/app_theme.dart';
import '../assets/data/assets_provider.dart';
import 'data/activity_provider.dart';

class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allLogs = ref.watch(activityLogsProvider);
    final allAssets = ref.watch(assetsProvider);

    final dateFormat = DateFormat('EEE, d MMM yyyy · HH:mm', strings.isId ? 'id_ID' : 'en_US');

    return Scaffold(
      backgroundColor: isDark ? JagainColors.darkBackground : JagainColors.canvas,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.navActivity,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    strings.isId
                        ? 'Riwayat tindakan, servis, dan pengingat yang dieksekusi.'
                        : 'History of maintenance, executed reminders, and asset logs.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                        ),
                  ),
                ],
              ),
            ),

            // Timeline List
            Expanded(
              child: allLogs.isEmpty
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
                                Icons.history_rounded,
                                size: 48,
                                color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              strings.isId ? 'Belum ada aktivitas' : 'No activity yet',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              strings.isId
                                  ? 'Setiap kali kamu menyelesaikan pengingat atau mencatat servis, log akan muncul di sini.'
                                  : 'Whenever you complete reminders or log care actions, they will appear here.',
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
                      itemCount: allLogs.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final log = allLogs[index];
                        final asset = allAssets.where((a) => a.id == log.assetId).firstOrNull;
                        final assetName = asset?.name ?? (strings.isId ? 'Aset' : 'Asset');

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? JagainColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? JagainColors.darkBorder : JagainColors.border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Badges & Date
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
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  if (log.targetName != null) ...[
                                    Expanded(
                                      child: Text(
                                        log.targetName!,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ] else
                                    const Spacer(),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 11,
                                        color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        dateFormat.format(log.timestamp),
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Title
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check_rounded,
                                      size: 14,
                                      color: Color(0xFF10B981),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      log.title,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Notes if available
                              if (log.notes != null && log.notes!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark ? JagainColors.darkBackground : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.notes_rounded,
                                        size: 14,
                                        color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          log.notes!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.4,
                                            color: isDark ? JagainColors.darkText : JagainColors.ink,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
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
}
