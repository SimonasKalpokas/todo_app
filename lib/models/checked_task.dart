import 'package:flutter/material.dart';
import 'package:todo_app/models/base_task.dart';

class CheckedTaskNotifier extends CheckedTask
    with BaseTaskNotifier, ChangeNotifier {
  CheckedTaskNotifier(super.name, super.description, super.reoccurrence);
  CheckedTaskNotifier.fromMap(super.id, super.map) : super.fromMap();

  @override
  void refreshState() {}
}

class CheckedTask extends BaseTask {
  CheckedTask(String name, String description, Reoccurrence reoccurrence)
      : super(TaskType.checked, name, description, reoccurrence);

  CheckedTask.fromMap(super.id, super.map) : super.fromMap();
}
