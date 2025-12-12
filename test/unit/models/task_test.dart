import 'package:flutter_test/flutter_test.dart';
import 'package:rest_api_demo/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('should create Task with default values', () {
      final task = Task(title: 'Test Task', userId: 'user123');

      expect(task.title, 'Test Task');
      expect(task.userId, 'user123');
      expect(task.description, '');
      expect(task.completed, false);
      expect(task.isSynced, false);
      expect(task.serverId, isNull);
      expect(task.localId, isNull);
    });

    test('should serialize to JSON for API', () {
      final task = Task(
        serverId: 1,
        title: 'API Task',
        description: 'For API testing',
        completed: true,
        userId: 'user123',
        createdAt: DateTime(2024, 1, 1),
        isSynced: true,
      );

      final json = task.toJson();

      expect(json['title'], 'API Task');
      expect(json['description'], 'For API testing');
      expect(json['completed'], true);
      expect(json['user_id'], 'user123');
      expect(json['id'], 1);
      expect(json['created_at'], '2024-01-01T00:00:00.000');
    });

    test('should deserialize from JSON from API', () {
      final json = {
        'id': 1,
        'title': 'From API',
        'description': 'API description',
        'completed': true,
        'user_id': 'user123',
        'created_at': '2024-01-01T00:00:00.000',
      };

      final task = Task.fromJson(json);

      expect(task.serverId, 1);
      expect(task.title, 'From API');
      expect(task.description, 'API description');
      expect(task.completed, true);
      expect(task.userId, 'user123');
      expect(task.createdAt, DateTime(2024, 1, 1));
      expect(task.isSynced, true);
    });

    test('should handle null/missing fields in JSON', () {
      final json = {
        'id': 1,
        'title': 'Partial Task',

        'completed': false,

        'created_at': null,
      };

      final task = Task.fromJson(json);

      expect(task.title, 'Partial Task');
      expect(task.description, '');
      expect(task.userId, '');
      expect(task.createdAt, isNull);
    });

    test('should serialize to Map for SQLite', () {
      final task = Task(
        localId: 1,
        serverId: 100,
        title: 'SQLite Task',
        description: 'For database',
        completed: true,
        userId: 'user123',
        createdAt: DateTime(2024, 1, 1),
        isSynced: false,
      );

      final map = task.toMap();

      expect(map['local_id'], 1);
      expect(map['server_id'], 100);
      expect(map['title'], 'SQLite Task');
      expect(map['description'], 'For database');
      expect(map['completed'], 1);
      expect(map['user_id'], 'user123');
      expect(map['is_synced'], 0);
    });

    test('should deserialize from Map from SQLite', () {
      final map = {
        'local_id': 1,
        'server_id': 100,
        'title': 'From DB',
        'description': 'Database description',
        'completed': 1,
        'user_id': 'user123',
        'created_at': '2024-01-01T00:00:00.000',
        'is_synced': 0,
      };

      final task = Task.fromMap(map);

      expect(task.localId, 1);
      expect(task.serverId, 100);
      expect(task.title, 'From DB');
      expect(task.description, 'Database description');
      expect(task.completed, true);
      expect(task.isSynced, false);
    });

    test('should create copy with updated fields', () {
      final original = Task(
        localId: 1,
        serverId: 100,
        title: 'Original',
        userId: 'user123',
      );

      final updated = original.copyWith(
        title: 'Updated',
        completed: true,
        isSynced: true,
      );

      expect(updated.localId, 1);
      expect(updated.serverId, 100);
      expect(updated.title, 'Updated');
      expect(updated.completed, true);
      expect(updated.isSynced, true);
      expect(updated.userId, 'user123');
    });

    test('should handle invalid date strings', () {
      final json = {
        'id': 1,
        'title': 'Invalid Date Task',
        'created_at': 'not-a-valid-date',
      };

      final task = Task.fromJson(json);

      expect(task.createdAt, isNull);
    });

    test('should handle empty JSON object', () {
      final json = <String, dynamic>{};

      final task = Task.fromJson(json);

      expect(task.title, '');
      expect(task.description, '');
      expect(task.completed, false);
      expect(task.userId, '');
      expect(task.createdAt, isNull);
      expect(task.isSynced, true);
    });
  });
}
