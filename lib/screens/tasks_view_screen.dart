import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';

import '../providers/tasks.dart';
import 'add_task_screen.dart';

class TasksViewScreen extends StatelessWidget {
  const TasksViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks:")),
      body: Column(
        children: [
          TasksListView(
            condition: (task) => task.status == Status.undone,
          ),
          const Text("Done"),
          TasksListView(
            condition: (task) => task.status == Status.done,
          ),
        ],
      ),
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
  final bool Function(BaseTask)? condition;

  const TasksListView({Key? key, this.condition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tasks = context.watch<Tasks>().tasks;
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        var task = tasks[index];
        if (condition != null && !condition!(task)) {
          return Container();
        }
        bool? value;
        switch (task.status) {
          case Status.done:
            value = true;
            break;
          case Status.undone:
            value = false;
            break;
          default:
            assert(false, "Unreachable");
        }
        return Card(
          child: CheckboxListTile(
            title: Text(task.name),
            subtitle: Text(task.description),
            onChanged: (bool? value) {
              context.read<Tasks>().changeStatus(index, value);
            },
            value: value,
            controlAffinity: ListTileControlAffinity.leading,
            checkboxShape: const CircleBorder(),
          ),
        );
      },
    );
  }
}
