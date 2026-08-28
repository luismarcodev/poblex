import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

const double _minimumBodyTextContrast = 4.5;
const double _minimumGraphicContrast = 3.0;

/// Same six seeds documented and hand-verified in design-system.md §2.9,
/// including the two hostile cases: a fully saturated yellow and the exact
/// red used for the highest alert severity.
const Map<String, int> _municipalitySeeds = <String, int>{
  'Poblex default': 0xFFD97757,
  'Verde Albufera': 0xFF1F6F5C,
  'Amarillo saturado': 0xFFFFD400,
  'Azul institucional': 0xFF0057B7,
  'Rojo (peor caso, coincide con la alerta roja)': 0xFFB3261E,
  'Morado': 0xFF7B2D8E,
};

void main() {
  group('BrandPalette.fromSeed — the hard guarantee', () {
    // This is the test the class's own doc comment asks for: a bad
    // municipality colour must fail CI, never reach production. See
    // design-system.md §2.9, rule 3 — "no hay entrada válida que produzca una
    // salida que incumpla".
    for (final MapEntry<String, int> entry in _municipalitySeeds.entries) {
      test('${entry.key} derives a palette that meets WCAG AA', () {
        final BrandPalette palette = BrandPalette.fromSeed(Color(entry.value));

        expect(
          palette.meetsContrastRequirements,
          isTrue,
          reason:
              'Seed #${entry.value.toRadixString(16)} produced an action '
              'colour that does not clear 4.5:1.',
        );
      });
    }

    test('every derived action colour clears 4.5:1 against its background', () {
      for (final int seed in _municipalitySeeds.values) {
        final BrandPalette palette = BrandPalette.fromSeed(Color(seed));

        expect(
          BrandPalette.contrastRatio(palette.lightAction, AppPalette.neutral50),
          greaterThanOrEqualTo(_minimumBodyTextContrast),
        );
        expect(
          BrandPalette.contrastRatio(palette.lightAction, AppPalette.neutral0),
          greaterThanOrEqualTo(_minimumBodyTextContrast),
        );
        expect(
          BrandPalette.contrastRatio(
            palette.darkAction,
            AppPalette.darkBackground,
          ),
          greaterThanOrEqualTo(_minimumBodyTextContrast),
        );
      }
    });

    test('the decorative step is taken from the seed, unadjusted', () {
      // Rule 4: the decorative role carries no text, so the town's raw colour
      // is what it recognises as "its own" — the loop never touches it.
      for (final int seed in _municipalitySeeds.values) {
        final BrandPalette palette = BrandPalette.fromSeed(Color(seed));
        expect(palette.decorative, Color(seed));
      }
    });

    test(
      'the graphic step clears 3:1 even when unadjusted decorative would not',
      () {
        for (final int seed in _municipalitySeeds.values) {
          final BrandPalette palette = BrandPalette.fromSeed(Color(seed));
          expect(
            BrandPalette.contrastRatio(palette.graphic, AppPalette.neutral50),
            greaterThanOrEqualTo(_minimumGraphicContrast),
          );
        }
      },
    );
  });

  test(
    'the hand-tuned Poblex default is not run through the loop, and beats it',
    () {
      // design-system.md §1 documents primary-700 (Stitch's #AC3509) at
      // 6.43:1 against pure white and 6.10:1 against the bone background —
      // both comfortably past the loop's own worst case (~4.55:1, see the
      // seed table above).
      final Color action = BrandPalette.poblex.lightAction;
      expect(
        BrandPalette.contrastRatio(action, AppPalette.neutral0),
        greaterThanOrEqualTo(6.0),
      );
      expect(
        BrandPalette.contrastRatio(action, AppPalette.neutral50),
        greaterThanOrEqualTo(6.0),
      );
    },
  );
}
