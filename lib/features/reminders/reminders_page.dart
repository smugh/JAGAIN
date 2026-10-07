import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/app_locale.dart';
import '../shared/section_page.dart';

class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return SectionPage(
      title: strings.navReminders,
      subtitle: strings.isId
          ? 'Hal yang perlu dilakukan untuk merawat asetmu.'
          : 'Things to do to care for your assets.',
      icon: Icons.notifications_active_outlined,
      emptyTitle: strings.isId
          ? 'Belum ada pengingat'
          : 'No reminders yet',
      emptyMessage: strings.isId
          ? 'Buat pengingat servis, perpanjangan, atau perawatan berkala.'
          : 'Create reminders for service, renewals, or regular maintenance.',
    );
  }
}
