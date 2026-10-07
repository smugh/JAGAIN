import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/services/permission_service.dart';
import '../../../core/utils/date_format_helper.dart';
import '../../../i18n/app_locale.dart';
import '../../../theme/app_theme.dart';
import '../../assets/data/assets_provider.dart';
import '../data/reminders_provider.dart';

class AddReminderSheet extends ConsumerStatefulWidget {
  const AddReminderSheet({this.preselectedAssetId, super.key});

  final String? preselectedAssetId;

  static Future<void> show(BuildContext context, {String? preselectedAssetId}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddReminderSheet(preselectedAssetId: preselectedAssetId),
    );
  }

  @override
  ConsumerState<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends ConsumerState<AddReminderSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  late String? _selectedAssetId;
  ReminderTargetType _targetType = ReminderTargetType.asset;
  String? _selectedChecklistItemId;
  late DateTime _selectedDateTime;
  ReminderRecurrence _recurrence = ReminderRecurrence.once;

  @override
  void initState() {
    super.initState();
    _selectedAssetId = widget.preselectedAssetId;
    final now = DateTime.now();
    _selectedDateTime = DateTime(now.year, now.month, now.day + 7, 9, 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final assets = ref.read(assetsProvider);
      if (_selectedAssetId == null && assets.isNotEmpty) {
        setState(() {
          _selectedAssetId = assets.first.id;
        });
      }
      _updateDefaultTitle();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _updateDefaultTitle() {
    if (_selectedAssetId == null) return;
    final assets = ref.read(assetsProvider);
    final currentAsset = assets.where((a) => a.id == _selectedAssetId).firstOrNull;
    if (currentAsset == null) return;

    if (_targetType == ReminderTargetType.checklistItem && _selectedChecklistItemId != null) {
      final item = currentAsset.checklist.where((c) => c.id == _selectedChecklistItemId).firstOrNull;
      if (item != null) {
        _titleController.text = item.title;
        return;
      }
    }

    if (_titleController.text.trim().isEmpty) {
      _titleController.text = 'Servis & Perawatan ${currentAsset.name}';
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (pickedDate == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        _selectedDateTime.hour,
        _selectedDateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        _selectedDateTime.year,
        _selectedDateTime.month,
        _selectedDateTime.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) return;
    if (_selectedAssetId == null) return;

    // Request permissions
    await PermissionService.requestInitialPermissions();

    final reminder = AssetReminder(
      id: 'rem_${DateTime.now().millisecondsSinceEpoch}',
      assetId: _selectedAssetId!,
      checklistItemId: _targetType == ReminderTargetType.checklistItem ? _selectedChecklistItemId : null,
      targetType: _targetType,
      title: _titleController.text.trim(),
      dueDate: _selectedDateTime,
      recurrence: _recurrence,
      status: ReminderStatus.upcoming,
      notificationEnabled: true,
      createdAt: DateTime.now(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    ref.read(remindersProvider.notifier).addReminder(reminder);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ref.read(stringsProvider).isId
              ? 'Pengingat berhasil ditambahkan!'
              : 'Reminder added successfully!',
        ),
        backgroundColor: JagainColors.primaryDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final assets = ref.watch(assetsProvider);

    final currentAsset = assets.where((a) => a.id == _selectedAssetId).firstOrNull;
    final checklist = currentAsset?.checklist ?? [];

    final dateFormat =
        safeDateFormat('EEE, d MMM yyyy', strings.isId ? 'id_ID' : 'en_US');
    final timeFormat =
        safeDateFormat('HH:mm', strings.isId ? 'id_ID' : 'en_US');

    final bgColor = isDark ? JagainColors.darkBackground : Colors.white;
    final surfaceColor = isDark ? JagainColors.darkSurface : const Color(0xFFF8FAFC);
    final borderColor = isDark ? JagainColors.darkBorder : JagainColors.border;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: borderColor, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: JagainColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.alarm_add_rounded, color: JagainColors.primary, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    strings.addReminderTitle,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Pilih Aset (if not preselected)
              if (widget.preselectedAssetId == null) ...[
                Text(
                  strings.isId ? 'Pilih Aset' : 'Select Asset',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedAssetId,
                      isExpanded: true,
                      items: assets.map((a) {
                        return DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedAssetId = val;
                          _selectedChecklistItemId = null;
                        });
                        _updateDefaultTitle();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Opsi Target Reminder: Aset vs Sub-Item
              Text(
                strings.reminderTargetLabel,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _targetType = ReminderTargetType.asset;
                          _selectedChecklistItemId = null;
                        });
                        _updateDefaultTitle();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _targetType == ReminderTargetType.asset
                              ? JagainColors.primary.withValues(alpha: isDark ? 0.25 : 0.15)
                              : surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _targetType == ReminderTargetType.asset ? JagainColors.primary : borderColor,
                            width: _targetType == ReminderTargetType.asset ? 1.8 : 1.0,
                          ),
                        ),
                        child: Text(
                          strings.reminderTargetAsset,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _targetType == ReminderTargetType.asset ? FontWeight.w700 : FontWeight.w500,
                            color: _targetType == ReminderTargetType.asset
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
                          _targetType = ReminderTargetType.checklistItem;
                          if (checklist.isNotEmpty && _selectedChecklistItemId == null) {
                            _selectedChecklistItemId = checklist.first.id;
                          }
                        });
                        _updateDefaultTitle();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: _targetType == ReminderTargetType.checklistItem
                              ? JagainColors.primary.withValues(alpha: isDark ? 0.25 : 0.15)
                              : surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _targetType == ReminderTargetType.checklistItem ? JagainColors.primary : borderColor,
                            width: _targetType == ReminderTargetType.checklistItem ? 1.8 : 1.0,
                          ),
                        ),
                        child: Text(
                          strings.reminderTargetChecklist,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: _targetType == ReminderTargetType.checklistItem ? FontWeight.w700 : FontWeight.w500,
                            color: _targetType == ReminderTargetType.checklistItem
                                ? (isDark ? JagainColors.primaryLight : JagainColors.primaryDark)
                                : (isDark ? JagainColors.darkMuted : JagainColors.muted),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Sub-Item Dropdown if targetType == checklistItem
              if (_targetType == ReminderTargetType.checklistItem) ...[
                if (checklist.isNotEmpty) ...[
                  Text(
                    strings.chooseChecklistItemForReminder,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedChecklistItemId ?? checklist.first.id,
                        isExpanded: true,
                        items: checklist.map((item) {
                          return DropdownMenuItem(
                            value: item.id,
                            child: Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedChecklistItemId = val;
                          });
                          _updateDefaultTitle();
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
                      style: const TextStyle(fontSize: 11.5, color: Colors.amber),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
              ],

              // Judul Pengingat
              Text(
                strings.reminderTitleLabel,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: strings.reminderTitleHint,
                  prefixIcon: const Icon(Icons.title_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 16),

              // Tanggal & Waktu Pengingat
              Text(
                strings.reminderDateTimeLabel,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_rounded, size: 16),
                      label: Text(dateFormat.format(_selectedDateTime), style: const TextStyle(fontSize: 12.5)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTime,
                      icon: const Icon(Icons.access_time_filled_rounded, size: 16),
                      label: Text('${timeFormat.format(_selectedDateTime)} WIB', style: const TextStyle(fontSize: 12.5)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Frekuensi Pengulangan
              Text(
                strings.reminderRecurrenceLabel,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ReminderRecurrence>(
                    value: _recurrence,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(value: ReminderRecurrence.once, child: Text(strings.recurrenceOnce)),
                      DropdownMenuItem(value: ReminderRecurrence.monthly, child: Text(strings.recurrenceMonthly)),
                      DropdownMenuItem(value: ReminderRecurrence.everyThreeMonths, child: Text(strings.recurrenceEvery3Months)),
                      DropdownMenuItem(value: ReminderRecurrence.everySixMonths, child: Text(strings.recurrenceEvery6Months)),
                      DropdownMenuItem(value: ReminderRecurrence.yearly, child: Text(strings.recurrenceYearly)),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _recurrence = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Catatan Pengingat
              Text(
                strings.notesLabel,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: strings.notesHint,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 22),

              // Save Action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(strings.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(strings.isId ? 'Simpan Pengingat' : 'Save Reminder'),
                      style: FilledButton.styleFrom(
                        backgroundColor: JagainColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
