import 'package:todo_app/models/base_task.dart';

// TODO: handle isActive change when task is executing (for example on a new day)
class TimedTask extends BaseTask {
  Duration totalTime;
  Duration _remainingTime;
  bool executing = false;
  DateTime? startOfExecution;
  DateTime? lastExecution;

  TimedTask(String name, String description, Reoccurrence reoccurrence,
      this.totalTime)
      : _remainingTime = totalTime,
        super(TaskType.timed, name, description, reoccurrence);

  @override
  Status get status {
    if (super.status == Status.done) {
      return Status.done;
    }
    if (executing || reoccurrence.isActiveNow(startOfExecution)) {
      return Status.started;
    }
    return Status.undone;
  }

  Duration get remainingTime {
    switch (status) {
      case Status.undone:
        _remainingTime = totalTime;
        break;
      case Status.done:
        break;
      case Status.started:
        break;
    }
    return _remainingTime;
  }

  set remainingTime(Duration time) {
    _remainingTime = time;
  }

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map.addAll({
      'totalTime': totalTime.toString(),
      'remainingTime': remainingTime.toString(),
      'startOfExecution': startOfExecution?.toIso8601String(),
      'executing': executing,
      'lastExecution': lastExecution?.toIso8601String(),
    });
    return map;
  }

  @override
  TimedTask.fromMap(super.id, super.map)
      : totalTime = DurationParse.tryParse(map['totalTime'])!,
        _remainingTime = DurationParse.tryParse(map['remainingTime'])!,
        startOfExecution = map['startOfExecution'] == null
            ? null
            : DateTime.parse(map['startOfExecution']),
        lastExecution = map['lastExecution'] == null
            ? null
            : DateTime.parse(map['lastExecution']),
        executing = map['executing'],
        super.fromMap();
}

extension DurationParse on Duration {
  static Duration? tryParse(String? str) {
    if (str == null) {
      return null;
    }
    final parts = str.split(':');
    final hours = int.parse(parts[0]);
    final mins = int.parse(parts[1]);
    final secs = int.parse(parts[2].substring(0, 2));
    final microsecs = int.parse(parts[2].substring(3));
    return Duration(
        hours: hours, minutes: mins, seconds: secs, microseconds: microsecs);
  }
}
