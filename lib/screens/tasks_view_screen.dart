import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/tasks.dart';
import 'add_task_screen.dart';

class TasksViewScreen extends StatelessWidget {
  const TasksViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks:")),
      body: const TasksListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        tooltip: 'Add a task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TasksListView extends StatelessWidget {
  const TasksListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tasks = context.watch<Tasks>().tasks;
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        var task = tasks[index];
        return Card(
          child: CheckboxListTile(
            title: Text(task.name),
            subtitle: Text(task.description),
            onChanged: (bool? value) {
              if (value != null) {
                context.read<Tasks>().toggle(index);
              }
            },
            value: task.completed,
            controlAffinity: ListTileControlAffinity.leading,
            checkboxShape: const CircleBorder(),
          ),
        );
      },
    );
  }
}
