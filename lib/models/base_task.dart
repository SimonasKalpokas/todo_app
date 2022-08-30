class BaseTask {
  String name;
  String description;
  Status status = Status.undone;
  Reoccurrence type;

  BaseTask(this.name, this.description, this.type);
}

enum Status {
  done,
  undone,
}

enum Reoccurrence {
  daily,
  weekly,
  notRepeating,
}

extension ReoccurrenceExtension on Reoccurrence {
  String get displayTitle {
    assert(Reoccurrence.values.length == 3);
    switch (this) {
      case Reoccurrence.daily:
        return 'Daily';
      case Reoccurrence.weekly:
        return 'Weekly';
      case Reoccurrence.notRepeating:
        return 'Not repeating';
    }
  }
}
