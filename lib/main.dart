import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/screens/tasks_view_screen.dart';
import 'package:todo_app/services/firestore_service.dart';

Future<void> initialiseDb() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAUgahltvdx26ZtuRmJqlbfZpkKleQAf2U",
        authDomain: "todoapp-69903.firebaseapp.com",
        projectId: "todoapp-69903",
        storageBucket: "todoapp-69903.appspot.com",
        messagingSenderId: "256435746073",
        appId: "1:256435746073:web:b292cfcd1e54ca86928188",
        measurementId: "G-BHH0MLZ0SW",
      ),
    );
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp();
  } else {
    throw UnimplementedError("Platform not supported");
  }
}

// TODO: add different lists of tasks
// TODO: show most recent tasks on top
Future<void> main() async {
  await initialiseDb();

  runApp(MultiProvider(
    providers: [Provider(create: (_) => FirestoreService())],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Builder(
        builder: (context) => const TasksViewScreen(),
      ),
    );
  }
}
