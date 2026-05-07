import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/app_router.dart';
import 'database/database_service.dart';
import 'models/subject_model.dart';
import 'models/topic_model.dart';
import 'models/schedule_model.dart';
import 'providers/database_provider.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'utils/sample_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(SubjectModelAdapter());
  Hive.registerAdapter(TopicStatusAdapter());
  Hive.registerAdapter(TopicModelAdapter());
  Hive.registerAdapter(ScheduleModelAdapter());

  // Initialize database
  final dbService = DatabaseService();
  await dbService.init();

  // Seed sample data on first launch
  await seedSampleData(dbService);

  // Initialize notifications
  await NotificationService.init();
  await NotificationService.requestPermissions();

  runApp(
    ProviderScope(
      overrides: [
        // Provide the pre-initialized DatabaseService
        databaseServiceProvider.overrideWithValue(dbService),
      ],
      child: const SmartStudyPlannerApp(),
    ),
  );
}

/// Root application widget
class SmartStudyPlannerApp extends ConsumerWidget {
  const SmartStudyPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Smart Study Planner',
      debugShowCheckedModeBanner: false,
      themeMode:
          settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      routerConfig: appRouter,
    );
  }
}
