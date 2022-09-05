import 'package:clock/clock.dart';

abstract class BaseTask {
  String? id;
  String name;
  String description;
  DateTime? lastCompletedOn;
  Reoccurrence reoccurrence;
  TaskType type;

  BaseTask(this.type, this.name, this.description, this.reoccurrence);

  // TODO: for weekly (also maybe for daily) add choice of first week day (time)
  // TODO: change status and isDone to methods
  Status get status =>
      reoccurrence.isActiveNow(lastCompletedOn) ? Status.done : Status.undone;

  bool get isDone => status == Status.done;

  Map<String, dynamic> toMap() => {
        'name': name,
        'description': description,
        'lastCompleted': lastCompletedOn?.toIso8601String(),
        'reoccurrence': reoccurrence.index,
        'type': type.index,
      };

  // TODO: write tests for this function
  BaseTask.fromMap(this.id, Map<String, dynamic> map)
      : name = map['name'],
        description = map['description'],
        lastCompletedOn = map['lastCompleted'] == null
            ? null
            : DateTime.parse(map['lastCompleted']),
        type = TaskType.values[map['type']],
        reoccurrence = Reoccurrence.values[map['reoccurrence']];
}

enum Status {
  undone,
  done,
  started,
}

enum Reoccurrence {
  daily,
  weekly,
  notRepeating,
}

enum TaskType {
  checked,
  timed,
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

  bool wasActiveLastTimePeriod(DateTime? dateTime) {
    if (dateTime == null) {
      return false;
    }
    if (isActiveNow(dateTime)) {
      return false;
    }

    final now = clock.now();
    switch (this) {
      case Reoccurrence.daily:
        dateTime = dateTime.subtract(const Duration(days: 1));
        if (now.difference(dateTime).inDays > 1 || now.day != dateTime.day) {
          return false;
        }
        break;
      case Reoccurrence.weekly:
        dateTime = dateTime.subtract(const Duration(days: 7));
        if (now.difference(dateTime).inDays > now.weekday ||
            now.weekday < dateTime.weekday) {
          return false;
        }
        break;
      case Reoccurrence.notRepeating:
        break;
    }
    return true;
  }

  bool isActiveNow(DateTime? dateTime) {
    if (dateTime == null) {
      return false;
    }
    final now = clock.now();

    if (now.isBefore(dateTime)) {
      // TODO: handle time in the future better
      throw Exception('Time of task completion is in the future.');
    }

    switch (this) {
      case Reoccurrence.daily:
        if (now.difference(dateTime).inDays > 1 || now.day != dateTime.day) {
          return false;
        }
        break;
      case Reoccurrence.weekly:
        if (now.difference(dateTime).inDays > now.weekday ||
            now.weekday < dateTime.weekday) {
          return false;
        }
        break;
      case Reoccurrence.notRepeating:
        break;
    }
    return true;
  }
}
