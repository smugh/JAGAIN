import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
