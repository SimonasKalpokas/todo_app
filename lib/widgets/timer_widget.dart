import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/constants.dart';
import 'package:todo_app/models/category.dart';

import '../models/timed_task.dart';
import '../providers/color_provider.dart';

class TimerWidget extends StatefulWidget {
  final TimedTask timedTask;
  const TimerWidget({super.key, required this.timedTask});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> with WidgetsBindingObserver {
  late Timer timer;
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
    final appColors = Provider.of<ColorProvider>(context).appColors;
    var category = widget.timedTask.categoryId != null
        ? Provider.of<Iterable<Category>>(context)
            .firstWhereOrNull((c) => c.id == widget.timedTask.categoryId)
        : null;
    var categoryColor =
        category?.colorValue != null ? Color(category!.colorValue) : null;

    int hours = timeLeft.inHours;
    int mins = timeLeft.inMinutes - hours * 60;
    int secs = timeLeft.inSeconds - hours * 3600 - mins * 60;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        widget.timedTask.executing
            ? IconButton(
                icon: const Icon(Icons.pause),
                color: categoryColor ?? appColors.borderColor,
                onPressed: () {
                  widget.timedTask.stopExecution();
                },
              )
            : IconButton(
                icon: const Icon(Icons.play_arrow),
                color: categoryColor ?? appColors.borderColor,
                onPressed: () {
                  widget.timedTask.startExecution();
                },
              ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}',
              style: TextStyle(
                  fontSize: fontSize * 8 / 9, color: appColors.secondaryColor),
            ),
            Container(
                height: 5,
                width: 65,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    color: appColors.taskBackgroundColor,
                    border: Border.all(
                        color: categoryColor ?? appColors.borderColor,
                        width: 1)),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 5,
                      width: (1 -
                              timeLeft.inSeconds /
                                  widget.timedTask.totalTime.inSeconds) *
                          65,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            bottomLeft: Radius.circular(5.0)),
                        color: categoryColor ?? appColors.borderColor,
                      ),
                    ))),
          ],
        ),
      ],
    );
  }
}
