import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:grpc/grpc_or_grpcweb.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:todo_app/generated/todo_server/task_service.pbgrpc.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/providers/color_provider.dart';
import 'package:todo_app/providers/selection_provider.dart';
import 'package:todo_app/repositories/category_repository.dart';
import 'package:todo_app/repositories/task_repository.dart';
import 'package:todo_app/screens/tasks_view_screen.dart';

final migrations = SqliteMigrations()
  ..add(SqliteMigration(
    1,
    (tx) async {
      await tx.executeMultiple(
        """
        CREATE TABLE tasks (
          id text PRIMARY KEY,
          name text NOT NULL,
          description text NOT NULL,
          parent_id text references tasks(id),
          last_done_on timestamp,
          reoccurrence text NOT NULL,
          type text NOT NULL,
          done_until timestamp,
          category_id text,
          order_index text NOT NULL,
          created_at timestamp NOT NULL
        );
        CREATE TABLE categories (
          id text PRIMARY KEY,
          name text NOT NULL,
          color_value int NOT NULL,
          created_at timestamp NOT NULL
        );
        """,
      );
    },
    downMigration: SqliteDownMigration(toVersion: 0)
      ..add('DROP TABLE tasks;')
      ..add('DROP TABLE categories;'),
  ));

Future<SqliteDatabase> initialiseDb() async {
  SqliteDatabase database;
  if (kIsWeb) {
    database = SqliteDatabase(
        path: 'todo.db',
        options: SqliteOptions(
            webSqliteOptions: WebSqliteOptions(
                wasmUri:
                    'https://cdn.jsdelivr.net/npm/@powersync/dart-wasm-bundles@latest/dist/sqlite3.wasm',
                workerUri: 'db_worker.js')));
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    final dir = await getApplicationSupportDirectory();
    database = SqliteDatabase(path: p.join(dir.path, 'todo.db'));
  } else {
    throw UnimplementedError("Platform not supported");
  }

  await migrations.migrate(database);
  return database;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await initialiseDb();

  var prefs = await SharedPreferences.getInstance();
  var categoryRepository = CategoryRepository(database: database);
  var initialCategories = await categoryRepository.watchCategories().first;

  final channel = GrpcOrGrpcWebClientChannel.toSingleEndpoint(
    host: 'localhost',
    port: 9001,
    transportSecure: true,
  );
  final taskServiceClient = TaskServiceClient(channel);

  runApp(MultiProvider(
    providers: [
      Provider(create: (_) => CategoryRepository(database: database)),
      ChangeNotifierProvider(create: (_) => ColorProvider(prefs)),
      StreamProvider<Iterable<Category>>.value(
        value: categoryRepository.watchCategories(),
        initialData: initialCategories,
      ),
      Provider(
          create: (_) =>
              TaskRepository(client: taskServiceClient, database: database)),
      ChangeNotifierProvider(create: (_) => SelectionProvider<Task>())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var appColors = Provider.of<ColorProvider>(context).appColors;
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        canvasColor: Colors.transparent,
        fontFamily: 'Nunito',
        primaryColor: appColors.primaryColor,
        appBarTheme: AppBarTheme(
          backgroundColor: appColors.headerFooterColor,
          titleTextStyle: TextStyle(
            color: appColors.primaryColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
          ),
          toolbarHeight: 76,
          titleSpacing: 16,
        ),
        dialogBackgroundColor: appColors.backgroundColor,
        dialogTheme: DialogThemeData(
          titleTextStyle: TextStyle(
            color: appColors.primaryColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: appColors.taskBackgroundColor,
            hintStyle: TextStyle(color: appColors.borderColor),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: appColors.borderColor),
                borderRadius: BorderRadius.circular(5)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: appColors.borderColor),
                borderRadius: BorderRadius.circular(5)),
            contentPadding:
                const EdgeInsets.only(left: 8.0, top: 10, bottom: 10)),
        scaffoldBackgroundColor: appColors.backgroundColor,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontWeight: FontWeight.bold),
          labelLarge: TextStyle(fontWeight: FontWeight.bold),
          labelMedium: TextStyle(fontWeight: FontWeight.bold),
        ),
        tabBarTheme: TabBarThemeData(
          indicator: BoxDecoration(color: appColors.primaryColorLight),
          labelColor: Colors.black,
          unselectedLabelColor: const Color(0xFF737373),
          labelStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
          unselectedLabelStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Nunito'),
        ),
        checkboxTheme: CheckboxThemeData(
          side: BorderSide(color: appColors.borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
      home: Builder(
        builder: (context) => const TasksViewScreen(
          parentIds: [],
          parentTask: null,
        ),
      ),
    );
  }
}
