import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/app_locale.dart';
import '../../theme/app_theme.dart';
import '../assets/data/assets_provider.dart';
import '../categories/data/categories_provider.dart';

class CategoryManagementPage extends ConsumerWidget {
  const CategoryManagementPage({super.key});

  IconData _getIconFromKey(String key) {
    switch (key) {
      case 'car':
        return Icons.directions_car_rounded;
      case 'laptop':
        return Icons.devices_rounded;
      case 'house':
        return Icons.home_work_rounded;
      case 'watch':
        return Icons.watch_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'tools':
        return Icons.build_rounded;
      case 'camera':
        return Icons.camera_alt_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'bag':
        return Icons.shopping_bag_rounded;
      case 'star':
        return Icons.star_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref, AppStrings strings) {
    final nameController = TextEditingController();
    String selectedIcon = 'star';

    final availableIcons = <Map<String, dynamic>>[
      {'key': 'car', 'icon': Icons.directions_car_rounded, 'label': 'Mobil/Motor'},
      {'key': 'laptop', 'icon': Icons.devices_rounded, 'label': 'Elektronik'},
      {'key': 'house', 'icon': Icons.home_work_rounded, 'label': 'Properti'},
      {'key': 'watch', 'icon': Icons.watch_rounded, 'label': 'Aksesoris'},
      {'key': 'camera', 'icon': Icons.camera_alt_rounded, 'label': 'Kamera'},
      {'key': 'music', 'icon': Icons.music_note_rounded, 'label': 'Musik'},
      {'key': 'tools', 'icon': Icons.build_rounded, 'label': 'Peralatan'},
      {'key': 'fitness', 'icon': Icons.fitness_center_rounded, 'label': 'Olahraga'},
      {'key': 'bag', 'icon': Icons.shopping_bag_rounded, 'label': 'Fashion'},
      {'key': 'star', 'icon': Icons.star_rounded, 'label': 'Lainnya'},
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? JagainColors.darkSurface : Colors.white,
              title: Text(
                strings.addCategory,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.categoryNameLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: strings.categoryNameHint,
                        prefixIcon: const Icon(Icons.label_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      strings.isId ? 'Pilih Ikon Representasi:' : 'Select Category Icon:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableIcons.map((item) {
                        final key = item['key'] as String;
                        final icon = item['icon'] as IconData;
                        final isSelected = selectedIcon == key;

                        return InkWell(
                          onTap: () {
                            setDialogState(() {
                              selectedIcon = key;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? JagainColors.primary.withValues(alpha: isDark ? 0.3 : 0.15)
                                  : (isDark ? JagainColors.darkBackground : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? JagainColors.primary
                                    : (isDark ? JagainColors.darkBorder : JagainColors.border),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: isSelected
                                  ? JagainColors.primaryLight
                                  : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                              size: 22,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(strings.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    ref.read(categoriesProvider.notifier).addCategory(
                          name: name,
                          iconKey: selectedIcon,
                        );

                    Navigator.of(dialogCtx).pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          strings.isId
                              ? 'Kategori "$name" berhasil ditambahkan!'
                              : 'Category "$name" added successfully!',
                        ),
                        backgroundColor: JagainColors.primaryDark,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(strings.isId ? 'Tambah' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteCategory(
    BuildContext context,
    WidgetRef ref,
    CategoryItem category,
    AppStrings strings,
    int assetCount,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? JagainColors.darkSurface : Colors.white,
        title: Text(
          strings.isId ? 'Hapus Kategori?' : 'Delete Category?',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.isId
                  ? 'Apakah Anda yakin ingin menghapus kategori "${category.localizedName(strings.isId)}"?\n\n$assetCount aset saat ini terdaftar dengan kategori ini.'
                  : 'Are you sure you want to delete category "${category.localizedName(strings.isId)}"?\n\n$assetCount assets currently use this category.',
              style: TextStyle(
                color: isDark ? JagainColors.darkText : JagainColors.ink,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              strings.categoryDeleteWarning,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? JagainColors.darkMuted : JagainColors.muted,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              ref.read(categoriesProvider.notifier).removeCategory(category.id);
              Navigator.of(dialogCtx).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    strings.isId
                        ? 'Kategori "${category.localizedName(strings.isId)}" berhasil dihapus.'
                        : 'Category "${category.localizedName(strings.isId)}" deleted.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text(strings.deleteCategory),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final categories = ref.watch(categoriesProvider);
    final assets = ref.watch(assetsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? JagainColors.darkBackground : JagainColors.canvas,
      appBar: AppBar(
        title: Text(
          strings.masterCategoryTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: strings.addCategory,
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showAddCategoryDialog(context, ref, strings),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          Text(
            strings.masterCategorySubtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? JagainColors.darkMuted : JagainColors.muted,
            ),
          ),
          const SizedBox(height: 18),

          // Categories list
          ...categories.map((cat) {
            final assetCount = assets.where((a) => a.categoryId == cat.id).length;
            final icon = _getIconFromKey(cat.iconKey);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? JagainColors.darkBackground : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? JagainColors.darkBorder : JagainColors.border,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                    size: 22,
                  ),
                ),
                title: Text(
                  cat.localizedName(strings.isId),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  strings.isId
                      ? '$assetCount aset terdaftar'
                      : '$assetCount registered assets',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
                      tooltip: strings.deleteCategory,
                      onPressed: () => _confirmDeleteCategory(
                        context,
                        ref,
                        cat,
                        strings,
                        assetCount,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Button to add new category
          OutlinedButton.icon(
            onPressed: () => _showAddCategoryDialog(context, ref, strings),
            icon: const Icon(Icons.add_rounded),
            label: Text(strings.addCategory),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
