import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:rest_api_demo/main.dart' as app;
import 'package:rest_api_demo/models/task.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Complete User Flow Tests', () {
    testWidgets('Login → Add Task → Delete Task → Logout', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('emailField')),
        'test@example.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Your Tasks'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('titleField')),
        'Integration Test Task',
      );
      await tester.enterText(
        find.byKey(const Key('descriptionField')),
        'Task from integration test',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Integration Test Task'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.check_box_outline_blank).first);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      expect(find.text('Login'), findsOneWidget);
    });
  });
}
