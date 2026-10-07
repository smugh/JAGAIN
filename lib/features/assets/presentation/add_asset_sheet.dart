import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/services/permission_service.dart';
import '../../../core/utils/date_format_helper.dart';
import '../../../i18n/app_locale.dart';
import '../../../theme/app_theme.dart';
import '../../categories/data/categories_provider.dart';
import '../../reminders/data/reminders_provider.dart';
import '../../shared/widgets/asset_image_view.dart';
import '../data/assets_provider.dart';

class AddAssetSheet extends ConsumerStatefulWidget {
  const AddAssetSheet({this.assetToEdit, super.key});

  final Asset? assetToEdit;

  static Future<void> show(BuildContext context, {Asset? assetToEdit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAssetSheet(assetToEdit: assetToEdit),
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

  // Reminder fields (Asset-level vs Checklist Sub-item)
  bool _enableReminder = false;
  ReminderTargetType _reminderTargetType = ReminderTargetType.asset;
  String? _selectedReminderChecklistId;
  final _reminderTitleController = TextEditingController();
  late DateTime _reminderDateTime;
  ReminderRecurrence _reminderRecurrence = ReminderRecurrence.once;
  final _reminderNotesController = TextEditingController();

  final List<Map<String, String>> _photoPresets = const [
    {'path': 'assets/images/car.png', 'label': 'Mobil'},
    {'path': 'assets/images/motor.png', 'label': 'Motor'},
    {'path': 'assets/images/laptop.png', 'label': 'Laptop'},
    {'path': 'assets/images/gadget.png', 'label': 'Gadget'},
    {'path': 'assets/images/house.png', 'label': 'Rumah'},
    {'path': 'assets/images/watch.png', 'label': 'Jam'},
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _reminderDateTime = DateTime(now.year, now.month, now.day + 7, 9, 0);

    final editAsset = widget.assetToEdit;
    if (editAsset != null) {
      _nameController.text = editAsset.name;
      _brandController.text = editAsset.brand ?? '';
      _modelController.text = editAsset.model ?? '';
      _yearController.text = editAsset.year != null ? editAsset.year.toString() : '';
      _locationController.text = editAsset.location ?? '';
      _notesController.text = editAsset.notes ?? '';
      _selectedCategory = editAsset.categoryId;
      _selectedImagePath = editAsset.imagePath;
      _selectedCondition = editAsset.condition;
      _checklistItems.addAll(editAsset.checklist);
      if ((editAsset.brand != null && editAsset.brand!.isNotEmpty) ||
          (editAsset.model != null && editAsset.model!.isNotEmpty) ||
          editAsset.year != null ||
          (editAsset.location != null && editAsset.location!.isNotEmpty) ||
          (editAsset.notes != null && editAsset.notes!.isNotEmpty)) {
        _showAdvancedInfo = true;
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      String finalPath = pickedFile.path;
      if (!kIsWeb) {
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final photoDir = Directory(p.join(appDir.path, 'asset_photos'));
          if (!await photoDir.exists()) {
            await photoDir.create(recursive: true);
          }
          final ext = p.extension(pickedFile.path).isNotEmpty ? p.extension(pickedFile.path) : '.jpg';
          final fileName = 'asset_${DateTime.now().millisecondsSinceEpoch}$ext';
          final saved = await File(pickedFile.path).copy(p.join(photoDir.path, fileName));
          finalPath = saved.path;
        } catch (_) {
          finalPath = pickedFile.path;
        }
      }

      setState(() {
        _selectedImagePath = finalPath;
      });
    } catch (e) {
      if (mounted) {
        final strings = ref.read(stringsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              strings.isId ? 'Gagal membuka kamera/galeri: $e' : 'Failed to access camera/gallery: $e',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _customChecklistController.dispose();
    _reminderTitleController.dispose();
    _reminderNotesController.dispose();
    super.dispose();
  }

  void _updateReminderDefaultTitle() {
    if (_reminderTargetType == ReminderTargetType.checklistItem && _selectedReminderChecklistId != null) {
      final item = _checklistItems.where((c) => c.id == _selectedReminderChecklistId).firstOrNull;
      if (item != null) {
        _reminderTitleController.text = item.title;
        return;
      }
    }
    final assetName = _nameController.text.trim();
    _reminderTitleController.text = assetName.isEmpty ? 'Servis & Perawatan Aset' : 'Servis & Perawatan $assetName';
  }

  Future<void> _pickReminderDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null) return;
    setState(() {
      _reminderDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _reminderDateTime.hour,
        _reminderDateTime.minute,
      );
    });
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderDateTime),
    );
    if (picked == null) return;
    setState(() {
      _reminderDateTime = DateTime(
        _reminderDateTime.year,
        _reminderDateTime.month,
        _reminderDateTime.day,
        picked.hour,
        picked.minute,
      );
    });
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
    final isEdit = widget.assetToEdit != null;

    if (isEdit) {
      final updatedAsset = widget.assetToEdit!.copyWith(
        name: _nameController.text.trim(),
        categoryId: _selectedCategory,
        imagePath: _selectedImagePath,
        condition: _selectedCondition,
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        model: _modelController.text.trim().isEmpty ? null : _modelController.text.trim(),
        year: year,
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        checklist: List.from(_checklistItems),
        updatedAt: DateTime.now(),
      );

      ref.read(assetsProvider.notifier).updateAsset(updatedAsset);

      if (_enableReminder) {
        final reminderTitle = _reminderTitleController.text.trim().isNotEmpty
            ? _reminderTitleController.text.trim()
            : (_reminderTargetType == ReminderTargetType.asset ? 'Servis ${updatedAsset.name}' : 'Checklist Reminder');

        final reminder = AssetReminder(
          id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
          assetId: updatedAsset.id,
          checklistItemId: _reminderTargetType == ReminderTargetType.checklistItem ? _selectedReminderChecklistId : null,
          targetType: _reminderTargetType,
          title: reminderTitle,
          dueDate: _reminderDateTime,
          recurrence: _reminderRecurrence,
          status: ReminderStatus.upcoming,
          notificationEnabled: true,
          createdAt: DateTime.now(),
          notes: _reminderNotesController.text.trim().isEmpty ? null : _reminderNotesController.text.trim(),
        );

        ref.read(remindersProvider.notifier).addReminder(reminder);
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.assetUpdatedSuccess),
          backgroundColor: JagainColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
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

      if (_enableReminder) {
        final reminderTitle = _reminderTitleController.text.trim().isNotEmpty
            ? _reminderTitleController.text.trim()
            : (_reminderTargetType == ReminderTargetType.asset ? 'Servis ${newAsset.name}' : 'Checklist Reminder');

        final reminder = AssetReminder(
          id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
          assetId: newAsset.id,
          checklistItemId: _reminderTargetType == ReminderTargetType.checklistItem ? _selectedReminderChecklistId : null,
          targetType: _reminderTargetType,
          title: reminderTitle,
          dueDate: _reminderDateTime,
          recurrence: _reminderRecurrence,
          status: ReminderStatus.upcoming,
          notificationEnabled: true,
          createdAt: DateTime.now(),
          notes: _reminderNotesController.text.trim().isEmpty ? null : _reminderNotesController.text.trim(),
        );

        ref.read(remindersProvider.notifier).addReminder(reminder);
      }

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.assetSavedSuccess),
          backgroundColor: JagainColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final categories = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.assetToEdit != null;

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
                        isEdit ? Icons.edit_note_rounded : Icons.add_task_rounded,
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
                            isEdit ? strings.editFormTitle : strings.formTitle,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            isEdit ? strings.editFormSubtitle : strings.formSubtitle,
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
                  autofocus: false,
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

                // 3. Opsi Foto Aset (Camera, Gallery, and Preset Icons)
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
                const SizedBox(height: 12),

                // Preview Box & Camera/Gallery Action Buttons
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Live Image Preview
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              color: isDark ? JagainColors.darkBackground : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: JagainColors.primary.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _selectedImagePath != null && _selectedImagePath!.isNotEmpty
                                  ? AssetImageWidget(
                                      imagePath: _selectedImagePath,
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.add_a_photo_outlined,
                                        color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                        size: 26,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Camera & Gallery Buttons
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _pickImage(ImageSource.camera),
                                        icon: const Icon(Icons.camera_alt_rounded, size: 16),
                                        label: Text(
                                          strings.takePhotoCamera,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: JagainColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () => _pickImage(ImageSource.gallery),
                                        icon: const Icon(Icons.photo_library_rounded, size: 16),
                                        label: Text(
                                          strings.pickFromGallery,
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                          side: BorderSide(
                                            color: isDark ? JagainColors.primaryLight : JagainColors.primary,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_selectedImagePath != null && _selectedImagePath!.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: InkWell(
                                      onTap: () => setState(() => _selectedImagePath = null),
                                      borderRadius: BorderRadius.circular(6),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.delete_outline_rounded,
                                              size: 15,
                                              color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFEF4444),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              strings.removePhoto,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFEF4444),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Presets Divider / Header
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          strings.photoPresetsLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Presets Horizontal list
                      SizedBox(
                        height: 58,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // "Polos / Tanpa Foto" option
                            InkWell(
                              onTap: () => setState(() => _selectedImagePath = null),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 50,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: _selectedImagePath == null
                                      ? JagainColors.primary.withValues(alpha: 0.25)
                                      : (isDark ? JagainColors.darkBackground : Colors.white),
                                  borderRadius: BorderRadius.circular(10),
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
                                      size: 18,
                                      color: _selectedImagePath == null
                                          ? JagainColors.primaryLight
                                          : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      strings.isId ? 'Polos' : 'None',
                                      style: TextStyle(
                                        fontSize: 9,
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

                            // Image presets
                            ..._photoPresets.map((preset) {
                              final path = preset['path']!;
                              final label = preset['label']!;
                              final isSelected = _selectedImagePath == path;

                              return InkWell(
                                onTap: () => setState(() => _selectedImagePath = path),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 50,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? JagainColors.primary.withValues(alpha: 0.2)
                                        : (isDark ? JagainColors.darkBackground : Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? JagainColors.primary : borderColor,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(7),
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
                                                fontSize: 8.5,
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
                                            child: const Icon(Icons.check, size: 8, color: Colors.white),
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
                    ],
                  ),
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
                const SizedBox(height: 20),

                // 7. Set Pengingat Perawatan (Opsional) - Melekat pada Aset vs Sub-Item + Waktu & Tanggal + Permission
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _enableReminder ? JagainColors.primary.withValues(alpha: 0.6) : borderColor,
                      width: _enableReminder ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: _enableReminder
                                  ? JagainColors.primary.withValues(alpha: 0.2)
                                  : (isDark ? Colors.white10 : Colors.black12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.alarm_on_rounded,
                              size: 19,
                              color: _enableReminder
                                  ? (isDark ? JagainColors.primaryLight : JagainColors.primaryDark)
                                  : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.reminderSectionTitle,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  strings.reminderSectionSubtitle,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _enableReminder,
                            activeColor: JagainColors.primary,
                            onChanged: (val) async {
                              setState(() => _enableReminder = val);
                              if (val) {
                                await PermissionService.requestInitialPermissions();
                                if (_reminderTitleController.text.trim().isEmpty) {
                                  _updateReminderDefaultTitle();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                      if (_enableReminder) ...[
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 14),

                        // Opsi Target: 📌 Melekat pada Aset VS 📋 Melekat pada Sub-Item Checklist
                        Text(
                          strings.reminderTargetLabel,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _reminderTargetType = ReminderTargetType.asset;
                                    _selectedReminderChecklistId = null;
                                  });
                                  _updateReminderDefaultTitle();
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: _reminderTargetType == ReminderTargetType.asset
                                        ? JagainColors.primary.withValues(alpha: isDark ? 0.25 : 0.15)
                                        : (isDark ? JagainColors.darkBackground : Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _reminderTargetType == ReminderTargetType.asset ? JagainColors.primary : borderColor,
                                      width: _reminderTargetType == ReminderTargetType.asset ? 1.8 : 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    strings.reminderTargetAsset,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: _reminderTargetType == ReminderTargetType.asset ? FontWeight.w700 : FontWeight.w500,
                                      color: _reminderTargetType == ReminderTargetType.asset
                                          ? (isDark ? JagainColors.primaryLight : JagainColors.primaryDark)
                                          : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _reminderTargetType = ReminderTargetType.checklistItem;
                                    if (_checklistItems.isNotEmpty && _selectedReminderChecklistId == null) {
                                      _selectedReminderChecklistId = _checklistItems.first.id;
                                    }
                                  });
                                  _updateReminderDefaultTitle();
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: _reminderTargetType == ReminderTargetType.checklistItem
                                        ? JagainColors.primary.withValues(alpha: isDark ? 0.25 : 0.15)
                                        : (isDark ? JagainColors.darkBackground : Colors.white),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _reminderTargetType == ReminderTargetType.checklistItem ? JagainColors.primary : borderColor,
                                      width: _reminderTargetType == ReminderTargetType.checklistItem ? 1.8 : 1.0,
                                    ),
                                  ),
                                  child: Text(
                                    strings.reminderTargetChecklist,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: _reminderTargetType == ReminderTargetType.checklistItem ? FontWeight.w700 : FontWeight.w500,
                                      color: _reminderTargetType == ReminderTargetType.checklistItem
                                          ? (isDark ? JagainColors.primaryLight : JagainColors.primaryDark)
                                          : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Sub-Item Checklist Selector
                        if (_reminderTargetType == ReminderTargetType.checklistItem) ...[
                          if (_checklistItems.isNotEmpty) ...[
                            Text(
                              strings.chooseChecklistItemForReminder,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: isDark ? JagainColors.darkBackground : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: borderColor),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedReminderChecklistId ?? _checklistItems.first.id,
                                  isExpanded: true,
                                  items: _checklistItems.map((item) {
                                    return DropdownMenuItem(
                                      value: item.id,
                                      child: Text(item.title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500)),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    setState(() => _selectedReminderChecklistId = val);
                                    _updateReminderDefaultTitle();
                                  },
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                strings.noChecklistForReminderWarning,
                                style: const TextStyle(fontSize: 11, color: Colors.amber),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                        ],

                        // Judul Pengingat
                        Text(
                          strings.reminderTitleLabel,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _reminderTitleController,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: strings.reminderTitleHint,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tanggal & Waktu Pickers
                        Text(
                          strings.reminderDateTimeLabel,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickReminderDate,
                                icon: const Icon(Icons.calendar_month_rounded, size: 15),
                                label: Text(
                                  safeDateFormat('EEE, d MMM yyyy', strings.isId ? 'id_ID' : 'en_US').format(_reminderDateTime),
                                  style: const TextStyle(fontSize: 11.5),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  side: BorderSide(color: borderColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _pickReminderTime,
                                icon: const Icon(Icons.access_time_filled_rounded, size: 15),
                                label: Text(
                                  '${safeDateFormat('HH:mm', strings.isId ? 'id_ID' : 'en_US').format(_reminderDateTime)} WIB',
                                  style: const TextStyle(fontSize: 11.5),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  side: BorderSide(color: borderColor),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Frekuensi Pengulangan
                        Text(
                          strings.reminderRecurrenceLabel,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: isDark ? JagainColors.darkBackground : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: borderColor),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ReminderRecurrence>(
                              value: _reminderRecurrence,
                              isExpanded: true,
                              items: [
                                DropdownMenuItem(value: ReminderRecurrence.once, child: Text(strings.recurrenceOnce, style: const TextStyle(fontSize: 12.5))),
                                DropdownMenuItem(value: ReminderRecurrence.monthly, child: Text(strings.recurrenceMonthly, style: const TextStyle(fontSize: 12.5))),
                                DropdownMenuItem(value: ReminderRecurrence.everyThreeMonths, child: Text(strings.recurrenceEvery3Months, style: const TextStyle(fontSize: 12.5))),
                                DropdownMenuItem(value: ReminderRecurrence.everySixMonths, child: Text(strings.recurrenceEvery6Months, style: const TextStyle(fontSize: 12.5))),
                                DropdownMenuItem(value: ReminderRecurrence.yearly, child: Text(strings.recurrenceYearly, style: const TextStyle(fontSize: 12.5))),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _reminderRecurrence = val);
                              },
                            ),
                          ),
                        ),
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
                        label: Text(
                          isEdit
                              ? (strings.isId ? 'Simpan Perubahan' : 'Save Changes')
                              : strings.saveAsset,
                        ),
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
