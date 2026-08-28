import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

void main() {
  test('the implicit Material body style honours the 18 sp product base', () {
    final TextTheme theme = AppTypography.textTheme(Colors.black);

    expect(theme.bodyMedium?.fontSize, 18);
    expect(theme.bodyLarge?.fontSize, 18);
  });

  test('smaller styles remain restricted to metadata and secondary copy', () {
    final TextTheme theme = AppTypography.textTheme(Colors.black);

    expect(theme.bodySmall?.fontSize, AppTypography.minBodySize);
    expect(theme.labelSmall?.fontSize, AppTypography.minLabelSize);
  });
}
