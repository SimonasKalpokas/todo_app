import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/checked_task.dart';
import 'package:todo_app/models/timed_task.dart';
import 'package:todo_app/services/firestore_service.dart';

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

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  var reoccurrence = Reoccurrence.notRepeating;
  var type = "Checked";
  var totalTime = const Duration(hours: 1);

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
          DropdownButton<String>(
            value: type,
            items: const [
              DropdownMenuItem(value: "Checked", child: Text("Checked")),
              DropdownMenuItem(value: "Timed", child: Text("Timed"))
            ],
            onChanged: (value) => setState(() => type = value!),
          ),
          Visibility(
            visible: type == "Timed",
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
            child: const Text("Sumbit"),
            onPressed: () {
              var form = _formKey.currentState!;
              if (form.validate()) {
                switch (type) {
                  case 'Checked':
                    var task = CheckedTask(nameController.text,
                        descriptionController.text, reoccurrence);
                    firestoreService.addTask('checked', task);
                    break;
                  case 'Timed':
                    TimedTask task = TimedTask(nameController.text,
                        descriptionController.text, reoccurrence, totalTime);
                    firestoreService.addTask('timed', task);
                    break;
                  default:
                    throw UnimplementedError();
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
