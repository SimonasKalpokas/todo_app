import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/timed_task.dart';
import '../services/firestore_service.dart';

class TimerWidget extends StatefulWidget {
  final TimedTask timedTask;
  const TimerWidget({Key? key, required this.timedTask}) : super(key: key);

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> with WidgetsBindingObserver {
  late Timer timer;
  late FirestoreService firestoreService;
  late Duration timeLeft;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    timeLeft = widget.timedTask.calculateCurrentRemainingTime();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.timedTask.executing) {
        setState(() {
          timeLeft -= const Duration(seconds: 1);
        });
        if (timeLeft <= Duration.zero) {
          timer.cancel();
          widget.timedTask.updateState();
        }
      }
    });
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      var remainingTime = widget.timedTask.calculateCurrentRemainingTime();
      if (remainingTime != timeLeft) {
        setState(() {
          timeLeft = remainingTime;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    firestoreService = Provider.of<FirestoreService>(context);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant TimerWidget oldWidget) {
    var remainingTime = widget.timedTask.calculateCurrentRemainingTime();
    if (remainingTime != timeLeft) {
      setState(() {
        timeLeft = remainingTime;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int hours = timeLeft.inHours;
    int mins = timeLeft.inMinutes - hours * 60;
    int secs = timeLeft.inSeconds - hours * 3600 - mins * 60;
    return timeLeft == Duration.zero
        ? Checkbox(value: true, onChanged: (_) {})
        : TextButton(
            onPressed: () {
              if (!widget.timedTask.executing) {
                widget.timedTask.startExecution();
              } else {
                widget.timedTask.stopExecution();
              }
              // firestoreService.updateTask(widget.timedTask);
            },
            child: Text('$hours:$mins:$secs'),
          );
  }
}
