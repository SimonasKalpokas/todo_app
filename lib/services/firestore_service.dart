import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/models/category.dart';

class FirestoreService {
  late CollectionReference<Map<String, dynamic>> tasks;
  final SharedPreferences _prefs;
  late String mainCollection;
  final CollectionReference<Map<String, dynamic>> categoriesCollection =
      FirebaseFirestore.instance.collection('categories');

  FirestoreService(SharedPreferences preferences) : _prefs = preferences {
    mainCollection = _prefs.getString('mainCollection') ?? "tasks";
    tasks = FirebaseFirestore.instance
        .collection(mainCollection)
        .doc('tasks')
        .collection("tasks");
  }

  CollectionReference<Map<String, dynamic>> _currentTasks(String? parentId) {
    return tasks.doc(parentId ?? 'root').collection('tasks');
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

  Stream<Iterable<Category>> getCategories() {
    return categoriesCollection.snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => Category.fromMap(doc.data())));
  }

  Future<void> addCategory(Category category) {
    return categoriesCollection.doc(category.id).set(category.toMap());
  }

  Future<void> updateCategory(Category category) {
    return categoriesCollection.doc(category.id).set(category.toMap());
  }

  Future<void> deleteCategory(Category category) {
    return categoriesCollection.doc(category.id).delete();
  }

  Future<void> addTaskToTop(Task task) async {
    if (task.type == TaskType.parent) {
      await tasks.doc(task.id).set({'parentId': task.parentId});
    }
    var currentTasks = _currentTasks(task.parentId);
    var snapshot = await currentTasks.get();
    task.index = snapshot.size;
    await currentTasks.doc(task.id).set(task.toMap());
  }

  Future<void> updateTask(Task task) {
    return _currentTasks(task.parentId).doc(task.id).set(task.toMap());
  }

  Future<void> reorderTask(
      String? parentId, String id, int index, int index2) async {
    var currentTasks = _currentTasks(parentId);
    var snapshot = await currentTasks.get();
    var task = (await currentTasks.doc(id).get()).data()!;
    if (index < index2) {
      for (var doc in snapshot.docs) {
        if (doc['index'] > index && doc['index'] <= index2) {
          await currentTasks.doc(doc.id).update({'index': doc['index'] - 1});
        }
      }
    } else {
      for (var doc in snapshot.docs) {
        if (doc['index'] < index && doc['index'] >= index2) {
          await currentTasks.doc(doc.id).update({'index': doc['index'] + 1});
        }
      }
    }
    task['index'] = index2;
    await currentTasks.doc(id).set(task);
  }

  Future<bool> canTasksBeMoved(
      String? targetTaskId, List<String> currentTaskIds) async {
    while (targetTaskId != null) {
      if (currentTaskIds.contains(targetTaskId)) {
        return false;
      }
      targetTaskId = (await tasks.doc(targetTaskId).get())['parentId'];
    }
    return true;
  }
}
