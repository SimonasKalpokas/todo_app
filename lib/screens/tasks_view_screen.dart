import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/repositories/task_repository.dart';
import 'package:todo_app/services/firestore_service.dart';
import 'package:todo_app/widgets/movable_list/movable_list_item.dart';
import 'package:todo_app/widgets/task_card_widget.dart';

import '../providers/color_provider.dart';
import '../providers/selection_provider.dart';
import '../widgets/dialogs/category_settings_dialog.dart';
import '../widgets/dialogs/choose_main_collection_dialog.dart';
import 'task_form_screen.dart';

enum TaskListCommand {
  highlightRandomTask,
}

class TasksViewScreen extends StatefulWidget {
  final Task? parentTask;
  final List<String> parentIds;
  const TasksViewScreen(
      {super.key, required this.parentTask, required this.parentIds});

  @override
  State<TasksViewScreen> createState() => _TasksViewScreenState();
}

class _TasksViewScreenState extends State<TasksViewScreen> {
  var showDone = false;
  final taskListCommandController = StreamController<TaskListCommand>();

  @override
  Widget build(BuildContext context) {
    final parentTask = widget.parentTask;
    final selectionProvider = Provider.of<SelectionProvider<Task>>(context);
    final taskRepository = Provider.of<TaskRepository>(context);
    final appColors = Provider.of<ColorProvider>(context).appColors;
    var undoneTasks = taskRepository.watchUndoneTasks(parentTask?.id);
    var doneTasks = taskRepository.watchDoneTasks(parentTask?.id);
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
              taskListCommandController
                  .add(TaskListCommand.highlightRandomTask);
            },
            icon: Icon(
              Icons.view_in_ar_outlined,
              color: appColors.primaryColorLight,
            ),
          ),
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
            TasksListView(
              tasks: undoneTasks,
              parentIds: widget.parentIds,
              commands: taskListCommandController.stream,
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
            TasksListView(
              tasks: doneTasks,
              parentIds: widget.parentIds,
              visible: showDone,
            ),
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
                        taskRepository.deleteTask(item.value.id);
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
                    var parentIds = widget.parentIds;
                    if (parentTask != null) {
                      parentIds.add(parentTask.id);
                    }
                    if (!await taskRepository.moveTasks(
                      selectionProvider.selectedItems.map((item) => item.value),
                      parentIds,
                    )) {
                      if (context.mounted) {
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

class TasksListView extends StatefulWidget {
  final Stream<Iterable<Task>> tasks;
  final Stream<TaskListCommand>? commands;
  final List<String> parentIds;
  final bool visible;

  const TasksListView(
      {super.key,
      required this.tasks,
      required this.parentIds,
      this.commands,
      this.visible = true});

  @override
  State<TasksListView> createState() => _TasksListViewState();
}

class _TasksListViewState extends State<TasksListView> {
  Stream<Iterable<Task>> get tasks => widget.tasks;
  bool get visible => widget.visible;

  int? highlightedTaskIndex;
  Iterable<Task> _latestTasks = [];

  @override
  void initState() {
    super.initState();

    if (widget.commands != null) {
      widget.commands!.listen((command) {
        if (command == TaskListCommand.highlightRandomTask) {
          if (_latestTasks.isNotEmpty) {
            setState(() {
              highlightedTaskIndex = Random().nextInt(_latestTasks.length);
            });
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Iterable<Task>>(
      stream: tasks,
      builder: (context, AsyncSnapshot<Iterable<Task>> snapshot) {
        _latestTasks = snapshot.data ?? [];

        if (!visible) {
          return const SizedBox();
        }
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ReorderableListView(
          reverse: true,
          buildDefaultDragHandles: false,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final oldTask = snapshot.data!.elementAt(oldIndex);
            final newTask = snapshot.data!.elementAt(newIndex);
            final firestoreService =
                Provider.of<FirestoreService>(context, listen: false);
            firestoreService.reorderTask(
                oldTask.parentId, oldTask.id, oldTask.index, newTask.index);
          },
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: snapshot.data!
              .mapIndexed((index, task) => ReorderableDelayedDragStartListener(
                    key: Key(task.id),
                    index: index,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 4.0,
                      ),
                      child: MovableListItem(
                          selectionItem: SelectionItem(task),
                          selectionProvider:
                              Provider.of<SelectionProvider<Task>>(context),
                          child: TaskCardWidget(
                              task: task,
                              parentIds: widget.parentIds,
                              highlighted: index == highlightedTaskIndex)),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}
