import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/task.dart';

void main() {
  group("Reoccurrence", () {
    group("calculateDoneUntil", () {
      test("daily", () {
        expect(Reoccurrence.daily.calculateDoneUntil(DateTime(2004, 3, 2)),
            DateTime(2004, 3, 3));
        expect(
            Reoccurrence.daily.calculateDoneUntil(DateTime(2004, 3, 2, 9, 12)),
            DateTime(2004, 3, 3));
        expect(
            Reoccurrence.daily.calculateDoneUntil(DateTime(2004, 1, 31, 9, 12)),
            DateTime(2004, 2, 1));
      });
      test("weekly", () {
        // Tuesday
        expect(Reoccurrence.weekly.calculateDoneUntil(DateTime(2004, 3, 2)),
            DateTime(2004, 3, 8));
        // Sunday
        expect(Reoccurrence.weekly.calculateDoneUntil(DateTime(2004, 3, 7)),
            DateTime(2004, 3, 8));
        // Monday
        expect(Reoccurrence.weekly.calculateDoneUntil(DateTime(2004, 3, 29)),
            DateTime(2004, 4, 5));
      });
      test("notRepeating", () {
        expect(
            Reoccurrence.notRepeating.calculateDoneUntil(DateTime(2004, 3, 2)),
            DateTime(9999));
      });
    });
    group("isActiveNow()", () {
      group("daily", () {
        test("same day returns true", () {
          withClock(Clock.fixed(DateTime(2004, 3, 2, 10, 11)), () {
            expect(Reoccurrence.daily.isActiveNow(DateTime(2004, 3, 2, 9, 12)),
                true);
            expect(Reoccurrence.daily.isActiveNow(DateTime(2004, 3, 2, 3, 32)),
                true);
            expect(Reoccurrence.daily.isActiveNow(DateTime(2004, 3, 2, 1, 44)),
                true);
          });
        });
        test("previous days return false", () {
          withClock(Clock.fixed(DateTime(2001, 1, 1, 0, 2)), () {
            expect(
                Reoccurrence.daily
                    .isActiveNow(DateTime(2000, 12, 31, 23, 59, 59)),
                false);
            expect(Reoccurrence.daily.isActiveNow(DateTime(2000, 6, 11, 2, 20)),
                false);
            expect(Reoccurrence.daily.isActiveNow(DateTime(1924, 1, 3)), false);
          });
        });
      });
      test("future datetime throws exception", () {
        withClock(Clock.fixed(DateTime(2013, 3, 4, 12, 10)), () {
          for (var reoccurrence in Reoccurrence.values) {
            expect(
                () => reoccurrence.isActiveNow(DateTime(2013, 3, 4, 12, 10, 2)),
                throwsException);
            expect(() => reoccurrence.isActiveNow(DateTime(2013, 3, 5, 10)),
                throwsException);
            expect(() => reoccurrence.isActiveNow(DateTime(2013, 12, 3)),
                throwsException);
          }
        });
      });
    });
  });
}
