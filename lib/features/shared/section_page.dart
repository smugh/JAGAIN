import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class SectionPage extends StatelessWidget {
  const SectionPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emptyTitle,
    required this.emptyMessage,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 22),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: isDark ? JagainColors.darkAccentBg : JagainColors.mint,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark ? JagainColors.darkBorder : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: isDark ? JagainColors.primaryLight : JagainColors.primaryDark,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  emptyTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
