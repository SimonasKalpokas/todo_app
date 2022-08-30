import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';

import '../main.dart';

// TODO: Add selections of task type aka weekly/daily
class AddTask extends StatefulWidget {
  const AddTask({Key? key}) : super(key: key);

  @override
  State<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final BaseTask _task = BaseTask("", "", TaskType.daily);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(hintText: "Name"),
              validator: (String? value) {
                if (value == null || value.isEmpty) {
                  return "Name cannot be empty";
                }
                return null;
              },
              onSaved: (value) => setState(() => _task.name = value!),
            ),
            TextFormField(
              decoration: const InputDecoration(hintText: "Description"),
              onSaved: (value) => setState(() => _task.description = value!),
            ),
            ElevatedButton(
              child: const Text("Sumbit"),
              onPressed: () {
                var form = _formKey.currentState!;
                if (form.validate()) {
                  form.save();
                  context.read<Tasks>().add(_task);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
