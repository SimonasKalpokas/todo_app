import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/services/firestore_service.dart';
import 'package:todo_app/widgets/movable_list/movable_list_item.dart';
import 'package:todo_app/widgets/task_card_widget.dart';

import '../providers/color_provider.dart';
import '../providers/selection_provider.dart';
import '../widgets/dialogs/category_settings_dialog.dart';
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
    final selectionProvider = Provider.of<SelectionProvider<BaseTask>>(context);
    final appColors = Provider.of<ColorProvider>(context).appColors;
    var undoneTasks = firestoreService.getTasks(parentTask?.id, true);
    var doneTasks = firestoreService.getTasks(parentTask?.id, false);
    return Scaffold(
      appBar: AppBar(
        title: selectionProvider.isSelecting
            ? Text("${selectionProvider.selectedItems.length} tasks selected")
            : Text("${parentTask?.name ?? "Tasks"}:"),
        leading: parentTask == null
            ? null
            : IconButton(
                icon: Icon(Icons.keyboard_arrow_left,
                    color: appColors.primaryColorLight),
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
            icon: Icon(
              Icons.settings,
              color: appColors.primaryColorLight,
            ),
          ),
          IconButton(
            onPressed: () {
              showDialog<bool?>(
                  context: context,
                  builder: (context) => CategorySettingsDialog(
                      categories: Provider.of<Iterable<Category>>(context,
                          listen: false)));
            },
            icon: Icon(
              Icons.category,
              color: appColors.primaryColorLight,
            ),
          ),
          parentTask != null
              ? IconButton(
                  icon: Icon(Icons.edit, color: appColors.primaryColorLight),
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
            TasksListView(tasks: undoneTasks),
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
                    Text(
                      "Completed",
                      style: TextStyle(
                          fontSize: 18,
                          color: appColors.borderColor.withOpacity(0.5)),
                    ),
                    showDone
                        ? Icon(Icons.keyboard_arrow_up,
                            color: appColors.borderColor.withOpacity(0.5))
                        : Icon(Icons.keyboard_arrow_down,
                            color: appColors.borderColor.withOpacity(0.5)),
                  ],
                ),
              ),
            ),
            TasksListView(tasks: doneTasks, visible: showDone),
          ],
        ),
      ),
      floatingActionButton: selectionProvider.isSelecting
          ? Container()
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          TaskFormScreen(parentId: parentTask?.id)),
                );
              },
              backgroundColor: appColors.headerFooterColor,
              tooltip: 'Add a task',
              child: Icon(Icons.add, color: appColors.primaryColor),
            ),
      persistentFooterButtons: selectionProvider.state ==
              SelectionState.inactive
          ? null
          : [
              if (selectionProvider.isSelecting)
                TextButton(
                  onPressed: () {
                    selectionProvider.clearSelection();
                  },
                  child: const Text("Cancel"),
                ),
              if (selectionProvider.isSelecting)
                TextButton(
                  onPressed: () {
                    deleteAndClearSelection() {
                      for (var item in selectionProvider.selectedItems) {
                        firestoreService.deleteTask(
                            item.value.parentId, item.value.id);
                      }
                      selectionProvider.clearSelection();
                    }

                    if (selectionProvider.selectedItems
                        .any((item) => item.value.type == TaskType.parent)) {
                      showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Warning"),
                          content: Text(
                              "When deleting a parent task, all of its children will be deleted as well.",
                              style:
                                  TextStyle(color: appColors.secondaryColor)),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Ok")),
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel")),
                          ],
                        ),
                      ).then(
                        (bool? value) {
                          if (value ?? false) {
                            deleteAndClearSelection();
                          }
                        },
                      );
                    } else {
                      deleteAndClearSelection();
                    }
                  },
                  child: const Text("Delete selected"),
                ),
              if (selectionProvider.isSelecting)
                TextButton(
                  onPressed: () {
                    selectionProvider.setStateMoving();
                  },
                  child: const Text("Move selected"),
                ),
              if (selectionProvider.state == SelectionState.moving)
                TextButton(
                  onPressed: () {
                    selectionProvider.clearSelection();
                  },
                  child: const Text("Cancel"),
                ),
              if (selectionProvider.state == SelectionState.moving)
                TextButton(
                  onPressed: () async {
                    if (!await firestoreService.moveTasks(
                        selectionProvider.selectedItems
                            .map((item) => item.value),
                        parentTask?.id)) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Cannot move selected tasks here"),
                          ),
                        );
                      }
                    } else {
                      selectionProvider.clearSelection();
                    }
                  },
                  child: const Text("Move here"),
                ),
            ],
    );
  }
}

class TasksListView extends StatelessWidget {
  final Stream<Iterable<BaseTask>> tasks;
  final bool visible;

  const TasksListView({Key? key, required this.tasks, this.visible = true})
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
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 4.0,
                ),
                child: MovableListItem(
                    selectionItem: SelectionItem(task),
                    selectionProvider:
                        Provider.of<SelectionProvider<BaseTask>>(context),
                    child: TaskCardWidget(key: Key(task.id), task: task)),
              );
            },
          ).toList(),
        );
      },
    );
  }
}
