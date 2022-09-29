import 'package:flutter/material.dart';
import 'package:todo_app/models/base_task.dart';

class ParentTaskListenable extends ParentTask
    with BaseTaskListenable, ChangeNotifier {
  ParentTaskListenable(super.parentId, super.name, super.description,
      super.reoccurrence, super.subtasks);
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

  ParentTask(String? parentId, String name, String description,
      Reoccurrence reoccurrence, this.subtasks)
      : super(TaskType.parent, parentId, name, description, reoccurrence);

  // TODO: think about how to calculate status correctly based on subtasks
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
