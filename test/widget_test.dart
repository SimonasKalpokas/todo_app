// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';

import 'package:todo_app/screens/tasks_view_screen.dart';
import 'package:todo_app/services/firestore_service.dart';

class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Stream<Iterable<BaseTask>> getTasks() {
    var one = BaseTask("One", "one desc", Reoccurrence.daily);
    return Stream.value([
      one,
      BaseTask("Two", "two desc", Reoccurrence.weekly),
      BaseTask("Three", "three desc", Reoccurrence.notRepeating),
    ]);
  }
}

void main() {
  testWidgets('Widget loading test', (WidgetTester tester) async {
    final mockFirestoreService = MockFirestoreService();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<FirestoreService>(
          create: (_) => mockFirestoreService,
        ),
      ],
      child: const MaterialApp(home: TasksViewScreen()),
    ));
    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    expect(find.text("Done"), findsOneWidget);

    await tester.pump(Duration.zero);
    expect(find.text("One"), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  test('BaseTask.status() reoccurance notRepeating test', () {
    var task = BaseTask("Test", "desc", Reoccurrence.notRepeating);
    withClock(Clock.fixed(DateTime(2000, 1, 11, 13, 20)), () {
      expect(task.status(), Status.undone);

      task.lastCompletedOn = DateTime(2000, 1, 1);
      expect(task.status(), Status.done);

      task.lastCompletedOn = DateTime(2000, 1, 10, 20);
      expect(task.status(), Status.done);

      task.lastCompletedOn = DateTime(2000, 1, 11, 10);
      expect(task.status(), Status.done);

      task.lastCompletedOn = DateTime(2000, 1, 12, 10);
      expect(() => task.status(), throwsException);
    });
  });

  test('BaseTask.status() daily test', () {
    var task = BaseTask("Test", "desc", Reoccurrence.daily);
    withClock(Clock.fixed(DateTime(2000, 1, 11, 13, 20)), () {
      expect(task.status(), Status.undone);

      task.lastCompletedOn = DateTime(2000, 1, 1);
      expect(task.status(), Status.undone);

      task.lastCompletedOn = DateTime(2000, 1, 11, 10);
      expect(task.status(), Status.done);

      task.lastCompletedOn = DateTime(2000, 1, 10, 20);
      expect(task.status(), Status.undone);
    });
  });
  test('BaseTask.status() weekly test', () {
    var task = BaseTask("Test", "desc", Reoccurrence.weekly);
    // 2000-01-11 is Tuesday
    withClock(Clock.fixed(DateTime(2000, 1, 11, 13, 20)), () {
      expect(task.status(), Status.undone);

      task.lastCompletedOn = DateTime(2000, 1, 10, 20);
      expect(task.status(), Status.done);

      task.lastCompletedOn = DateTime(2000, 1, 9, 20);
      expect(task.status(), Status.undone);
      task.lastCompletedOn = DateTime(2000, 1, 4, 20);
      expect(task.status(), Status.undone);
      task.lastCompletedOn = DateTime(2000, 1, 3, 11);
      expect(task.status(), Status.undone);
      task.lastCompletedOn = DateTime(2000, 1, 3, 20);
      expect(task.status(), Status.undone);
    });
  });
}
