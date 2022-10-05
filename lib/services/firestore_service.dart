import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/category.dart';

class FirestoreService {
  final SharedPreferences _prefs;
  String mainCollection;
  late CollectionReference<Map<String, dynamic>> tasks;

  FirestoreService(this._prefs)
      : mainCollection = _prefs.getString('mainCollection') ?? "tasks" {
    tasks = FirebaseFirestore.instance
        .collection(mainCollection)
        .doc('tasks')
        .collection('tasks');
  }

  /// Returns whether the main collection was set.
  Future<bool> setMainCollection(String newCollection) async {
    if (newCollection.trim().isEmpty) {
      return false;
    }
    await _prefs.setString('mainCollection', newCollection);
    mainCollection = newCollection;
    tasks = FirebaseFirestore.instance
        .collection(mainCollection)
        .doc('tasks')
        .collection('tasks');
    return true;
  }

  Future<DocumentReference<Map<String, dynamic>>> addTask(BaseTask task) {
    return tasks.add(task.toMap());
  }

  Stream<Iterable<BaseTask>> getTasks() {
    return tasks.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var taskListenable =
            BaseTaskListenable.createTaskListenable(doc.id, doc.data());
        taskListenable.addListener(() {
          tasks.doc(doc.id).set(taskListenable.toMap());
        });
        taskListenable.refreshState();
        return taskListenable;
      });
    });
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

  List<Category> getCategories() {
    return [
      Category('1', Colors.red.value, 'Red'),
      Category('2', Colors.blue.value, 'Blue'),
      Category('3', Colors.green.value, 'Green'),
      Category('4', Colors.yellow.value, 'Yellow'),
      Category('5', Colors.purple.value, 'Purple'),
      Category('6', Colors.orange.value, 'Orange'),
      Category('7', Colors.pink.value, 'Pink'),
      Category('8', Colors.teal.value, 'Teal'),
      Category('9', Colors.brown.value, 'Brown'),
      Category('10', Colors.grey.value, 'Grey'),
    ];
  }
}
