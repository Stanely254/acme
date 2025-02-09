import 'package:hive/hive.dart';

part 'task_status.g.dart';

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  todo,

  @HiveField(1)
  inProgress,

  @HiveField(2)
  completed
}
