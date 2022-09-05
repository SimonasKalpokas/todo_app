import 'package:todo_app/models/base_task.dart';

class CheckedTask extends BaseTask {
  CheckedTask(String name, String description, Reoccurrence reoccurrence)
      : super(TaskType.checked, name, description, reoccurrence);

  CheckedTask.fromMap(super.id, super.map) : super.fromMap();
}
