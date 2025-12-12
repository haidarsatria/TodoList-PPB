import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rest_api_demo/api/task_api.dart';
import 'package:rest_api_demo/models/task.dart';
import '../../helpers/test_helper.dart';

void main() {
  late TaskApiService apiService;
  late MockClient mockClient;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockClient = MockClient();
    mockPrefs = MockSharedPreferences();
    apiService = TaskApiService();

    SharedPreferences.setMockInitialValues({});
  });

  group('Authentication Tests', () {
    test('should login successfully', () async {
      final responseJson = {
        'access_token': 'token123',
        'user': {'id': 'user123', 'email': 'test@example.com'},
      };

      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(responseJson), 200));
    });

    test('should handle login failure', () async {
      when(
        () => mockClient.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('', 401));
    });
  });

  group('Task Operations Tests', () {
    test('should convert Task to correct JSON for API', () {
      final task = Task(
        serverId: 1,
        title: 'Test Task',
        description: 'Description',
        completed: true,
        userId: 'user123',
        createdAt: DateTime(2024, 1, 1),
      );

      final json = task.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Test Task');
      expect(json['completed'], true);
      expect(json['user_id'], 'user123');
      expect(json['created_at'], isA<String>());
    });

    test('should parse API response to Task', () {
      final apiResponse = {
        'id': 1,
        'title': 'API Task',
        'description': 'From API',
        'completed': false,
        'user_id': 'user123',
        'created_at': '2024-01-01T00:00:00.000',
      };

      final task = Task.fromJson(apiResponse);

      expect(task.serverId, 1);
      expect(task.title, 'API Task');
      expect(task.isSynced, true);
    });
  });
}
