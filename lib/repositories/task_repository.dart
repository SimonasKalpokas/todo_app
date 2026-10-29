import 'package:clock/clock.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:todo_app/generated/todo_server/task_service.pbgrpc.dart' as pb;
import 'package:todo_app/models/task.dart';
import 'package:todo_app/utilities/fractional_indexing.dart';

class TaskRepository {
  // ignore: unused_field
  final pb.TaskServiceClient _client;
  final SqliteDatabase _database;

  TaskRepository(
      {required pb.TaskServiceClient client, required SqliteDatabase database})
      : _database = database,
        _client = client;

  Future<void> createTask(Task task) async {
    await _database.execute(
      '''
      INSERT INTO tasks(id, name, description, reoccurrence, type, parent_id, category_id, order_index, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
      ''',
      [
        task.id,
        task.name,
        task.description,
        task.reoccurrence.name,
        task.type.name,
        task.parentId,
        task.categoryId,
        task.orderIndex,
        task.createdAt.toIso8601String(),
      ],
    );
  }

  Stream<Iterable<Task>> watchUndoneTasks(String? parentId) {
    final stream = _database.watch(
      '''
      SELECT * FROM tasks
      WHERE parent_id IS ? AND (done_until is NULL OR done_until < ?)
      ORDER BY order_index DESC
      ''',
      parameters: [
        parentId,
        clock.now().toIso8601String(),
      ],
    ).map((tasks) => tasks.map(Task.fromMap));
    return stream;
  }

  Stream<Iterable<Task>> watchDoneTasks(String? parentId) {
    final stream = _database.watch(
      '''
      SELECT * FROM tasks
      WHERE parent_id IS ? AND done_until > ?
      ORDER BY order_index DESC
      ''',
      parameters: [
        parentId,
        clock.now().toIso8601String(),
      ],
    ).map((tasks) => tasks.map(Task.fromMap));
    return stream;
  }

  Future<void> setTaskCompletion(
    String taskId,
    DateTime? lastDoneOn,
    DateTime? doneUntil,
    String orderIndex,
  ) async {
    await _database.execute(
      '''
      UPDATE tasks
      SET last_done_on = ?, done_until = ?, order_index = ?
      WHERE id = ?
      ''',
      [
        lastDoneOn?.toIso8601String(),
        doneUntil?.toIso8601String(),
        orderIndex,
        taskId,
      ],
    );
  }

  Future<void> deleteTask(String taskId) async {
    await _database.execute(
      '''
      DELETE FROM tasks
      WHERE id = ? OR parent_id = ?
      ''',
      [taskId, taskId],
    );
  }

  Future<void> updateTask(Task task) async {
    await _database.execute(
      '''
      UPDATE tasks
      SET name = ?, description = ?, last_done_on = ?, done_until = ?, reoccurrence = ?, category_id = ?
      WHERE id = ?
      ''',
      [
        task.name,
        task.description,
        task.lastDoneOn?.toIso8601String(),
        task.doneUntil?.toIso8601String(),
        task.reoccurrence.name,
        task.categoryId,
        task.id,
      ],
    );
  }

  Future<bool> moveTasks(
    List<Task> tasksToMove,
    List<String> parentIds,
    String? topUndoneOrderIndex,
    String? topDoneOrderIndex,
  ) async {
    // TODO: move this check to a service
    // Check that no circular dependencies happen.
    final taskIds = tasksToMove.map((t) => t.id).toList();

    if (taskIds.any(parentIds.contains)) return false;
    if (taskIds.isEmpty) return true;

    final undone = tasksToMove.where((t) => !t.isDone).toList();
    final done = tasksToMove.where((t) => t.isDone).toList();

    final undoneIndexes =
        nIndexesBetween(undone.length, null, topUndoneOrderIndex);
    final doneIndexes = nIndexesBetween(done.length, null, topDoneOrderIndex);

    // task id -> new order index
    final newIndexes = <String, String>{
      for (var i = 0; i < undone.length; i++) undone[i].id: undoneIndexes[i],
      for (var i = 0; i < done.length; i++) done[i].id: doneIndexes[i],
    };

    final placeholders = List.filled(taskIds.length, '?').join(', ');
    final cases = List.filled(taskIds.length, 'WHEN ? THEN ?').join(' ');

    await _database.execute(
      '''
      UPDATE tasks
      SET parent_id = ?,
          order_index = CASE id $cases END
      WHERE id IN ($placeholders)
      ''',
      [
        parentIds.lastOrNull,
        for (final e in newIndexes.entries) ...[e.key, e.value],
        ...taskIds,
      ],
    );

    return true;
  }

  Future<void> updateTaskOrderIndex(Task task) async {
    await _database.execute(
      '''
      UPDATE tasks
      SET order_index = ?
      WHERE id = ?
      ''',
      [task.orderIndex, task.id],
    );
  }
}

typedef CreateTaskInput = ({
  String name,
  String description,
  Reoccurrence reoccurrence,
  TaskType type,
  String? parentId,
});

extension CreateTaskInputProto on CreateTaskInput {
  pb.CreateTaskRequest toProto() {
    final request = pb.CreateTaskRequest()
      ..name = name
      ..description = description
      ..reoccurrence = reoccurrence.toProto()
      ..type = type.toProto();

    if (parentId != null) {
      request.parentId = parentId!;
    }

    return request;
  }
}

extension ReoccurrenceProto on Reoccurrence {
  pb.Reoccurrence toProto() => switch (this) {
        Reoccurrence.notRepeating => pb.Reoccurrence.REOCCURRENCE_UNSPECIFIED,
        Reoccurrence.daily => pb.Reoccurrence.REOCCURRENCE_DAILY,
        Reoccurrence.weekly => pb.Reoccurrence.REOCCURRENCE_WEEKLY,
      };
}

extension TaskTypeProto on TaskType {
  pb.TaskType toProto() => switch (this) {
        TaskType.checked => pb.TaskType.TASK_TYPE_CHECKED,
        TaskType.timed => pb.TaskType.TASK_TYPE_TIMED,
        TaskType.parent => pb.TaskType.TASK_TYPE_PARENT,
      };
}
