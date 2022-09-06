import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/timed_task.dart';
import 'package:todo_app/services/firestore_service.dart';

import '../models/checked_task.dart';
import '../widgets/timer_widget.dart';
import 'add_task_screen.dart';

class TasksViewScreen extends StatelessWidget {
  const TasksViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    var checkedTasks = firestoreService
        .getTasks<CheckedTask>(CheckedTask.fromMap)
        .asBroadcastStream();
    var timedTasks = firestoreService
        .getTasks<TimedTask>(TimedTask.fromMap)
        .asBroadcastStream();
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks:")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TasksListView(
              condition: (task) => !task.isDone,
              tasks: checkedTasks,
            ),
            TasksListView(
              condition: (task) => !task.isDone,
              tasks: timedTasks,
            ),
            const Text("Done"),
            TasksListView(
              condition: (task) => task.isDone,
              tasks: checkedTasks,
            ),
            TasksListView(
              condition: (task) => task.isDone,
              tasks: timedTasks,
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
  final Stream<Iterable<BaseTask>> tasks;

  const TasksListView({Key? key, this.condition, required this.tasks})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Iterable<BaseTask>>(
      stream: tasks,
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
              return TaskCard(task);
            },
          ).toList(),
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final BaseTask task;

  const TaskCard(this.task, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var firestoreService = Provider.of<FirestoreService>(context);
    return Card(
      child: Dismissible(
        key: ObjectKey(task),
        onDismissed: ((direction) {
          firestoreService.deleteTask(task.type, task.id);
        }),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
          child: const Icon(Icons.delete_sweep),
        ),
        child: ListTile(
          title: Text(task.name),
          subtitle: Text(task.description),
          trailing: Text(task.reoccurrence.displayTitle),
          // TODO: add editing onTap
          // onTap: () {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => const AddTaskScreen()),
          //   );
          // },
          leading: task.type == TaskType.timed
              ? TimerWidget(timedTask: task as TimedTask)
              : Checkbox(
                  onChanged: (bool? value) {
                    if (value == null) {
                      throw UnimplementedError();
                    }
                    firestoreService.updateTaskFields(task.type, task.id, {
                      'lastCompletedOn':
                          value ? clock.now().toIso8601String() : null
                    });
                  },
                  value: task.isDone,
                  shape: const CircleBorder(),
                ),
        ),
      ),
    );
  }
}
