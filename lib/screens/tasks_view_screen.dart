import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/constants.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/services/firestore_service.dart';
import 'package:todo_app/widgets/movable_list/movable_list_item.dart';
import 'package:todo_app/widgets/task_card_widget.dart';

import '../providers/selection_provider.dart';
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
    final selectionProvider = Provider.of<SelectionProvider>(context);
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
          IconButton(
            onPressed: () {
              showDialog<bool?>(
                  context: context,
                  builder: (context) => CategorySettingsDialog(
                      categories: Provider.of<Iterable<Category>>(context,
                          listen: false)));
            },
            icon: const Icon(
              Icons.category,
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
              tooltip: 'Add a task',
              child: const Icon(Icons.add),
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
                    for (var item in selectionProvider.selectedItems) {
                      firestoreService.deleteTask(item.parentId, item.id);
                    }
                    selectionProvider.clearSelection();
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
                        selectionProvider.selectedItems, parentTask?.id)) {
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

class CategorySettingsDialog extends StatefulWidget {
  final Iterable<Category> categories;

  const CategorySettingsDialog({Key? key, required this.categories})
      : super(key: key);

  @override
  State<CategorySettingsDialog> createState() => _CategorySettingsDialogState();
}

class _CategorySettingsDialogState extends State<CategorySettingsDialog> {
  final categoryNameController = TextEditingController();
  Category? category;

  @override
  void dispose() {
    categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Category settings'),
        content: Column(
          children: [
            DropdownButton<Category?>(
              value: category,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('None'),
                ),
                ...widget.categories.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        c.name,
                        style: TextStyle(color: Color(c.colorValue)),
                      ),
                    ))
              ],
              onChanged: (value) {
                setState(() {
                  category = value;
                });
              },
            ),
            TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: 'New category name'),
              controller: categoryNameController,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (category != null &&
                    categoryNameController.text.isNotEmpty) {
                  category!.name = categoryNameController.text;
                  Provider.of<FirestoreService>(context, listen: false)
                      .updateCategory(category!);
                }
                Navigator.pop(context);
              },
              child: const Text('OK')),
          TextButton(
              onPressed: () {
                if (category != null) {
                  Provider.of<FirestoreService>(context, listen: false)
                      .deleteCategory(category!);
                }
                Navigator.pop(context);
              },
              child: const Text('Delete')),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ]);
  }
}

class ChooseMainCollectionDialog extends StatefulWidget {
  const ChooseMainCollectionDialog({
    Key? key,
  }) : super(key: key);

  @override
  State<ChooseMainCollectionDialog> createState() =>
      _ChooseMainCollectionDialogState();
}

class _ChooseMainCollectionDialogState
    extends State<ChooseMainCollectionDialog> {
  final mainCollectionController = TextEditingController();

  @override
  void dispose() {
    mainCollectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Choose main collection'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Main collection'),
          controller: mainCollectionController,
        ),
        actions: [
          TextButton(
              onPressed: () async {
                var res =
                    await Provider.of<FirestoreService>(context, listen: false)
                        .setMainCollection(mainCollectionController.text);

                if (!mounted) {
                  return;
                }
                Navigator.pop(context, res);
              },
              child: const Text('OK')),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ]);
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
                  style:
                      TextStyle(fontSize: fontSize, color: Color(0xFF787878)),
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
                    selectionItem:
                        SelectionItem(task.id, parentId: task.parentId),
                    child: TaskCardWidget(key: Key(task.id), task: task)),
              );
            },
          ).toList(),
        );
      },
    );
  }
}
