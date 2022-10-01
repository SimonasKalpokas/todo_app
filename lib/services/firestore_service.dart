import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/base_task.dart';

class FirestoreService {
  final SharedPreferences _prefs;
  String mainCollection;
  late CollectionReference<Map<String, dynamic>> tasks;
  final StreamController<CollectionReference<Map<String, dynamic>>>
      _tasksController = StreamController();

  FirestoreService(this._prefs)
      : mainCollection = _prefs.getString('mainCollection') ?? "tasks" {
    tasks = FirebaseFirestore.instance
        .collection(mainCollection)
        .doc('tasks')
        .collection('tasks');
    _tasksController.add(tasks);
  }

  Future<void> setMainCollection(String newCollection) async {
    if (newCollection.trim().isEmpty) {
      return;
    }
    await _prefs.setString('mainCollection', newCollection);
    mainCollection = newCollection;
    tasks = FirebaseFirestore.instance
        .collection(mainCollection)
        .doc('tasks')
        .collection('tasks');
    _tasksController.add(tasks);
  }

  Future<DocumentReference<Map<String, dynamic>>> addTask(BaseTask task) {
    return tasks.add(task.toMap());
  }

  Stream<Iterable<BaseTask>> getTasks() {
    return _tasksController.stream
        .asyncMap((tasks) => tasks.get())
        .map((querySnapshot) => querySnapshot.docs.map((doc) {
              var taskListenable =
                  BaseTaskListenable.createTaskListenable(doc.id, doc.data());
              taskListenable.addListener(() {
                tasks.doc(doc.id).set(taskListenable.toMap());
              });
              taskListenable.refreshState();
              return taskListenable;
            }));
  }

  Future<void> updateTaskFields(String? taskId, Map<String, dynamic> fields) {
    return tasks.doc(taskId).update(fields);
  }

  Future<void> deleteTask(String? taskId) {
    return tasks.doc(taskId).delete();
  }

  Future<void> updateTask(BaseTask task) {
    return tasks.doc(task.id).set(task.toMap());
  }
}
