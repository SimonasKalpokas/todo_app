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

  Stream<List<BaseTask>> getTasks(String? parentId, bool done) {
    return _currentCollection(parentId)
        .orderBy('index', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) {
              var taskListenable =
                  BaseTaskListenable.createTaskListenable(doc.id, doc.data());
              taskListenable.addListener(() {
                _currentCollection(parentId)
                    .doc(doc.id)
                    .set(taskListenable.toMap());
              });
              taskListenable.refreshState();
              return taskListenable;
            })
            .where((task) => task.isDone == done)
            .toList());
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

  void reorderTasks(String? parentId, int target, int source) {
    if (source == target) {
      return;
    }
    if (source > target) {
      target += 1;
    }

    var tasksList = [];
    var task = tasksList[source];
    task.index = target;

    tasksList.removeAt(source);
    tasksList.insert(target, task);
    if (source > target) {
      var tmp = source;
      source = target;
      target = tmp;
    }

    for (var i = source; i <= target; i++) {
      tasksList[i].index = i;
      updateTask(tasksList[i]);
    }
    // for (var i = 0; i < tasksList.length; i++) {
    //   // tasksList[i].reference.update({'index': i});
    // }
  }

  Future<void> migrateDb(String collection) async {
    var i = 0;
    for (var doc in (await _currentCollection(collection).get()).docs) {
      await tasks.collection(collection).doc(doc.id).update({'index': i});
      await migrateDb(doc.id);
      i++;
    }
  }
}
