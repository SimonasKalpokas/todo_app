import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/models/base_task.dart';

import 'add_task_screen.dart';

class TasksViewScreen extends StatelessWidget {
  const TasksViewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks:")),
      body: Column(
        children: [
          TasksListView(
            condition: (task) => task.status == Status.undone,
          ),
          const Text("Done"),
          TasksListView(
            condition: (task) => task.status == Status.done,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        tooltip: 'Add a task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TasksListView extends StatelessWidget {
  final bool Function(BaseTask)? condition;

  const TasksListView({Key? key, this.condition}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (BuildContext context, int index) {
            var doc = snapshot.data!.docs[index];
            var task = BaseTask.fromMap(doc.id, doc.data());
            if (condition != null && !condition!(task)) {
              return Container();
            }
            bool? value;
            assert(Status.values.length == 2);
            switch (task.status) {
              case Status.done:
                value = true;
                break;
              case Status.undone:
                value = false;
                break;
            }
            return Card(
              child: CheckboxListTile(
                title: Text(task.name),
                subtitle: Text(task.description),
                secondary: Text(task.reoccurrence.displayTitle),
                onChanged: (bool? value) {
                  assert(Status.values.length == 2);
                  if (value == null) {
                    throw UnimplementedError();
                  }
                  FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(task.id)
                      .update(
                    {'status': value ? Status.done.index : Status.undone.index},
                  );
                },
                value: value,
                controlAffinity: ListTileControlAffinity.leading,
                checkboxShape: const CircleBorder(),
              ),
            );
          },
        );
      },
    );
  }
}
