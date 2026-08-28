import 'package:flutter/material.dart';

import 'app_colors.dart';

BrandPalette resolveBrandPalette(String? value) {
  final color = parseHexColor(value);
  return color == null ? BrandPalette.poblex : BrandPalette.fromSeed(color);
}

@visibleForTesting
Color? parseHexColor(String? value) {
  if (value == null) return null;
  final cleaned = value.trim().replaceFirst('#', '');
  if (cleaned.length != 6 && cleaned.length != 8) return null;
  final parsed = int.tryParse(cleaned, radix: 16);
  if (parsed == null) return null;
  return Color(cleaned.length == 6 ? 0xFF000000 | parsed : parsed);
}
