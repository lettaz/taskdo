import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taskdo/data/models/project.dart';
import 'package:taskdo/screens/auth/login_screen.dart';
import 'package:taskdo/screens/auth/password_reset_screen.dart';
import 'package:taskdo/screens/auth/register_screen.dart';
import 'package:taskdo/screens/auth/verification_screen.dart';
import 'package:taskdo/screens/dashboard/dashboard_screen.dart';
import 'package:taskdo/screens/projects/projects.dart';
import 'package:taskdo/screens/tasks/tasks_list_screen.dart';
import 'package:taskdo/screens/tasks/task_form_screen.dart';
import 'package:taskdo/screens/settings/settings_screen.dart';
import 'package:taskdo/data/models/task.dart';

// We'll replace these import placeholders with actual screens as we create them
// import 'package:taskdo/screens/onboarding/onboarding_screen.dart';
// import 'package:taskdo/screens/tasks/task_detail_screen.dart';
// import 'package:taskdo/screens/tags/tags_list_screen.dart';
// import 'package:taskdo/screens/tags/tag_form_screen.dart';
// import 'package:taskdo/screens/pomodoro/pomodoro_screen.dart';
// import 'package:taskdo/screens/reports/reports_screen.dart';
// import 'package:taskdo/screens/settings/settings_screen.dart';

class AppRouter {
  // Route names as constants
  static const String login = '/login';
  static const String register = '/register';
  static const String verification = '/verification';
  static const String passwordReset = '/password-reset';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:id';
  static const String projectCreate = '/projects/create';
  static const String projectEdit = '/projects/:id/edit';
  static const String tasks = '/tasks';
  static const String taskDetail = '/tasks/:id';
  static const String taskCreate = '/tasks/create';
  static const String taskEdit = '/tasks/:id/edit';
  static const String tags = '/tags';
  static const String tagCreate = '/tags/create';
  static const String tagEdit = '/tags/:id/edit';
  static const String pomodoro = '/pomodoro';
  static const String reports = '/reports';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // Router configuration
  static final GoRouter router = GoRouter(
    initialLocation: login,
    routes: [
      // Authentication routes
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: verification,
        builder: (context, state) {
          final Map<String, dynamic> extra = state.extra as Map<String, dynamic>? ?? {};
          final String email = extra['email'] ?? '';
          return VerificationScreen(email: email);
        },
      ),
      GoRoute(
        path: passwordReset,
        builder: (context, state) => const PasswordResetScreen(),
      ),
      
      // Onboarding
      GoRoute(
        path: onboarding,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Onboarding Screen - To be implemented'))),
      ),
      
      // Dashboard
      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      
      // Projects
      GoRoute(
        path: projects,
        builder: (context, state) => const ProjectsListScreen(),
      ),
      GoRoute(
        path: projectCreate,
        builder: (context, state) => const ProjectFormScreen(),
      ),
      GoRoute(
        path: projectEdit,
        builder: (context, state) => ProjectFormScreen(
          project: state.extra as Project?,
        ),
      ),
      GoRoute(
        path: projectDetail,
        builder: (context, state) => ProjectDetailScreen(projectId: state.pathParameters['id']!),
      ),
      
      // Tasks
      GoRoute(
        path: tasks,
        builder: (context, state) => const TasksListScreen(),
      ),
      GoRoute(
        path: taskCreate,
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: taskEdit,
        builder: (context, state) => TaskFormScreen(
          task: state.extra as Task?,
        ),
      ),
      GoRoute(
        path: taskDetail,
        builder: (context, state) => Scaffold(body: Center(child: Text('Task Detail Screen - ID: ${state.pathParameters['id']}'))),
      ),
      
      // Tags
      GoRoute(
        path: tags,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Tags List Screen - To be implemented'))),
      ),
      GoRoute(
        path: tagCreate,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Tag Create Screen - To be implemented'))),
      ),
      GoRoute(
        path: tagEdit,
        builder: (context, state) => Scaffold(body: Center(child: Text('Tag Edit Screen - ID: ${state.pathParameters['id']}'))),
      ),
      
      // Pomodoro
      GoRoute(
        path: pomodoro,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Pomodoro Screen - To be implemented'))),
      ),
      
      // Reports
      GoRoute(
        path: reports,
        builder: (context, state) => const Scaffold(body: Center(child: Text('Reports Screen - To be implemented'))),
      ),
      
      // Settings
      GoRoute(
        path: settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      
      // Profile (points to the same screen as settings)
      GoRoute(
        path: profile,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Page not found!'),
      ),
    ),
  );
} 