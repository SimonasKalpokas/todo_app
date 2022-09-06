import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/timed_task.dart';

import '../datetime_wrapper.dart';

void main() {
  group('TimedTask', () {
    test('remainingTime test', () {
      var timedTask = TimedTask(
          'test one', '', Reoccurrence.daily, const Duration(hours: 2));
      expect(timedTask.remainingTime, const Duration(hours: 2));
      var dateTimeWrapper = DateTimeWrapper(DateTime(2000, 2, 3, 1, 10));
      withClock(Clock(() => dateTimeWrapper.dateTime), () {
        timedTask.startExecution();

        dateTimeWrapper.add(const Duration(minutes: 13));
        expect(timedTask.remainingTime, const Duration(hours: 1, minutes: 47));

        dateTimeWrapper.add(const Duration(minutes: 17));
        expect(timedTask.remainingTime, const Duration(hours: 1, minutes: 30));

        dateTimeWrapper.add(const Duration(minutes: 25, seconds: 23));
        timedTask.stopExecution();
        expect(timedTask.remainingTime,
            const Duration(hours: 1, minutes: 4, seconds: 37));

        dateTimeWrapper.add(const Duration(minutes: 44, seconds: 37));
        expect(timedTask.remainingTime,
            const Duration(hours: 1, minutes: 4, seconds: 37));
        timedTask.startExecution();

        dateTimeWrapper.add(const Duration(minutes: 50));
        expect(
            timedTask.remainingTime, const Duration(minutes: 14, seconds: 37));

        dateTimeWrapper.add(const Duration(days: 1, hours: 1, minutes: 5));
        expect(timedTask.remainingTime, Duration.zero);
        expect(timedTask.status, Status.undone);
        timedTask.stopExecution();
        expect(timedTask.remainingTime, Duration.zero);
        expect(timedTask.status, Status.undone);
        expect(timedTask.lastCompletedOn, DateTime(2000, 2, 3, 3, 54, 37));
      });
    });
  });
}
