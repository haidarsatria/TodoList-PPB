import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'package:rest_api_demo/models/task.dart';

class MockClient extends Mock implements http.Client {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockDatabase extends Mock implements Database {}

class MockBatch extends Mock implements Batch {}

class FakeTask extends Fake implements Task {}

final mockTasksJson = [
  {
    'id': 1,
    'title': 'Test Task 1',
    'description': 'Description 1',
    'completed': false,
    'user_id': 'user123',
    'created_at': '2024-01-01T00:00:00.000',
  },
  {
    'id': 2,
    'title': 'Test Task 2',
    'description': 'Description 2',
    'completed': true,
    'user_id': 'user123',
    'created_at': '2024-01-02T00:00:00.000',
  },
];

void setupMockTailFallbacks() {
  registerFallbackValue(FakeTask());
  registerFallbackValue(Uri());
  registerFallbackValue(<String, String>{});
}
