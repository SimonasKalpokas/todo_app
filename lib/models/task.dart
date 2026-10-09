import 'package:clock/clock.dart';
import 'package:todo_app/models/entity.dart';

class Task extends Entity {
  String name;
  String? parentId;
  String description;
  String? categoryId;
  DateTime? lastDoneOn;
  DateTime? doneUntil;
  Reoccurrence reoccurrence;
  TaskType type;
  int index;

  Task(this.type, this.parentId, this.name, this.description, this.reoccurrence,
      this.index, this.categoryId)
      : super.create();

  // TODO: for weekly (also maybe for daily) add choice of first week day (time)
  Status calculateCurrentStatus() =>
      reoccurrence.isActiveNow(lastDoneOn) ? Status.done : Status.undone;

  bool get isDone => calculateCurrentStatus() == Status.done;

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map.addAll({
      'name': name,
      'parentId': parentId,
      'description': description,
      'lastDoneOn': lastDoneOn?.toIso8601String(),
      'reoccurrence': reoccurrence.index,
      'type': type.index,
      'categoryId': categoryId,
      'index': index,
    });
    return map;
  }

  Task.fromMap(super.map)
      : name = map['name'],
        parentId = map['parent_id'],
        description = map['description'],
        lastDoneOn = map['last_done_on'] == null
            ? null
            : DateTime.parse(map['last_done_on']),
        type = TaskType.values.byName(map['type']),
        reoccurrence = Reoccurrence.values.byName(map["reoccurrence"]),
        categoryId = map['category_id'],
        index = 0,
        doneUntil = map['done_until'] == null
            ? null
            : DateTime.parse(map['done_until']),
        super.fromMap();
}

enum Status {
  undone,
  done,
  // TODO: think about if started is really neccessary
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
  parent;

  String get displayTitle {
    switch (this) {
      case TaskType.checked:
        return 'Checked';
      case TaskType.timed:
        return 'Timed';
      case TaskType.parent:
        return 'Parent'; // TODO: Consider changing to list or smth
    }
  }
}

extension ReoccurrenceExtension on Reoccurrence {
  String get displayTitle {
    assert(Reoccurrence.values.length == 3);
    switch (this) {
      case Reoccurrence.daily:
        return 'daily';
      case Reoccurrence.weekly:
        return 'weekly';
      case Reoccurrence.notRepeating:
        return 'not repeating';
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

  DateTime calculateDoneUntil(DateTime doneOn) {
    return switch (this) {
      Reoccurrence.daily => DateTime(doneOn.year, doneOn.month, doneOn.day + 1),
      Reoccurrence.weekly =>
        DateTime(doneOn.year, doneOn.month, doneOn.day + 8 - doneOn.weekday),
      Reoccurrence.notRepeating => DateTime(9999),
    };
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
