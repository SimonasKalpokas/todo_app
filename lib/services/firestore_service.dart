import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/models/base_task.dart';

class FirestoreService {
  final tasks = FirebaseFirestore.instance
      .collection('tasks')
      .doc('tasks')
      .collection('tasks');

  Future<DocumentReference<Map<String, dynamic>>> addTask(BaseTask task) {
    return tasks.add(task.toMap());
  }

  Stream<Iterable<BaseTask>> getTasks() {
    return tasks.snapshots().map((snapshot) => snapshot.docs.map((doc) {
          var taskNotifier =
              BaseTaskListenable.createTaskNotifier(doc.id, doc.data());
          taskNotifier.addListener(() {
            tasks.doc(doc.id).set(taskNotifier.toMap());
          });
          taskNotifier.refreshState();
          return taskNotifier;
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
