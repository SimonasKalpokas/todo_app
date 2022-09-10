import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/timed_task.dart';
import 'package:todo_app/services/firestore_service.dart';
import 'package:todo_app/widgets/timer_widget.dart';

import '../datetime_wrapper.dart';

class MockFirestoreService extends Mock implements FirestoreService {
  TimedTaskNotifier task = TimedTaskNotifier(
      'one', 'description', Reoccurrence.daily, const Duration(seconds: 20));
  StreamController streamController = StreamController();

  MockFirestoreService() {
    task.addListener(() {
      assert(task.type == TaskType.timed);
      assert(task.id == null);

      streamController.add(() {});
    });
  }

  // @override
  // Future<void> updateTask(BaseTask task) async {
  //   assert(task.type == TaskType.timed);
  //   assert(task.id == null);

  //   this.task = task as TimedTask;
  //   streamController.add(() {});
  // }
}

void main() {
  var binding = TestWidgetsFlutterBinding.ensureInitialized();
  if (binding is LiveTestWidgetsFlutterBinding) {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.onlyPumps;
  }
  var dateTime = DateTimeWrapper(DateTime(2015, 1, 1, 23, 59, 45));
  testWidgets('Timer test', (WidgetTester tester) async {
    await withClock(Clock(() => dateTime.dateTime), () async {
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
      {
        dateTime.add(const Duration(seconds: 5));
        await tester.pump(const Duration(seconds: 5));
      }

      var secs20 = find.text("0:0:20");
      var secs18 = find.text("0:0:18");
      var secs3 = find.text("0:0:3");

      expect(secs20, findsOneWidget);
      await tester.tap(secs20);
      {
        dateTime.add(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 2));
      }
      expect(secs18, findsOneWidget);

      await tester.tap(secs18);
      {
        dateTime.add(const Duration(seconds: 4));
        await tester.pump(const Duration(seconds: 4));
      }
      expect(secs18, findsOneWidget);
      await tester.tap(secs18);
      {
        dateTime.add(const Duration(seconds: 15));
        await tester.pump(const Duration(seconds: 15));
      }
      expect(secs3, findsOneWidget);
      await tester.tap(secs3);
      {
        dateTime.add(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
      }
      expect(clock.now(), DateTime(2015, 1, 2, 0, 0, 12));
      expect(secs20, findsOneWidget);
    });
  });
}
