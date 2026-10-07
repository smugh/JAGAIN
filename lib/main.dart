import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/utils/date_format_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initAppDateFormatting();
  runApp(const ProviderScope(child: JagainApp()));
}
