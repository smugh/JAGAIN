import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../i18n/app_locale.dart';
import '../../../theme/app_theme.dart';
import '../../categories/data/categories_provider.dart';
import '../data/assets_provider.dart';

class AddAssetSheet extends ConsumerStatefulWidget {
  const AddAssetSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAssetSheet(),
    );
  }

  @override
  ConsumerState<AddAssetSheet> createState() => _AddAssetSheetState();
}

class _AddAssetSheetState extends ConsumerState<AddAssetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _customChecklistController = TextEditingController();

  String _selectedCategory = 'vehicle';
  String? _selectedImagePath = 'assets/images/car.png';
  AssetCondition _selectedCondition = AssetCondition.good;
  bool _showAdvancedInfo = false;
  final List<ChecklistItem> _checklistItems = [];

  final List<Map<String, String>> _photoPresets = const [
    {'path': 'assets/images/car.png', 'label': 'Mobil'},
    {'path': 'assets/images/motor.png', 'label': 'Motor'},
    {'path': 'assets/images/laptop.png', 'label': 'Laptop'},
    {'path': 'assets/images/gadget.png', 'label': 'Gadget'},
    {'path': 'assets/images/house.png', 'label': 'Rumah'},
    {'path': 'assets/images/watch.png', 'label': 'Jam'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _customChecklistController.dispose();
    super.dispose();
  }

  List<String> _getSuggestionsForCategory(String category) {
    switch (category) {
      case 'vehicle':
        return [
          'Jadwal servis berkala',
          'Bayar pajak (PKB)',
          'Ganti kampas rem',
          'Ganti oli mesin',
          'Cek ban & aki',
        ];
      case 'electronics':
        return [
          'Backup berkala',
          'Cek battery health',
          'Bersihkan debu & kipas',
          'Update software',
        ];
      case 'property':
        return [
          'Servis AC rutin',
          'Bayar PBB tahunan',
          'Cek instalasi listrik',
          'Cek talang & rembesan',
        ];
      case 'personal':
        return [
          'Ganti baterai',
          'Pembersihan rutin',
          'Cek kartu garansi',
        ];
      default:
        return [
          'Pemeriksaan rutin',
          'Perawatan berkala',
          'Cek kelengkapan',
        ];
    }
  }

  void _addChecklistSuggestion(String title) {
    if (_checklistItems.any((item) => item.title.toLowerCase() == title.toLowerCase())) return;
    setState(() {
      _checklistItems.add(
        ChecklistItem(
          id: 'chk_${DateTime.now().millisecondsSinceEpoch}_${_checklistItems.length}',
          title: title,
          isCompleted: false,
        ),
      );
    });
  }

  void _addCustomChecklistItem() {
    final text = _customChecklistController.text.trim();
    if (text.isEmpty) return;
    _addChecklistSuggestion(text);
    _customChecklistController.clear();
  }

  void _removeChecklistItem(String id) {
    setState(() {
      _checklistItems.removeWhere((item) => item.id == id);
    });
  }

  IconData _getCategoryIcon(String iconKey) {
    switch (iconKey) {
      case 'car':
        return Icons.directions_car_rounded;
      case 'laptop':
        return Icons.devices_rounded;
      case 'house':
        return Icons.home_work_rounded;
      case 'watch':
        return Icons.watch_rounded;
      case 'camera':
        return Icons.camera_alt_rounded;
      case 'music':
        return Icons.music_note_rounded;
      case 'tools':
        return Icons.build_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'bag':
        return Icons.shopping_bag_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  String _defaultImageForCategory(String categoryId) {
    switch (categoryId) {
      case 'vehicle':
        return 'assets/images/car.png';
      case 'electronics':
        return 'assets/images/laptop.png';
      case 'property':
        return 'assets/images/house.png';
      case 'personal':
        return 'assets/images/watch.png';
      default:
        return 'assets/images/gadget.png';
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final strings = ref.read(stringsProvider);
    final year = int.tryParse(_yearController.text.trim());

    final newAsset = Asset(
      id: 'ast-${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      categoryId: _selectedCategory,
      imagePath: _selectedImagePath,
      condition: _selectedCondition,
      status: AssetStatus.active,
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
      year: year,
      location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      checklist: List.from(_checklistItems),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    ref.read(assetsProvider.notifier).addAsset(newAsset);

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.assetSavedSuccess),
        backgroundColor: JagainColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final categories = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? JagainColors.darkBackground : Colors.white;
    final surfaceColor = isDark ? JagainColors.darkSurface : const Color(0xFFF1F5F9);
    final borderColor = isDark ? JagainColors.darkBorder : JagainColors.border;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? JagainColors.darkAccentBg : JagainColors.mint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.add_task_rounded,
                        color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.formTitle,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            strings.formSubtitle,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // 1. Kategori (PRD: Step 1 - Choose Category, Loaded dynamically)
                Text(
                  strings.chooseCategory,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = _selectedCategory == cat.id;
                      final catName = cat.localizedName(strings.isId);
                      final icon = _getCategoryIcon(cat.iconKey);

                      return ChoiceChip(
                        avatar: Icon(
                          icon,
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                        ),
                        label: Text(catName),
                        selected: isSelected,
                        selectedColor: JagainColors.primary,
                        backgroundColor: surfaceColor,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? JagainColors.darkText : JagainColors.ink),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 13,
                        ),
                        side: BorderSide(
                          color: isSelected ? JagainColors.primary : borderColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = cat.id;
                              _selectedImagePath = _defaultImageForCategory(cat.id);
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Nama Aset (PRD: Step 2 - Asset Name, Required)
                Text(
                  strings.assetNameLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: strings.assetNameHint,
                    prefixIcon: const Icon(Icons.inventory_2_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return strings.assetNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 3. Opsi Foto Aset (Requested: "tambahkan opsi foto aset")
                Text(
                  strings.photoOptionLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  strings.photoOptionHint,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                  ),
                ),
                const SizedBox(height: 10),

                // Photo Presets & Preview
                Row(
                  children: [
                    // Preview Box
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: JagainColors.primary.withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: _selectedImagePath != null && _selectedImagePath!.isNotEmpty
                            ? Image.asset(
                                _selectedImagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Center(
                                  child: Icon(
                                    Icons.photo_outlined,
                                    color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.hide_image_outlined,
                                  color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Preset Scroll
                    Expanded(
                      child: SizedBox(
                        height: 64,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // "Tanpa Foto" option
                            InkWell(
                              onTap: () => setState(() => _selectedImagePath = null),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 56,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: _selectedImagePath == null
                                      ? JagainColors.primary.withValues(alpha: 0.25)
                                      : surfaceColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _selectedImagePath == null ? JagainColors.primary : borderColor,
                                    width: _selectedImagePath == null ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.block_rounded,
                                      size: 20,
                                      color: _selectedImagePath == null
                                          ? JagainColors.primaryLight
                                          : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      strings.isId ? 'Polos' : 'None',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _selectedImagePath == null
                                            ? JagainColors.primaryLight
                                            : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Presets
                            ..._photoPresets.map((preset) {
                              final path = preset['path']!;
                              final label = preset['label']!;
                              final isSelected = _selectedImagePath == path;

                              return InkWell(
                                onTap: () => setState(() => _selectedImagePath = path),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 56,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? JagainColors.primary.withValues(alpha: 0.2)
                                        : surfaceColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected ? JagainColors.primary : borderColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: Image.asset(
                                                  path,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              label,
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                                color: isSelected
                                                    ? JagainColors.primaryLight
                                                    : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: JagainColors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.check, size: 10, color: Colors.white),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Kondisi (PRD: Step 3 - Asset Condition)
                Text(
                  strings.conditionLabel,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildConditionChip(
                      condition: AssetCondition.good,
                      label: strings.conditionGood,
                      color: const Color(0xFF10B981),
                    ),
                    _buildConditionChip(
                      condition: AssetCondition.needsAttention,
                      label: strings.conditionAttention,
                      color: const Color(0xFFF59E0B),
                    ),
                    _buildConditionChip(
                      condition: AssetCondition.underMaintenance,
                      label: strings.conditionMaintenance,
                      color: const Color(0xFF3B82F6),
                    ),
                    _buildConditionChip(
                      condition: AssetCondition.critical,
                      label: strings.conditionCritical,
                      color: const Color(0xFFEF4444),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 5. Progressive Enrichment (Collapsible optional fields)
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderColor),
                    ),
                    child: ExpansionTile(
                      initiallyExpanded: _showAdvancedInfo,
                      onExpansionChanged: (val) => setState(() => _showAdvancedInfo = val),
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(
                        strings.additionalInfo,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      leading: Icon(
                        Icons.tune_rounded,
                        color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _brandController,
                                      textCapitalization: TextCapitalization.words,
                                      decoration: InputDecoration(
                                        labelText: strings.brandLabel,
                                        hintText: strings.brandHint,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _modelController,
                                      decoration: InputDecoration(
                                        labelText: strings.modelLabel,
                                        hintText: strings.modelHint,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _yearController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: strings.yearLabel,
                                        hintText: strings.yearHint,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _locationController,
                                      decoration: InputDecoration(
                                        labelText: strings.locationLabel,
                                        hintText: strings.locationHint,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _notesController,
                                maxLines: 2,
                                decoration: InputDecoration(
                                  labelText: strings.notesLabel,
                                  hintText: strings.notesHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 6. Checklist & Atribut Perawatan (PRD & Case Requirement)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.fact_check_rounded,
                            size: 20,
                            color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            strings.checklistTitle,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          if (_checklistItems.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: JagainColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_checklistItems.length} item',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.isId
                            ? 'Tambahkan tugas atau jadwal perawatan (contoh: jadwal service, bayar pajak, ganti kampas dsb).'
                            : 'Add tasks or maintenance checklists (e.g. service schedule, tax payment, brake pads, etc).',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Quick Suggestion Chips based on Category
                      Text(
                        strings.isId ? 'Rekomendasi Cepat:' : 'Quick Suggestions:',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _getSuggestionsForCategory(_selectedCategory).map((suggestion) {
                          final isAdded = _checklistItems.any(
                            (item) => item.title.toLowerCase() == suggestion.toLowerCase(),
                          );
                          return InkWell(
                            onTap: () {
                              if (isAdded) {
                                final existing = _checklistItems.firstWhere(
                                  (item) => item.title.toLowerCase() == suggestion.toLowerCase(),
                                );
                                _removeChecklistItem(existing.id);
                              } else {
                                _addChecklistSuggestion(suggestion);
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isAdded
                                    ? JagainColors.primary.withValues(alpha: isDark ? 0.25 : 0.12)
                                    : (isDark ? JagainColors.darkBackground : Colors.white),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isAdded
                                      ? JagainColors.primary
                                      : (isDark ? JagainColors.darkBorder : JagainColors.border),
                                  width: isAdded ? 1.4 : 1.0,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isAdded ? Icons.check_rounded : Icons.add_rounded,
                                    size: 14,
                                    color: isAdded
                                        ? (isDark ? JagainColors.primaryLight : JagainColors.primaryDark)
                                        : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    suggestion,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isAdded ? FontWeight.w700 : FontWeight.w500,
                                      color: isAdded
                                          ? (isDark ? JagainColors.primaryLight : JagainColors.primaryDark)
                                          : (isDark ? JagainColors.darkText : JagainColors.ink),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Custom Input Field
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customChecklistController,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _addCustomChecklistItem(),
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: strings.checklistHint,
                                hintStyle: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          FilledButton(
                            onPressed: _addCustomChecklistItem,
                            style: FilledButton.styleFrom(
                              backgroundColor: JagainColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Icon(Icons.add_rounded, size: 18),
                          ),
                        ],
                      ),

                      // List of Added Items
                      if (_checklistItems.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        ..._checklistItems.map((item) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 16,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                InkWell(
                                  onTap: () => _removeChecklistItem(item.id),
                                  borderRadius: BorderRadius.circular(12),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.close_rounded, size: 15, color: Colors.redAccent),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons (PRD: Save <30s)
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: borderColor),
                        ),
                        child: Text(strings.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(strings.saveAsset),
                        style: FilledButton.styleFrom(
                          backgroundColor: JagainColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConditionChip({
    required AssetCondition condition,
    required String label,
    required Color color,
  }) {
    final isSelected = _selectedCondition == condition;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => setState(() => _selectedCondition = condition),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.25 : 0.15)
              : (isDark ? JagainColors.darkSurface : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : (isDark ? JagainColors.darkBorder : JagainColors.border),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.white : JagainColors.ink)
                    : (isDark ? JagainColors.darkMuted : JagainColors.muted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
