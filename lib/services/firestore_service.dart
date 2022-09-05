import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/models/base_task.dart';

// TODO: change String collection to TaskType taskType in getTasks and remove elsewhere as type is accessible from task
class FirestoreService {
  final tasks = FirebaseFirestore.instance.collection('tasks').doc('tasks');

  Future<DocumentReference<Map<String, dynamic>>> addTask(
      String collection, BaseTask task) {
    return tasks.collection(collection).add(task.toMap());
  }

  Stream<Iterable<T>> getTasks<T extends BaseTask>(String collection,
      T Function(String?, Map<String, dynamic>) constructor) {
    return tasks.collection(collection).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => constructor(doc.id, doc.data())));
  }

  Future<void> updateTaskFields(
      String collection, String? taskId, Map<String, dynamic> fields) {
    return tasks.collection(collection).doc(taskId).update(fields);
  }

  Future<void> deleteTask(String collection, String? taskId) {
    return tasks.collection(collection).doc(taskId).delete();
  }
}
