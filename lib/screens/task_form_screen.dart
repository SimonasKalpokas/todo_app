import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/custom_icons.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/checked_task.dart';
import 'package:todo_app/models/timed_task.dart';
import 'package:todo_app/services/firestore_service.dart';
import 'package:todo_app/models/category.dart';

class TaskFormScreen extends StatelessWidget {
  final BaseTask? task;
  final List<Category> categories;
  const TaskFormScreen({Key? key, this.task, required this.categories})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New task"),
        automaticallyImplyLeading: false,
      ),
      body: TaskForm(task: task, categories: categories),
    );
  }
}

class TaskForm extends StatefulWidget {
  final BaseTask? task;
  final List<Category> categories;
  const TaskForm({Key? key, this.task, required this.categories})
      : super(key: key);

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final hoursController = TextEditingController(text: '0');
  final minutesController = TextEditingController(text: '0');

  late final isReoccurringTabController = TabController(length: 2, vsync: this);
  late final reoccurrencePeriodTabController =
      TabController(length: 4, vsync: this);
  late final startingTabController = TabController(length: 4, vsync: this);
  late final typeTabController = TabController(length: 2, vsync: this);

  var isReoccurrenceOptionsExpanded = true;
  var isTimedOptionsExpanded = true;
  var isReoccurring = false;
  var isTimed = false;
  var reoccurrence = Reoccurrence.notRepeating;
  var type = TaskType.checked;
  var totalTime = const Duration(hours: 1);
  String? categoryId;

  @override
  void initState() {
    if (widget.task != null) {
      nameController.text = widget.task!.name;
      descriptionController.text = widget.task!.description;
      reoccurrence = widget.task!.reoccurrence;
      type = widget.task!.type;
      if (type == TaskType.timed) {
        totalTime = (widget.task! as TimedTask).totalTime;
      }
      categoryId = widget.task!.categoryId;
    }
    super.initState();
  }

  @override
  void dispose() {
    isReoccurringTabController.dispose();
    reoccurrencePeriodTabController.dispose();
    typeTabController.dispose();
    startingTabController.dispose();
    super.dispose();
  }

  // TODO: extract title + input to separate widget
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    return Scaffold(
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 0, 6.0, 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC36A),
                    minimumSize: const Size.fromHeight(43)),
                child: const Text(
                  "Save",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  var form = _formKey.currentState!;
                  if (form.validate()) {
                    totalTime = Duration(
                        hours: int.parse(hoursController.text),
                        minutes: int.parse(minutesController.text));
                    if (widget.task != null) {
                      widget.task!.name = nameController.text;
                      widget.task!.description = descriptionController.text;
                      widget.task!.reoccurrence = reoccurrence;
                      widget.task!.type =
                          isTimed ? TaskType.timed : TaskType.checked;
                      if (widget.task!.type == TaskType.timed) {
                        (widget.task! as TimedTask).totalTime = totalTime;
                      }
                      widget.task!.categoryId = categoryId;
                      firestoreService.updateTask(widget.task!);
                    } else {
                      BaseTask? task;
                      switch (isTimed ? TaskType.timed : TaskType.checked) {
                        case TaskType.checked:
                          task = CheckedTask(nameController.text,
                              descriptionController.text, reoccurrence);
                          break;
                        case TaskType.timed:
                          task = TimedTask(
                              nameController.text,
                              descriptionController.text,
                              reoccurrence,
                              totalTime);
                          break;
                      }
                      task.categoryId = categoryId;
                      firestoreService.addTask(task);
                    }
                    Navigator.pop(context);
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
                  child: const Text("Cancel",
                      style: TextStyle(color: Color(0xFFFFC36A), fontSize: 20)),
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
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: ListView(
            children: [
              const FormLabel(text: "Task"),
              TextFormField(
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
                maxLines: 4,
                minLines: 3,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFFFFC36A)),
                  ),
                  child: TabBar(
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
                      if (isTimed && isTimedOptionsExpanded) {
                        setState(() {
                          isTimedOptionsExpanded = false;
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
              Visibility(
                visible: isReoccurring,
                child: isReoccurrenceOptionsExpanded
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FormLabel(text: "Repeat"),
                          Container(
                            height: 22,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border:
                                  Border.all(color: const Color(0xFFFFC36A)),
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
                                  ?.copyWith(fontSize: 11),
                              unselectedLabelStyle: Theme.of(context)
                                  .tabBarTheme
                                  .unselectedLabelStyle
                                  ?.copyWith(fontSize: 11),
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
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                              border:
                                  Border.all(color: const Color(0xFFFFC36A)),
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
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFAAAAAA),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito'),
                        child: Row(children: [
                          const Text("Repeats "),
                          Text(
                            reoccurrence.displayTitle,
                            style: const TextStyle(color: Color(0xFF666666)),
                          ),
                          const Text(' starting '),
                          const Text(
                            '8th of August, 2023',
                            style: TextStyle(color: Color(0xFF666666)),
                          ),
                          const Spacer(),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  isReoccurrenceOptionsExpanded = true;
                                });
                                if (isTimed && isTimedOptionsExpanded) {
                                  setState(() {
                                    isTimedOptionsExpanded = false;
                                  });
                                }
                              },
                              child: const Text(
                                'Modify',
                                style: TextStyle(
                                    color: Color(0xFFFFC36A), fontSize: 11),
                              ))
                        ]),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: const Color(0xFFFFC36A)),
                  ),
                  child: TabBar(
                    onTap: (index) {
                      setState(() {
                        isTimed = index == 1;
                      });
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
              Visibility(
                visible: isTimed,
                child: isTimedOptionsExpanded
                    ? Row(children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: SizedBox(
                            width: 44,
                            height: 22,
                            child: TextFormField(
                              controller: hoursController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                        const FormLabel(text: "Hours"),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 12.0),
                          child: SizedBox(
                            width: 44,
                            height: 22,
                            child: TextFormField(
                              controller: minutesController,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ),
                        const FormLabel(text: "Minutes"),
                      ])
                    : DefaultTextStyle(
                        style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFAAAAAA),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito'),
                        child: Row(children: [
                          Text(
                              '${hoursController.text} hours ${minutesController.text} minutes',
                              style: const TextStyle(color: Color(0xFF666666))),
                          const Text(' to complete'),
                          const Spacer(),
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  isTimedOptionsExpanded = true;
                                });
                                if (isReoccurring &&
                                    isReoccurrenceOptionsExpanded) {
                                  setState(() {
                                    isReoccurrenceOptionsExpanded = false;
                                  });
                                }
                              },
                              child: const Text(
                                'Modify',
                                style: TextStyle(
                                    color: Color(0xFFFFC36A), fontSize: 11),
                              ))
                        ]),
                      ),
              ),
              const AddIconTextButton(
                iconData: Icons.notifications_active,
                label: "Set reminder",
              ),
              AddIconTextButton(
                iconData: Icons.add,
                label: "Assign a category",
                onPressed: (() {
                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('Select category'),
                            content: DropdownButton<String>(
                              value: categoryId,
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('None'),
                                ),
                                ...widget.categories
                                    .map((c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Text(c.name),
                                        ))
                              ],
                              onChanged: (value) {
                                setState(() {
                                  categoryId = value;
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Ok')),
                            ],
                          ));
                }),
                trailing: categoryId != null
                    ? Text(
                        widget.categories
                            .firstWhere((c) => c.id == categoryId)
                            .name,
                        style: TextStyle(
                            color: Color(widget.categories
                                .firstWhere((c) => c.id == categoryId)
                                .color)))
                    : null,
              ),
              const AddIconTextButton(
                iconData: CustomIcons.sublist,
                label: "Assign to parent task",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddIconTextButton extends StatelessWidget {
  final IconData iconData;
  final String label;
  final Widget? trailing;
  final VoidCallback? onPressed;
  const AddIconTextButton(
      {super.key,
      required this.iconData,
      required this.label,
      this.trailing,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: onPressed ??
                () {
                  notImplementedAlert(context);
                },
            style: const ButtonStyle(alignment: Alignment.centerLeft),
            icon: Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(iconData, color: const Color(0xFF666666), size: 16),
            ),
            label: Text(label,
                style: const TextStyle(color: Color(0xFF666666), fontSize: 13)),
          ),
          const Spacer(),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class FormLabel extends StatelessWidget {
  final String text;
  const FormLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black, fontSize: 12),
      ),
    );
  }
}

void notImplementedAlert(BuildContext context) {
  showDialog(
      context: context,
      builder: (context) =>
          const AlertDialog(content: Text("oops not implemented")));
}
