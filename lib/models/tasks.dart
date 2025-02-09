import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'task_status.dart';

part 'tasks.g.dart';

@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  TaskStatus status;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime lastModified;

  @HiveField(6)
  bool isSynced;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.status = TaskStatus.todo,
    DateTime? createdAt,
    DateTime? lastModified,
    this.isSynced = false,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastModified = lastModified ?? DateTime.now();

  // Convert to Firebase document
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  // Create a Task from Firebase document
  factory Task.fromFirebase(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastModified: map['updatedAt'] != null
          ? (map['updatedAt'] as Timestamp).toDate()
          : null,
      status: TaskStatus.values.firstWhere(
        (status) => status.toString().split('.').last == map['status'],
        orElse: () => TaskStatus.todo,
      ),
    );
  }

  // Convert Task to Firebase document
  Map<String, dynamic> toFirebase() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(lastModified),
      'status': status.toString().split('.').last,
    };
  }

  // Create from Firebase document
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: TaskStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      lastModified: DateTime.parse(json['lastModified']),
    );
  }
}
