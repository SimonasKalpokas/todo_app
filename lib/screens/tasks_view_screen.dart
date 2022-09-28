import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/timed_task.dart';
import 'package:todo_app/services/firestore_service.dart';

import '../widgets/timer_widget.dart';
import 'task_form_screen.dart';

class TasksViewScreen extends StatelessWidget {
  const TasksViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    var tasks = firestoreService.getTasks();
    var tasks1 = firestoreService.getTasks();
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks:")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TasksListView(
              condition: (task) => !task.isDone,
              tasks: tasks,
            ),
            DoneTasksListView(tasks: tasks1),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TaskFormScreen()),
          );
        },
        tooltip: 'Add a task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class DoneTasksListView extends StatefulWidget {
  final Stream<Iterable<BaseTask>> tasks;
  const DoneTasksListView({super.key, required this.tasks});

  @override
  State<DoneTasksListView> createState() => DoneTasksListViewState();
}

class DoneTasksListViewState extends State<DoneTasksListView> {
  bool showDone = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 8.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                showDone = !showDone;
              });
            },
            child: Row(
              children: [
                const Text(
                  "Completed",
                  style: TextStyle(fontSize: 18, color: Color(0xFF787878)),
                ),
                showDone
                    ? const Icon(Icons.keyboard_arrow_up,
                        color: Color(0xFF787878))
                    : const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF787878))
              ],
            ),
          ),
        ),
        showDone
            ? TasksListView(
                condition: (task) => task.isDone,
                tasks: widget.tasks,
              )
            : Container(
                height: 20,
              ),
      ],
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
          physics: const NeverScrollableScrollPhysics(),
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
      margin: const EdgeInsets.fromLTRB(15, 8.0, 15, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Color(task.isDone ? 0xFFD7D7D7 : 0xFFFFD699)),
      ),
      color: task.isDone ? const Color(0xFFF6F6F6) : Colors.white,
      child: Dismissible(
        key: ObjectKey(task),
        onDismissed: ((direction) {
          firestoreService.deleteTask(task.id);
        }),
        direction: DismissDirection.endToStart,
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
          child: const Icon(Icons.delete_sweep),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 20),
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              task.name,
              style: TextStyle(
                  fontSize: 18,
                  color: task.isDone ? const Color(0xFFDBDBDB) : Colors.black),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TaskFormScreen(task: task)),
            );
          },
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              task.type == TaskType.timed
                  ? task.isDone
                      ? const Icon(Icons.repeat, color: Color(0xFF5F5F5F))
                      : TimerWidget(timedTask: task as TimedTask)
                  : Container(),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: Checkbox(
                    onChanged: (bool? value) {
                      if (value == null) {
                        throw UnimplementedError();
                      }
                      firestoreService.updateTaskFields(task.id, {
                        'lastDoneOn':
                            value ? clock.now().toIso8601String() : null
                      });
                    },
                    value: task.isDone,
                    side: const BorderSide(color: Color(0xFFFFD699)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    activeColor: const Color(0xFFD9D9D9),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
