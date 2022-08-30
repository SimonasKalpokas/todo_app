class BaseTask {
  String name;
  String description;
  Status status = Status.undone;
  Reoccurance type;

  BaseTask(this.name, this.description, this.type);
}

enum Status {
  done,
  undone,
}

enum Reoccurance {
  daily,
  weekly,
  notRepeating,
}

extension ReoccuranceExtension on Reoccurance {
  String get displayTitle {
    assert(Reoccurance.values.length == 3);
    switch (this) {
      case Reoccurance.daily:
        return 'Daily';
      case Reoccurance.weekly:
        return 'Weekly';
      case Reoccurance.notRepeating:
        return 'Not repeating';
    }
  }
}
