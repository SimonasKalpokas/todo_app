import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/services/firestore_service.dart';
import 'package:todo_app/widgets/task_card_widget.dart';

import '../widgets/dialogs/choose_main_collection_dialog.dart';
import 'task_form_screen.dart';

class TasksViewScreen extends StatefulWidget {
  final BaseTask? parentTask;
  const TasksViewScreen({Key? key, required this.parentTask}) : super(key: key);

  @override
  State<TasksViewScreen> createState() => _TasksViewScreenState();
}

class _TasksViewScreenState extends State<TasksViewScreen> {
  var showDone = false;

  @override
  Widget build(BuildContext context) {
    final parentTask = widget.parentTask;
    final firestoreService = Provider.of<FirestoreService>(context);
    var tasks = firestoreService.getTasks(parentTask?.id).asBroadcastStream();
    return Scaffold(
      appBar: AppBar(
        title: Text("${parentTask?.name ?? "Tasks"}:"),
        leading: parentTask == null
            ? null
            : IconButton(
                icon:
                    const Icon(Icons.keyboard_arrow_left, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog<bool?>(
                      context: context,
                      builder: (context) => const ChooseMainCollectionDialog())
                  .then(
                (hasChanged) {
                  if (hasChanged ?? false) {
                    setState(() {});
                  }
                },
              );
            },
            icon: const Icon(
              Icons.settings,
              color: Color(0xFF666666),
            ),
          ),
          parentTask != null
              ? IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskFormScreen(
                            parentId: parentTask.parentId, task: parentTask),
                      ),
                    );
                  },
                )
              : Container()
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TasksListView(
              condition: (task) => !task.isDone,
              tasks: tasks,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 8.0),
              child: InkWell(
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
            TasksListView(
              tasks: tasks,
              condition: (task) => task.isDone,
              visible: showDone,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TaskFormScreen(parentId: parentTask?.id)),
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
  final bool visible;

  const TasksListView(
      {Key? key, this.condition, required this.tasks, this.visible = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Iterable<BaseTask>>(
      stream: tasks,
      builder: (context, AsyncSnapshot<Iterable<BaseTask>> snapshot) {
        if (!visible) {
          return const SizedBox();
        }
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
              // TODO: make task.id mandatory
              return TaskCardWidget(key: Key(task.id!), task: task);
            },
          ).toList(),
        );
      },
    );
  }
}
