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
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFD699),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
          ),
          toolbarHeight: 76,
          titleSpacing: 16,
        ),
        inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFFFD699)),
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFFFD699)),
                borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.only(left: 8.0)),
        scaffoldBackgroundColor: const Color(0xFFFFF9F1),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontWeight: FontWeight.bold),
          labelLarge: TextStyle(fontWeight: FontWeight.bold),
        ),
        fontFamily: 'Nunito',
      ),
      // darkTheme: ThemeData(
      //   primarySwatch: Colors.blue,
      //   scaffoldBackgroundColor: Colors.black,
      //   listTileTheme: const ListTileThemeData(tileColor: Colors.green),
      // ),
      home: Builder(
        builder: (context) => const TasksViewScreen(),
      ),
    );
  }
}
