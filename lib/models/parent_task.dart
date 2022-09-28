import 'package:flutter/material.dart';
import 'package:todo_app/models/base_task.dart';

class ParentTaskListenable extends ParentTask
    with BaseTaskListenable, ChangeNotifier {
  ParentTaskListenable(
      super.name, super.description, super.reoccurrence, super.subtasks);
  ParentTaskListenable.fromMap(super.id, super.map) : super.fromMap();

  @override
  void refreshState() {}
}

class ParentTask extends BaseTask {
  List<BaseTask> subtasks;

  bool completable = false;

  ParentTask.fromMap(super.id, super.map)
      : subtasks = List.empty(),
        super.fromMap();

  ParentTask(
      String name, String description, Reoccurrence reoccurrence, this.subtasks)
      : super(TaskType.parent, name, description, reoccurrence);

  @override
  Status calculateCurrentStatus() {
    if (!completable) {
      return Status.undone;
    }
    if (reoccurrence.isActiveNow(lastDoneOn)) {
      return Status.done;
    }
    if (subtasks
        .every((task) => task.calculateCurrentStatus() == Status.done)) {
      return Status.done;
    }
    return Status.undone;
  }
}
