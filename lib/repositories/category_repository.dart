import 'package:sqlite_async/sqlite_async.dart';
import 'package:todo_app/models/category.dart';

class CategoryRepository {
  final SqliteDatabase _database;

  CategoryRepository({required SqliteDatabase database}) : _database = database;

  Stream<Iterable<Category>> watchCategories() {
    return _database
        .watch('SELECT * FROM categories')
        .map((resultSet) => resultSet.map(Category.fromMap));
  }

  Future<void> createCategory(Category category) async {
    await _database.execute(
      '''
      INSERT INTO categories(id, name, color_value, created_at)
      VALUES (?, ?, ?, ?)
      ''',
      [
        category.id,
        category.name,
        category.colorValue,
        category.createdAt.toIso8601String(),
      ],
    );
  }

  Future<void> updateCategory(Category category) async {
    await _database.execute(
      '''
      UPDATE categories
      SET name = ?, color_value = ?
      WHERE id = ?
      ''',
      [category.name, category.colorValue, category.id],
    );
  }

  Future<void> deleteCategory(Category category) async {
    await _database.execute(
      '''
      UPDATE tasks
      SET category_id = NULL
      WHERE category_id = ?
      ''',
      [category.id],
    );
    await _database.execute(
      '''
      DELETE FROM categories
      WHERE id = ?
      ''',
      [category.id],
    );
  }
}
