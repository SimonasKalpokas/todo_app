import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/models/base_task.dart';

class TimedTaskNotifier extends TimedTask
    with BaseTaskNotifier, ChangeNotifier {
  TimedTaskNotifier(
      super.name, super.description, super.reoccurrence, super.totalTime);

  TimedTaskNotifier.fromMap(super.id, super.map) : super.fromMap();

  @override
  void refreshState() {
    if (super.updateState()) {
      notifyListeners();
    }
  }

  @override
  bool startExecution() {
    if (super.startExecution()) {
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  bool stopExecution() {
    if (super.stopExecution()) {
      notifyListeners();
      return true;
    }
    return false;
  }
}

// TODO: add constrait that totalTime < reoccurence time period
// TODO: rethink logic and responsibilities of this class
class TimedTask extends BaseTask {
  Duration totalTime;
  Duration _remainingTime;
  bool executing = false;
  DateTime? startOfExecution;

  TimedTask(String name, String description, Reoccurrence reoccurrence,
      this.totalTime)
      : assert(name.isNotEmpty),
        _remainingTime = totalTime,
        super(TaskType.timed, name, description, reoccurrence);

  // @override
  // DateTime? get lastCompletedOn  {
  //   if (executing &&
  //       _remainingTime - clock.now().difference(_startOfExecution!) <=
  //           Duration.zero) {
  //     return _startOfExecution!.add(_remainingTime);
  //   }
  //   return super.lastCompletedOn;
  // }
  bool isCurrentlyExecuting() {
    return (executing &&
        !reoccurrence.isActiveNow(lastCompletedOn) &&
        (_remainingTime - clock.now().difference(startOfExecution!) >
            Duration.zero));
  }

  Duration calculateCurrentRemainingTime() {
    if (reoccurrence.isActiveNow(startOfExecution) &&
        reoccurrence.isActiveNow(lastCompletedOn)) {
      return Duration.zero;
    }
    if (executing) {
      var dur = _remainingTime - clock.now().difference(startOfExecution!);
      if (dur <= Duration.zero) {
        if (reoccurrence.isActiveNow(startOfExecution)) {
          return Duration.zero;
        }
        return totalTime;
      }
      return dur;
    }
    if (reoccurrence.isActiveNow(startOfExecution)) {
      return _remainingTime;
    }
    return totalTime;
  }

  @override
  Status calculateCurrentStatus() {
    if (reoccurrence.isActiveNow(startOfExecution) &&
        reoccurrence.isActiveNow(lastCompletedOn)) {
      return Status.done;
    }
    if (executing) {
      var dur = _remainingTime - clock.now().difference(startOfExecution!);
      if (dur <= Duration.zero) {
        if (reoccurrence.isActiveNow(startOfExecution)) {
          return Status.done;
        }
        return Status.undone;
      }
      return Status.started;
    }
    if (reoccurrence.isActiveNow(startOfExecution)) {
      return Status.started;
    }
    return Status.undone;
  }

  DateTime? calculateCurrentLastCompletedOn() {
    if (executing) {
      if (reoccurrence.isActiveNow(startOfExecution)) {
        if (lastCompletedOn != null &&
            lastCompletedOn!.isAfter(startOfExecution!)) {
          return lastCompletedOn;
        }
      }
      var dur = _remainingTime - clock.now().difference(startOfExecution!);
      if (dur <= Duration.zero) {
        return startOfExecution!.add(_remainingTime);
      }
    }
    return lastCompletedOn;
  }

  // TODO: think about separating methods like status (of the state) and calculateCurrentStatus (with regard to the current time)
  /// Updates state based on current DateTime.
  /// Returns whether a change has happenned
  bool updateState() {
    var newStatus = calculateCurrentStatus();
    var newRemainingTime = calculateCurrentRemainingTime();

    if (executing && newStatus != Status.started) {
      var newLastCompletedOn = calculateCurrentLastCompletedOn();
      lastCompletedOn = newLastCompletedOn;
      executing = false;
      _remainingTime = newRemainingTime;
      return true;
    }
    if (newStatus == Status.undone && _remainingTime != newRemainingTime) {
      _remainingTime = newRemainingTime;
      return true;
    }
    return false;
  }

  // Status get status {
  //   if (reoccurrence.isActiveNow(startOfExecution)) {
  //     if ((lastCompletedOn != null &&
  //             lastCompletedOn!.isAfter(startOfExecution!)) ||
  //         (executing &&
  //             _remainingTime - clock.now().difference(startOfExecution!) <=
  //                 Duration.zero)) {
  //       return Status.done;
  //     }
  //     return Status.started;
  //   }
  //   return Status.undone;
  // }

  /// Returns whether any change has happenned.
  bool startExecution() {
    var ret = updateState();
    if (executing || isDone) {
      return ret;
    }
    startOfExecution = clock.now();
    executing = true;
    return true;
  }

  /// Returns whether any change has happenned.
  bool stopExecution() {
    var ret = updateState();
    if (!executing) {
      return ret;
    }
    _remainingTime = calculateCurrentRemainingTime();
    executing = false;
    return true;
  }

  Duration get remainingTime {
    if (executing) {
      if (reoccurrence.isActiveNow(startOfExecution)) {
        var ret = _remainingTime - clock.now().difference(startOfExecution!);
        if (ret <= Duration.zero) {
          return Duration.zero;
        }
        return ret;
      }
      return totalTime;
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
