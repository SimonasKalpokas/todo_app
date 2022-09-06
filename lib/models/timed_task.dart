import 'package:clock/clock.dart';
import 'package:todo_app/models/base_task.dart';

// TODO: add constrait that totalTime < reoccurence time period
class TimedTask extends BaseTask {
  Duration totalTime;
  Duration _remainingTime;
  bool executing = false;
  DateTime? startOfExecution;

  TimedTask(String name, String description, Reoccurrence reoccurrence,
      this.totalTime)
      : _remainingTime = totalTime,
        super(TaskType.timed, name, description, reoccurrence);

  @override
  Status get status {
    if (reoccurrence.isActiveNow(startOfExecution)) {
      if (remainingTime <= Duration.zero) {
        return Status.done;
      }
      return Status.started;
    }
    return Status.undone;
  }

  void startExecution() {
    if (executing || isDone) {
      return;
    }
    startOfExecution = clock.now();
    executing = true;
  }

  void stopExecution() {
    if (!executing) {
      return;
    }
    var dur = remainingTime;
    if (dur == Duration.zero) {
      lastCompletedOn = startOfExecution!.add(_remainingTime);
    }
    _remainingTime = dur;
    executing = false;
  }

  Duration get remainingTime {
    if (executing) {
      var ret = _remainingTime - clock.now().difference(startOfExecution!);
      if (ret <= Duration.zero) {
        return Duration.zero;
      }
      return ret;
    }
    return _remainingTime;
  }

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map.addAll({
      'totalTime': totalTime.toString(),
      'remainingTime': _remainingTime.toString(),
      'startOfExecution': startOfExecution?.toIso8601String(),
      'executing': executing,
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
