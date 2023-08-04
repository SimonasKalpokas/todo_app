// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/models/checked_task.dart';
import 'package:todo_app/models/timed_task.dart';
import 'package:todo_app/providers/color_provider.dart';
import 'package:todo_app/providers/selection_provider.dart';

import 'package:todo_app/screens/tasks_view_screen.dart';
import 'package:todo_app/services/firestore_service.dart';

// TODO: write tests for existing functionality
class MockFirestoreService extends Mock implements FirestoreService {
  StreamController<Iterable<BaseTaskListenable>> doneStreamController =
      StreamController();
  StreamController<Iterable<BaseTaskListenable>> undoneStreamController =
      StreamController();
  var one = CheckedTaskListenable.fromMap({
    "id": "abc",
    "createdAt": DateTime.now().toIso8601String(),
    "name": "One",
    "description": "one desc",
    "type": TaskType.checked.index,
    "reoccurrence": Reoccurrence.daily.index,
  });

  MockFirestoreService() {
    undoneStreamController.add([
      TimedTaskListenable(null, 'TimedOne', 'timedOne desc',
          Reoccurrence.notRepeating, const Duration(days: 1)),
      one,
      CheckedTaskListenable(null, "Two", "two desc", Reoccurrence.weekly),
      CheckedTaskListenable(
          null, "Three", "three desc", Reoccurrence.notRepeating)
    ]);
    doneStreamController.add(const Iterable.empty());
  }
  @override
  Stream<Iterable<Category>> getCategories() {
    return Stream.value([
      Category(0xFF000000, "Category 1"),
      Category(0xFF000000, "Category 2"),
      Category(0xFF000000, "Category 3"),
    ]);
  }

  @override
  Stream<Iterable<BaseTaskListenable>> getTasks(String? parentId, bool undone) {
    if (!undone) {
      return doneStreamController.stream;
    } else {
      return undoneStreamController.stream;
    }
  }

  @override
  Future<void> updateTaskFields(
      String? parentId, String? taskId, Map<String, dynamic> fields) async {
    if (fields.length == 1 && fields["lastDoneOn"] != null) {
      one.lastDoneOn = DateTime.parse(fields["lastDoneOn"]);
      undoneStreamController.add([
        TimedTaskListenable(null, 'TimedOne', 'timedOne desc',
            Reoccurrence.notRepeating, const Duration(days: 1)),
        CheckedTaskListenable(null, "Two", "two desc", Reoccurrence.weekly),
        CheckedTaskListenable(
            null, "Three", "three desc", Reoccurrence.notRepeating)
      ]);
      doneStreamController.add([one]);
    } else {
      throw Exception("Only task with id 'abc' was expected");
    }
  }
}

void main() {
  testWidgets('Widget loading test', (WidgetTester tester) async {
    final mockFirestoreService = MockFirestoreService();
    var categories = await mockFirestoreService.getCategories().first;
    SharedPreferences.setMockInitialValues({});
    var prefs = await SharedPreferences.getInstance();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MultiProvider(
      providers: [
        StreamProvider<Iterable<Category>>.value(
            value: mockFirestoreService.getCategories(),
            initialData: categories),
        Provider<FirestoreService>(
          create: (_) => mockFirestoreService,
        ),
        ChangeNotifierProvider(create: (_) => SelectionProvider<BaseTask>()),
        ChangeNotifierProvider(create: (_) => ColorProvider(prefs)),
      ],
      child: const MaterialApp(
          home: TasksViewScreen(
        parentTask: null,
      )),
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    var completed = find.text("Completed");
    expect(completed, findsOneWidget);

    await tester.pump(Duration.zero);
    final checkedTaskOne = find.byKey(const Key("abc"));
    expect(checkedTaskOne, findsOneWidget);
    expect(checkedTaskOne, findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(
        find.descendant(of: checkedTaskOne, matching: find.byType(Checkbox)));
    await tester.pumpAndSettle();
    expect(checkedTaskOne, findsNothing);

    await tester.tap(completed);
    await tester.pumpAndSettle();
    expect(find.text("TimedOne"), findsOneWidget);
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
