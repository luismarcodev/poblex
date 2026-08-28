import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poblex_backoffice/features/alerts/domain/entities/managed_alert.dart';
import 'package:poblex_backoffice/features/alerts/presentation/widgets/alert_severity_card.dart';
import 'package:poblex_design_system/poblex_design_system.dart';

void main() {
  testWidgets(
    'keeps the four severity channels visible at 320dp and 200% text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          builder: AppTheme.textScalingBuilder,
          home: Scaffold(
            body: SingleChildScrollView(
              child: AlertSeverityCard(
                alert: _alert(),
                severityLabel: 'Aviso rojo · Nivel 3',
                phenomenonTypeLabel: 'Meteorológico',
                sourceLabel: 'Manual',
                statusLabel: 'Activo',
                body: 'Evita los desplazamientos por la zona inundable.',
                startLabel: 'Empieza: 10/8/2026 10:00',
                endLabel: 'Sin fecha de fin',
                semanticsLabel: 'Aviso rojo, inundación',
                editLabel: 'Editar',
                deleteLabel: 'Borrar',
                busy: false,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aviso rojo · Nivel 3'), findsOneWidget);
      expect(find.byIcon(Icons.emergency_rounded), findsOneWidget);
      expect(find.bySemanticsLabel('Aviso rojo, inundación'), findsOneWidget);
      expect(tester.takeException(), isNull);

      final decoration =
          tester
                  .widget<DecoratedBox>(find.byType(DecoratedBox).first)
                  .decoration
              as BoxDecoration;
      expect((decoration.border! as Border).left.width, 12);
    },
  );
}

ManagedAlert _alert() => ManagedAlert(
  id: 'alert-1',
  municipalityId: 'municipality-1',
  source: ManagedAlertSource.manual,
  severity: ManagedAlertSeverity.red,
  phenomenonType: ManagedAlertPhenomenonType.meteorologico,
  phenomenon: 'Inundación',
  body: const AlertLocalizedText(es: 'Evita la zona'),
  startAt: DateTime.utc(2026, 8, 10, 10),
  forcesNotification: true,
);
