import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../i18n/app_locale.dart';
import '../../../theme/app_theme.dart';
import '../../assets/data/assets_provider.dart';

class AssetDashboardCard extends ConsumerWidget {
  const AssetDashboardCard({
    this.onViewAllAssets,
    super.key,
  });

  final VoidCallback? onViewAllAssets;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assets = ref.watch(assetsProvider);

    final totalCount = assets.length;
    final goodCount = assets.where((a) => a.condition == AssetCondition.good).length;
    final attentionCount = assets.where((a) =>
        a.condition == AssetCondition.needsAttention ||
        a.condition == AssetCondition.critical).length;
    final maintenanceCount =
        assets.where((a) => a.condition == AssetCondition.underMaintenance).length;

    // Category distribution
    final vehicleCount = assets.where((a) => a.categoryId == 'vehicle').length;
    final electronicsCount = assets.where((a) => a.categoryId == 'electronics').length;
    final propertyCount = assets.where((a) => a.categoryId == 'property').length;
    final personalCount = assets.where((a) => a.categoryId == 'personal').length;

    final healthPercentage = totalCount > 0 ? ((goodCount / totalCount) * 100).toInt() : 100;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? JagainColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark ? JagainColors.darkBorder : JagainColors.border,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? JagainColors.darkAccentBg : JagainColors.mint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  strings.dashboardTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$healthPercentage% Prima',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4 Stats Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  isDark: isDark,
                  label: strings.totalAssets,
                  value: '$totalCount',
                  icon: Icons.inventory_2_rounded,
                  iconColor: JagainColors.primary,
                  bgColor: isDark ? JagainColors.darkAccentBg : const Color(0xFFE6F4EA),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  context,
                  isDark: isDark,
                  label: strings.goodCondition,
                  value: '$goodCount',
                  icon: Icons.check_circle_rounded,
                  iconColor: const Color(0xFF10B981),
                  bgColor: isDark ? const Color(0xFF0D281E) : const Color(0xFFE8F8F0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  context,
                  isDark: isDark,
                  label: strings.needsAttention,
                  value: '$attentionCount',
                  icon: Icons.warning_amber_rounded,
                  iconColor: const Color(0xFFF59E0B),
                  bgColor: isDark ? const Color(0xFF2E2412) : const Color(0xFFFEF3C7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  context,
                  isDark: isDark,
                  label: strings.underMaintenance,
                  value: '$maintenanceCount',
                  icon: Icons.build_rounded,
                  iconColor: JagainColors.secondary,
                  bgColor: isDark ? JagainColors.darkBlueBg : const Color(0xFFEBF5FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Category Quick Chips
          Text(
            strings.categoryBreakdown,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryPill(
                  isDark: isDark,
                  icon: Icons.directions_car_rounded,
                  label: '${strings.categoryName('vehicle')}: $vehicleCount',
                ),
                const SizedBox(width: 8),
                _buildCategoryPill(
                  isDark: isDark,
                  icon: Icons.devices_rounded,
                  label: '${strings.categoryName('electronics')}: $electronicsCount',
                ),
                const SizedBox(width: 8),
                _buildCategoryPill(
                  isDark: isDark,
                  icon: Icons.home_work_rounded,
                  label: '${strings.categoryName('property')}: $propertyCount',
                ),
                if (personalCount > 0) ...[
                  const SizedBox(width: 8),
                  _buildCategoryPill(
                    isDark: isDark,
                    icon: Icons.watch_rounded,
                    label: '${strings.categoryName('personal')}: $personalCount',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required bool isDark,
    required String label,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? JagainColors.darkBackground : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? JagainColors.darkBorder : JagainColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPill({
    required bool isDark,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? JagainColors.darkBackground : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? JagainColors.darkBorder : JagainColors.border,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? JagainColors.darkText : JagainColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
