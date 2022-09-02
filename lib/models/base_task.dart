import 'package:clock/clock.dart';

class BaseTask {
  String? id;
  String name;
  String description;
  DateTime? lastCompletedOn;
  Reoccurrence reoccurrence;

  BaseTask(this.name, this.description, this.reoccurrence);

  // TODO: for weekly (also maybe for daily) add choice of first week day (time)
  // TODO: extract Reoccurrence to separate class
  Status status() {
    if (lastCompletedOn == null) {
      return Status.undone;
    }
    final now = clock.now();

    if (now.isBefore(lastCompletedOn!)) {
      throw Exception('Time of task completion is in the future.');
    }

    switch (reoccurrence) {
      case Reoccurrence.daily:
        if (now.difference(lastCompletedOn!).inDays > 1 ||
            now.day != lastCompletedOn!.day) {
          return Status.undone;
        }
        break;
      case Reoccurrence.weekly:
        if (now.difference(lastCompletedOn!).inDays > now.weekday ||
            now.weekday < lastCompletedOn!.weekday) {
          return Status.undone;
        }
        break;
      case Reoccurrence.notRepeating:
        break;
    }
    return Status.done;
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'lastCompleted': lastCompletedOn?.toIso8601String(),
        'reoccurrence': reoccurrence.index,
      };

  // TODO: write tests for this function
  BaseTask.fromMap(this.id, Map<String, dynamic> map)
      : name = map['name'],
        description = map['description'],
        lastCompletedOn = map['lastCompleted'] == null
            ? null
            : DateTime.parse(map['lastCompleted']),
        reoccurrence = Reoccurrence.values[map['reoccurrence']];
}

enum Status {
  undone,
  done,
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
