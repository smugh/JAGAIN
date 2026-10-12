import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/local_database_service.dart';
import 'core/utils/date_format_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppDateFormatting();
  await LocalDatabaseService.instance.init();
  runApp(const ProviderScope(child: JagainApp()));
}
