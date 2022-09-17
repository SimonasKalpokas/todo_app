import 'package:clock/clock.dart';
import 'package:flutter/cupertino.dart';
import 'package:todo_app/models/base_task.dart';

class AmountedTaskListenable extends AmountedTask
    with BaseTaskListenable, ChangeNotifier {
  AmountedTaskListenable.fromMap(super.id, super.map) : super.fromMap();
  AmountedTaskListenable(super.name, super.description, super.reoccurrence,
      super.totalAmount, super.units);

  @override
  void addAmount(int amount) {
    super.addAmount(amount);
    notifyListeners();
  }

  @override
  void refreshState() {}
}

class AmountedTask extends BaseTask {
  // TODO: Create special number where you can choose how many numbers after comma there will be
  int totalAmount;
  // TODO: Maybe change remainingTime to something like doneAmount, so that it counts up
  int remainingAmount;
  DateTime? startOfExecution;
  String units;

  AmountedTask(String name, String description, Reoccurrence reoccurrence,
      this.totalAmount, this.units)
      : remainingAmount = totalAmount,
        super(TaskType.amounted, name, description, reoccurrence);

  AmountedTask.fromMap(super.id, super.map)
      : totalAmount = map['totalAmount'],
        remainingAmount = map['remainingAmount'],
        units = map['units'],
        startOfExecution = map['startOfExecution'] == null
            ? null
            : DateTime.parse(map['startOfExecution']),
        super.fromMap();

  void addAmount(int amount) {
    assert(amount > 0);

    var status = calculateCurrentStatus();
    if (status == Status.done) {
      return;
    }
    if (status == Status.undone) {
      startOfExecution = clock.now();
    }
    remainingAmount -= amount;
    if (remainingAmount <= 0) {
      lastDoneOn = clock.now();
    }
  }

  @override
  Status calculateCurrentStatus() {
    if (reoccurrence.isActiveNow(lastDoneOn)) {
      return Status.done;
    }
    if (reoccurrence.isActiveNow(startOfExecution)) {
      return Status.started;
    }
    return Status.undone;
  }

  @override
  Map<String, dynamic> toMap() {
    var map = super.toMap();
    map.addAll({
      'totalAmount': totalAmount,
      'remainingAmount': remainingAmount,
      'startOfExecution': startOfExecution?.toIso8601String(),
      'units': units,
    });
    return map;
  }
}
