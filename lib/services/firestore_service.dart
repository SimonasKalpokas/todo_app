import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/base_task.dart';
import 'package:todo_app/models/category.dart';

import '../providers/selection_provider.dart';

class FirestoreService {
  CollectionReference<Map<String, dynamic>> _currentTasks(String? parentId) {
    return tasks.doc(parentId ?? 'root').collection('tasks');
  }

  late CollectionReference<Map<String, dynamic>> tasks;
  final SharedPreferences _prefs;
  late String mainCollection;
  final CollectionReference<Map<String, dynamic>> categoriesCollection =
      FirebaseFirestore.instance.collection('categories');

  FirestoreService(SharedPreferences preferences) : _prefs = preferences {
    mainCollection = _prefs.getString('mainCollection') ?? "tasks";
    tasks = FirebaseFirestore.instance
        .collection(mainCollection)
        .doc('withParentTasks')
        .collection("tasks");
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
        .doc('withParentTasks')
        .collection('tasks');
    return true;
  }

  Stream<Iterable<Category>> getCategories() {
    return categoriesCollection.snapshots().map(
        (snapshot) => snapshot.docs.map((doc) => Category.fromMap(doc.data())));
  }

  Future<void> addCategory(Category category) {
    return categoriesCollection.add(category.toMap());
  }

  Future<void> updateCategory(Category category) {
    return categoriesCollection.doc(category.id).set(category.toMap());
  }

  Future<void> deleteCategory(Category category) {
    return categoriesCollection.doc(category.id).delete();
  }

  Future<void> addTask(BaseTask task) async {
    if (task.type == TaskType.parent) {
      await tasks.doc(task.id).set({'parentId': task.parentId});
    }
    await _currentTasks(task.parentId).doc(task.id).set(task.toMap());
  }

  // TODO: make filter parameters better
  // currently undone true means undone while undone false means done
  // which isn't very clear
  Stream<Iterable<BaseTask>> getTasks(String? parentId, bool undone) {
    return _currentTasks(parentId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              var taskListenable =
                  BaseTaskListenable.createTaskListenable(doc.data());
              taskListenable.addListener(() {
                _currentTasks(parentId).doc(doc.id).set(taskListenable.toMap());
              });
              taskListenable.refreshState();
              return taskListenable;
            }).where((task) => task.isDone == !undone));
  }

  Future<void> moveTask(BaseTask task, String? newParentId) async {
    await _currentTasks(task.parentId).doc(task.id).delete();
    task.parentId = newParentId;
    await _currentTasks(newParentId).doc(task.id).set(task.toMap());
  }

  Future<void> updateTaskFields(
      String? parentId, String? taskId, Map<String, dynamic> fields) {
    return _currentTasks(parentId).doc(taskId).update(fields);
  }

  Future<void> deleteTask(String? parentId, String? taskId) {
    return _currentTasks(parentId).doc(taskId).delete();
  }

  Future<void> updateTask(BaseTask task) {
    return _currentTasks(task.parentId).doc(task.id).set(task.toMap());
  }

  Future<bool> moveTasks(
      List<SelectionItem> tasksToMove, String? newParentId) async {
    if (!await canTasksBeMoved(
        newParentId, tasksToMove.map((e) => e.id).toList())) {
      return false;
    }
    for (var taskIds in tasksToMove) {
      var task =
          (await _currentTasks(taskIds.parentId).doc(taskIds.id).get()).data()!;
      task['parentId'] = newParentId;
      await _currentTasks(newParentId).doc(taskIds.id).set(task);
      if (task['type'] == TaskType.parent.index) {
        await tasks.doc(taskIds.id).set({'parentId': newParentId});
      }
      await deleteTask(taskIds.parentId, taskIds.id);
    }
    return true;
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
