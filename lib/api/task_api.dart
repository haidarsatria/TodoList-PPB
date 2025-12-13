import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskApiService {
  static const String _baseUrl = 'API URL';
  static const String _apiKey = 'API KEY';

  String? _accessToken;

  Map<String, String> _getHeaders({
    bool includeAuth = true,
    bool returnRepresentation = false,
  }) {
    final headers = <String, String>{
      'apikey': _apiKey,
      'Content-Type': 'application/json',
    };

    if (includeAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }

    if (returnRepresentation) {
      headers['Prefer'] = 'return=representation';
    }

    return headers;
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/v1/token?grant_type=password'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        await _saveSession(data);
        return data;
      }

      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/v1/signup'),
        headers: _getHeaders(includeAuth: false),
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        await _saveSession(data);
        return data;
      }
      return null;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }

  Future<Map<String, String>?> loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      final userId = prefs.getString('user_id');
      final email = prefs.getString('user_email');

      if (token != null && userId != null && email != null) {
        _accessToken = token;
        return {'token': token, 'userId': userId, 'email': email};
      }
      return null;
    } catch (e) {
      print('Load session error: $e');
      return null;
    }
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      await prefs.remove('user_id');
      await prefs.remove('user_email');
      _accessToken = null;
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('access_token', data['access_token']);
      await prefs.setString('user_id', data['user']['id'].toString());
      await prefs.setString('user_email', data['user']['email']);
    } catch (e) {
      print('Save session error: $e');
    }
  }

  Future<List<Task>> getTasks() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/rest/v1/tasks?select=*&order=created_at.desc'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Task.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } else if (response.statusCode == 401) {
        print('Unauthorized: Token may be expired');
        return [];
      }

      return [];
    } catch (e) {
      print('Get tasks error: $e');
      return [];
    }
  }

  Future<Task?> createTask(Task task) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/rest/v1/tasks'),
        headers: _getHeaders(returnRepresentation: true),
        body: jsonEncode(task.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.body.isEmpty) {
          return task;
        }

        final data = jsonDecode(response.body);

        if (data is List && data.isNotEmpty) {
          return Task.fromJson(Map<String, dynamic>.from(data[0]));
        } else if (data is Map) {
          return Task.fromJson(Map<String, dynamic>.from(data));
        } else {
          return null;
        }
      }

      return null;
    } catch (e) {
      print('Create task error: $e');
      return null;
    }
  }

  Future<bool> updateTask(Task task) async {
    if (task.serverId == null) return false;

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/rest/v1/tasks?id=eq.${task.serverId}'),
        headers: _getHeaders(),
        body: jsonEncode(task.toJson()),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Update task error: $e');
      return false;
    }
  }

  Future<bool> deleteTask(int serverId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/rest/v1/tasks?id=eq.$serverId'),
        headers: _getHeaders(),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Delete task error: $e');
      return false;
    }
  }
}
