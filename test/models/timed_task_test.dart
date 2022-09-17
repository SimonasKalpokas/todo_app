import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/timed_task.dart';

import '../datetime_wrapper.dart';

// TODO: group tests better (maybe by function aka startExection, stopExecution)
void main() {
  group('TimedTask', () {
    test('execution, stop execution and completion', () {
      Reoccurrence reoccurrence = Reoccurrence.daily;
      var timedTask = TimedTask(
          'a', 'description', reoccurrence, const Duration(seconds: 10));
      var dateTime = DateTimeWrapper(DateTime(2015, 5, 2, 13, 20));
      withClock(Clock(() => dateTime.dateTime), () {
        // when(reoccurrence.isActiveNow(clock.now())).thenReturn(true);
        expect(timedTask.isCurrentlyExecuting(), false);
        expect(timedTask.calculateCurrentLastDoneOn(), null);
        expect(timedTask.startOfExecution, null);
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(seconds: 10));
        expect(timedTask.totalTime, const Duration(seconds: 10));
        expect(timedTask.calculateCurrentStatus(), Status.undone);

        timedTask.startExecution();
        expect(timedTask.isCurrentlyExecuting(), true);
        expect(timedTask.calculateCurrentLastDoneOn(), null);
        expect(timedTask.startOfExecution, DateTime(2015, 5, 2, 13, 20));
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(seconds: 10));
        expect(timedTask.totalTime, const Duration(seconds: 10));
        expect(timedTask.calculateCurrentStatus(), Status.started);

        dateTime.add(const Duration(seconds: 5));
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(seconds: 5));

        timedTask.stopExecution();
        expect(timedTask.isCurrentlyExecuting(), false);
        expect(timedTask.calculateCurrentLastDoneOn(), null);
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(seconds: 5));
        expect(timedTask.totalTime, const Duration(seconds: 10));
        expect(timedTask.calculateCurrentStatus(), Status.started);

        dateTime.add(const Duration(seconds: 3));

        timedTask.stopExecution();
        expect(timedTask.isCurrentlyExecuting(), false);
        expect(timedTask.calculateCurrentLastDoneOn(), null);
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(seconds: 5));
        expect(timedTask.totalTime, const Duration(seconds: 10));
        expect(timedTask.calculateCurrentStatus(), Status.started);

        timedTask.startExecution();
        dateTime.add(const Duration(seconds: 7));
        expect(timedTask.isCurrentlyExecuting(), false);
        expect(timedTask.calculateCurrentLastDoneOn(),
            DateTime(2015, 5, 2, 13, 20, 13));
        expect(timedTask.calculateCurrentRemainingTime(), Duration.zero);
        expect(timedTask.totalTime, const Duration(seconds: 10));
        expect(timedTask.calculateCurrentStatus(), Status.done);
      });
    });
    test('remainingTime test', () {
      var timedTask = TimedTask(
          'test one', '', Reoccurrence.daily, const Duration(hours: 2));
      expect(
          timedTask.calculateCurrentRemainingTime(), const Duration(hours: 2));
      var dateTimeWrapper = DateTimeWrapper(DateTime(2000, 2, 3, 1, 10));
      withClock(Clock(() => dateTimeWrapper.dateTime), () {
        timedTask.startExecution();

        dateTimeWrapper.add(const Duration(minutes: 13));
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(hours: 1, minutes: 47));

        dateTimeWrapper.add(const Duration(minutes: 17));
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(hours: 1, minutes: 30));

        dateTimeWrapper.add(const Duration(minutes: 25, seconds: 23));
        timedTask.stopExecution();
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(hours: 1, minutes: 4, seconds: 37));

        dateTimeWrapper.add(const Duration(minutes: 44, seconds: 37));
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(hours: 1, minutes: 4, seconds: 37));
        timedTask.startExecution();

        dateTimeWrapper.add(const Duration(minutes: 50));
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(minutes: 14, seconds: 37));
        dateTimeWrapper.add(const Duration(days: 1, hours: 1, minutes: 5));
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(hours: 2));
        expect(timedTask.calculateCurrentStatus(), Status.undone);
        timedTask.stopExecution();
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(hours: 2));
        expect(timedTask.calculateCurrentStatus(), Status.undone);
        expect(timedTask.calculateCurrentLastDoneOn(),
            DateTime(2000, 2, 3, 3, 54, 37));
      });
    });
    test('Complete previous task on this reoccurrence period', () {
      var timedTask = TimedTask(
          'test', 'wawa', Reoccurrence.daily, const Duration(hours: 1));
      var dateTime = DateTimeWrapper(DateTime(2015, 1, 1, 20, 5));
      withClock(Clock(() => dateTime.dateTime), () {
        timedTask.startExecution();
        dateTime.add(const Duration(minutes: 50));
        timedTask.stopExecution();
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(minutes: 10));
        expect(timedTask.lastDoneOn, null);
        expect(timedTask.startOfExecution, DateTime(2015, 1, 1, 20, 5));
        expect(timedTask.calculateCurrentStatus(), Status.started);
        dateTime.add(const Duration(hours: 3));

        timedTask.startExecution();
        dateTime.add(const Duration(minutes: 15));
        timedTask.stopExecution();
        expect(timedTask.calculateCurrentRemainingTime(),
            const Duration(hours: 1));
        expect(timedTask.startOfExecution, DateTime(2015, 1, 1, 23, 55));
        expect(timedTask.lastDoneOn, DateTime(2015, 1, 2, 0, 5));
        expect(timedTask.calculateCurrentStatus(), Status.undone);
      });
    });
  });
}
