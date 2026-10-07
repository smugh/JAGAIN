import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/app_locale.dart';
import '../../theme/app_theme.dart';
import '../categories/data/categories_provider.dart';
import 'data/assets_provider.dart';
import 'presentation/asset_detail_page.dart';

class AssetsPage extends ConsumerStatefulWidget {
  const AssetsPage({super.key});

  @override
  ConsumerState<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends ConsumerState<AssetsPage> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allAssets = ref.watch(assetsProvider);
    final categories = ref.watch(categoriesProvider);

    final filteredAssets = _selectedCategory == 'all'
        ? allAssets
        : allAssets.where((a) => a.categoryId == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
        children: [
          // Header (Focused purely on browsing database assets, without Add button)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.navAssets,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                strings.isId
                    ? 'Semua yang penting, tersimpan di satu tempat.'
                    : 'Everything that matters, saved in one place.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Category Filter Chips (Dynamic from categoriesProvider)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', strings.isId ? 'Semua' : 'All', isDark),
                const SizedBox(width: 8),
                ...categories.map((cat) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(
                      cat.id,
                      cat.localizedName(strings.isId),
                      isDark,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Asset List
          if (filteredAssets.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.isId ? 'Tidak ada aset di kategori ini' : 'No assets in this category',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            )
          else
            ...filteredAssets.map(
              (asset) => _buildAssetCard(context, isDark, strings, categories, asset),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String id, String label, bool isDark) {
    final isSelected = _selectedCategory == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: JagainColors.primary,
      backgroundColor: isDark ? JagainColors.darkSurface : const Color(0xFFF1F5F9),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : (isDark ? JagainColors.darkText : JagainColors.ink),
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? JagainColors.primary : (isDark ? JagainColors.darkBorder : JagainColors.border),
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedCategory = id);
      },
    );
  }

  Widget _buildAssetCard(
    BuildContext context,
    bool isDark,
    AppStrings strings,
    List<CategoryItem> categories,
    Asset asset,
  ) {
    IconData getFallbackIcon(String cat) {
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

    String getCategoryLabel() {
      final found = categories.where((c) => c.id == asset.categoryId);
      if (found.isNotEmpty) {
        return found.first.localizedName(strings.isId);
      }
      return strings.categoryName(asset.categoryId);
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Image Asset instead of generic icon
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? JagainColors.darkBackground : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? JagainColors.darkBorder : JagainColors.border,
                        ),
                      ),
                      child: asset.imagePath != null && asset.imagePath!.isNotEmpty
                          ? Image.asset(
                              asset.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Icon(
                                getFallbackIcon(asset.categoryId),
                                color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                                size: 22,
                              ),
                            )
                          : Icon(
                              getFallbackIcon(asset.categoryId),
                              color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                              size: 22,
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
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        Text(
                          getCategoryLabel(),
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
                      border: Border.all(color: condColor.withValues(alpha: 0.4)),
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
              if (asset.brand != null || asset.model != null || asset.location != null) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (asset.brand != null) _buildTag(Icons.branding_watermark_outlined, asset.brand!, isDark),
                    if (asset.model != null) _buildTag(Icons.tag_rounded, asset.model!, isDark),
                    if (asset.year != null) _buildTag(Icons.calendar_today_rounded, '${asset.year}', isDark),
                    if (asset.location != null) _buildTag(Icons.location_on_outlined, asset.location!, isDark),
                  ],
                ),
              ],
              if (asset.notes != null && asset.notes!.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? JagainColors.darkBackground : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    asset.notes!,
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                    ),
                  ),
                ),
              ],
              if (asset.hasChecklist) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
                      Row(
                        children: [
                          Icon(
                            Icons.fact_check_outlined,
                            size: 15,
                            color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            strings.checklistTitle,
                            style: TextStyle(
                              fontSize: 12,
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
                      const SizedBox(height: 8),
                      ...asset.checklist.take(4).map((item) {
                        return InkWell(
                          onTap: () {
                            ref
                                .read(assetsProvider.notifier)
                                .toggleChecklistItem(asset.id, item.id);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3.5, horizontal: 2),
                            child: Row(
                              children: [
                                Icon(
                                  item.isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  size: 17,
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
                                      fontSize: 12.5,
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
                      if (asset.checklist.length > 4)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, left: 24),
                          child: Text(
                            '+${asset.checklist.length - 4} item lainnya...',
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

  Widget _buildTag(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? JagainColors.darkBackground : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isDark ? JagainColors.darkMuted : JagainColors.muted),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? JagainColors.darkText : JagainColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
