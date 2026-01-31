import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chacarita_voley_app/features/auth/presentation/pages/login_page.dart';

void main() {
  group('LoginPage Validations', () {
    testWidgets('Debe mostrar SnackBar cuando el email está vacío', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Hacer scroll para que el botón esté visible
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Buscar el botón de login por tipo y presionarlo sin llenar los campos
      final loginButton = find.byType(ElevatedButton);
      expect(loginButton, findsOneWidget);

      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verificar que se muestre el SnackBar con el error
      expect(find.text('El email es obligatorio'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Debe mostrar SnackBar cuando el email no es válido', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Ingresar un email inválido
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'emailinvalido');

      // Hacer scroll para que el botón esté visible
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Presionar el botón de login
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verificar que se muestre el SnackBar con el error
      expect(find.text('Ingresa un email válido'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Debe mostrar SnackBar cuando la contraseña está vacía', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Ingresar solo el email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'test@example.com');

      // Hacer scroll para que el botón esté visible
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Presionar el botón de login
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verificar que se muestre el SnackBar con el error
      expect(find.text('La contraseña es obligatoria'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Debe mostrar SnackBar cuando la contraseña es muy corta', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Ingresar email y contraseña corta
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, '12');

      // Hacer scroll para que el botón esté visible
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Presionar el botón de login
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verificar que se muestre el SnackBar con el error
      expect(
        find.text('La contraseña debe tener al menos 3 caracteres'),
        findsOneWidget,
      );
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('No debe mostrar SnackBars cuando los campos son válidos', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Ingresar datos válidos
      final emailField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      // Hacer scroll para que el botón esté visible
      await tester.ensureVisible(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Presionar el botón de login
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pump();

      // Verificar que no haya SnackBars de validación
      expect(find.text('El email es obligatorio'), findsNothing);
      expect(find.text('Ingresa un email válido'), findsNothing);
      expect(find.text('La contraseña es obligatoria'), findsNothing);
      expect(
        find.text('La contraseña debe tener al menos 3 caracteres'),
        findsNothing,
      );
    });
  });
}
