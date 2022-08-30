class BaseTask {
  String name;
  String description;
  bool completed = false;
  final TaskType type;

  BaseTask(this.name, this.description, this.type);
}

enum TaskType {
  daily,
  weekly,
}
