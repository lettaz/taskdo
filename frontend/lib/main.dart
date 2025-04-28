import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskdo/blocs/auth/auth.dart';
import 'package:taskdo/blocs/projects/projects.dart';
import 'package:taskdo/blocs/tasks/tasks.dart';
import 'package:taskdo/config/routes.dart';
import 'package:taskdo/config/themes.dart';
import 'package:taskdo/data/providers/api_provider.dart';
import 'package:taskdo/data/providers/secure_storage.dart';
import 'package:taskdo/data/repositories/auth_repository.dart';
import 'package:taskdo/data/repositories/projects_repository.dart';
import 'package:taskdo/data/repositories/tasks_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize providers
  final secureStorageProvider = SecureStorageProvider();
  final apiProvider = ApiProvider(secureStorage: secureStorageProvider);
  
  // Initialize repositories
  final authRepository = AuthRepository(
    apiProvider: apiProvider,
    secureStorageProvider: secureStorageProvider,
  );
  
  final projectsRepository = ProjectsRepository(
    apiProvider: apiProvider,
    secureStorageProvider: secureStorageProvider,
  );
  
  final tasksRepository = TasksRepository(
    apiProvider: apiProvider,
    secureStorageProvider: secureStorageProvider,
  );
  
  runApp(
    TaskdoApp(
      secureStorageProvider: secureStorageProvider,
      apiProvider: apiProvider,
      authRepository: authRepository,
      projectsRepository: projectsRepository,
      tasksRepository: tasksRepository,
    ),
    );
}

class TaskdoApp extends StatelessWidget {
  final SecureStorageProvider secureStorageProvider;
  final ApiProvider apiProvider;
  final AuthRepository authRepository;
  final ProjectsRepository projectsRepository;
  final TasksRepository tasksRepository;

  const TaskdoApp({
    super.key,
    required this.secureStorageProvider,
    required this.apiProvider,
    required this.authRepository,
    required this.projectsRepository,
    required this.tasksRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: secureStorageProvider),
        RepositoryProvider.value(value: apiProvider),
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: projectsRepository),
        RepositoryProvider.value(value: tasksRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: authRepository,
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => ProjectsBloc(
              projectsRepository: projectsRepository,
            ),
          ),
          BlocProvider(
            create: (context) => TasksBloc(
              tasksRepository: tasksRepository,
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'TaskDo',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
