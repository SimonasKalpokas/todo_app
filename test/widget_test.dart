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
// TODO: organise tests better
class MockFirestoreService extends Mock implements FirestoreService {
  @override
  Stream<Iterable<T>> getTasks<T extends BaseTask>(
      T Function(String?, Map<String, dynamic>) constructor) {
    if (T == TimedTask) {
      return Stream.value([
        TimedTask('TimedOne', 'timedOne desc', Reoccurrence.notRepeating,
            const Duration(days: 1)) as T,
      ]);
    }
    var one = CheckedTask("One", "one desc", Reoccurrence.daily) as T;
    return Stream.value([
      one,
      CheckedTask("Two", "two desc", Reoccurrence.weekly) as T,
      CheckedTask("Three", "three desc", Reoccurrence.notRepeating) as T,
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
    expect(find.byType(CircularProgressIndicator), findsNWidgets(4));
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
