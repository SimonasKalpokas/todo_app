class BaseTask {
  String name;
  String description;
  Status status = Status.undone;
  final TaskType type;

  BaseTask(this.name, this.description, this.type);
}

enum Status {
  done,
  undone,
}

enum TaskType {
  daily,
  weekly,
}
