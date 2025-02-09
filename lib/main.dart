import 'package:acme/controller/task_controller.dart';
import 'package:acme/views/home/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:provider/provider.dart';

import 'models/task_status.dart'; // Make sure to import the TaskStatus
import 'models/tasks.dart';
import 'repositories/task_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp();

  // Get the application documents directory
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();

  // Initialize Hive with the directory
  await Hive.initFlutter(appDocumentDir.path);

  // Initialize Hive adapters
  await initHive();

  // Setup repositories and services
  final taskBox = await Hive.openBox<Task>('tasks');
  final firestore = FirebaseFirestore.instance;
  final repository = TaskRepositoryImpl(taskBox, firestore);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskController(repository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// Initialize Hive with adapters
Future<void> initHive() async {
  // Register TaskStatus adapter first
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(TaskStatusAdapter());
  }

  // Then register Task adapter
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(TaskAdapter());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Acme Tasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
