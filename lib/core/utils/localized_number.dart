import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

/// Converts a number to a locale-aware string.
/// Bangla locale → ১২৩, English locale → 123
String localizedNumber(BuildContext context, num value) {
  final languageCode = Localizations.localeOf(context).languageCode;
  return NumberFormat.decimalPattern(languageCode).format(value);
}
