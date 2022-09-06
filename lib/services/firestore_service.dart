import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/models/base_task.dart';

// TODO: decide whether providing TaskType or <T extends BaseTask> is cleaner
class FirestoreService {
  final tasks = FirebaseFirestore.instance.collection('tasks').doc('tasks');

  Future<DocumentReference<Map<String, dynamic>>> addTask(BaseTask task) {
    return tasks.collection(task.type.name).add(task.toMap());
  }

  Stream<Iterable<T>> getTasks<T extends BaseTask>(
      T Function(String?, Map<String, dynamic>) constructor) {
    return tasks.collection(TaskType.of<T>().name).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => constructor(doc.id, doc.data())));
  }

  Future<void> updateTaskFields(
      TaskType type, String? taskId, Map<String, dynamic> fields) {
    return tasks.collection(type.name).doc(taskId).update(fields);
  }

  Future<void> deleteTask(TaskType type, String? taskId) {
    return tasks.collection(type.name).doc(taskId).delete();
  }

  Future<void> updateTask(BaseTask task) async {
    return tasks.collection(task.type.name).doc(task.id).set(task.toMap());
  }
}
