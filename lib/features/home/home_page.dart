import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/app_locale.dart';
import '../../theme/app_theme.dart';
import '../assets/data/assets_provider.dart';
import '../assets/presentation/add_asset_sheet.dart';
import '../assets/presentation/asset_detail_page.dart';
import '../shared/widgets/asset_image_view.dart';
import 'widgets/asset_dashboard_card.dart';
import 'widgets/asset_image_carousel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final assets = ref.watch(assetsProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      children: [
        // Top Bar: Horizontal Logo only, Dark/Light Mode Toggle, and Notification Icon
        Row(
          children: [
            Image.asset(
              isDark
                  ? 'assets/icons/horizontal_logo_dark.png'
                  : 'assets/icons/horizontal_logo.png',
              height: 32,
              fit: BoxFit.contain,
            ),
            const Spacer(),

            // Top Bar: Dark / Light Mode Toggle Pill (Replaced language toggle)
            Container(
              height: 34,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isDark ? JagainColors.darkSurface : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? JagainColors.darkBorder : JagainColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ThemeButton(
                    icon: Icons.light_mode_rounded,
                    isSelected: !isDark,
                    isDark: isDark,
                    tooltip: 'Mode Terang',
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.light),
                  ),
                  _ThemeButton(
                    icon: Icons.dark_mode_rounded,
                    isSelected: isDark,
                    isDark: isDark,
                    tooltip: 'Mode Gelap',
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.dark),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Notification Button
            IconButton.filledTonal(
              tooltip: strings.notificationTitle,
              visualDensity: VisualDensity.compact,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(strings.allSafeForNow),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.notifications_none_rounded, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Welcome Tagline
        Text(
          strings.welcomeGreeting,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? JagainColors.darkMuted : JagainColors.muted,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          strings.brandEssence,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 18),

        // 1. Carousel Aset (Card Paling Atas Sesuai Request)
        AssetImageCarousel(
          assets: assets,
          onAddAsset: () => AddAssetSheet.show(context),
        ),
        const SizedBox(height: 22),

        // 2. Dashboard Informasi Aset
        const AssetDashboardCard(),
        const SizedBox(height: 24),

        // 3. Section: Perlu Perhatian
        Row(
          children: [
            Text(
              strings.sectionNeedsAttention,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: Text(strings.seeAll),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildAttentionSection(context, ref, isDark, strings, assets),
        const SizedBox(height: 24),

        // 4. Section: Aset Kamu
        Row(
          children: [
            Text(
              strings.sectionYourAssets,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            Text(
              '${assets.length} ${strings.navAssets}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (assets.isEmpty)
          const _EmptySection(
            icon: Icons.home_work_outlined,
            title: 'Belum ada aset yang dijagain',
            subtitle:
                'Tambahkan barang penting agar informasi dan perawatannya tersimpan.',
          )
        else
          ...assets.take(4).map(
                (asset) => _buildAssetItemCard(context, ref, isDark, strings, asset),
              ),
      ],
    );
  }

  Widget _buildAttentionSection(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AppStrings strings,
    List<Asset> assets,
  ) {
    final attentionAssets = assets
        .where((a) =>
            a.condition == AssetCondition.needsAttention ||
            a.condition == AssetCondition.critical)
        .toList();

    if (attentionAssets.isEmpty) {
      return _EmptySection(
        icon: Icons.check_circle_outline_rounded,
        title: strings.allSafeForNow,
        subtitle: strings.allSafeSubtitle,
      );
    }

    final topAsset = attentionAssets.first;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF59E0B),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${topAsset.name} — ${strings.conditionAttention}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topAsset.notes ?? strings.allSafeSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetItemCard(
    BuildContext context,
    WidgetRef ref,
    bool isDark,
    AppStrings strings,
    Asset asset,
  ) {
    IconData getCategoryIcon(String cat) {
      switch (cat) {
        case 'vehicle':
          return Icons.directions_car_rounded;
        case 'electronics':
          return Icons.devices_rounded;
        case 'property':
          return Icons.home_work_rounded;
        case 'personal':
          return Icons.watch_rounded;
        default:
          return Icons.category_rounded;
      }
    }

    Color getConditionColor(AssetCondition condition) {
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

    String getConditionText(AssetCondition condition) {
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

    final condColor = getConditionColor(asset.condition);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AssetDetailPage(asset: asset),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Image, Name, Subtitle, Condition Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDark ? JagainColors.darkBackground : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? JagainColors.darkBorder : JagainColors.border,
                        ),
                      ),
                      child: AssetImageWidget(
                        imagePath: asset.imagePath,
                        fit: BoxFit.cover,
                        placeholder: Icon(
                          getCategoryIcon(asset.categoryId),
                          color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          [
                            if (asset.brand != null) asset.brand,
                            if (asset.model != null) asset.model,
                            if (asset.location != null) asset.location,
                          ].whereType<String>().join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: condColor.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: condColor.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      getConditionText(asset.condition),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: condColor,
                      ),
                    ),
                  ),
                ],
              ),

              // Checklist Section (Interactive tap-to-toggle checkboxes inside the card)
              if (asset.hasChecklist) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  decoration: BoxDecoration(
                    color: isDark ? JagainColors.darkBackground : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? JagainColors.darkBorder : JagainColors.border.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checklist Header with Counter
                      Row(
                        children: [
                          Icon(
                            Icons.fact_check_outlined,
                            size: 14,
                            color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            strings.checklistTitle,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? JagainColors.darkText : JagainColors.ink,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${asset.completedChecklistCount}/${asset.totalChecklistCount} ${strings.checklistDone}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: asset.completedChecklistCount == asset.totalChecklistCount
                                  ? const Color(0xFF10B981)
                                  : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Checklist Items (up to 3 items shown directly)
                      ...asset.checklist.take(3).map((item) {
                        return InkWell(
                          onTap: () {
                            ref
                                .read(assetsProvider.notifier)
                                .toggleChecklistItem(asset.id, item.id);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
                            child: Row(
                              children: [
                                Icon(
                                  item.isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  size: 16,
                                  color: item.isCompleted
                                      ? const Color(0xFF10B981)
                                      : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      decoration: item.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none,
                                      color: item.isCompleted
                                          ? (isDark ? JagainColors.darkMuted : JagainColors.muted)
                                          : (isDark ? JagainColors.darkText : JagainColors.ink),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      if (asset.checklist.length > 3)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 24),
                          child: Text(
                            '+${asset.checklist.length - 3} item lainnya...',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton({
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? JagainColors.primary : JagainColors.primaryDark)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isSelected
              ? Colors.white
              : (isDark ? JagainColors.darkMuted : JagainColors.muted),
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  const _EmptySection({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
