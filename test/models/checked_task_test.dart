import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/checked_task.dart';

void main() {
  group('CheckedTask', () {
    calculateCurrentStatusTest();
  });
}

void calculateCurrentStatusTest() {
  group('calculateCurrentStatus()', () {
    test('Reoccurance notRepeating', () {
      var task = CheckedTask("Test", "desc", Reoccurrence.notRepeating);
      withClock(Clock.fixed(DateTime(2000, 1, 11, 13, 20)), () {
        expect(task.calculateCurrentStatus(), Status.undone);

        task.lastDoneOn = DateTime(2000, 1, 1);
        expect(task.calculateCurrentStatus(), Status.done);

        task.lastDoneOn = DateTime(2000, 1, 10, 20);
        expect(task.calculateCurrentStatus(), Status.done);

        task.lastDoneOn = DateTime(2000, 1, 11, 10);
        expect(task.calculateCurrentStatus(), Status.done);

        task.lastDoneOn = DateTime(2000, 1, 12, 10);
        expect(() => task.calculateCurrentStatus(), throwsException);
      });
    });

    test('Reoccurrence daily', () {
      var task = CheckedTask("Test", "desc", Reoccurrence.daily);
      withClock(Clock.fixed(DateTime(2000, 1, 11, 13, 20)), () {
        expect(task.calculateCurrentStatus(), Status.undone);

        task.lastDoneOn = DateTime(2000, 1, 1);
        expect(task.calculateCurrentStatus(), Status.undone);

        task.lastDoneOn = DateTime(2000, 1, 11, 10);
        expect(task.calculateCurrentStatus(), Status.done);

        task.lastDoneOn = DateTime(2000, 1, 10, 20);
        expect(task.calculateCurrentStatus(), Status.undone);
      });
    });
    test('Reoccurrence weekly', () {
      var task = CheckedTask("Test", "desc", Reoccurrence.weekly);
      // 2000-01-11 is Tuesday
      withClock(Clock.fixed(DateTime(2000, 1, 11, 13, 20)), () {
        expect(task.calculateCurrentStatus(), Status.undone);

        task.lastDoneOn = DateTime(2000, 1, 10, 20);
        expect(task.calculateCurrentStatus(), Status.done);

        task.lastDoneOn = DateTime(2000, 1, 9, 20);
        expect(task.calculateCurrentStatus(), Status.undone);
        task.lastDoneOn = DateTime(2000, 1, 4, 20);
        expect(task.calculateCurrentStatus(), Status.undone);
        task.lastDoneOn = DateTime(2000, 1, 3, 11);
        expect(task.calculateCurrentStatus(), Status.undone);
        task.lastDoneOn = DateTime(2000, 1, 3, 20);
        expect(task.calculateCurrentStatus(), Status.undone);
      });
    });
  });
}
