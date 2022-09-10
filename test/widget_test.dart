// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/checked_task.dart';
import 'package:todo_app/models/timed_task.dart';

import 'package:todo_app/screens/tasks_view_screen.dart';
import 'package:todo_app/services/firestore_service.dart';

// TODO: write tests for existing functionality
class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Stream<Iterable<BaseTaskNotifier>> getTasks() {
    var one = CheckedTaskNotifier("One", "one desc", Reoccurrence.daily);
    return Stream.value([
      TimedTaskNotifier('TimedOne', 'timedOne desc', Reoccurrence.notRepeating,
          const Duration(days: 1)),
      one,
      CheckedTaskNotifier("Two", "two desc", Reoccurrence.weekly),
      CheckedTaskNotifier("Three", "three desc", Reoccurrence.notRepeating),
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

  test('Duration parse test', () {
    const dur = Duration(
      days: 2,
      hours: 1,
      minutes: 11,
      milliseconds: 4,
      microseconds: 3,
      seconds: 11,
    );
    expect(DurationParse.tryParse(dur.toString()), dur);
  });
}
