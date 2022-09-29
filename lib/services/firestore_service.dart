import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_app/models/base_task.dart';

class FirestoreService {
  final tasks =
      FirebaseFirestore.instance.collection('tasks').doc('withParentTasks');

  CollectionReference<Map<String, dynamic>> _currentCollection(
      String? parentId) {
    return tasks.collection(parentId ?? 'root');
  }

  Future<DocumentReference<Map<String, dynamic>>> addTask(BaseTask task) {
    return _currentCollection(task.parentId).add(task.toMap());
  }

  Stream<Iterable<BaseTask>> getTasks(String? parentId) {
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
            }));
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
