import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/services/firestore_service.dart';

import 'add_task_screen.dart';

class TasksViewScreen extends StatelessWidget {
  const TasksViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks:")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TasksListView(
              condition: (task) => task.status() == Status.undone,
            ),
            const Text("Done"),
            TasksListView(
              condition: (task) => task.status() == Status.done,
            ),
          ],
        ),
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
    final firestoreService = Provider.of<FirestoreService>(context);
    return StreamBuilder<Iterable<BaseTask>>(
      stream: firestoreService.getTasks(),
      builder: (context, AsyncSnapshot<Iterable<BaseTask>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: snapshot.data!.map(
            (task) {
              if (condition != null && !condition!(task)) {
                return Container();
              }
              bool? value;
              assert(Status.values.length == 2);
              switch (task.status()) {
                case Status.done:
                  value = true;
                  break;
                case Status.undone:
                  value = false;
                  break;
              }
              return Card(
                child: CheckboxListTile(
                  title: Text(task.name),
                  subtitle: Text(task.description),
                  secondary: Text(task.reoccurrence.displayTitle),
                  onChanged: (bool? value) {
                    if (value == null) {
                      throw UnimplementedError();
                    }
                    firestoreService.updateTaskFields(task.id, {
                      'lastCompleted':
                          value ? clock.now().toIso8601String() : null
                    });
                  },
                  value: value,
                  controlAffinity: ListTileControlAffinity.leading,
                  checkboxShape: const CircleBorder(),
                ),
              );
            },
          ).toList(),
        );
      },
    );
  }
}
