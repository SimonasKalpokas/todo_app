import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/timed_task.dart';
import 'package:todo_app/services/firestore_service.dart';
import 'package:todo_app/widgets/timer_widget.dart';

class MockFirestoreService extends Mock implements FirestoreService {
  TimedTask task = TimedTask(
      'one', 'description', Reoccurrence.daily, const Duration(seconds: 10));
  StreamController streamController = StreamController();

  @override
  Future<void> updateTask(BaseTask task) async {
    assert(task.type == TaskType.timed);
    assert(task.id == null);

    this.task = task as TimedTask;
    streamController.add(() {});
  }
}

void main() {
  var binding = TestWidgetsFlutterBinding.ensureInitialized();
  if (binding is LiveTestWidgetsFlutterBinding) {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
  }
  testWidgets('Timer test', (WidgetTester tester) async {
    final mockFirestoreService = MockFirestoreService();

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<FirestoreService>(
          create: (_) => mockFirestoreService,
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: StreamBuilder(
              stream: mockFirestoreService.streamController.stream,
              builder: ((context, snapshot) =>
                  TimerWidget(timedTask: mockFirestoreService.task))),
        ),
      ),
    ));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    var secs10 = find.text("0:0:10");
    var secs8 = find.text("0:0:8");

    expect(secs10, findsOneWidget);
    await tester.tap(secs10);
    await tester.pump(const Duration(seconds: 2));
    expect(secs8, findsOneWidget);

    await tester.tap(secs8);
    await tester.pump(const Duration(seconds: 4));
    expect(secs8, findsOneWidget);
    await tester.tap(secs8);
    await tester.pump(const Duration(seconds: 15));
    expect(find.byType(Checkbox), findsOneWidget);
  });
}
