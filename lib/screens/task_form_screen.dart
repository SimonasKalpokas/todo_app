import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/checked_task.dart';
import 'package:todo_app/models/timed_task.dart';
import 'package:todo_app/services/firestore_service.dart';

class TaskFormScreen extends StatelessWidget {
  final BaseTask? task;
  const TaskFormScreen({Key? key, this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Add new Task"),
      ),
      body: TaskForm(task: task),
    );
  }
}

class TaskForm extends StatefulWidget {
  final BaseTask? task;
  const TaskForm({Key? key, this.task}) : super(key: key);

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  var reoccurrence = Reoccurrence.notRepeating;
  var type = TaskType.checked;
  var totalTime = const Duration(hours: 1);

  @override
  void initState() {
    if (widget.task != null) {
      nameController.text = widget.task!.name;
      descriptionController.text = widget.task!.description;
      reoccurrence = widget.task!.reoccurrence;
      type = widget.task!.type;
      if (type == TaskType.timed) {
        totalTime = (widget.task! as TimedTask).totalTime;
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Name"),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Name cannot be empty";
              }
              return null;
            },
          ),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: "Description"),
          ),
          DropdownButton<Reoccurrence>(
            value: reoccurrence,
            items: Reoccurrence.values
                .map((type) => DropdownMenuItem<Reoccurrence>(
                      value: type,
                      child: Text(type.displayTitle),
                    ))
                .toList(),
            onChanged: (value) => setState(() => reoccurrence = value!),
          ),
          widget.task != null
              ? Text(widget.task!.type.displayTitle)
              : DropdownButton<TaskType>(
                  value: type,
                  items: TaskType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.displayTitle),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => type = value!),
                ),
          Visibility(
            visible: type == TaskType.timed,
            child: CupertinoTimerPicker(
              onTimerDurationChanged: (duration) {
                setState(() {
                  totalTime = duration;
                });
              },
              mode: CupertinoTimerPickerMode.hms,
              initialTimerDuration: totalTime,
            ),
          ),
          ElevatedButton(
            child: const Text("Submit"),
            onPressed: () {
              var form = _formKey.currentState!;
              if (form.validate()) {
                if (widget.task != null) {
                  widget.task!.name = nameController.text;
                  widget.task!.description = descriptionController.text;
                  widget.task!.reoccurrence = reoccurrence;
                  widget.task!.type = type;
                  if (type == TaskType.timed) {
                    (widget.task! as TimedTask).totalTime = totalTime;
                  }
                  firestoreService.updateTask(widget.task!);
                } else {
                  BaseTask? task;
                  switch (type) {
                    case TaskType.checked:
                      task = CheckedTask(nameController.text,
                          descriptionController.text, reoccurrence);
                      break;
                    case TaskType.timed:
                      task = TimedTask(nameController.text,
                          descriptionController.text, reoccurrence, totalTime);
                      break;
                  }
                  firestoreService.addTask(task);
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
