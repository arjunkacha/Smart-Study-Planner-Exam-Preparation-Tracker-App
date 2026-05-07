import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/subjects/subjects_screen.dart';
import '../screens/subjects/subject_detail_screen.dart';
import '../screens/scheduling/scheduling_screen.dart';
import '../screens/progress/progress_screen.dart';
import '../screens/search/search_filter_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/bottom_nav_scaffold.dart';

/// App router configuration using GoRouter
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Splash
    GoRoute(
      path: '/',
      builder: (_, __) => const SplashScreen(),
    ),

    // Main shell with bottom nav
    ShellRoute(
      builder: (context, state, child) =>
          BottomNavScaffold(child: child, location: state.uri.toString()),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/subjects',
          builder: (_, __) => const SubjectsScreen(),
        ),
        GoRoute(
          path: '/schedule',
          builder: (_, __) => const SchedulingScreen(),
        ),
        GoRoute(
          path: '/progress',
          builder: (_, __) => const ProgressScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (_, __) => const SearchFilterScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (_, __) => const SettingsScreen(),
        ),
      ],
    ),

    // Subject flow (outside shell, full-screen)
    GoRoute(
      path: '/subjects/add',
      builder: (_, __) => const AddEditSubjectScreen(),
    ),
    GoRoute(
      path: '/subjects/edit/:id',
      builder: (_, state) =>
          AddEditSubjectScreen(subjectId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/subjects/:id',
      builder: (_, state) =>
          SubjectDetailScreen(subjectId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/subjects/:subjectId/add-topic',
      builder: (_, state) =>
          AddEditTopicScreen(subjectId: state.pathParameters['subjectId']!),
    ),
    GoRoute(
      path: '/subjects/:subjectId/edit-topic/:topicId',
      builder: (_, state) => AddEditTopicScreen(
        subjectId: state.pathParameters['subjectId']!,
        topicId: state.pathParameters['topicId'],
      ),
    ),

    // Schedule flow
    GoRoute(
      path: '/schedule/add',
      builder: (_, __) => const AddEditScheduleScreen(),
    ),
    GoRoute(
      path: '/schedule/edit/:id',
      builder: (_, state) =>
          AddEditScheduleScreen(scheduleId: state.pathParameters['id']),
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);
