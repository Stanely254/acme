import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../controller/task_controller.dart';
import '../../../models/task_status.dart';
import '../../../models/tasks.dart';
import '../../details/detail_screen.dart';

class TaskListItem extends StatelessWidget {
  const TaskListItem({
    super.key,
    required this.task,
  });
  final Task task;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id),
      onDismissed: (_) {
        context.read<TaskController>().deleteTask(task.id);
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        title: Text(task.title),
        subtitle: Text(task.description),
        trailing: _buildStatusIcon(),
        onTap: () => _showTaskDetailScreen(context),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (task.status) {
      case TaskStatus.todo:
        icon = Icons.fiber_new;
        color = Colors.blue;
        break;
      case TaskStatus.inProgress:
        icon = Icons.pending;
        color = Colors.orange;
        break;
      case TaskStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
    }

    return Icon(icon, color: color);
  }

  void _showTaskDetailScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(task: task),
      ),
    );
  }
}
