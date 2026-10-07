import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../i18n/app_locale.dart';
import '../../../theme/app_theme.dart';
import '../data/assets_provider.dart';

class AssetDetailPage extends ConsumerWidget {
  const AssetDetailPage({required this.asset, super.key});

  final Asset asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allAssets = ref.watch(assetsProvider);
    final currentAsset = allAssets.firstWhere(
      (a) => a.id == asset.id,
      orElse: () => asset,
    );

    final condColor = _getConditionColor(currentAsset.condition);
    final condText = _getConditionText(currentAsset.condition, strings);

    return Scaffold(
      backgroundColor: isDark ? JagainColors.darkBackground : JagainColors.canvas,
      appBar: AppBar(
        title: Text(
          currentAsset.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: strings.isId ? 'Hapus Aset' : 'Delete Asset',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context, ref, strings, currentAsset),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        children: [
          // 1. Asset Hero Image & Condition Badge
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              height: 200,
              width: double.infinity,
              color: isDark ? JagainColors.darkSurface : const Color(0xFFF1F5F9),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (currentAsset.imagePath != null && currentAsset.imagePath!.isNotEmpty)
                    Image.asset(
                      currentAsset.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _buildFallbackImage(isDark),
                    )
                  else
                    _buildFallbackImage(isDark),
                  // Gradient Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Condition Badge on Image
                  Positioned(
                    bottom: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: condColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: condColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shield_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            condText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. Asset Header Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      currentAsset.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strings.categoryName(currentAsset.categoryId),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (isDark ? JagainColors.darkSurface : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? JagainColors.darkBorder : JagainColors.border,
                  ),
                ),
                child: Text(
                  strings.isId ? 'Aktif Dijagain' : 'Actively Cared',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // 3. Information Card (PRD: Brand, Model, Year, Location)
          Text(
            strings.isId ? 'Informasi Aset' : 'Asset Information',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(
                    context,
                    isDark,
                    icon: Icons.branding_watermark_outlined,
                    label: strings.brandLabel,
                    value: currentAsset.brand ?? '-',
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    context,
                    isDark,
                    icon: Icons.tag_rounded,
                    label: strings.modelLabel,
                    value: currentAsset.model ?? '-',
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    context,
                    isDark,
                    icon: Icons.calendar_today_rounded,
                    label: strings.yearLabel,
                    value: currentAsset.year != null ? '${currentAsset.year}' : '-',
                  ),
                  const Divider(height: 20),
                  _buildDetailRow(
                    context,
                    isDark,
                    icon: Icons.location_on_outlined,
                    label: strings.locationLabel,
                    value: currentAsset.location ?? '-',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          // 4. Checklist & Atribut Perawatan (Interactive Checklist)
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.checklistTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _showAddChecklistDialog(context, ref, currentAsset.id, strings),
                icon: const Icon(Icons.add_task_rounded, size: 16),
                label: Text(strings.isId ? 'Tambah' : 'Add'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${currentAsset.completedChecklistCount} dari ${currentAsset.totalChecklistCount} ${strings.checklistDone}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        currentAsset.totalChecklistCount == 0
                            ? '0%'
                            : '${((currentAsset.completedChecklistCount / currentAsset.totalChecklistCount) * 100).toInt()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: currentAsset.totalChecklistCount == 0
                          ? 0.0
                          : currentAsset.completedChecklistCount / currentAsset.totalChecklistCount,
                      minHeight: 6,
                      backgroundColor: isDark ? JagainColors.darkBackground : const Color(0xFFE2E8F0),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        currentAsset.completedChecklistCount == currentAsset.totalChecklistCount && currentAsset.totalChecklistCount > 0
                            ? const Color(0xFF10B981)
                            : JagainColors.primary,
                      ),
                    ),
                  ),
                  if (currentAsset.checklist.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 4),
                    ...currentAsset.checklist.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () {
                                ref
                                    .read(assetsProvider.notifier)
                                    .toggleChecklistItem(currentAsset.id, item.id);
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  item.isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: item.isCompleted
                                      ? const Color(0xFF10B981)
                                      : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  decoration: item.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: item.isCompleted
                                      ? (isDark ? JagainColors.darkMuted : JagainColors.muted)
                                      : (isDark ? JagainColors.darkText : JagainColors.ink),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16),
                              color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                ref
                                    .read(assetsProvider.notifier)
                                    .removeChecklistItem(currentAsset.id, item.id);
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ] else ...[
                    const SizedBox(height: 12),
                    Text(
                      strings.isId
                          ? 'Belum ada checklist. Ketuk "+ Tambah" untuk menambahkan tugas servis, pajak, perbaikan, dll.'
                          : 'No checklist yet. Tap "+ Add" to add service, tax, maintenance tasks, etc.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          // 5. Catatan Perawatan
          if (currentAsset.notes != null && currentAsset.notes!.isNotEmpty) ...[
            Text(
              strings.notesLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentAsset.notes!,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark ? JagainColors.darkText : JagainColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
          ],

          // 6. Upcoming Reminders (PRD FR-05 & FR-06)
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.isId ? 'Pengingat Perawatan' : 'Care Reminders',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        strings.isId
                            ? 'Fitur tambah pengingat untuk ${currentAsset.name}'
                            : 'Add reminder for ${currentAsset.name}',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.add_alert_rounded, size: 16),
                label: Text(strings.isId ? 'Tambah' : 'Add'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: Color(0xFF10B981),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.isId ? 'Jadwal Servis Berkala' : 'Periodic Service Schedule',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        strings.isId
                            ? 'Pengingat berkala otomatis terhubung ke aset ini.'
                            : 'Automatic reminders linked to this asset.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildFallbackImage(bool isDark) {
    return Center(
      child: Icon(
        Icons.inventory_2_rounded,
        size: 64,
        color: isDark ? JagainColors.darkMuted : JagainColors.muted,
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    bool isDark, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? JagainColors.darkMuted : JagainColors.muted,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? JagainColors.darkMuted : JagainColors.muted,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getConditionColor(AssetCondition condition) {
    switch (condition) {
      case AssetCondition.good:
        return const Color(0xFF10B981);
      case AssetCondition.needsAttention:
        return const Color(0xFFF59E0B);
      case AssetCondition.underMaintenance:
        return const Color(0xFF3B82F6);
      case AssetCondition.critical:
        return const Color(0xFFEF4444);
    }
  }

  String _getConditionText(AssetCondition condition, AppStrings strings) {
    switch (condition) {
      case AssetCondition.good:
        return strings.conditionGood;
      case AssetCondition.needsAttention:
        return strings.conditionAttention;
      case AssetCondition.underMaintenance:
        return strings.conditionMaintenance;
      case AssetCondition.critical:
        return strings.conditionCritical;
    }
  }

  void _showAddChecklistDialog(
    BuildContext context,
    WidgetRef ref,
    String assetId,
    AppStrings strings,
  ) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.addChecklistItem),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: strings.checklistHint,
          ),
          onSubmitted: (val) {
            if (val.trim().isNotEmpty) {
              ref.read(assetsProvider.notifier).addChecklistItem(assetId, val.trim());
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(assetsProvider.notifier).addChecklistItem(assetId, controller.text.trim());
                Navigator.of(ctx).pop();
              }
            },
            child: Text(strings.isId ? 'Tambah' : 'Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, AppStrings strings, Asset asset) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(strings.isId ? 'Hapus Aset?' : 'Delete Asset?'),
        content: Text(
          strings.isId
              ? 'Aset "${asset.name}" akan dihapus dari database.'
              : 'Asset "${asset.name}" will be deleted from the database.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () {
              ref.read(assetsProvider.notifier).removeAsset(asset.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    strings.isId
                        ? 'Aset "${asset.name}" telah dihapus.'
                        : 'Asset "${asset.name}" deleted.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(strings.isId ? 'Hapus' : 'Delete'),
          ),
        ],
      ),
    );
  }
}
