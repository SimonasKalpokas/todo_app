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
    var doneTasks = firestoreService.getTasks(parentTask?.id, true);
    var undoneTasks = firestoreService.getTasks(parentTask?.id, false);
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
              tasks: undoneTasks,
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
              tasks: doneTasks,
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

class TasksListView extends StatefulWidget {
  final bool Function(BaseTask)? condition;
  final Stream<List<BaseTask>> tasks;
  final bool visible;

  const TasksListView(
      {Key? key, this.condition, required this.tasks, this.visible = true})
      : super(key: key);

  @override
  State<TasksListView> createState() => _TasksListViewState();
}

class _TasksListViewState extends State<TasksListView> {
  List<BaseTask> tasks = [];

  void _onReorder(int oldIndex, int newIndex) {
    var firestoreService =
        Provider.of<FirestoreService>(context, listen: false);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    print("Moving ${tasks[oldIndex].name} from $oldIndex to $newIndex");
    // setState(() {
    //   final task = tasks.removeAt(oldIndex);
    //   tasks.insert(newIndex, task);
    // });
    setState(() {
      final task = tasks.removeAt(oldIndex);
      tasks.insert(newIndex, task);
    });

    // if (newIndex > oldIndex) {
    //   for (var i = oldIndex; i < newIndex; i++) {
    //     print(
    //         "Updating ${tasks[i].name} with index ${tasks[i].index} to index $i");
    //     tasks[i].index = i + 1;
    //     tasks[i + 1].index = i;
    //     firestoreService.updateTask(tasks[i]);
    //     firestoreService.updateTask(tasks[i + 1]);
    //     var temp = tasks[i];
    //     tasks[i] = tasks[i + 1];
    //     tasks[i + 1] = temp;
    //     // tasks[i].index = i;
    //     // firestoreService.updateTask(tasks[i]);
    //   }
    // } else {
    //   for (var i = oldIndex; i > newIndex; i--) {
    //     print(
    //         "Updating ${tasks[i].name} with index ${tasks[i].index} to index $i");
    //     var temp = tasks[i];
    //     tasks[i] = tasks[i - 1];
    //     tasks[i - 1] = temp;
    //     // tasks[i].index = i;
    //     // firestoreService.updateTask(tasks[i]);
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BaseTask>>(
      stream: widget.tasks,
      builder: (context, AsyncSnapshot<List<BaseTask>> snapshot) {
        if (!widget.visible) {
          return const SizedBox();
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        tasks = snapshot.data!.toList();
        return ReorderableListView(
          onReorder: ((oldIndex, newIndex) async {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            setState(() {
              var task = snapshot.data!.removeAt(oldIndex);
              snapshot.data!.insert(newIndex, task);
            });
            if (newIndex > oldIndex) {
              for (var i = oldIndex; i <= newIndex; i++) {
                await Provider.of<FirestoreService>(context, listen: false)
                    .updateTaskFields(
                        tasks[i].parentId, tasks[i].id, {'index': i});
              }
            } else {
              for (var i = oldIndex; i >= newIndex; i--) {
                await Provider.of<FirestoreService>(context, listen: false)
                    .updateTaskFields(
                        tasks[i].parentId, tasks[i].id, {'index': i});
              }
            }
          }),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: snapshot.data!.map(
            (task) {
              if (widget.condition != null && !widget.condition!(task)) {
                return Container(key: Key(task.id!));
              }
              // TODO: make task.id mandatory
              return TaskCardWidget(
                  key: Key(task.id!), task: task, onReorder: _onReorder);
            },
          ).toList(),
        );
      },
    );
  }
}
