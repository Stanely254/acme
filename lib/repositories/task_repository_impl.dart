// Implementation combining Hive and Firebase
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import '../models/tasks.dart';
import 'task_repository.dart';

/// Implementation of the TaskRepository interface that provides methods
/// for managing tasks locally using a Hive box and syncing with Firebase Firestore.
///
/// This class handles CRUD operations for tasks, including adding, updating,
/// deleting, and retrieving tasks. It also provides methods for syncing tasks
/// with Firebase Firestore and resolving conflicts between local and remote tasks.
///
/// The class uses a Hive box to store tasks locally and Firebase Firestore
/// to store tasks remotely. It includes methods for checking online status,
/// handling conflicts, and performing background syncs.
///
/// Methods:
/// - `deleteTask(String id)`: Deletes a task by its ID from both local storage and Firestore.
/// - `getTask(String id)`: Retrieves a task by its ID from local storage.
/// - `watchTasks()`: Returns a stream of all tasks from local storage.
/// - `getAllTasks()`: Retrieves all tasks from local storage.
/// - `addTask(Task task)`: Adds a new task to local storage and attempts to sync it with Firestore.
/// - `updateTask(Task task)`: Updates an existing task in local storage and attempts to sync it with Firestore.
/// - `syncWithFirebase()`: Syncs tasks between local storage and Firestore, resolving conflicts.
/// - `startBackgroundSync()`: Starts a background service to periodically sync unsynced tasks with Firestore.
///
/// Private Methods:
/// - `_handleConflict(Task remoteTask, Task localTask)`: Handles conflicts between local and remote tasks, giving precedence to remote changes.
/// - `_isOnline()`: Checks if the device is online by making a request to Google.
class TaskRepositoryImpl implements TaskRepository {
  @override
  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
    if (await _isOnline()) {
      try {
        await _firestore.collection('tasks').doc(id).delete();
      } catch (e) {
        debugPrint('Error deleting task: $e');
      }
    }
  }

  @override
  Future<Task?> getTask(String id) async {
    return _taskBox.get(id);
  }

  @override
  Stream<List<Task>> watchTasks() {
    return _taskBox.watch().map((event) => _taskBox.values.toList());
  }

  final Box<Task> _taskBox;
  final FirebaseFirestore _firestore;

  TaskRepositoryImpl(this._taskBox, this._firestore);

  @override
  Future<List<Task>> getAllTasks() async {
    return _taskBox.values.toList();
  }

  @override
  Future<void> addTask(Task task) async {
    // Save locally first
    await _taskBox.put(task.id, task);

    // Try to sync if online
    try {
      await _firestore.collection('tasks').doc(task.id).set(task.toJson());
      task.isSynced = true;
      await _taskBox.put(task.id, task);
    } catch (e, stack) {
      debugPrint('Error syncing task: $e, $stack');
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    task.lastModified = DateTime.now();
    await _taskBox.put(task.id, task);

    if (await _isOnline()) {
      try {
        // Check for conflicts
        final remoteDoc =
            await _firestore.collection('tasks').doc(task.id).get();
        if (remoteDoc.exists) {
          final remoteTask = Task.fromJson(remoteDoc.data()!);
          if (remoteTask.lastModified.isAfter(task.lastModified)) {
            // Handle conflict - in this case, remote wins
            await _handleConflict(remoteTask, task);
            return;
          }
        }

        await _firestore.collection('tasks').doc(task.id).set(task.toJson());
        task.isSynced = true;
        await _taskBox.put(task.id, task);
      } catch (e) {
        debugPrint('Error updating task: $e');
      }
    }
  }

  Future<void> _handleConflict(Task remoteTask, Task localTask) async {
    // For this implementation, remote changes take precedence
    // You could implement more sophisticated conflict resolution here
    remoteTask.isSynced = true;
    await _taskBox.put(remoteTask.id, remoteTask);
  }

  Future<bool> _isOnline() async {
    try {
      final response = await http
          .get(Uri.parse('https://google.com'))
          .timeout(const Duration(seconds: 5));
      debugPrint('Response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> syncWithFirebase() async {
    try {
      // Get all remote tasks
      final snapshot = await _firestore.collection('tasks').get();
      final remoteTasks =
          snapshot.docs.map((doc) => Task.fromFirebase(doc.data())).toList();

      // Get all local tasks
      final localTasks = _taskBox.values.toList();

      // Sync remote to local
      for (final remoteTask in remoteTasks) {
        final localTask = localTasks.firstWhere(
          (lt) => lt.id == remoteTask.id,
          orElse: () => Task(
              id: '',
              title: '',
              description: '',
              isSynced: false,
              lastModified: DateTime.now()),
        );

        if ((remoteTask.lastModified.isAfter(localTask.lastModified))) {
          await _taskBox.put(remoteTask.id, remoteTask);
        }
      }

      // Sync local to remote
      for (final localTask in localTasks) {
        final remoteTask = remoteTasks.firstWhere(
          (rt) => rt.id == localTask.id,
          orElse: () => Task(
              id: '',
              title: '',
              description: '',
              isSynced: false,
              lastModified: DateTime.now()),
        );

        if ((localTask.lastModified.isAfter(remoteTask.lastModified))) {
          await _firestore
              .collection('tasks')
              .doc(localTask.id)
              .set(localTask.toFirebase());
        }
      }
    } catch (e) {
      debugPrint('Failed to sync with Firebase: $e');
      throw Exception('Failed to sync with Firebase');
    }
  }

  // Background sync service
  void startBackgroundSync() {
    Timer.periodic(Duration(minutes: 5), (timer) async {
      if (await _isOnline()) {
        final unsyncedTasks = _taskBox.values.where((task) => !task.isSynced);
        for (final task in unsyncedTasks) {
          await updateTask(task);
        }
      }
    });
  }
}
