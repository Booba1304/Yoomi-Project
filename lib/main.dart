import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'interfaces/ecrans/project_list_screen.dart';
import 'theme/app_theme.dart';
import 'donnee/models/project.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Hive
  await Hive.initFlutter();

  // Enregistrer les adapters
  Hive.registerAdapter(ProjectStatusAdapter());
  Hive.registerAdapter(ProjectAdapter());

  // Ouvrir la box AVANT d'utiliser Hive
  await Hive.openBox<Project>('projectsBox');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projects App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const ProjectListScreen(),
    );
  }
}
