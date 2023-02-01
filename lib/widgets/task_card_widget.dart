import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/timed_task.dart';
import 'package:todo_app/widgets/list_drag_target.dart';
import 'package:todo_app/widgets/timer_widget.dart';

import '../models/base_task.dart';
import '../screens/task_form_screen.dart';
import '../screens/tasks_view_screen.dart';
import '../services/firestore_service.dart';

class TaskCardWidget extends StatefulWidget {
  final BaseTask task;
  final void Function(int, int) onReorder;
  const TaskCardWidget(
      {super.key, required this.task, required this.onReorder});

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget> {
  bool isExpanded = false;
  Widget? ghost;

  @override
  Widget build(BuildContext context) {
    var firestoreService = Provider.of<FirestoreService>(context);

    var task = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 4.0,
      ),
      child: Container(
        padding: const EdgeInsets.only(right: 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: widget.task.isDone
                ? const Color(0xFFD7D7D7)
                : const Color(0xFFFFD699),
          ),
          color: widget.task.isDone ? const Color(0xFFF6F6F6) : Colors.white,
        ),
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
                    ? const Color(0xFFF6F6F6)
                    : const Color(0xFFFFFFFF),
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
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 13, horizontal: 0),
                            child: Text(
                              widget.task.name,
                              maxLines: isExpanded ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 18,
                                color: widget.task.isDone
                                    ? const Color(0xFFDBDBDB)
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.task.reoccurrence !=
                              Reoccurrence.notRepeating &&
                          widget.task.isDone)
                        const Icon(Icons.repeat, color: Color(0xFF5F5F5F)),
                      if (widget.task is TimedTask && !widget.task.isDone)
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child:
                              TimerWidget(timedTask: widget.task as TimedTask),
                        ),
                      widget.task.type == TaskType.parent
                          ? const Padding(
                              padding: EdgeInsets.only(right: 5),
                              child: Icon(Icons.folder))
                          : Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: Checkbox(
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
                                    const BorderSide(color: Color(0xFFFFD699)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                activeColor: const Color(0xFFD9D9D9),
                              ),
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
                                Container(
                                  color: const Color(0xFF7F7F7F),
                                  height: 1,
                                  width: 140,
                                ),
                                if (widget.task.description.isNotEmpty)
                                  Text(widget.task.description,
                                      style: const TextStyle(
                                          color: Color(0xFF898989))),
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
                                          color: Color(0xFFFF0000),
                                        ),
                                        label: const Text(
                                          'Delete',
                                          style: TextStyle(
                                              color: Color(0xFFFF0000),
                                              fontSize: 12),
                                        ),
                                      ),
                                      Container(
                                        color: const Color(0xFFD3D3D3),
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
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Color(0xFFFFAC30),
                                        ),
                                        label: const Text(
                                          'Edit',
                                          style: TextStyle(
                                              color: Color(0xFFFFAC30),
                                              fontSize: 12),
                                        ),
                                      ),
                                      Container(
                                        color: const Color(0xFFD3D3D3),
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
                                        icon: const Icon(
                                          Icons.done,
                                          color: Color(0xFFFFAC30),
                                        ),
                                        label: const Text(
                                          'Mark as complete',
                                          style: TextStyle(
                                              color: Color(0xFFFFAC30),
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
    );
    // return DragTarget<ListDragTarget>(
    //   onWillAccept: (incomingWidget) {
    //     ghost = incomingWidget?.child;
    //     return true;
    //   },
    //   onLeave: (data) {
    //     ghost = null;
    //   },
    //   onAccept: (data) {
    //     ghost = null;
    //     widget.onReorder(data.index, widget.task.index);
    //   },
    //   builder: (context, candidateData, rejectedData) =>
    //       Draggable<ListDragTarget>(
    //     data: ListDragTarget(widget.task.index, task),
    //     axis: Axis.vertical,
    //     childWhenDragging: Container(),
    //     feedback: SizedBox(
    //       width: MediaQuery.of(context).size.width,
    //       child: Material(color: Colors.transparent, child: task),
    //     ),
    // child: GestureDetector(
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
      child: ghost == null
          ? task
          : Column(mainAxisSize: MainAxisSize.min, children: [
              Opacity(opacity: 0.5, child: ghost!),
              task,
            ]),
      //   ),
      // ),
    );
  }
}
