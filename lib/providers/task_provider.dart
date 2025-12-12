import 'package:flutter/material.dart';

import '../api/task_api.dart';
import '../local/task_local_db.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  final TaskApiService _apiService;
  final TaskLocalDb _localDb;

  TaskProvider(this._apiService, this._localDb);

  bool _isAuthenticated = false;
  bool _isAuthLoading = true;
  bool _isTaskLoading = false;
  String? _email;
  String? _userId;
  String? _errorMessage;

  List<Task> _tasks = [];

  bool _isSyncing = false;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isAuthLoading;
  bool get isAuthLoading => _isAuthLoading;
  bool get isTaskLoading => _isTaskLoading;
  bool get isSyncing => _isSyncing;
  String? get email => _email;
  String? get userId => _userId;
  String? get errorMessage => _errorMessage;
  List<Task> get tasks => _tasks;

  int get unsyncedCount =>
      _tasks.where((task) => task.isSynced == false).length;

  Future<void> checkSession() async {
    _isAuthLoading = true;
    notifyListeners();

    final session = await _apiService.loadSession();
    if (session != null) {
      _isAuthenticated = true;
      _email = session['email'];
      _userId = session['userId'];

      await loadTasksOfflineFirst();
    }

    _isAuthLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _errorMessage = null;
    _isAuthLoading = true;
    notifyListeners();

    final result = await _apiService.login(email, password);

    _isAuthLoading = false;

    if (result != null) {
      _isAuthenticated = true;
      _email = result['user']['email'];
      _userId = result['user']['id'];

      await loadTasksOfflineFirst();

      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Login gagal. Periksa email dan password.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _errorMessage = null;
    _isAuthLoading = true;
    notifyListeners();

    final result = await _apiService.register(email, password);

    _isAuthLoading = false;

    if (result != null) {
      _isAuthenticated = true;
      _email = result['user']['email'];
      _userId = result['user']['id'].toString();

      await loadTasksOfflineFirst();

      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Registrasi gagal. Coba email lain.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _apiService.logout();
    await _localDb.clearAll();

    _isAuthenticated = false;
    _email = null;
    _userId = null;
    _tasks = [];
    notifyListeners();
  }

  Future<void> loadTasksOfflineFirst() async {
    if (_userId == null) return;

    _isTaskLoading = true;
    notifyListeners();

    try {
      _tasks = await _localDb.getAllTasks();
      notifyListeners();

      final remote = await _apiService.getTasks();

      final unsyncedLocal = await _localDb.getUnsyncedTasks();
      for (final t in unsyncedLocal) {
        try {
          final uploaded = await _apiService.createTask(t);
          if (uploaded != null) {
            final fixed = t.copyWith(
              serverId: uploaded.serverId,
              isSynced: true,
              createdAt: uploaded.createdAt ?? t.createdAt,
            );
            await _localDb.updateTask(fixed);
          }
        } catch (_) {}
      }

      final mergedLocal = await _localDb.getAllTasks();

      final Map<int?, Task> map = {};

      for (final r in remote) {
        map[r.serverId] = r.copyWith(userId: _userId, isSynced: true);
      }
      for (final l in mergedLocal) {
        if (l.serverId == null || !map.containsKey(l.serverId)) {
          map[l.serverId] = l;
        }
      }

      _tasks =
          map.values.toList()
            ..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    } catch (e) {}

    _isTaskLoading = false;
    notifyListeners();
  }

  Future<bool> addTask(String title, String description) async {
    if (_userId == null) return false;

    _errorMessage = null;

    final localTask = Task(
      title: title,
      description: description,
      userId: _userId!,
      completed: false,
      isSynced: false,
      createdAt: DateTime.now(),
    );

    int localId;
    try {
      localId = await _localDb.insertTask(localTask);
    } catch (e) {
      _errorMessage = "Gagal menyimpan ke database lokal.";
      notifyListeners();
      return false;
    }

    final insertedTask = localTask.copyWith(localId: localId);

    _tasks.insert(0, insertedTask);
    notifyListeners();

    try {
      final createdOnServer = await _apiService.createTask(insertedTask);

      if (createdOnServer != null) {
        final syncedTask = insertedTask.copyWith(
          serverId: createdOnServer.serverId,
          isSynced: true,
          createdAt: createdOnServer.createdAt ?? insertedTask.createdAt,
        );

        await _localDb.updateTask(syncedTask);

        final index = _tasks.indexWhere(
          (t) => t.localId == insertedTask.localId,
        );
        if (index != -1) {
          _tasks[index] = syncedTask;
        }

        notifyListeners();
        return true;
      } else {
        _errorMessage = "Task disimpan di lokal, gagal ke server.";
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = "Mode offline: task disimpan lokal.";
      notifyListeners();
      return true;
    }
  }

  Future<bool> toggleTask(Task task) async {
    final updatedLocal = task.copyWith(
      completed: !task.completed,
      isSynced: false,
    );

    await _localDb.updateTask(updatedLocal);

    final index = _tasks.indexWhere((t) => t.localId == task.localId);
    if (index != -1) {
      _tasks[index] = updatedLocal;
      notifyListeners();
    }

    if (task.serverId == null) {
      return true;
    }

    try {
      final success = await _apiService.updateTask(
        updatedLocal.copyWith(serverId: task.serverId),
      );

      if (success) {
        final syncedTask = updatedLocal.copyWith(isSynced: true);

        await _localDb.updateTask(syncedTask);

        final idx = _tasks.indexWhere((t) => t.localId == syncedTask.localId);
        if (idx != -1) {
          _tasks[idx] = syncedTask;
          notifyListeners();
        }

        return true;
      } else {
        _errorMessage = 'Gagal mengupdate task di server.';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Mode offline: perubahan hanya tersimpan lokal.';
      notifyListeners();
      return true;
    }
  }

  Future<bool> deleteTask(Task task) async {
    if (task.localId == null) return false;

    await _localDb.deleteTask(task.localId!);
    _tasks.removeWhere((t) => t.localId == task.localId);
    notifyListeners();

    if (task.serverId == null) {
      return true;
    }

    try {
      final success = await _apiService.deleteTask(task.serverId!);
      if (!success) {
        _errorMessage = 'Gagal menghapus task di server.';
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Mode offline: task hanya terhapus di lokal.';
      notifyListeners();
      return true;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
