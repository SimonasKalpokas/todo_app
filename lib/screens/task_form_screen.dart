import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/providers/color_provider.dart';
import 'package:todo_app/services/firestore_service.dart';
import 'package:collection/collection.dart';

import '../repositories/task_repository.dart';
import '../widgets/add_icon_text_button.dart';
import '../widgets/dialogs/choose_category_dialog.dart';
import '../widgets/form_label.dart';
import '../widgets/not_implemented_alert.dart';

class TaskFormScreen extends StatelessWidget {
  final String? parentId;
  final Task? task;
  const TaskFormScreen({super.key, required this.parentId, this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task != null ? "Edit task" : "New task"),
        automaticallyImplyLeading: false,
      ),
      body: TaskForm(parentId: parentId, task: task),
    );
  }
}

class TaskForm extends StatefulWidget {
  final String? parentId;
  final Task? task;
  const TaskForm({super.key, required this.parentId, this.task});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  late final isReoccurringTabController = TabController(length: 2, vsync: this);
  late final reoccurrencePeriodTabController =
      TabController(length: 4, vsync: this);
  late final startingTabController = TabController(length: 4, vsync: this);
  late final typeTabController = TabController(length: 2, vsync: this);

  var isReoccurrenceOptionsExpanded = true;
  var isReoccurring = false;
  var isParent = false;
  var reoccurrence = Reoccurrence.notRepeating;
  DateTime? lastDoneOn;
  DateTime? doneUntil;
  var type = TaskType.checked;
  var totalTime = const Duration(hours: 1);
  Category? category;
  var showExtra = false;
  String? parentId;
  int index = 0;

  @override
  void initState() {
    final task = widget.task;
    if (task != null) {
      nameController.text = task.name;
      descriptionController.text = task.description;
      reoccurrence = task.reoccurrence;
      index = task.index;
      lastDoneOn = task.lastDoneOn;
      doneUntil = task.doneUntil;
      isReoccurringTabController.index =
          reoccurrence == Reoccurrence.notRepeating ? 0 : 1;
      isReoccurring = reoccurrence != Reoccurrence.notRepeating;
      isReoccurrenceOptionsExpanded = !isReoccurring;
      reoccurrencePeriodTabController.index =
          reoccurrence == Reoccurrence.weekly ? 1 : 0;

      typeTabController.index = widget.task!.type.index % 2;
      type = widget.task!.type;
    }
    parentId = widget.parentId;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    category = widget.task != null
        ? Provider.of<Iterable<Category>>(context)
            .firstWhereOrNull((c) => c.id == widget.task!.categoryId)
        : null;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    isReoccurringTabController.dispose();
    reoccurrencePeriodTabController.dispose();
    typeTabController.dispose();
    startingTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final taskRepository = Provider.of<TaskRepository>(context);
    final categories = Provider.of<Iterable<Category>>(context);
    final appColors = Provider.of<ColorProvider>(context).appColors;
    return Scaffold(
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0, 6.0, 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: appColors.primaryColor,
                    minimumSize: const Size.fromHeight(43)),
                child: Text(
                  "Save",
                  style: TextStyle(
                      color: appColors.buttonTextColor,
                      fontSize: 20,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  var form = _formKey.currentState!;
                  if (form.validate()) {
                    final task = widget.task;
                    if (task != null) {
                      task.name = nameController.text;
                      task.description = descriptionController.text;
                      task.lastDoneOn = lastDoneOn;
                      task.doneUntil = doneUntil;
                      task.reoccurrence = reoccurrence;
                      task.categoryId = category?.id;
                      await taskRepository.updateTask(task);
                      firestoreService.updateTask(task);
                    } else {
                      final task = Task(
                          isParent ? TaskType.parent : TaskType.checked,
                          parentId,
                          nameController.text,
                          descriptionController.text,
                          reoccurrence,
                          index,
                          category?.id);
                      await taskRepository.createTask(task);
                    }
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6.0, 0, 12.0, 8.0),
              child: TextButton(
                  style: TextButton.styleFrom(
                      minimumSize: const Size.fromHeight(43)),
                  child: Text("Cancel",
                      style: TextStyle(
                          color: appColors.primaryColor, fontSize: 20)),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12.0),
          child: ListView(
            children: [
              const FormLabel(text: "Task"),
              TextFormField(
                decoration: const InputDecoration(
                  hintText: "Enter task name",
                  contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8),
                ),
                style: TextStyle(fontSize: 20, color: appColors.secondaryColor),
                controller: nameController,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Name cannot be empty";
                  }
                  return null;
                },
              ),
              const FormLabel(text: "Description"),
              TextFormField(
                controller: descriptionController,
                keyboardType: TextInputType.multiline,
                style: TextStyle(fontSize: 18, color: appColors.secondaryColor),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(12, 8, 12, 8)),
                maxLines: 4,
                minLines: 3,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  setState(() {
                    showExtra = !showExtra;
                  });
                },
                child: Row(
                  children: [
                    showExtra
                        ? Icon(Icons.keyboard_arrow_down,
                            color: appColors.secondaryColor)
                        : Icon(Icons.keyboard_arrow_right,
                            color: appColors.secondaryColor),
                    Text(
                      "Advanced",
                      style: TextStyle(
                          fontSize: 16, color: appColors.secondaryColor),
                    ),
                  ],
                ),
              ),
              if (showExtra)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: appColors.taskBackgroundColor,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: appColors.borderColor),
                    ),
                    child: TabBar(
                      labelStyle: Theme.of(context)
                          .tabBarTheme
                          .labelStyle
                          ?.copyWith(fontSize: 16),
                      unselectedLabelStyle: Theme.of(context)
                          .tabBarTheme
                          .unselectedLabelStyle
                          ?.copyWith(fontSize: 16),
                      controller: isReoccurringTabController,
                      onTap: (index) {
                        setState(() {
                          isReoccurring = index == 1;
                        });
                        if (index == 1 &&
                            reoccurrence == Reoccurrence.notRepeating) {
                          setState(() {
                            reoccurrence = Reoccurrence.daily;
                          });
                        }
                      },
                      tabs: const [
                        Tab(child: Text('Normal')),
                        Tab(child: Text('Repeating')),
                      ],
                    ),
                  ),
                ),
              if (showExtra)
                Visibility(
                  visible: isReoccurring,
                  child: isReoccurrenceOptionsExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FormLabel(
                              text: "Repeat",
                              fontSize: 14,
                            ),
                            Container(
                              height: 35,
                              decoration: BoxDecoration(
                                color: appColors.taskBackgroundColor,
                                borderRadius: BorderRadius.circular(5),
                                border:
                                    Border.all(color: appColors.borderColor),
                              ),
                              child: TabBar(
                                onTap: (index) {
                                  if (index > 1) {
                                    reoccurrencePeriodTabController.index =
                                        reoccurrencePeriodTabController
                                            .previousIndex;
                                    notImplementedAlert(context);
                                  } else {
                                    setState(() {
                                      reoccurrence = Reoccurrence.values[index];
                                    });
                                  }
                                },
                                controller: reoccurrencePeriodTabController,
                                labelStyle: Theme.of(context)
                                    .tabBarTheme
                                    .labelStyle
                                    ?.copyWith(fontSize: 14),
                                unselectedLabelStyle: Theme.of(context)
                                    .tabBarTheme
                                    .unselectedLabelStyle
                                    ?.copyWith(fontSize: 14),
                                tabs: const [
                                  Tab(child: Text('Daily')),
                                  Tab(child: Text('Weekly')),
                                  Tab(child: Text('Monthly')),
                                  Tab(child: Text('Custom..')),
                                ],
                              ),
                            ),
                            const FormLabel(text: 'Starting'),
                            Container(
                              height: 22,
                              decoration: BoxDecoration(
                                color: appColors.taskBackgroundColor,
                                borderRadius: BorderRadius.circular(5),
                                border:
                                    Border.all(color: appColors.borderColor),
                              ),
                              child: TabBar(
                                controller: startingTabController,
                                labelStyle: Theme.of(context)
                                    .tabBarTheme
                                    .labelStyle
                                    ?.copyWith(fontSize: 11),
                                unselectedLabelStyle: Theme.of(context)
                                    .tabBarTheme
                                    .unselectedLabelStyle
                                    ?.copyWith(fontSize: 11),
                                tabs: const [
                                  Tab(child: Text('Today')),
                                  Tab(child: Text('Next week')),
                                  Tab(child: Text('Next month')),
                                  Tab(child: Text('Custom..')),
                                ],
                              ),
                            ),
                          ],
                        )
                      : DefaultTextStyle(
                          style: TextStyle(
                              fontSize: 11,
                              color: appColors.borderColor.withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nunito'),
                          child: Row(children: [
                            const Text("Repeats "),
                            Text(
                              reoccurrence.displayTitle,
                              style: TextStyle(color: appColors.borderColor),
                            ),
                            const Text(' starting '),
                            Text(
                              '8th of August, 2023',
                              style: TextStyle(color: appColors.borderColor),
                            ),
                            const Spacer(),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    isReoccurrenceOptionsExpanded = true;
                                  });
                                },
                                child: Text(
                                  'Modify',
                                  style: TextStyle(
                                      color: appColors.primaryColor,
                                      fontSize: 11),
                                ))
                          ]),
                        ),
                ),
              if (showExtra)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: appColors.taskBackgroundColor,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: appColors.borderColor),
                    ),
                    child: TabBar(
                      onTap: (index) {
                        if (isReoccurring && isReoccurrenceOptionsExpanded) {
                          setState(() {
                            isReoccurrenceOptionsExpanded = false;
                          });
                        }
                      },
                      controller: typeTabController,
                      tabs: const [
                        Tab(child: Text('Checklist')),
                        Tab(child: Text('Timed')),
                      ],
                    ),
                  ),
                ),
              if (showExtra)
                AddIconTextButton(
                  iconData: Icons.add,
                  label: "Assign a category",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => ChooseCategoryDialog(
                          categories: categories, category: category),
                    ).then((value) => setState(() {
                          category = value;
                        }));
                  },
                  trailing: category != null
                      ? Text(category!.name,
                          style: TextStyle(color: Color(category!.colorValue)))
                      : null,
                ),
              if (showExtra && widget.task == null)
                AddIconTextButton(
                  iconData: Icons.folder,
                  label: "Make into a list",
                  onPressed: () {
                    setState(() {
                      isParent = !isParent;
                    });
                  },
                  trailing: Checkbox(
                      value: isParent,
                      activeColor: appColors.primaryColorLight,
                      checkColor: appColors.taskBackgroundColor,
                      onChanged: (value) {
                        setState(() {
                          isParent = value!;
                        });
                      }),
                ),
              if (showExtra && widget.task?.type == TaskType.parent)
                AddIconTextButton(
                  iconData: Icons.folder,
                  label: "Mark parent task as completed",
                  onPressed: () {
                    // TODO: move logic somewhere else
                    DateTime? newLastDoneOn;
                    DateTime? newDoneUntil;
                    if (lastDoneOn == null) {
                      final now = clock.now();
                      newLastDoneOn = now;
                      newDoneUntil = reoccurrence.calculateDoneUntil(now);
                    }
                    setState(() {
                      lastDoneOn = newLastDoneOn;
                      doneUntil = newDoneUntil;
                    });
                  },
                  trailing: Checkbox(
                      value: lastDoneOn != null,
                      activeColor: appColors.primaryColorLight,
                      checkColor: appColors.taskBackgroundColor,
                      onChanged: (bool? value) {
                        // TODO: move logic somewhere else
                        DateTime? newLastDoneOn;
                        DateTime? newDoneUntil;
                        if (value!) {
                          final now = clock.now();
                          newLastDoneOn = now;
                          newDoneUntil = reoccurrence.calculateDoneUntil(now);
                        }
                        setState(() {
                          lastDoneOn = newLastDoneOn;
                          doneUntil = newDoneUntil;
                        });
                      }),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
