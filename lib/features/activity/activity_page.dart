import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/app_locale.dart';
import '../shared/section_page.dart';

class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);

    return SectionPage(
      title: strings.navActivity,
      subtitle: strings.isId
          ? 'Riwayat perawatan dan perubahan aset.'
          : 'Maintenance history and asset events.',
      icon: Icons.history_rounded,
      emptyTitle: strings.isId
          ? 'Aktivitas akan muncul di sini'
          : 'Activity will appear here',
      emptyMessage: strings.isId
          ? 'Catatan servis dan perawatan akan tersimpan sebagai riwayat otomatis.'
          : 'Service and care logs will be saved here as chronological history.',
    );
  }
}
