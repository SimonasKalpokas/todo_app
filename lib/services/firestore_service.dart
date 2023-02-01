import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/base_task.dart';

class FirestoreService {
  // final tasks =
  //     FirebaseFirestore.instance.collection('tasks').doc('withParentTasks');
  late DocumentReference<Map<String, dynamic>> tasks;

  CollectionReference<Map<String, dynamic>> _currentCollection(
      String? parentId) {
    return tasks.collection(parentId ?? 'root');
  }

  final SharedPreferences _prefs;
  String mainCollection;

  FirestoreService(this._prefs)
      : mainCollection = _prefs.getString('mainCollection') ?? "tasks" {
    tasks = FirebaseFirestore.instance
        .collection(mainCollection)
        .doc('withParentTasks');
  }

  /// Returns whether the main collection was set.
  Future<bool> setMainCollection(String newCollection) async {
    if (newCollection.trim().isEmpty) {
      return false;
    }
    await _prefs.setString('mainCollection', newCollection);
    mainCollection = newCollection;
    tasks = FirebaseFirestore.instance.collection(mainCollection).doc('tasks');
    return true;
  }

  Future<DocumentReference<Map<String, dynamic>>> addTask(BaseTask task) {
    return _currentCollection(task.parentId).add(task.toMap());
  }

  // TODO: make filter parameters better
  // currently undone true means undone while undone false means done
  // which isn't very clear
  Stream<Iterable<BaseTask>> getTasks(String? parentId, bool undone) {
    return _currentCollection(parentId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var taskListenable =
                  BaseTaskListenable.createTaskListenable(doc.id, doc.data());
              taskListenable.addListener(() {
                _currentCollection(parentId)
                    .doc(doc.id)
                    .set(taskListenable.toMap());
              });
              taskListenable.refreshState();
              return taskListenable;
            }).where((task) => task.isDone == !undone));
  }

  Future<void> moveTask(BaseTask task, String? newParentId) async {
    await _currentCollection(task.parentId).doc(task.id).delete();
    task.parentId = newParentId;
    await _currentCollection(newParentId).doc(task.id).set(task.toMap());
  }

  Future<void> updateTaskFields(
      String? parentId, String? taskId, Map<String, dynamic> fields) {
    return _currentCollection(parentId).doc(taskId).update(fields);
  }

  Future<void> deleteTask(String? parentId, String? taskId) {
    return _currentCollection(parentId).doc(taskId).delete();
  }

  Future<void> updateTask(BaseTask task) {
    return _currentCollection(task.parentId).doc(task.id).set(task.toMap());
  }
}
