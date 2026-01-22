import 'package:chacarita_voley_app/app/layout/app_scaffold.dart';
import 'package:chacarita_voley_app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppScaffold shows subtitle under title when provided', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const AppScaffold(
          title: 'Gestión de Entrenamientos',
          subtitle: 'Chaca Feme',
          child: SizedBox.shrink(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Gestión de Entrenamientos'), findsOneWidget);
    expect(find.text('Chaca Feme'), findsOneWidget);
  });
}
