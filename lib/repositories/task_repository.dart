// Task Repository Interface
import '../models/tasks.dart';

/// An abstract class that defines the contract for a task repository.
/// This repository is responsible for performing CRUD operations on tasks.
abstract class TaskRepository {
  /// Fetches all tasks from the repository.
  ///
  /// Returns a [Future] that completes with a list of [Task] objects.
  Future<List<Task>> getAllTasks();

  /// Fetches a single task by its [id] from the repository.
  ///
  /// Returns a [Future] that completes with the [Task] object if found,
  /// or `null` if no task with the given [id] exists.
  Future<Task?> getTask(String id);

  /// Adds a new [Task] to the repository.
  ///
  /// Takes a [Task] object as a parameter.
  /// Returns a [Future] that completes when the task has been added.
  Future<void> addTask(Task task);

  /// Updates an existing [Task] in the repository.
  ///
  /// Takes a [Task] object as a parameter.
  /// Returns a [Future] that completes when the task has been updated.
  Future<void> updateTask(Task task);

  /// Deletes a task by its [id] from the repository.
  ///
  /// Takes a [String] [id] as a parameter.
  /// Returns a [Future] that completes when the task has been deleted.
  Future<void> deleteTask(String id);

  /// Watches for changes to the list of tasks in the repository.
  ///
  /// Returns a [Stream] that emits a list of [Task] objects whenever
  /// there is a change in the repository.
  Stream<List<Task>> watchTasks();

  /// Synchronizes the local data with Firebase.
  ///
  /// This method ensures that any changes made locally are reflected in the
  /// Firebase database and vice versa. It handles the necessary logic to
  /// merge, update, or delete data as required to keep both the local and
  /// remote data in sync.
  ///
  /// Throws:
  /// - [FirebaseException] if there is an error during the synchronization process.
  ///
  /// Example usage:
  /// ```dart
  /// await taskRepository.syncWithFirebase();
  /// ```
  Future<void> syncWithFirebase();
}
