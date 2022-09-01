import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/models/base_task.dart';

class FirestoreService {
  final tasks = FirebaseFirestore.instance.collection('tasks');

  Future<DocumentReference<Map<String, dynamic>>> addTask(BaseTask task) {
    return tasks.add(task.toMap());
  }

  Stream<Iterable<BaseTask>> getTasks() {
    return tasks.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => BaseTask.fromMap(doc.id, doc.data())));
  }

  Future<void> updateTaskFields(String? taskId, Map<String, dynamic> fields) {
    return tasks.doc(taskId).update(fields);
  }
}
