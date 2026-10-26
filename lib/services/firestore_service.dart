import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
