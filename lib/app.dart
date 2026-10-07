import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/activity/activity_page.dart';
import 'features/assets/assets_page.dart';
import 'features/assets/presentation/add_asset_sheet.dart';
import 'features/home/home_page.dart';
import 'features/settings/settings_page.dart';
import 'i18n/app_locale.dart';
import 'theme/app_theme.dart';

class JagainApp extends ConsumerStatefulWidget {
  const JagainApp({super.key});

  @override
  ConsumerState<JagainApp> createState() => _JagainAppState();
}

class _JagainAppState extends ConsumerState<JagainApp> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final themeMode = ref.watch(themeModeProvider);

    final pages = <Widget>[
      const HomePage(),
      const AssetsPage(),
      const ActivityPage(),
      SettingsPage(
        isDarkMode: themeMode == ThemeMode.dark,
        onToggleDarkMode: () => ref.read(themeModeProvider.notifier).toggle(),
      ),
    ];

    return MaterialApp(
      title: 'JAGAIN',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: Builder(
        builder: (innerContext) => Scaffold(
          body: SafeArea(child: pages[_selectedIndex]),
          bottomNavigationBar: _buildCustomBottomBar(innerContext, strings, themeMode == ThemeMode.dark),
        ),
      ),
    );
  }

  Widget _buildCustomBottomBar(BuildContext context, AppStrings strings, bool isDark) {
    final navBg = isDark ? JagainColors.darkSurface : Colors.white;
    final borderColor = isDark ? JagainColors.darkBorder : JagainColors.border;

    return Container(
      decoration: BoxDecoration(
        color: navBg,
        border: Border(
          top: BorderSide(color: borderColor, width: 0.8),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, -1),
                ),
              ],
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: Row(
            children: [
              // 1. Beranda
              Expanded(
                child: _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home_rounded,
                  label: strings.navHome,
                  isDark: isDark,
                ),
              ),

              // 2. Aset
              Expanded(
                child: _buildNavItem(
                  index: 1,
                  icon: Icons.inventory_2_outlined,
                  selectedIcon: Icons.inventory_2_rounded,
                  label: strings.navAssets,
                  isDark: isDark,
                ),
              ),

              // 3. Center Add Asset Button with Prepared Logo
              Expanded(
                child: _buildProminentAddButton(context, strings, isDark),
              ),

              // 4. Aktivitas
              Expanded(
                child: _buildNavItem(
                  index: 2,
                  icon: Icons.history_rounded,
                  selectedIcon: Icons.history_rounded,
                  label: strings.navActivity,
                  isDark: isDark,
                ),
              ),

              // 5. Pengaturan
              Expanded(
                child: _buildNavItem(
                  index: 3,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings_rounded,
                  label: strings.navSettings,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _selectedIndex == index;
    final activeColor = isDark ? JagainColors.primaryLight : JagainColors.primaryDark;
    final inactiveColor = isDark ? JagainColors.darkMuted : JagainColors.muted;

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 28,
              child: Center(
                child: Icon(
                  isSelected ? selectedIcon : icon,
                  color: isSelected ? activeColor : inactiveColor,
                  size: 21,
                ),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.1,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProminentAddButton(
    BuildContext context,
    AppStrings strings,
    bool isDark,
  ) {
    return InkWell(
      onTap: () => AddAssetSheet.show(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF04B185).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
                border: Border.all(
                  color: isDark ? JagainColors.darkSurface : Colors.white,
                  width: 1.2,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.asset(
                  'assets/icons/vaficon_hijau.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 1),
            Text(
              strings.navAddAsset,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                height: 1.1,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2DD4BF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
