import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:chacarita_voley_app/features/trainings/presentation/pages/trainings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TrainingsPage builds correctly with team context', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const TrainingsPage(teamId: '1', teamName: 'Equipo A'),
      ),
    );

    await tester.pumpAndSettle();

    // Verificamos que se muestre la sección de filtros
    expect(find.text('Filtro'), findsOneWidget);
  });

  testWidgets(
    'TrainingsPage builds with team context even when trainings are global',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const TrainingsPage(teamId: '999', teamName: 'Equipo Test'),
        ),
      );

      await tester.pumpAndSettle();

      // La pantalla se construye y muestra al menos la sección de filtros
      expect(find.text('Filtro'), findsOneWidget);
    },
  );
}
