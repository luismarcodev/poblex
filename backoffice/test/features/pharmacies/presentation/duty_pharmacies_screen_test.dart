import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/pharmacies/domain/entities/duty_pharmacy.dart';
import 'package:poblex_backoffice/features/pharmacies/presentation/screens/duty_pharmacies_screen.dart';
import 'package:poblex_backoffice/features/pharmacies/presentation/viewmodels/duty_pharmacies_view_model.dart';
import 'package:poblex_backoffice/l10n/app_localizations.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

class FakeDutyPharmaciesViewModel extends DutyPharmaciesViewModel {
  FakeDutyPharmaciesViewModel(this.loader);

  final Future<DutyPharmaciesUiState> Function() loader;
  int refreshCalls = 0;
  int previousMonthCalls = 0;

  @override
  Future<DutyPharmaciesUiState> build() => loader();

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }

  @override
  Future<void> showPreviousMonth() async {
    previousMonthCalls++;
  }
}

void main() {
  testWidgets('renders a guard at 320dp and 200% text without overflow', (
    tester,
  ) async {
    _configureCompactLargeText(tester, height: 1800);
    late FakeDutyPharmaciesViewModel fake;
    await tester.pumpWidget(
      _app(
        locale: const Locale('ca'),
        override: dutyPharmaciesViewModelProvider.overrideWith(() {
          fake = FakeDutyPharmaciesViewModel(
            () async => DutyPharmaciesUiState(
              municipalityId: 'sollana',
              month: DateTime(2026, 8),
              items: [_pharmacy],
            ),
          );
          return fake;
        }),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Farmàcia Ribera'), findsOneWidget);
    expect(find.text('Carrer Major, 12'), findsOneWidget);
    expect(find.text('Editar la guàrdia'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Mes anterior'));
    await tester.pump();
    expect(fake.previousMonthCalls, 1);
  });

  testWidgets('keeps the empty month explicit', (tester) async {
    await tester.pumpWidget(
      _app(
        override: dutyPharmaciesViewModelProvider.overrideWith(
          () => FakeDutyPharmaciesViewModel(
            () async => DutyPharmaciesUiState(
              municipalityId: 'sollana',
              month: DateTime(2026, 8),
              items: const [],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No hay guardias cargadas'), findsOneWidget);
    expect(
      find.text('Añade las farmacias de guardia para este mes.'),
      findsOneWidget,
    );
  });
}

Widget _app({required Override override, Locale locale = const Locale('es')}) =>
    ProviderScope(
      overrides: [override],
      child: MaterialApp(
        locale: locale,
        theme: AppTheme.light(),
        builder: AppTheme.textScalingBuilder,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: DutyPharmaciesScreen()),
      ),
    );

void _configureCompactLargeText(WidgetTester tester, {double height = 800}) {
  tester.view.physicalSize = Size(320, height);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = 2;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

final DutyPharmacy _pharmacy = DutyPharmacy(
  id: 'pharmacy-1',
  municipalityId: 'sollana',
  date: DateTime(2026, 8, 12),
  pharmacyName: 'Farmàcia Ribera',
  address: 'Carrer Major, 12',
  phone: '961 234 567',
  schedule: '9:00 - 22:00',
);
