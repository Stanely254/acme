import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/tasks.dart';
import '../repositories/task_repository.dart';

/// A controller class for managing tasks, extending [ChangeNotifier].
///
/// This class handles the loading, adding, updating, and deleting of tasks
/// using a [TaskRepository]. It also provides error handling and state
/// management for the task list.
///
/// The [TaskController] constructor requires a [TaskRepository] instance.
///
/// Properties:
/// - `tasks`: A list of [Task] objects.
/// - `isLoading`: A boolean indicating if tasks are currently being loaded.
/// - `error`: An optional error message string.
///
/// Methods:
/// - `_loadTasks()`: Loads all tasks from the repository and updates the state.
/// - `addTask(String title, String description)`: Adds a new task with the given title and description.
/// - `updateTask(Task task)`: Updates an existing task.
/// - `deleteTask(String id)`: Deletes a task by its ID.
/// - `refreshTasks()`: Reloads all tasks from the repository.
/// - `clearError()`: Clears the current error message.
class TaskController extends ChangeNotifier {
  final TaskRepository _repository;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;
  bool _isSyncing = false;

  TaskController(this._repository) {
    _loadTasks();
  }

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _repository.getAllTasks();
    } catch (e) {
      _error = 'Failed to load tasks: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title, String description) async {
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
    );

    try {
      // Optimistic update
      _tasks.add(task);
      notifyListeners();

      await _repository.addTask(task);
    } catch (e) {
      // Rollback on error
      _tasks.remove(task);
      _error = 'Failed to add task: $e';
      notifyListeners();
    }
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    final oldTask = _tasks[index];

    try {
      // Optimistic update
      _tasks[index] = task;
      notifyListeners();

      await _repository.updateTask(task);
    } catch (e) {
      // Rollback on error
      _tasks[index] = oldTask;
      _error = 'Failed to update task: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((t) => t.id == id);
    final oldTask = _tasks[index];

    try {
      // Optimistic update
      _tasks.removeAt(index);
      notifyListeners();

      await _repository.deleteTask(id);
    } catch (e) {
      // Rollback on error
      _tasks.insert(index, oldTask);
      _error = 'Failed to delete task: $e';
      notifyListeners();
    }
  }

  Future<void> refreshTasks() => _loadTasks();

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> syncWithFirebase() async {
    if (_isSyncing) return;

    _isSyncing = true;
    notifyListeners();

    try {
      await _repository.syncWithFirebase();
      await _loadTasks();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
