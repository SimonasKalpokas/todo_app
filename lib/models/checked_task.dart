import 'package:flutter/material.dart';
import 'package:todo_app/models/base_task.dart';

class CheckedTaskListenable extends CheckedTask
    with BaseTaskListenable, ChangeNotifier {
  CheckedTaskListenable(
      super.parentId, super.name, super.description, super.reoccurrence);
  CheckedTaskListenable.fromMap(super.id, super.map) : super.fromMap();

  @override
  void refreshState() {}
}

class CheckedTask extends BaseTask {
  CheckedTask(String? parentId, String name, String description,
      Reoccurrence reoccurrence)
      : super(TaskType.checked, parentId, name, description, reoccurrence);

  CheckedTask.fromMap(super.id, super.map) : super.fromMap();
}
