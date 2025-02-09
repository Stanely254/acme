import 'package:acme/controller/task_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/add_task_dialog.dart';
import 'widgets/task_list_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<TaskController>().syncWithFirebase();
            },
            icon: Icon(Icons.sync),
          )
        ],
      ),
      body: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: Consumer<TaskController>(
          builder: (context, taskProvider, child) {
            if (taskProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (taskProvider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(taskProvider.error!),
                    ElevatedButton(
                      onPressed: taskProvider.clearError,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: taskProvider.refreshTasks,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: taskProvider.tasks.length,
                itemBuilder: (context, index) {
                  final task = taskProvider.tasks[index];
                  return TaskListItem(task: task);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(),
    );
  }
}
