import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';

import '../providers/tasks.dart';

class AddTaskScreen extends StatelessWidget {
  const AddTaskScreen({Key? key}) : super(key: key);

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
      body: const AddTaskForm(),
    );
  }
}

// TODO: Add selections of task type aka weekly/daily
class AddTaskForm extends StatefulWidget {
  const AddTaskForm({Key? key}) : super(key: key);

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final BaseTask _task = BaseTask("", "", TaskType.daily);

  @override
  Widget build(BuildContext context) {
    return Form(
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
    );
  }
}
