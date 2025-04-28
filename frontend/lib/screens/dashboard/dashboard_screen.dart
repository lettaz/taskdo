import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taskdo/blocs/auth/auth.dart';
import 'package:taskdo/config/routes.dart';
import 'package:taskdo/config/themes.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go(AppRouter.login);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              _buildAppBar(),
              
              // Dashboard Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting & Date
                      _buildGreeting(),
                      const SizedBox(height: 24),
                      
                      // Stats Overview
                      _buildStatsOverview(),
                      const SizedBox(height: 24),
                      
                      // Active Timer (if any)
                      _buildActivePomodoroTimer(),
                      const SizedBox(height: 24),
                      
                      // Tasks Due Today
                      _buildSectionHeader('Tasks Due Today', onViewAll: () {
                        context.push(AppRouter.tasks);
                      }),
                      const SizedBox(height: 12),
                      _buildTasksList(),
                      const SizedBox(height: 24),
                      
                      // Recent Projects
                      _buildSectionHeader('Recent Projects', onViewAll: () {
                        context.push(AppRouter.projects);
                      }),
                      const SizedBox(height: 12),
                      _buildRecentProjects(),
                      const SizedBox(height: 24),
                      
                      // Activity Timeline
                      _buildSectionHeader('Recent Activity'),
                      const SizedBox(height: 12),
                      _buildActivityTimeline(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: _buildQuickActions(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TaskDo',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.grey),
                onPressed: () {
                  // Search functionality would go here
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.grey),
                onPressed: () {
                  // Notifications would go here
                },
              ),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return GestureDetector(
                    onTap: () {
                      _showProfileMenu();
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: state is AuthAuthenticated
                            ? Text(
                                state.user.email.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Icon(
                                Icons.person_outline,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to profile screen
                  context.push(AppRouter.profile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRouter.settings);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _confirmLogout();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }
    
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = state is AuthAuthenticated
            ? state.user.email.split('@').first
            : 'User';
            
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting, ${name.substring(0, 1).toUpperCase() + name.substring(1)}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_getWeekday(now)}, ${now.day} ${_getMonth(now.month)}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsOverview() {
    return Row(
      children: [
        _buildStatCard(
          title: 'Completed',
          value: '12',
          iconData: Icons.check_circle_outline,
          color: Colors.green,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          title: 'In Progress',
          value: '5',
          iconData: Icons.pending_actions_outlined,
          color: Colors.orange,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          title: 'Upcoming',
          value: '8',
          iconData: Icons.upcoming_outlined,
          color: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData iconData,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconData, color: color, size: 18),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePomodoroTimer() {
    // Dummy active timer - this would be controlled by the PomodoroBloc in the real app
    final bool isActive = true;  // This would come from the bloc in reality
    
    if (!isActive) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              const Text(
                'Active Pomodoro',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // This would navigate to the Pomodoro screen
                  context.push(AppRouter.pomodoro);
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('View'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Timer Display
          const Text(
            '18:45',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          // Task Name
          Text(
            'Implement Dashboard UI',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 12),
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPomodoroControlButton(
                icon: Icons.pause,
                label: 'Pause',
                onTap: () {},
              ),
              const SizedBox(width: 24),
              _buildPomodoroControlButton(
                icon: Icons.stop,
                label: 'Stop',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPomodoroControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              minimumSize: const Size(50, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
            ),
            child: const Text('View All'),
          ),
      ],
    );
  }

  Widget _buildTasksList() {
    // Dummy tasks
    final tasks = [
      {
        'title': 'Complete dashboard design',
        'project': 'TaskDo App',
        'priority': 'High',
        'dueTime': '2:00 PM',
      },
      {
        'title': 'Review project requirements',
        'project': 'Client Project',
        'priority': 'Medium',
        'dueTime': '4:30 PM',
      },
      {
        'title': 'Team meeting',
        'project': 'TaskDo App',
        'priority': 'Low',
        'dueTime': '5:00 PM',
      },
    ];
    
    if (tasks.isEmpty) {
      return _buildEmptyState(
        icon: Icons.task_alt_outlined,
        message: 'No tasks due today',
        buttonText: 'Create Task',
        onAction: () {
          context.push(AppRouter.taskCreate);
        },
      );
    }
    
    return Column(
      children: tasks.map((task) {
        Color priorityColor;
        switch (task['priority']) {
          case 'High':
            priorityColor = Colors.red;
            break;
          case 'Medium':
            priorityColor = Colors.orange;
            break;
          default:
            priorityColor = Colors.green;
        }
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            title: Text(
              task['title']!,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task['project']!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      task['priority']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: priorityColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  task['dueTime']!,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.circle_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
            onTap: () {
              // Navigate to task details
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentProjects() {
    // Dummy projects
    final projects = [
      {
        'name': 'TaskDo App',
        'color': '#9C27B0', // Purple
        'tasks': '8 tasks',
        'progress': 0.6,
      },
      {
        'name': 'Website Redesign',
        'color': '#2196F3', // Blue
        'tasks': '12 tasks',
        'progress': 0.3,
      },
      {
        'name': 'Marketing Campaign',
        'color': '#FF9800', // Orange
        'tasks': '5 tasks',
        'progress': 0.8,
      },
      {
        'name': 'Research Project',
        'color': '#4CAF50', // Green
        'tasks': '3 tasks',
        'progress': 0.2,
      },
    ];
    
    if (projects.isEmpty) {
      return _buildEmptyState(
        icon: Icons.folder_outlined,
        message: 'No projects yet',
        buttonText: 'Create Project',
        onAction: () {
          context.push(AppRouter.projectCreate);
        },
      );
    }
    
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          final Color projectColor = _parseColor(project['color'] as String);
          
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: projectColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        project['tasks'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Progress bar
                      LinearProgressIndicator(
                        value: project['progress'] as double,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          projectColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${((project['progress'] as double) * 100).toInt()}% Completed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Add a helper method to parse color strings
  Color _parseColor(String colorCode) {
    try {
      if (colorCode.startsWith('#')) {
        return Color(int.parse('0xFF${colorCode.substring(1)}'));
      }
      return AppTheme.primaryColor;
    } catch (e) {
      return AppTheme.primaryColor;
    }
  }

  Widget _buildActivityTimeline() {
    // Dummy activity data
    final activities = [
      {
        'icon': Icons.task_alt_outlined,
        'color': Colors.green,
        'text': 'Completed "Update documentation" task',
        'time': '2h ago',
      },
      {
        'icon': Icons.folder_outlined,
        'color': Colors.blue,
        'text': 'Created new project "Website Redesign"',
        'time': '3h ago',
      },
      {
        'icon': Icons.timer_outlined,
        'color': AppTheme.primaryColor,
        'text': 'Completed 4 Pomodoro sessions',
        'time': '5h ago',
      },
      {
        'icon': Icons.comment_outlined,
        'color': Colors.orange,
        'text': 'Added note to "TaskDo App" project',
        'time': '1d ago',
      },
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: activities.map((activity) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (activity['color'] as Color).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    activity['icon'] as IconData,
                    size: 16,
                    color: activity['color'] as Color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity['text'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity['time'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String buttonText,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 32,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return FloatingActionButton(
      onPressed: () {
        _showQuickActionsMenu();
      },
      backgroundColor: AppTheme.primaryColor,
      child: const Icon(Icons.add),
    );
  }

  void _showQuickActionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: 32,
            horizontal: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionItem(
                    icon: Icons.task_alt_outlined,
                    label: 'New Task',
                    color: Colors.blue,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRouter.taskCreate);
                    },
                  ),
                  _buildQuickActionItem(
                    icon: Icons.folder_outlined,
                    label: 'New Project',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRouter.projectCreate);
                    },
                  ),
                  _buildQuickActionItem(
                    icon: Icons.timer_outlined,
                    label: 'Start Timer',
                    color: AppTheme.primaryColor,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(AppRouter.pomodoro);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_outlined),
          label: 'Projects',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task_outlined),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timer_outlined),
          label: 'Pomodoro',
        ),
      ],
      onTap: (index) {
        if (index == 0) return; // Already on dashboard
        switch (index) {
          case 1:
            context.push(AppRouter.projects);
            break;
          case 2:
            context.push(AppRouter.tasks);
            break;
          case 3:
            context.push(AppRouter.pomodoro);
            break;
        }
      },
    );
  }

  String _getWeekday(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
} 