import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/constants.dart';
import 'package:todo_app/models/timed_task.dart';
import 'package:todo_app/widgets/timer_widget.dart';

import '../models/base_task.dart';
import '../models/category.dart';
import '../screens/task_form_screen.dart';
import '../screens/tasks_view_screen.dart';
import '../services/firestore_service.dart';

class TaskCardWidget extends StatefulWidget {
  final BaseTask task;
  const TaskCardWidget({super.key, required this.task});

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    var firestoreService = Provider.of<FirestoreService>(context);
    var categories = Provider.of<Iterable<Category>>(context);
    var category = widget.task.categoryId != null
        ? categories.firstWhere((c) => c.id == widget.task.categoryId)
        : null;
    var categoryColor =
        category?.colorValue != null ? Color(category!.colorValue) : null;

    return GestureDetector(
      onTap: () {
        widget.task.type == TaskType.parent
            ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        TasksViewScreen(parentTask: widget.task)))
            : setState(() {
                isExpanded = !isExpanded;
              });
      },
      child: Container(
        padding: const EdgeInsets.only(right: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              color: widget.task.isDone
                  ? white2.withOpacity(0.4)
                  : categoryColor ?? white2),
          color: widget.task.isDone ? tasksColor.withOpacity(0.4) : tasksColor,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 10,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                  color: widget.task.isDone
                      ? (category != null
                          ? white2.withOpacity(0.4)
                          : Colors.transparent)
                      : categoryColor ?? tasksColor,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AnimatedSize(
                            duration: const Duration(milliseconds: 300),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: category == null ? 13 : 5),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (category != null)
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                            fontSize: fontSize * 0.6,
                                            color: widget.task.isDone
                                                ? white1.withOpacity(0.4)
                                                : categoryColor),
                                      ),
                                    Text(
                                      widget.task.name,
                                      maxLines: isExpanded ? 2 : 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: widget.task.isDone
                                            ? white1.withOpacity(0.4)
                                            : white1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (widget.task.reoccurrence !=
                                Reoccurrence.notRepeating &&
                            widget.task.isDone) // TODO: add time until refresh
                          Icon(Icons.repeat, color: white2.withOpacity(0.75)),
                        if (widget.task is TimedTask && !widget.task.isDone)
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: TimerWidget(
                                timedTask: widget.task as TimedTask),
                          ),
                        widget.task.type == TaskType.parent
                            ? Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(Icons.folder,
                                    color: categoryColor ?? white2))
                            : Checkbox(
                                onChanged: (bool? value) {
                                  firestoreService.updateTaskFields(
                                      widget.task.parentId, widget.task.id, {
                                    'lastDoneOn': value!
                                        ? clock.now().toIso8601String()
                                        : null
                                  });
                                },
                                value: widget.task.isDone,
                                side:
                                    BorderSide(color: categoryColor ?? white2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                activeColor: white2.withOpacity(0.4),
                              ),
                      ],
                    ),
                    if (!widget.task.isDone)
                      AnimatedSwitcher(
                        transitionBuilder: (child, animation) => SizeTransition(
                          sizeFactor: animation,
                          child: child,
                        ),
                        duration: const Duration(milliseconds: 300),
                        child: isExpanded
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    color: white2.withOpacity(0.4),
                                    height: 1,
                                    width: 140,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  if (widget.task.description.isNotEmpty)
                                    Text(widget.task.description,
                                        style: TextStyle(
                                            color: white1.withOpacity(0.75))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 0.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton.icon(
                                          style: TextButton.styleFrom(
                                              padding: const EdgeInsets.only(
                                                  right: 8)),
                                          onPressed: () {
                                            firestoreService.deleteTask(
                                                widget.task.parentId,
                                                widget.task.id);
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: red,
                                          ),
                                          label: const Text(
                                            'Delete',
                                            style: TextStyle(
                                                color: red, fontSize: 12),
                                          ),
                                        ),
                                        Container(
                                          color: white2.withOpacity(0.4),
                                          width: 1,
                                          height: 12,
                                        ),
                                        TextButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TaskFormScreen(
                                                          parentId: widget
                                                              .task.parentId,
                                                          task: widget.task)),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: categoryColor ?? white2,
                                          ),
                                          label: Text(
                                            'Edit',
                                            style: TextStyle(
                                                color: categoryColor ?? white2,
                                                fontSize: 12),
                                          ),
                                        ),
                                        Container(
                                          color: white2.withOpacity(0.4),
                                          width: 1,
                                          height: 12,
                                        ),
                                        TextButton.icon(
                                          onPressed: () {
                                            firestoreService.updateTaskFields(
                                                widget.task.parentId,
                                                widget.task.id, {
                                              'lastDoneOn':
                                                  clock.now().toIso8601String()
                                            });
                                          },
                                          icon: Icon(
                                            Icons.done,
                                            color: categoryColor ?? white2,
                                          ),
                                          label: Text(
                                            'Mark as complete',
                                            style: TextStyle(
                                                color: categoryColor ?? white2,
                                                fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            : Container(),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
