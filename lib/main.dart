import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/models/category.dart';
import 'package:todo_app/providers/color_provider.dart';
import 'package:todo_app/providers/selection_provider.dart';
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

// TODO: show most recent tasks on top
Future<void> main() async {
  await initialiseDb();

  var prefs = await SharedPreferences.getInstance();
  var firestoreService = FirestoreService(prefs);

  var initialCategories = await firestoreService.getCategories().first;

  runApp(MultiProvider(
    providers: [
      Provider(create: (_) => firestoreService),
      ChangeNotifierProvider(create: (_) => ColorProvider(prefs)),
      StreamProvider<Iterable<Category>>.value(
          value: firestoreService.getCategories(),
          initialData: initialCategories),
      Provider(create: (_) => FirestoreService(prefs)),
      ChangeNotifierProvider(create: (_) => SelectionProvider())
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var appColors = Provider.of<ColorProvider>(context).appColors;
    return MaterialApp(
      title: 'ToDo App',
      theme: ThemeData(
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
        dialogTheme: DialogTheme(
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
        tabBarTheme: TabBarTheme(
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
          parentTask: null,
        ),
      ),
    );
  }
}
