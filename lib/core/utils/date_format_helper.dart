import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

/// Initializes local date formatting symbols for Indonesian and English.
Future<void> initAppDateFormatting() async {
  try {
    await initializeDateFormatting('id_ID', null);
  } catch (_) {}
  try {
    await initializeDateFormatting('id', null);
  } catch (_) {}
  try {
    await initializeDateFormatting('en_US', null);
  } catch (_) {}
}

/// Safely returns a DateFormat without throwing LocaleDataException
DateFormat safeDateFormat(String pattern, [String? locale]) {
  try {
    return DateFormat(pattern, locale);
  } catch (_) {
    try {
      return DateFormat(pattern);
    } catch (_) {
      return DateFormat();
    }
  }
}
