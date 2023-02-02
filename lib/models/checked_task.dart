import 'package:flutter/material.dart';
import 'package:todo_app/models/base_task.dart';

class CheckedTaskListenable extends CheckedTask
    with BaseTaskListenable, ChangeNotifier {
  CheckedTaskListenable.fromMap(super.map) : super.fromMap();
  CheckedTaskListenable(
      super.parentId, super.name, super.description, super.reoccurrence);

  @override
  void refreshState() {}
}

class CheckedTask extends BaseTask {
  CheckedTask(String? parentId, String name, String description,
      Reoccurrence reoccurrence)
      : super(TaskType.checked, parentId, name, description, reoccurrence);

  CheckedTask.fromMap(super.map) : super.fromMap();
}
