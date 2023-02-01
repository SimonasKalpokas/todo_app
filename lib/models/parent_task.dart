import 'package:flutter/material.dart';
import 'package:todo_app/models/base_task.dart';

class ParentTaskListenable extends ParentTask
    with BaseTaskListenable, ChangeNotifier {
  ParentTaskListenable(super.parentId, super.name, super.description,
      super.reoccurrence, super.index);
  ParentTaskListenable.fromMap(super.id, super.map) : super.fromMap();

  @override
  void refreshState() {}
}

class ParentTask extends BaseTask {
  ParentTask.fromMap(super.id, super.map) : super.fromMap();

  ParentTask(String? parentId, String name, String description,
      Reoccurrence reoccurrence, int index)
      : super(
            TaskType.parent, parentId, name, description, reoccurrence, index);

  @override
  Status calculateCurrentStatus() {
    return Status.undone;
  }
}
