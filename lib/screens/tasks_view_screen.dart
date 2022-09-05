import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/timed_task.dart';
import 'package:todo_app/services/firestore_service.dart';

import '../models/checked_task.dart';
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
                      'lastCompleted':
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

class TimerWidget extends StatefulWidget {
  final TimedTask timedTask;
  const TimerWidget({Key? key, required this.timedTask}) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  Timer? timer;
  FirestoreService? firestoreService;

  @override
  void didChangeDependencies() {
    firestoreService = Provider.of<FirestoreService>(context);
    if (widget.timedTask.executing) {
      var remainingTime = widget.timedTask.remainingTime -
          clock.now().difference(widget.timedTask.lastExecution!);
      if (remainingTime <= Duration.zero) {
        firestoreService!
            .updateTaskFields(TaskType.timed, widget.timedTask.id, {
          'lastCompleted': clock.now().toString(),
          'remainingTime': Duration.zero.toString(),
          'executing': false,
        });
      } else {
        setState(() {
          widget.timedTask.remainingTime = remainingTime;
        });
      }
    }
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.timedTask.executing &&
          widget.timedTask.remainingTime.inSeconds > 0) {
        setState(() {
          widget.timedTask.remainingTime -= const Duration(seconds: 1);
        });
        if (widget.timedTask.remainingTime.inSeconds <= 0) {
          firestoreService!
              .updateTaskFields(TaskType.timed, widget.timedTask.id, {
            'lastCompleted': clock.now().toString(),
            'remainingTime': Duration.zero.toString(),
            'executing': false,
          });
          timer.cancel();
        }
      }
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    timer!.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TimerWidget oldWidget) {
    if (oldWidget.timedTask.executing && widget.timedTask.executing) {
      setState(() {
        widget.timedTask.remainingTime = oldWidget.timedTask.remainingTime;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var task = widget.timedTask;
    int hours = task.remainingTime.inHours;
    int mins = task.remainingTime.inMinutes - hours * 60;
    int secs = task.remainingTime.inSeconds - hours * 3600 - mins * 60;
    return task.status == Status.done
        ? Checkbox(value: true, onChanged: (_) {})
        : TextButton(
            onPressed: () {
              Map<String, dynamic> fields = {
                'executing': !task.executing,
                'remainingTime': task.remainingTime.toString(),
              };
              if (!task.reoccurrence.isActiveNow(task.startOfExecution)) {
                fields.addAll({
                  'startOfExecution': clock.now().toIso8601String(),
                });
              }
              if (!task.executing) {
                fields.addAll({'lastExecution': clock.now().toIso8601String()});
              }
              firestoreService!.updateTaskFields(
                  TaskType.timed, widget.timedTask.id, fields);
            },
            child: Text('$hours:$mins:$secs'),
          );
  }
}
