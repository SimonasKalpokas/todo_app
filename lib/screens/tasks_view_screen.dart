import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/parent_task.dart';
import 'package:todo_app/models/timed_task.dart';
import 'package:todo_app/services/firestore_service.dart';

import '../widgets/timer_widget.dart';
import 'task_form_screen.dart';

class TasksViewScreen extends StatelessWidget {
  final BaseTask? parentTask;
  const TasksViewScreen({Key? key, required this.parentTask}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          parentTask != null
              ? IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskFormScreen(
                            parentId: parentTask!.parentId, task: parentTask),
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
            DoneTasksListView(tasks: tasks),
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
          condition: (task) => task.isDone,
          tasks: widget.tasks,
          visible: showDone,
        ),
      ],
    );
  }
}

class TasksListView extends StatelessWidget {
  final bool Function(BaseTask)? condition;
  final bool visible;
  final Stream<Iterable<BaseTask>> tasks;

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
              return TaskCard(task);
            },
          ).toList(),
        );
      },
    );
  }
}

class TaskCard extends StatefulWidget {
  final BaseTask task;

  const TaskCard(this.task, {Key? key}) : super(key: key);

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  var isOpen = false;
  @override
  Widget build(BuildContext context) {
    var firestoreService = Provider.of<FirestoreService>(context);
    Widget child = Column(
      children: [
        Card(
          margin: const EdgeInsets.fromLTRB(15, 8.0, 15, 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
                color: Color(widget.task.isDone ? 0xFFD7D7D7 : 0xFFFFD699)),
          ),
          color: widget.task.isDone ? const Color(0xFFF6F6F6) : Colors.white,
          child: Dismissible(
            key: ObjectKey(widget.task),
            onDismissed: ((direction) {
              firestoreService.deleteTask(widget.task.parentId, widget.task.id);
            }),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
              child: const Icon(Icons.delete_sweep),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 20),
              title: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.task.name,
                  style: TextStyle(
                      fontSize: 18,
                      color: widget.task.isDone
                          ? const Color(0xFFDBDBDB)
                          : Colors.black),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => widget.task.type == TaskType.parent
                          ? TasksViewScreen(parentTask: widget.task)
                          : TaskFormScreen(
                              parentId: widget.task.parentId,
                              task: widget.task)),
                );
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.task.isDone &&
                      widget.task.reoccurrence != Reoccurrence.notRepeating)
                    const Icon(Icons.repeat, color: Color(0xFF5F5F5F)),
                  if (widget.task.type == TaskType.timed && !widget.task.isDone)
                    TimerWidget(timedTask: widget.task as TimedTask),
                  widget.task is ParentTask
                      ? Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.folder,
                                color: Color(0xFF666666)),
                            onPressed: () {
                              setState(() {
                                isOpen = !isOpen;
                              });
                            },
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: Checkbox(
                              onChanged: (bool? value) {
                                if (value == null) {
                                  throw UnimplementedError();
                                }
                                firestoreService.updateTaskFields(
                                  widget.task.parentId,
                                  widget.task.id,
                                  {
                                    'lastDoneOn': value
                                        ? clock.now().toIso8601String()
                                        : null
                                  },
                                );
                              },
                              value: widget.task.isDone,
                              activeColor: const Color(0xFFD9D9D9),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        if (isOpen)
          Row(
            children: [
              // vertical line of parent's height and width 2

              // Container(
              //   height: 50,
              //   width: 2,
              //   color: const Color(0xFF666666),
              // ),
              Container(
                width: 15,
                color: const Color(0xFF666666),
                //constraints: const BoxConstraints.expand(width: 10),
              ),
              Expanded(
                child: TasksListView(
                  condition: (task) => !task.isDone,
                  tasks: firestoreService.getTasks(widget.task.id),
                ),
              ),
            ],
          ),
      ],
    );

    return DragTarget<BaseTask>(
      builder: (BuildContext context, List<BaseTask?> candidateData,
          List<dynamic> rejectedData) {
        return LongPressDraggable<BaseTask>(
          data: widget.task,
          axis: Axis.vertical,
          feedback: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Material(color: Colors.transparent, child: child),
          ),
          childWhenDragging: Container(),
          child: child,
        );
      },
      onWillAccept: (incoming) {
        return widget.task.type == TaskType.parent &&
            incoming!.parentId != widget.task.id;
      },
      onAccept: (incoming) {
        firestoreService.moveTask(incoming, widget.task.id);
      },
      onLeave: (incoming) {},
    );
  }
}
