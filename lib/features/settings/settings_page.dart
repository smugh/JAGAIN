import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/permission_service.dart';
import '../../i18n/app_locale.dart';
import '../../theme/app_theme.dart';
import 'category_management_page.dart';
import 'widgets/developer_letter_sheet.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({
    this.isDarkMode = true,
    this.onToggleDarkMode,
    super.key,
  });

  final bool isDarkMode;
  final VoidCallback? onToggleDarkMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final currentLang = ref.watch(appLanguageProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 80),
      children: [
        Text(
          strings.settingsTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          strings.settingsSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? JagainColors.darkMuted : JagainColors.muted,
              ),
        ),
        const SizedBox(height: 22),
        Card(
          child: Column(
            children: [
              // Dark Mode Switch
              ListTile(
                leading: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                ),
                title: Text(strings.darkMode),
                subtitle: Text(
                  isDark ? strings.darkModeActive : strings.lightModeActive,
                ),
                trailing: Switch(
                  value: isDark,
                  activeThumbColor: JagainColors.primaryLight,
                  onChanged: (val) => ref
                      .read(themeModeProvider.notifier)
                      .setThemeMode(val ? ThemeMode.dark : ThemeMode.light),
                ),
              ),
              const Divider(height: 1, indent: 56),

              // Language Setting
              ListTile(
                leading: Icon(
                  Icons.translate_rounded,
                  color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                ),
                title: Text(strings.languageSetting),
                subtitle: Text(strings.languageDesc),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? JagainColors.darkBackground : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? JagainColors.darkBorder : JagainColors.border,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<AppLanguage>(
                      value: currentLang,
                      isDense: true,
                      dropdownColor: isDark ? JagainColors.darkSurface : Colors.white,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? JagainColors.darkText : JagainColors.ink,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: AppLanguage.id,
                          child: Text('Bahasa Indonesia (ID)'),
                        ),
                        DropdownMenuItem(
                          value: AppLanguage.en,
                          child: Text('English (EN)'),
                        ),
                      ],
                      onChanged: (lang) {
                        if (lang != null) {
                          ref.read(appLanguageProvider.notifier).setLanguage(lang);
                        }
                      },
                    ),
                  ),
                ),
              ),
              const Divider(height: 1, indent: 56),

              // Master Kategori Setting
              _SettingRow(
                icon: Icons.category_outlined,
                title: strings.masterCategoryTitle,
                subtitle: strings.masterCategorySubtitle,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CategoryManagementPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1, indent: 56),

              _SettingRow(
                icon: Icons.lock_outline_rounded,
                title: strings.privacyTitle,
                subtitle: strings.privacySubtitle,
              ),
              const Divider(height: 1, indent: 56),
              _SettingRow(
                icon: Icons.backup_outlined,
                title: strings.backupTitle,
                subtitle: strings.backupSubtitle,
              ),
              const Divider(height: 1, indent: 56),
              _SettingRow(
                icon: Icons.notifications_none_rounded,
                title: strings.notificationTitle,
                subtitle: strings.notificationSubtitle,
                onTap: () => _showPermissionManagementSheet(context, isDark, strings),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Developer Support Card (PRD Section 50 & Surat dari Tim JAGAIN)
        Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => showDeveloperLetterSheet(
              context,
              isDark: isDark,
              isId: strings.isId,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: JagainColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.volunteer_activism_rounded,
                      color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                strings.isId ? 'Dukungan Pengembang' : 'Developer Support',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00AED6).withValues(alpha: isDark ? 0.2 : 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'GoPay',
                                style: TextStyle(
                                  color: Color(0xFF00AED6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.isId
                              ? 'Baca "Surat dari Tim JAGAIN" & dukung kelanjutan aplikasi.'
                              : 'Read "Letter from JAGAIN Team" & support our journey.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              strings.isId ? 'Buka Surat' : 'Open Letter',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        Center(
          child: Text(
            strings.footerText,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? JagainColors.darkMuted : JagainColors.muted,
                ),
          ),
        ),
      ],
    );
  }

  void _showPermissionManagementSheet(BuildContext context, bool isDark, AppStrings strings) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? JagainColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _PermissionSheetContent(isDark: isDark, isId: strings.isId),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      leading: Icon(
        icon,
        color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _PermissionSheetContent extends StatefulWidget {
  const _PermissionSheetContent({required this.isDark, required this.isId});

  final bool isDark;
  final bool isId;

  @override
  State<_PermissionSheetContent> createState() => _PermissionSheetContentState();
}

class _PermissionSheetContentState extends State<_PermissionSheetContent> {
  Map<String, bool> _statuses = {
    'camera': false,
    'notification': false,
    'exactAlarm': false,
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    final res = await PermissionService.checkPermissionStatuses();
    if (mounted) {
      setState(() {
        _statuses = res;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermissions() async {
    await PermissionService.requestInitialPermissions();
    await _loadStatuses();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final isId = widget.isId;
    final mutedColor = isDark ? JagainColors.darkMuted : JagainColors.muted;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? JagainColors.darkMuted.withValues(alpha: 0.4) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JagainColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.security_rounded, color: JagainColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isId ? 'Izin Akses Aplikasi' : 'App Permissions',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isId
                ? 'JAGAIN memerlukan izin berikut agar kamera, pengingat, dan notifikasi berjalan maksimal.'
                : 'JAGAIN requires these permissions so camera, reminders, and alerts work optimally.',
            style: TextStyle(fontSize: 12.5, color: mutedColor),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else ...[
            _buildPermissionItem(
              icon: Icons.camera_alt_outlined,
              title: isId ? 'Kamera & Foto' : 'Camera & Photos',
              desc: isId ? 'Untuk mengambil foto aset dan bukti perawatan fisik' : 'To take asset photos and care proof',
              isGranted: _statuses['camera'] ?? false,
              isDark: isDark,
              isId: isId,
            ),
            const SizedBox(height: 10),
            _buildPermissionItem(
              icon: Icons.notifications_active_outlined,
              title: isId ? 'Notifikasi' : 'Notifications',
              desc: isId ? 'Untuk pemberitahuan jadwal servis dan perawatan' : 'For service schedules and care alerts',
              isGranted: _statuses['notification'] ?? false,
              isDark: isDark,
              isId: isId,
            ),
            const SizedBox(height: 10),
            _buildPermissionItem(
              icon: Icons.alarm_rounded,
              title: isId ? 'Waktu, Tanggal & Pengingat Tepat' : 'Exact Alarms & Schedule',
              desc: isId ? 'Agar pengingat berbunyi tepat pada jam dan tanggal' : 'So reminders trigger exactly on time',
              isGranted: _statuses['exactAlarm'] ?? false,
              isDark: isDark,
              isId: isId,
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _requestPermissions,
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: Text(isId ? 'Minta Izin' : 'Request Permissions'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: JagainColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: PermissionService.openSettings,
                icon: const Icon(Icons.settings_outlined, size: 18),
                label: Text(isId ? 'Pengaturan HP' : 'Device Settings'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String desc,
    required bool isGranted,
    required bool isDark,
    required bool isId,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? JagainColors.darkBackground : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isGranted ? const Color(0xFF10B981).withValues(alpha: 0.3) : (isDark ? JagainColors.darkBorder : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isGranted ? const Color(0xFF10B981) : JagainColors.primary).withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: isGranted ? const Color(0xFF10B981) : JagainColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 11.5, color: isDark ? JagainColors.darkMuted : JagainColors.muted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isGranted
                  ? const Color(0xFF10B981).withValues(alpha: isDark ? 0.2 : 0.12)
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isGranted ? (isId ? 'Aktif' : 'Allowed') : (isId ? 'Belum' : 'Denied'),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isGranted ? const Color(0xFF10B981) : (isDark ? JagainColors.darkMuted : JagainColors.muted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
