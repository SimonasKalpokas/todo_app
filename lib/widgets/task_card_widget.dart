import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/constants.dart';
import 'package:todo_app/models/timed_task.dart';
import 'package:todo_app/widgets/timer_widget.dart';

import '../models/base_task.dart';
import '../models/category.dart';
import '../providers/color_provider.dart';
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
    final appColors = Provider.of<ColorProvider>(context).appColors;
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
                  ? appColors.borderColor.withOpacity(0.4)
                  : categoryColor ?? appColors.borderColor),
          color: widget.task.isDone
              ? appColors.taskBackgroundColor.withOpacity(0.4)
              : appColors.taskBackgroundColor,
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
                          ? appColors.borderColor.withOpacity(0.4)
                          : Colors.transparent)
                      : categoryColor ?? appColors.taskBackgroundColor,
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
                                                ? appColors.secondaryColor
                                                    .withOpacity(0.4)
                                                : categoryColor),
                                      ),
                                    Text(
                                      widget.task.name,
                                      maxLines: isExpanded ? 2 : 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: widget.task.isDone
                                            ? appColors.secondaryColor
                                                .withOpacity(0.4)
                                            : appColors.secondaryColor,
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
                          Icon(Icons.repeat,
                              color: appColors.borderColor.withOpacity(0.75)),
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
                                    color:
                                        categoryColor ?? appColors.borderColor))
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
                                side: BorderSide(
                                    color:
                                        categoryColor ?? appColors.borderColor),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                activeColor:
                                    appColors.borderColor.withOpacity(0.4),
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
                                    color:
                                        appColors.borderColor.withOpacity(0.4),
                                    height: 1,
                                    width: 140,
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  if (widget.task.description.isNotEmpty)
                                    Text(widget.task.description,
                                        style: TextStyle(
                                            color: appColors.secondaryColor
                                                .withOpacity(0.75))),
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
                                          icon: Icon(
                                            Icons.delete,
                                            color: appColors.red,
                                          ),
                                          label: Text(
                                            'Delete',
                                            style: TextStyle(
                                                color: appColors.red,
                                                fontSize: 12),
                                          ),
                                        ),
                                        Container(
                                          color: appColors.borderColor
                                              .withOpacity(0.4),
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
                                            color: categoryColor ??
                                                appColors.borderColor,
                                          ),
                                          label: Text(
                                            'Edit',
                                            style: TextStyle(
                                                color: categoryColor ??
                                                    appColors.borderColor,
                                                fontSize: 12),
                                          ),
                                        ),
                                        Container(
                                          color: appColors.borderColor
                                              .withOpacity(0.4),
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
                                            color: categoryColor ??
                                                appColors.borderColor,
                                          ),
                                          label: Text(
                                            'Mark as complete',
                                            style: TextStyle(
                                                color: categoryColor ??
                                                    appColors.borderColor,
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
