import 'package:flutter/material.dart';

import '../models/base_task.dart';

class Tasks with ChangeNotifier {
  // TODO: get tasks on initialisation from db
  final List<BaseTask> _tasks = [
    BaseTask("One", "One desc", TaskType.daily),
    BaseTask("Two", "Two desc", TaskType.weekly),
  ];

  // TODO: make returned list unmodifiable
  List<BaseTask> get tasks => _tasks;

  void add(BaseTask task) {
    _tasks.add(task);

    notifyListeners();
  }

  void toggle(int index) {
    _tasks[index].completed = !_tasks[index].completed;

    notifyListeners();
  }
}
