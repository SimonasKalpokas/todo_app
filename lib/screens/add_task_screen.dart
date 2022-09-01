import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/models/base_task.dart';

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

class AddTaskForm extends StatefulWidget {
  const AddTaskForm({Key? key}) : super(key: key);

  @override
  State<AddTaskForm> createState() => _AddTaskFormState();
}

class _AddTaskFormState extends State<AddTaskForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final BaseTask _task = BaseTask("", "", Reoccurrence.daily);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: "Name"),
            validator: (String? value) {
              if (value == null || value.isEmpty) {
                return "Name cannot be empty";
              }
              return null;
            },
            onSaved: (value) => setState(() => _task.name = value!),
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: "Description"),
            onSaved: (value) => setState(() => _task.description = value!),
          ),
          DropdownButton<Reoccurrence>(
            value: _task.reoccurrence,
            items: Reoccurrence.values
                .map((type) => DropdownMenuItem<Reoccurrence>(
                      value: type,
                      child: Text(type.displayTitle),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _task.reoccurrence = value!),
          ),
          ElevatedButton(
            child: const Text("Sumbit"),
            onPressed: () {
              var form = _formKey.currentState!;
              if (form.validate()) {
                form.save();
                FirebaseFirestore.instance
                    .collection('tasks')
                    .add(_task.toMap());
              }
            },
          ),
        ],
      ),
    );
  }
}
